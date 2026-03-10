# MulleGraphicsImage Library Documentation for AI
<!-- Keywords: image, graphics, PNG, GIF, BMP, SVG, Objective-C -->

## 1. Introduction & Purpose

MulleGraphicsImage defines UIImage and provides image file format support for the MulleUI framework. It serves as a bridge between the MulleImage and MulleGraphics libraries, enabling UI components to work with bitmap and vector images. The library provides categories that extend CGImage, UIBitmapImage, UISVGImage, and UIImage with format-specific reading/writing capabilities and graphics context integration. It supports PNG, GIF, BMP, and SVG formats through external libraries (libpng, nanosvg, and stb_image_write).

The primary purpose is to enable image loading, display, and export in MulleUI applications. This library is part of the MulleUI framework stack, positioned between MulleGraphics (low-level graphics) and MulleUICore (UI components).

## 2. Key Concepts & Design Philosophy

**Bridge Architecture**: MulleGraphicsImage acts as a bridge connecting image data representations (from MulleImage) with graphics rendering contexts (from MulleGraphics). It provides bidirectional conversion between UIBitmapImage and CGImage.

**Category-Based Extension**: Rather than defining new classes, the library extends existing classes from its dependencies through Objective-C categories. This approach maintains a clean separation of concerns while adding format-specific functionality.

**Context-Aware Caching**: UIBitmapImage maintains a map of CGImage instances per graphics context, allowing efficient reuse of texture images across multiple rendering operations. This cache is thread-safe through mutex locking.

**Immutability**: UIBitmapImage is designed to be immutable for thread-safety. The bitmap data should not be modified after creation, enabling safe sharing across multiple contexts.

**Format Abstraction**: The library abstracts file format details through writer categories (PNGWriter, GIFWriter, BMPWriter), providing a consistent interface regardless of the underlying format implementation.

**Protocols for Drawable Integration**: The categories implement protocols like CGBitmapDrawable, CGVectorDrawable, CGPaintable, and CGDrawable to integrate with the MulleGraphics rendering pipeline.

## 3. Core API & Data Structures

### 3.1. `CGImage+UIBitmapImage.h`

#### Category `CGImage( UIBitmapImage)`
- **Purpose:** Converts a CGImage (texture/GPU image) to a UIBitmapImage (CPU-side bitmap).
- **Core Operations:**
  - `-bitmapImage`: Extracts RGBA byte bitmap from CGImage and wraps it in a UIBitmapImage.

### 3.2. `UIBitmapImage+CGImage.h`

#### Category `UIBitmapImage( CGImage) <CGBitmapDrawable, CGContextResource>`
- **Purpose:** Converts UIBitmapImage to CGImage for rendering, with context-aware caching.
- **Key Concepts:**
  - Maintains a context map (`_context_map`) that caches CGImage instances per rendering context.
  - Supports flipped and non-flipped bitmap encodings (CGBitmapEncodingRGBABytes, CGBitmapEncodingFlipYRGBABytes).
  - Thread-safe through mutex locking (`_lock`).
- **Core Operations:**
  - `-cgImageWithContext:textureFlags:nameUTF8String:`: Creates or retrieves cached CGImage for the given context with specific texture flags and optional debug name.
  - `-cgImageWithContext:textureFlags:`: Same as above but without debug name parameter.
- **Caching Mechanism:**
  - Up to `UIBitmapImageNumberOfContextMappings` different texture flag configurations can be cached per UIBitmapImage.
  - Each configuration maintains a map from CGContext pointer to CGImage instance.
  - Texture flags control image properties like vertical flipping (NVG_IMAGE_FLIPY).

### 3.3. `UIBitmapImage+nanovg.h`

#### Category `UIBitmapImage( nanovg) <CGPaintable>`
- **Purpose:** Marks UIBitmapImage as paintable in nanovg-based rendering contexts.
- **Core Operations:**
  - Conforms to CGPaintable protocol for integration with nanovg paint system.

### 3.4. `UIImage+CGImageLayer.h`

#### Category `UIImage( CGImageLayer) <CGDrawable>`
- **Purpose:** Enables UIImage subclasses to participate in CGDrawable rendering pipeline.
- **Core Operations:**
  - `-preferredImageLayerClass`: Returns the preferred layer class for rendering this image type.

### 3.5. `UISVGImage+CGImage.h`

#### Category `UISVGImage( CGImage) <CGVectorDrawable>`
- **Purpose:** Enables SVG images to be rendered through the CGDrawable system.
- **Core Operations:**
  - `-drawRect:options:context:`: Renders the SVG content into the specified rectangle using the given context.

### 3.6. `CGImage+PNGWriter.h`

#### Category `CGImage( PNGWriter)`
- **Purpose:** Exports CGImage to PNG file format.
- **Core Operations:**
  - `-writeToPNGUTF8String:`: Writes the image to a PNG file at the specified path (C string).
- **Implementation Notes:**
  - Converts CGImage to UIBitmapImage first, then uses libpng for writing.

### 3.7. `CGImage+GIFWriter.h`

#### Category `CGImage( GIFWriter)`
- **Purpose:** Exports CGImage to GIF file format.
- **Core Operations:**
  - `-writeToGIFUTF8String:`: Writes the image to a GIF file at the specified path (C string).
- **Implementation Notes:**
  - Converts CGImage to UIBitmapImage first, then uses stb_image_write for GIF encoding.

### 3.8. `CGImage+BMPWriter.h`

#### Category `CGImage( BMPWriter)`
- **Purpose:** Exports CGImage to BMP file format.
- **Core Operations:**
  - `-writeToBMPUTF8String:`: Writes the image to a BMP file at the specified path (C string).
- **Implementation Notes:**
  - Converts CGImage to UIBitmapImage first, then uses stb_image_write for BMP encoding.

### 3.9. `MulleObjCLoader+MulleGraphicsImage.h`

#### Category `MulleObjCLoader( MulleGraphicsImage)`
- **Purpose:** Provides Objective-C runtime loader integration for the library.
- **Core Operations:**
  - Automatically invoked during library loading to register classes and categories.

## 4. Performance Characteristics

**Context Caching**: The UIBitmapImage context cache provides O(1) lookup for previously created CGImage instances, avoiding redundant texture uploads. Cache misses require texture creation which involves GPU memory allocation - typically O(n) where n is the pixel count.

**Thread-Safety**: UIBitmapImage context map operations are protected by a mutex, which may introduce contention in highly multithreaded rendering scenarios. However, once a CGImage is cached for a context, retrieval is lock-protected but fast.

**Memory Considerations**: Each cached CGImage instance consumes GPU memory. The cache size is limited to `UIBitmapImageNumberOfContextMappings` texture flag configurations per image. Shared UIBitmapImage instances across multiple contexts will create multiple CGImage instances.

**Format Writing**: PNG, GIF, and BMP write operations are synchronous and I/O bound. They require converting the CGImage to RGBA byte format first, which is O(n) for n pixels, followed by format-specific encoding.

**Immutability Benefits**: The immutable design of UIBitmapImage allows safe sharing across threads without additional synchronization beyond the context cache lock.

**SVG Rendering**: UISVGImage rendering performance depends on the complexity of the vector graphics. Each render call may involve path tessellation and fill operations - typically O(n) for n vector primitives.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Always use factory methods or designated initializers**: Create UIBitmapImage instances using `+imageWithBytes:bitmapInfo:allocator:` or `-initWithBitmap:freeWhenDone:`.

- **Specify allocator carefully**: When creating UIBitmapImage with dynamic memory, provide `&mulle_default_allocator`. For static/stack buffers, pass `NULL` to indicate no deallocation is needed.

- **Reuse UIBitmapImage instances**: Take advantage of the context cache by sharing UIBitmapImage instances across multiple render operations and contexts.

- **Use appropriate texture flags**: When obtaining CGImage from UIBitmapImage, specify texture flags that match your rendering requirements (e.g., NVG_IMAGE_FLIPY for flipped rendering).

- **Export through CGImage categories**: To write images to files, use the convenience methods on CGImage (writeToPNGUTF8String:, etc.) rather than accessing UIBitmapImage directly.

### Common Pitfalls

- **Do not modify bitmap data after creation**: UIBitmapImage assumes immutability. Modifying the underlying bytes after creation will cause undefined behavior in cached textures.

- **Be aware of memory ownership**: If `freeWhenDone:YES` is specified, the UIBitmapImage will free the bitmap bytes on deallocation. Ensure the bytes were allocated with a compatible allocator.

- **Context resource management**: CGImage instances are tied to their creating CGContext. Do not use a CGImage with a different context than it was created for.

- **Thread-safety limitations**: While UIBitmapImage's context cache is thread-safe, the CGImage instances themselves and the CGContext are not. Ensure proper synchronization when rendering from multiple threads.

### Idiomatic Usage

- **Standard image creation pattern**: Allocate bytes, create CGBitmapInfo, construct UIBitmapImage with appropriate allocator and ownership flags.

- **Rendering workflow**: Create UIBitmapImage once, obtain CGImage for each context as needed, render using CGDrawable protocol methods.

- **File export workflow**: Load or create image as CGImage, use category writer methods to export to desired format.

## 6. Integration Examples

### Example 1: Creating a UIBitmapImage with Dynamic Memory

```c
int   main( int argc, char *argv[])
{
   char                   *bytes;
   struct CGBitmapInfo    info;
   UIBitmapImage          *image;

   // Allocate bitmap bytes (8x8 pixels, 4 bytes per pixel RGBA)
   bytes = mulle_malloc( 256);
   
   // Define bitmap properties
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   
   // Create UIBitmapImage with ownership transfer
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];
   
   // Image now owns the bytes and will free them on deallocation
   return( 0);
}
```

### Example 2: Creating a UIBitmapImage with Static Memory

```c
int   main( int argc, char *argv[])
{
   char                   bytes[ 256];
   struct CGBitmapInfo    info;
   UIBitmapImage          *image;

   // Use stack-allocated buffer
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   
   // Create UIBitmapImage without ownership transfer (NULL allocator)
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:NULL];
   
   // Image will not free the bytes - caller manages lifetime
   return( 0);
}
```

### Example 3: Scaling an Image

```c
int   main( int argc, char *argv[])
{
   char                   *bytes;
   struct CGBitmapInfo    info;
   UIBitmapImage          *image;
   UIBitmapImage          *scaled;

   // Create original 8x8 image
   bytes = mulle_malloc( 256);
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];

   // Scale down to 4x4
   scaled = [image bitmapImageForBitmapInfo:CGBitmapInfoMakeWHRGBABytes( 4, 4)
                                  allocator:NULL];
   
   // Print resulting size
   printf( "%s\n", CGPixelSizeUTF8String( CGBitmapInfoGetSize( [scaled bitmapInfo])));
   
   return( 0);
}
```

### Example 4: Converting UIBitmapImage to CGImage for Rendering

```c
void   renderImage( UIBitmapImage *bitmapImage, CGContext *context)
{
   CGImage         *textureImage;
   NSUInteger      flags;
   
   // Specify texture flags (e.g., flipY for OpenGL coordinate system)
   flags        = NVG_IMAGE_FLIPY;
   
   // Get or create cached CGImage for this context
   textureImage = [bitmapImage cgImageWithContext:context
                                     textureFlags:flags];
   
   // Use textureImage for rendering operations
   // (The image is cached and reused for subsequent calls)
}
```

### Example 5: Exporting a CGImage to PNG

```c
void   exportToPNG( CGImage *image, char *filename)
{
   BOOL   success;
   
   // Write image to PNG file
   success = [image writeToPNGUTF8String:filename];
   
   if( ! success)
   {
      fprintf( stderr, "Failed to write PNG file: %s\n", filename);
   }
}
```

### Example 6: Exporting CGImage to Multiple Formats

```c
void   exportToAllFormats( CGImage *image, char *basePath)
{
   char   pngPath[ 256];
   char   gifPath[ 256];
   char   bmpPath[ 256];
   
   // Build file paths
   sprintf( pngPath, "%s.png", basePath);
   sprintf( gifPath, "%s.gif", basePath);
   sprintf( bmpPath, "%s.bmp", basePath);
   
   // Export to all supported formats
   [image writeToPNGUTF8String:pngPath];
   [image writeToGIFUTF8String:gifPath];
   [image writeToBMPUTF8String:bmpPath];
}
```

### Example 7: Thread-Safe Image Access

```c
int   main( int argc, char *argv[])
{
   char                   *bytes;
   struct CGBitmapInfo    info;
   UIBitmapImage          *image;

   // Create UIBitmapImage with proper allocator
   bytes = mulle_malloc( 256);
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];
   
   // Check thread-safety capability
   mulle_printf( "%btd\n", [image mulleIsThreadSafe]);
   
   // UIBitmapImage is thread-safe for context cache access
   // Multiple threads can safely call cgImageWithContext:
   
   return( 0);
}
```

## 7. Dependencies

MulleGraphicsImage depends on the following mulle-sde libraries:

- **MulleGraphics**: Provides CGImage, CGContext, CGBitmapInfo, and the core graphics rendering infrastructure. Defines protocols like CGDrawable, CGBitmapDrawable, and CGVectorDrawable.

- **MulleImage**: Provides UIImage, UIBitmapImage, and UISVGImage base classes. Defines the image data structures and basic image operations.

- **mulle-objc-list**: Build-time dependency for Objective-C project support (not linked).

Additionally, the library depends on system libraries:

- **libpng** (png): Used for PNG file format encoding/decoding.
- **libbz2** (bz2): Compression library dependency for PNG support.
- **libz** (z): Compression library dependency for PNG support.

Third-party libraries embedded or included:

- **nanosvg**: SVG parsing and rendering (header-only library in nanosvg/ directory).
- **stb_image_write**: Image writing for GIF and BMP formats (header-only library).
