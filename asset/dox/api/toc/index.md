# MulleGraphicsImage Library Documentation for AI
<!-- Keywords: image, graphics, PNG, GIF, BMP, SVG, Objective-C -->

## 1. Introduction & Purpose

MulleGraphicsImage defines UIImage and provides image file format support for the MulleUI framework. It serves as a bridge between the MulleImage and MulleGraphics libraries, enabling UI components to work with bitmap and vector images. The library provides categories that extend CGImage, UIBitmapImage, UISVGImage, and UIImage with format-specific reading/writing capabilities and graphics context integration. It supports PNG, GIF, BMP, and SVG formats through external libraries (libpng, nanosvg, and stb_image_write).

The primary purpose is to enable image loading, display, and export in MulleUI applications. This library is part of the MulleUI framework stack, positioned between MulleGraphics (low-level graphics) and MulleUICore (UI components).

**Version macro** (current version v0.0.3):
```c
#define MULLE_GRAPHICS_IMAGE_VERSION  ((0UL << 20) | (0 << 8) | 3)
```

## 2. Key Concepts & Design Philosophy

**Bridge Architecture**: MulleGraphicsImage acts as a bridge connecting image data representations (from MulleImage) with graphics rendering contexts (from MulleGraphics). It provides bidirectional conversion between UIBitmapImage and CGImage.

**Category-Based Extension**: Rather than defining new classes, the library extends existing classes from its dependencies through Objective-C categories. This approach maintains a clean separation of concerns while adding format-specific functionality.

**Context-Aware Caching**: UIBitmapImage maintains a map of CGImage instances per graphics context, allowing efficient reuse of texture images across multiple rendering operations. This cache is thread-safe through mutex locking.

**Immutability**: UIBitmapImage is designed to be immutable for thread-safety. The bitmap data should not be modified after creation, enabling safe sharing across multiple contexts.

**Format Abstraction**: The library abstracts file format details through writer categories (PNGWriter, GIFWriter, BMPWriter), providing a consistent interface regardless of the underlying format implementation.

**Protocols for Drawable Integration**: The categories implement protocols like CGBitmapDrawable, CGVectorDrawable, and CGDrawable to integrate with the MulleGraphics rendering pipeline. UIBitmapImage acts as a CGBitmapDrawable for direct rendering and provides fill/stroke pattern support via its private CGImageLayer category using CGContext pattern APIs (CGContextSetFillImagePattern, CGContextSetStrokeImagePattern).

**CGContext-Based Rendering**: All rendering (bitmap drawing, fill/stroke patterns, SVG vector graphics) is performed through CGContext APIs. The library has no runtime dependency on nanovg for rendering; nanosvg is used only for SVG file parsing.

**Factory Methods Preferred**: Use `+imageWithBytes:bitmapInfo:allocator:` instead of alloc/init patterns. The allocator parameter controls memory ownership; pass `&mulle_default_allocator` for dynamic memory or `NULL` for static buffers.

## 3. Core API & Data Structures

### 3.1. `CGImage+UIBitmapImage.h`

#### Category `CGImage( UIBitmapImage)`
- **Purpose:** Converts a CGImage (texture/GPU image) to a UIBitmapImage (CPU-side bitmap).
- **Core Operations:**
  - `- (UIBitmapImage *) bitmapImage`: Extracts RGBA byte bitmap from CGImage and wraps it in a UIBitmapImage.

### 3.2. `UIBitmapImage+CGImage.h`

#### Category `UIBitmapImage( CGImage) <CGBitmapDrawable, CGContextResource>`
- **Purpose:** Converts UIBitmapImage to CGImage for rendering, with context-aware caching.
- **Key Concepts:**
  - Maintains a context map (`_context_map`) that caches CGImage instances per rendering context.
  - Supports flipped and non-flipped bitmap encodings (CGBitmapEncodingRGBABytes, CGBitmapEncodingFlipYRGBABytes).
  - Thread-safe through mutex locking (`_lock`).
- **Core Operations:**
  - `- (CGImage *) cgImageWithContext:(CGContext *) context textureFlags:(NSUInteger) textureFlags nameUTF8String:(char *) nameUTF8String`: Creates or retrieves cached CGImage for the given context with specific texture flags and optional debug name.
  - `- (CGImage *) cgImageWithContext:(CGContext *) context textureFlags:(NSUInteger) textureFlags`: Same as above but without debug name parameter.
- **Caching Mechanism:**
  - Up to `UIBitmapImageNumberOfContextMappings` different texture flag configurations can be cached per UIBitmapImage.
  - Each configuration maintains a map from CGContext pointer to CGImage instance.
  - Texture flags control image properties like vertical flipping (CGImageFlagFlipY).
  - When the UIBitmapImage is removed from a context (via `didRemoveFromContext:`), all cached CGImage instances for that context are released.
- **Private Category `UIBitmapImage( CGImageLayer)`** (implemented in `UIBitmapImage+CGImageLayer.m`, no public header):
  - Provides fill/stroke pattern painting by obtaining a CGImage texture and delegating to CGContext pattern APIs.
  - `- (void) drawRect:(CGRect) rect options:(CGDrawableOptions *) options context:(CGContext *) context`: Delegates to `CGContextDrawBitmapDrawableInRect` with both source and destination rects matching.
  - `- (void) fillWithBounds:(CGRect) rect options:(struct CGFillOptions *) options context:(CGContext *) context`: Obtains the CGImage from the context cache, retrieves its textureID, and calls `CGContextSetFillImagePattern` with the bounds, rotation, and alpha from options before filling.
  - `- (void) strokeWithBounds:(CGRect) rect strokeWidth:(CGFloat) strokeWidth options:(struct CGStrokeOptions *) options context:(CGContext *) context`: Obtains the CGImage texture and calls `CGContextSetStrokeImagePattern`, sets stroke width, and strokes.

### 3.3. `UIImage+CGImageLayer.h`

#### Category `UIImage( CGImageLayer) <CGDrawable>`
- **Purpose:** Enables UIImage subclasses to participate in CGDrawable rendering pipeline.
- **Core Operations:**
  - `- (Class) preferredImageLayerClass` (`@optional`): Returns the preferred layer class for rendering this image type. Subclasses may override to provide a specific CAImageLayer subclass. Declared `@optional` — subclasses are not required to implement it. No default implementation is provided; the base UIImage class does not implement this method.
  - `- (CGRect) canvas`: Returns the canvas bounds for the image layer (0, 0, size).
  - `- (void) drawRect:(CGRect) rect options:(CGDrawableOptions *) options context:(CGContext *) context`: Draws the image into the given rect. Default implementation raises `MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION`.
  - `- (CGRect) bounds`: Returns bounds matching the size (0, 0, size).
  - `- (BOOL) isRepeating`: Whether the image repeats. Default implementation raises `MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION`.

### 3.4. `UISVGImage+CGImage.h`

#### Category `UISVGImage( CGImage) <CGVectorDrawable>`
- **Purpose:** Enables SVG images to be rendered through the CGDrawable system using CGContext vector drawing APIs. SVG file parsing is performed by nanosvg (NSVGImage structure), but all rendering uses CGContext primitives exclusively — there is no nanovg rendering dependency.
- **Core Operations:**
  - `- (void) drawRect:(CGRect) rect options:(CGDrawableOptions *) options context:(CGContext *) context`: Renders the SVG content into the specified rectangle using pure CGContext path operations.
- **Implementation Notes:**
  - Parses the nanosvg NSVGImage structure and iterates shapes and paths.
  - Uses `CGColorMakeWithRGBABytes` for color conversion from NSVG uint32_t color values.
  - Computes a projection transform from SVG bounds to target rect using `CGAffineTransformMakeProjection`.
  - Wraps rendering in `CGContextSave`/`CGContextRestore` and applies the transform via `CGContextTransform`.
  - Path construction: `CGContextBeginPath`, `CGContextMoveTo`, `CGContextBezierTo`, `CGContextLineTo` (for closed paths).
  - Fill and stroke colors set via `CGContextFillColor`/`CGContextStrokeColor` with alpha multiplication (`CGColorMultiplyAlpha`).
  - Stroke width set via `CGContextStrokeWidth`.
  - Fill and stroke operations: `CGContextFill`/`CGContextStroke`.
  - Enforces restrictions: `options->cornerInsets` must be all zero, `options->scale == NO`, `options->rotation == 0.0` (asserted).

### 3.5. `CGImage+PNGWriter.h`

#### Category `CGImage( PNGWriter)`
- **Purpose:** Exports CGImage to PNG file format.
- **Core Operations:**
  - `- (BOOL) writeToPNGUTF8String:(char *) filename`: Writes the image to a PNG file at the specified path (C string).
- **Implementation Notes:**
  - Converts CGImage to UIBitmapImage first, then uses libpng for writing.

### 3.6. `CGImage+GIFWriter.h`

#### Category `CGImage( GIFWriter)`
- **Purpose:** Exports CGImage to GIF file format.
- **Core Operations:**
  - `- (BOOL) writeToGIFUTF8String:(char *) filename`: Writes the image to a GIF file at the specified path (C string).
- **Implementation Notes:**
  - Converts CGImage to UIBitmapImage first, then uses stb_image_write for GIF encoding.

### 3.7. `CGImage+BMPWriter.h`

#### Category `CGImage( BMPWriter)`
- **Purpose:** Exports CGImage to BMP file format.
- **Core Operations:**
  - `- (BOOL) writeToBMPUTF8String:(char *) filename`: Writes the image to a BMP file at the specified path (C string).
- **Implementation Notes:**
  - Converts CGImage to UIBitmapImage first, then uses stb_image_write for BMP encoding.

### 3.8. `MulleObjCDeps+MulleGraphicsImage.h`

#### Category `MulleObjCDeps( MulleGraphicsImage)`
- **Purpose:** Provides Objective-C runtime loader integration for the library.
- **Core Operations:**
  - `+ (struct _mulle_objc_dependency *) dependencies`: Returns dependency information for the runtime loader. Automatically invoked during library loading to register classes and categories.

## 4. Performance Characteristics

**Context Caching**: The UIBitmapImage context cache provides O(1) lookup for previously created CGImage instances, avoiding redundant texture uploads. Cache misses require texture creation which involves GPU memory allocation — typically O(n) where n is the pixel count.

**Thread-Safety**: UIBitmapImage context map operations are protected by a mutex, which may introduce contention in highly multithreaded rendering scenarios. However, once a CGImage is cached for a context, retrieval is lock-protected but fast.

**Memory Considerations**: Each cached CGImage instance consumes GPU memory. The cache size is limited to `UIBitmapImageNumberOfContextMappings` texture flag configurations per image. Shared UIBitmapImage instances across multiple contexts will create multiple CGImage instances.

**Format Writing**: PNG, GIF, and BMP write operations are synchronous and I/O bound. They require converting the CGImage to RGBA byte format first, which is O(n) for n pixels, followed by format-specific encoding.

**Immutability Benefits**: The immutable design of UIBitmapImage allows safe sharing across threads without additional synchronization beyond the context cache lock.

**SVG Rendering**: UISVGImage rendering performance depends on the complexity of the vector graphics. Each render call iterates through all shapes and paths — O(n) for n vector primitives. All path and color operations use CGContext APIs directly rather than nanovg, providing a unified rendering pipeline with the rest of the MulleGraphics framework.

## 5. AI Usage Recommendations & Patterns

### Best Practices

- **Always use factory methods**: Create UIBitmapImage instances using `+imageWithBytes:bitmapInfo:allocator:` rather than alloc/init patterns.

- **Specify allocator carefully**: When creating UIBitmapImage with dynamic memory, provide `&mulle_default_allocator`. For static/stack buffers, pass `NULL` to indicate no deallocation is needed.

- **Reuse UIBitmapImage instances**: Take advantage of the context cache by sharing UIBitmapImage instances across multiple render operations and contexts.

- **Use appropriate texture flags**: When obtaining CGImage from UIBitmapImage, specify texture flags that match your rendering requirements (e.g., CGImageFlagFlipY for flipped coordinate systems).

- **Export through CGImage categories**: To write images to files, use the convenience methods on CGImage (writeToPNGUTF8String:, writeToGIFUTF8String:, writeToBMPUTF8String:) rather than accessing UIBitmapImage directly.

### Common Pitfalls

- **Do not modify bitmap data after creation**: UIBitmapImage assumes immutability. Modifying the underlying bytes after creation will cause undefined behavior in cached textures.

- **Be aware of memory ownership**: If you passed a valid allocator at creation time, the UIBitmapImage will free the bitmap bytes on deallocation. Ensure the bytes were allocated with a compatible allocator. If you passed `NULL` as allocator, the caller retains ownership.

- **Context resource management**: CGImage instances are tied to their creating CGContext. Do not use a CGImage with a different context than it was created for.

- **Thread-safety limitations**: While UIBitmapImage's context cache is thread-safe, the CGImage instances themselves and the CGContext are not. Ensure proper synchronization when rendering from multiple threads.

- **SVG render options**: UISVGImage drawRect: currently requires `options->scale == NO`, `options->rotation == 0.0`, and `options->cornerInsets` all zero (enforced by assertions).

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

   bytes = mulle_malloc( 256);

   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);

   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];

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

   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);

   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:NULL];

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

   bytes = mulle_malloc( 256);
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];

   scaled = [image bitmapImageForBitmapInfo:CGBitmapInfoMakeWHRGBABytes( 4, 4)
                                  allocator:NULL];

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

   flags        = CGImageFlagFlipY;

   textureImage = [bitmapImage cgImageWithContext:context
                                     textureFlags:flags];

}
```

### Example 5: Exporting a CGImage to PNG

```c
void   exportToPNG( CGImage *image, char *filename)
{
   BOOL   success;

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

   sprintf( pngPath, "%s.png", basePath);
   sprintf( gifPath, "%s.gif", basePath);
   sprintf( bmpPath, "%s.bmp", basePath);

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

   bytes = mulle_malloc( 256);
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];

   mulle_printf( "%btd\n", [image mulleIsThreadSafe]);

   return( 0);
}
```

### Example 8: Using UIBitmapImage as a Fill Pattern

```c
void   fillRectWithBitmapPattern( UIBitmapImage *bitmapImage,
                                  CGRect rect,
                                  CGContext *context)
{
   struct CGFillOptions   fillOptions;

   fillOptions             = CGFillOptionsDefault;
   fillOptions.paint.alpha = 0.75f;

   [bitmapImage fillWithBounds:rect
                       options:&fillOptions
                       context:context];
}
```

## 7. Dependencies

MulleGraphicsImage depends on the following mulle-sde libraries:

- **MulleGraphics**: Provides CGImage, CGContext, CGBitmapInfo, and the core graphics rendering infrastructure. Defines protocols like CGDrawable, CGBitmapDrawable, and CGVectorDrawable, as well as CGContext pattern APIs (CGContextSetFillImagePattern, CGContextSetStrokeImagePattern) and drawing functions (CGContextDrawBitmapDrawableInRect, CGContextTransform, etc.).

- **MulleImage**: Provides UIImage, UIBitmapImage, and UISVGImage base classes. Defines the image data structures and basic image operations. Includes the nanosvg header library for SVG file parsing.

- **mulle-objc-list**: Build-time dependency for Objective-C project support (not linked, not bequeathed, no header).

Additionally, the library depends on system libraries:

- **libpng** (png): Used for PNG file format encoding/decoding.
- **libbz2** (bz2): Compression library dependency for PNG support.
- **libz** (z): Compression library dependency for PNG support.

Third-party libraries:

- **nanosvg**: SVG file format parsing (header-only library in MulleImage, both nanosvg.h and nanosvgrast.h). Note: nanosvg is used only for parsing SVG file content into NSVGImage structures. All rendering is performed through CGContext APIs — there is no runtime rendering dependency on nanovg.
- **stb_image_write**: Image writing for GIF and BMP formats (header-only library).
