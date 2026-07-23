<!-- Keywords: mulle-graphics-image, UIImage, UIBitmapImage, UISVGImage, CGImage, PNG, GIF, BMP, SVG -->
# mulle-graphics-image

Use this when changing image loading, bitmap-to-`CGImage` bridging, SVG drawing, or file export in this repository. The local delta is the glue between `MulleImage` image objects and `MulleCG` drawables/resources.

## Understand first

```bash
mulle-sde api list
mulle-sde api cat MulleImage
mulle-sde api cat MulleCG
mulle-sde api apropos UIBitmapImage
mulle-sde api apropos UISVGImage
mulle-sde code search UIBitmapImage
mulle-sde code search UISVGImage
mulle-sde code search CGImage
```

## Local references

- `asset/dox/TOC.md`
- `src/UIBitmapImage+CGImage.h`
- `src/CGImage+UIBitmapImage.h`
- `src/UIImage+CGImageLayer.h`
- `src/UIImage+CGImageLayer.m`
- `src/UISVGImage+CGImage.h`
- `src/CGImage+PNGWriter.h`
- `src/CGImage+GIFWriter.h`
- `src/CGImage+BMPWriter.h`
- `demo/src/main-uiimage.m`
- `demo/src/main-animatedgif.m`
- `demo/src/main-tiger.m`
- `demo/src/main-bengal.m`
- `test/20-uibitmapimage/static.m`
- `test/20-uibitmapimage/scale.m`
- `test/20-uibitmapimage/threadsafe.m`

## Main local families

| Scenario | Start here | Local rule |
| --- | --- | --- |
| Load and display an image without caring whether it is bitmap or SVG | `UIImage`, `demo/src/main-uiimage.m`, `demo/src/main-bengal.m`, `demo/src/main-tiger.m` | Stay at `UIImage`/`CAImageLayer` level first; the class cluster can hand back `UIBitmapImage` or `UISVGImage`. |
| Share bitmap pixels with render contexts | `src/UIBitmapImage+CGImage.h`, `src/UIBitmapImage+CGImage.m` | `UIBitmapImage` is treated as immutable and caches `CGImage` objects per `CGContext` and texture-flag combination. |
| Render SVG through the drawable pipeline | `src/UISVGImage+CGImage.h`, `src/UISVGImage+CGImage.m` | SVG support is local `CGVectorDrawable` glue, not a bitmap conversion shortcut. |
| Export rendered output | `src/CGImage+PNGWriter.m`, `src/CGImage+GIFWriter.m`, `src/CGImage+BMPWriter.m`, `demo/src/main-animatedgif.m` | Static export goes through `CGImage` writer categories; animated GIF creation is a separate `UIAnimatedGIF` flow. |
| Add a new image subclass hook | `src/UIImage+CGImageLayer.h`, `src/UIImage+CGImageLayer.m` | New `UIImage` subclasses must provide `drawRect:options:context:` and `isRepeating`; `canvas` and `bounds` stay origin-based. `preferredImageLayerClass` is `@optional`. |

## Local workflow

- Pick the authoring level first: `UIImage` for format-agnostic loading, `UIBitmapImage` for pixel ownership/resizing, `UISVGImage` only when you need vector-specific behavior, `CGImage` only once a concrete render-context resource is needed.
- Decide ownership at creation time. Heap pixel buffers use an allocator such as `&mulle_default_allocator`; compiled-in or static buffers use `allocator:NULL` as shown in `test/20-uibitmapimage/static.m`, `demo/src/main-bengal.m`, and `demo/src/main-tiger.m`.
- Reuse the same `UIBitmapImage` object across draws and ask it for a `CGImage` per context instead of trying to share a `CGImage` across contexts yourself.
- Treat the `CGImage` writer categories as terminal export helpers. They flatten through `-bitmapImage` first, so they are for saving results, not for preserving vector semantics.

## Verify and report

```bash
mulle-sde test run test/20-uibitmapimage/static.m
mulle-sde test run test/20-uibitmapimage/scale.m
mulle-sde test run test/20-uibitmapimage/threadsafe.m
```

When reporting changes, say which family you touched: class-cluster loading, bitmap/context bridging, vector drawing, or export.
