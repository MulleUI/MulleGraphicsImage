<!-- Keywords: bitmap ownership, context cache, SVG assertions, export flattening, image loading -->
# mulle-graphics-image

Use this when verifying user code that loads `UIImage`, shares `UIBitmapImage` across draws, renders `UISVGImage`, or exports `CGImage` results. There are no repo-specific `MULLE_*` trace switches in this library; the local debugging delta is where it asserts, caches per context, and encodes ownership in `allocator:`.

## Understand first

```bash
mulle-sde api cat MulleImage
mulle-sde api cat MulleCG
mulle-sde api apropos UIImage
mulle-sde api apropos UIBitmapImage
mulle-sde api apropos UISVGImage
mulle-sde api apropos CGImage
mulle-sde code search cgImageWithContext
mulle-sde code search writeToPNGUTF8String
mulle-sde howto show debug
```

## Local references

- `asset/dox/TOC.md`
- `src/UIBitmapImage+CGImage.h`
- `src/UIBitmapImage+CGImage.m`
- `src/UISVGImage+CGImage.h`
- `src/UISVGImage+CGImage.m`
- `src/UIImage+CGImageLayer.h`
- `src/UIImage+CGImageLayer.m`
- `src/CGImage+UIBitmapImage.m`
- `src/CGImage+PNGWriter.h`
- `src/CGImage+GIFWriter.h`
- `src/CGImage+BMPWriter.h`
- `demo/src/main-uiimage.m`
- `demo/src/main-bengal.m`
- `demo/src/main-tiger.m`
- `demo/src/main-animatedgif.m`
- `test/20-uibitmapimage/static.m`
- `test/20-uibitmapimage/scale.m`
- `test/20-uibitmapimage/threadsafe.m`

## Main local checks

| Symptom | Start here | Local rule |
| --- | --- | --- |
| `UIImage` load fails for one asset family only | `demo/src/main-uiimage.m`, `demo/src/main-bengal.m`, `demo/src/main-tiger.m` | `UIImage` is the class-cluster entry point. Compare file-path loading with embedded-data loading before changing shared layer/view code. |
| Pixels go stale, flip wrong, or differ per window/context | `src/UIBitmapImage+CGImage.h`, `src/UIBitmapImage+CGImage.m`, `test/20-uibitmapimage/threadsafe.m` | `UIBitmapImage` is treated as immutable and caches `CGImage` by `CGContext` plus the lower 6 bits of `textureFlags`. Recreate the bitmap after pixel changes; do not move one `CGImage` across contexts. |
| Debug builds abort while drawing SVG | `src/UISVGImage+CGImage.m`, `demo/src/main-tiger.m` | The local vector path asserts on non-zero corner insets, `options->scale`, and `options->rotation`. Baseline support is projection into `rect` plus alpha. |
| Export output is wrong or writer calls fail | `src/CGImage+UIBitmapImage.m`, `src/CGImage+PNGWriter.h`, `src/CGImage+GIFWriter.h`, `src/CGImage+BMPWriter.h`, `demo/src/main-animatedgif.m` | Static writers flatten through `[self bitmapImage]`. Animated GIF generation is a separate screenshot loop, so debug capture separately from single-frame export. |
| A custom image subclass crashes with subclass-required errors | `src/UIImage+CGImageLayer.h`, `src/UIImage+CGImageLayer.m` | The base category only supplies origin-based `canvas`/`bounds`; subclasses must implement `isRepeating` and `drawRect:options:context:`. |

## Local workflow

- Reproduce at the lowest family that still fails: `UIImage` class-cluster load, direct `UIBitmapImage`, direct `UISVGImage`, then `CGImage` export.
- For ownership bugs, compare heap-backed `test/20-uibitmapimage/scale.m` / `test/20-uibitmapimage/threadsafe.m` with borrowed-storage `test/20-uibitmapimage/static.m` and the embedded-data demos. In this repo, ownership is entirely encoded by `allocator:` (`&mulle_default_allocator` transfers ownership, `NULL` borrows storage).
- Use `[image mulleIsThreadSafe]` only as a bitmap-object check. The repository test proves the `UIBitmapImage` object is shareable; it does not make `CGContext` or the returned `CGImage` cross-thread or cross-context safe.
- When allocator mistakes or use-after-free are suspected, fall back to the shared Objective-C diagnostics on your repro (`-DMULLE_TESTALLOCATOR=3`, `-DMULLE_OBJC_TRACE_ZOMBIE=YES`, `-DMULLE_OBJC_TRACE_LEAK=YES`). They matter here because wrong `allocator:` choices are the most direct way to break image lifetime.

## Verify and report

```bash
mulle-sde test run test/20-uibitmapimage/static.m
mulle-sde test run test/20-uibitmapimage/scale.m
mulle-sde test run test/20-uibitmapimage/threadsafe.m
```

Use those as baseline comparisons when user code disagrees with the repository examples, and report which family failed first: class-cluster loading, bitmap ownership/cache, SVG option handling, or export/capture.
