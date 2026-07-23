<!-- Keywords: patterns, UIImage, UIBitmapImage, UISVGImage, CGImage, export, animated GIF -->
# Patterns

## Load through `UIImage` first

Use the class cluster entry points when the caller does not need to care whether the asset is raster or vector yet.

```objective-c
CAImageLayer   *layer;
UIImage        *image;

layer = [CAImageLayer layerWithFrame:frame];
image = [UIImage imageWithContentsOfFileUTF8String:"parrot.png"];
[layer setImage:image];
```

This is the shape used in `demo/src/main-uiimage.m`. The same layer path is also used for SVG-backed `UIImage` values.

Custom `UIImage` subclasses can optionally override `preferredImageLayerClass` (declared `@optional` in `src/UIImage+CGImageLayer.h`) to return a different `CALayer` subclass for rendering.

## Load embedded file data with `allocator:NULL`

When the bytes are compiled into the binary, pass them as borrowed storage.

```objective-c
UIImage   *image;

image = [UIImage imageWithFileCData:mulle_data_make( bengal_jpg, s_bengal_jpg)
                          allocator:NULL];
```

See `demo/src/main-bengal.m` and `demo/src/main-tiger.m`. Do not invent a freeing allocator for static `.inc` data.

## Create `UIBitmapImage` with explicit ownership

For heap-backed RGBA bytes, transfer ownership with an allocator. For static bytes, keep ownership outside the image.

```objective-c
char                   *bytes;
struct CGBitmapInfo    info;
UIBitmapImage          *image;

bytes = mulle_malloc( 256);
info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
image = [UIBitmapImage imageWithBytes:bytes
                           bitmapInfo:info
                            allocator:&mulle_default_allocator];
```

This is the local happy path from `test/20-uibitmapimage/scale.m` and `test/20-uibitmapimage/threadsafe.m`.

## Derive resized/reencoded bitmaps instead of mutating

`UIBitmapImage` is treated as immutable here. Create a new bitmap image when size or bitmap info changes.

```objective-c
UIBitmapImage   *scaled;

scaled = [image bitmapImageForBitmapInfo:CGBitmapInfoMakeWHRGBABytes( 4, 4)
                               allocator:NULL];
```

This is the tested resize shape in `test/20-uibitmapimage/scale.m`.

## Ask the bitmap for a `CGImage` per context

The bridge category owns the per-context texture cache. Reuse the bitmap object; do not cache cross-context `CGImage` objects yourself.

```objective-c
CGImage   *texture;

texture = [image cgImageWithContext:context
                       textureFlags:[image textureFlags]];
```

Local behavior lives in `src/UIBitmapImage+CGImage.m` and `src/UIBitmapImage+CGImageLayer.m`.

## Let SVG stay vector

For SVG input, keep using `UIImage`/`CAImageLayer` or `UISVGImage` as a drawable. The local vector path is `UISVGImage( CGImage) <CGVectorDrawable>`, not a forced bitmap conversion.

```objective-c
UIImage       *tigerImage;
CAImageLayer  *imageLayer;

tigerImage = [UIImage imageWithFileCData:mulle_data_make( tiger_data, s_tiger_data)
                                allocator:NULL];
imageLayer = [CAImageLayer layerWithImage:tigerImage];
```

See `demo/src/main-tiger.m` and `src/UISVGImage+CGImage.m`.

## Export from `CGImage`

Static export uses the convenience categories on `CGImage`.

```objective-c
[image writeToPNGUTF8String:"out.png"];
[image writeToGIFUTF8String:"out.gif"];
[image writeToBMPUTF8String:"out.bmp"];
```

Those methods are thin local wrappers in `src/CGImage+PNGWriter.m`, `src/CGImage+GIFWriter.m`, and `src/CGImage+BMPWriter.m`.

## Build animated GIFs from captured bitmaps

For multi-frame export, use `UIAnimatedGIF` and feed it screenshots or other `CGBitmap` frames.

```objective-c
gif = [UIAnimatedGIF animatedGIFWithUTF8String:"animated.gif"
                                   bitmapSize:CGPixelSizeMake( 200, 150)
                                animationRate:1.0
                                         loop:YES];

screenshotBitmap = [window screenshotBitmap];
[gif addBitmap:screenshotBitmap
  freeWhenDone:YES];
[gif close];
```

The working repository example is `demo/src/main-animatedgif.m`.
