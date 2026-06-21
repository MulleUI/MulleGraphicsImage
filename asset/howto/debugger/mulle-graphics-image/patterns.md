<!-- Keywords: debugger patterns, UIImage, UIBitmapImage, UISVGImage, CGImage, cache, export -->
# Patterns

## Split format detection from drawing

Use the same `CAImageLayer` setup for both bitmap and SVG inputs, then swap only the `UIImage` source. That is the local fastest way to decide whether the breakage is in class selection or in the layer path.

```objective-c
CAImageLayer   *layer;
UIImage        *image;

image = [UIImage imageWithFileCData:mulle_data_make( tiger_data, s_tiger_data)
                          allocator:NULL];
assert( image);

layer = [CAImageLayer layerWithImage:image];
```

`demo/src/main-bengal.m`, `demo/src/main-tiger.m`, and `demo/src/main-uiimage.m` all feed `UIImage` into the same layer family. If only one asset family fails, stay on the concrete bitmap/SVG path before touching the view setup.

## Reproduce bitmap ownership with the test shape

Start from the tiny repository tests before debugging app code.

```objective-c
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
```

This is the exact shape from `test/20-uibitmapimage/scale.m`. The local expected output is `4 4`, and `test/20-uibitmapimage/static.m` shows the `allocator:NULL` variant for borrowed storage.

## Probe cache hits by reusing one bitmap in one context

The cache lives on `UIBitmapImage`, not on the caller.

```objective-c
CGImage   *a;
CGImage   *b;

a = [image cgImageWithContext:context
                 textureFlags:0];
b = [image cgImageWithContext:context
                 textureFlags:0];
```

In `src/UIBitmapImage+CGImage.m`, the second call should reuse the cached image for the same `CGContext` and flag bucket. Change the context or the relevant texture flags to force a different resource.

## Keep the first SVG repro inside the supported option set

Start with projection plus alpha only.

```objective-c
CGDrawableOptions   options;

options = CGDrawableOptionsDefault;
options.alpha = 0.5;

[svgImage drawRect:rect
           options:&options
           context:context];
```

`src/UISVGImage+CGImage.m` asserts on non-zero corner insets, non-default scale, and non-zero rotation. `demo/src/main-tiger.m` is the baseline path to compare against.

## Check bitmap paint failures through `textureID`

Pattern fill and stroke go through `UIBitmapImage+CGImageLayer.m`.

```objective-c
CGImage   *image;

image = [bitmapImage cgImageWithContext:context
                           textureFlags:[bitmapImage textureFlags]];
assert( [image textureID] != CGTextureIDInvalid);
```

If image-pattern fill or stroke is a no-op, debug the `cgImageWithContext:` result first. `fillWithBounds:options:context:` and `strokeWithBounds:strokeWidth:options:context:` both return early on missing context or invalid texture IDs.

## Separate static writers from animated capture

Use the writer categories only for single-frame bitmap export.

```objective-c
[cgImage writeToPNGUTF8String:"out.png"];
[cgImage writeToGIFUTF8String:"out.gif"];
[cgImage writeToBMPUTF8String:"out.bmp"];
```

For animation, follow `demo/src/main-animatedgif.m`: render a frame, grab `[window screenshotBitmap]`, feed it into `UIAnimatedGIF`, then close the GIF. If only animated export is wrong, debug the capture loop, not the static writer categories.
