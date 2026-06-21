<!-- Keywords: debugger, mulle-graphics-image, UIImage, UIBitmapImage, UISVGImage, CGImage, PNG, GIF, BMP, SVG -->
# mulle-graphics-image

Use this when tracing image load/class selection, bitmap/context cache bugs, SVG draw assertions, or export mismatches in this repository. The local delta is the bridge from `MulleImage` objects to `MulleCG` resources, with per-context `CGImage` caching hidden inside `UIBitmapImage`.

## Understand first

```bash
mulle-sde api list
mulle-sde api cat MulleImage
mulle-sde api cat MulleCG
mulle-sde api apropos UIBitmapImage
mulle-sde api apropos UISVGImage
mulle-sde api apropos CGImage
mulle-sde code search cgImageWithContext
mulle-sde code search didRemoveFromContext
mulle-sde code search writeToPNGUTF8String
```

## Local references

- `asset/dox/TOC.md`
- `src/UIBitmapImage+CGImage.h`
- `src/UIBitmapImage+CGImage.m`
- `src/UIBitmapImage+CGImageLayer.m`
- `src/UIImage+CGImageLayer.h`
- `src/UIImage+CGImageLayer.m`
- `src/UISVGImage+CGImage.h`
- `src/UISVGImage+CGImage.m`
- `src/CGImage+UIBitmapImage.m`
- `src/CGImage+PNGWriter.m`
- `src/CGImage+GIFWriter.m`
- `src/CGImage+BMPWriter.m`
- `demo/src/main-uiimage.m`
- `demo/src/main-bengal.m`
- `demo/src/main-tiger.m`
- `demo/src/main-animatedgif.m`
- `test/20-uibitmapimage/static.m`
- `test/20-uibitmapimage/scale.m`
- `test/20-uibitmapimage/threadsafe.m`

## Main local families

| Symptom | Start here | Local rule |
| --- | --- | --- |
| Same layer code works for PNG/JPG but not SVG, or vice versa | `demo/src/main-uiimage.m`, `demo/src/main-bengal.m`, `demo/src/main-tiger.m` | The visible API is `UIImage`, but the concrete path is bitmap or SVG. Split class-cluster selection bugs from layer/layout bugs first. |
| Stale pixels, wrong flip, or resource churn after redraws | `src/UIBitmapImage+CGImage.h`, `src/UIBitmapImage+CGImage.m`, `src/UIBitmapImage+CGImageLayer.m` | `UIBitmapImage` is treated as immutable and caches `CGImage` objects per `CGContext` plus texture-flag bucket. Reuse the bitmap, not the `CGImage`. |
| Debug builds abort while drawing SVG or transforms are ignored | `src/UISVGImage+CGImage.m`, `demo/src/main-tiger.m` | The vector path only supports projection into the destination rect plus alpha. Rotation, extra scaling, and corner insets assert out. |
| Export output differs from what the app showed on screen | `src/CGImage+UIBitmapImage.m`, `src/CGImage+PNGWriter.m`, `src/CGImage+GIFWriter.m`, `src/CGImage+BMPWriter.m`, `demo/src/main-animatedgif.m` | Static writers flatten through `-bitmapImage`. Animated GIF output is a separate screenshot loop, not the same code path. |

## Local workflow

- Reproduce at the lowest level that still fails: `UIImage` file load, embedded-data `UIImage`, direct `UIBitmapImage`, direct `UISVGImage`, or `CGImage` export.
- Cut the filesystem out early when format detection is suspicious. `demo/src/main-bengal.m` and `demo/src/main-tiger.m` show the local `imageWithFileCData:allocator:NULL` path.
- For bitmap failures, check allocator ownership, bitmap size changes, and whether the failure appears only after crossing into a new `CGContext`.
- For SVG failures, start from default options and add only one option at a time; the implementation asserts instead of degrading unsupported cases.
- For export failures, decide whether the bad output starts at render time, at `CGImage -> UIBitmapImage`, or only in the final writer call.

## Verify and report

```bash
mulle-sde test run test/20-uibitmapimage/static.m
mulle-sde test run test/20-uibitmapimage/scale.m
mulle-sde test run test/20-uibitmapimage/threadsafe.m
```

When reporting, name the failing family: class-cluster loading, bitmap/context bridging, vector drawing, or export/capture.
