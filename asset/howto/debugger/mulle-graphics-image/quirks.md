<!-- Keywords: debugger quirks, class cluster, textureFlags, cache, flip, SVG assertions, export -->
# Quirks

## `UIImage` hides two different concrete paths

- `demo/src/main-uiimage.m` and `demo/src/main-tiger.m` both feed `UIImage` into `CAImageLayer`, but the concrete image class can differ by format.
- Comparison: unlike UIKit-style debugging where `UIImage` often stays the whole story, here the first split is usually `UIBitmapImage` versus `UISVGImage`.
- If one asset format fails and another does not, debug the concrete family before changing shared layer code.

## `UIBitmapImage` is shared-state input, not mutable working storage

- `src/UIBitmapImage+CGImage.h` explicitly treats `UIBitmapImage` as effectively immutable.
- Mutating backing bytes after creation can invalidate the internal `CGImage` cache in ways the repository does not try to repair.
- If pixels or size change, create another `UIBitmapImage`.

## Cache keys are narrower than they look

- `src/UIBitmapImage+CGImage.m` caches by `CGContext` and only the lower 6 bits of `textureFlags`.
- The image keeps only `UIBitmapImageNumberOfContextMappings` flag buckets per bitmap. After that, new `CGImage` objects are created but not inserted into the cache.
- If a bug appears only with certain flag combinations or after lots of context churn, inspect the cache bucket logic before blaming drawing code.

## Context removal is partial cleanup

- `didRemoveFromContext:` removes the matching `CGContext` entry, but the implementation does not reset `_n_imageFlag_index`.
- Expect texture-flag slots to remain allocated until full `releaseAllImages`/finalization.
- This matters when you are debugging cache growth or repeated create/destroy cycles across many contexts.

## Flip handling is normalized once already

- `src/UIBitmapImage+CGImage.m` XORs `CGImageFlagFlipY` with the bitmap encoding when the stored bytes are already flipped.
- If you pre-flip the bytes and also request flipped texture output, you can debug the wrong image because the inversion happened twice.

## The repository thread-safety proof is narrow

- `test/20-uibitmapimage/threadsafe.m` proves `[image mulleIsThreadSafe]` is `YES` for the bitmap object.
- It does not prove that the surrounding `CGContext` or the returned `CGImage` is safe to move freely across threads.
- Keep thread bugs split into image-object safety versus context/resource ownership.

## `UIImage+CGImageLayer` is abstract glue

- `src/UIImage+CGImageLayer.m` fixes `canvas` and `bounds` to origin-based rectangles built from `[self size]`.
- `isRepeating` and `drawRect:options:context:` are subclass-required there.
- If a new `UIImage` subclass crashes with a subclass-requires-implementation failure, this category is the first place to inspect.

## The SVG path is intentionally incomplete

- `src/UISVGImage+CGImage.m` asserts `cornerInsets.topLeft == 0.0`, `options->scale == NO`, and `options->rotation == 0.0`.
- That means the local vector path handles projection and alpha, but not rounded-corner clipping, arbitrary scaling, or rotation-aware rendering.
- A debug-build abort here is usually an unsupported-option bug, not malformed SVG input.

## Writer categories always flatten to a bitmap first

- `src/CGImage+PNGWriter.m`, `src/CGImage+GIFWriter.m`, and `src/CGImage+BMPWriter.m` all call `[self bitmapImage]`.
- `src/CGImage+UIBitmapImage.m` allocates a fresh bitmap with `RGBABytesBitmap:&mulle_default_allocator` and wraps it in a `UIBitmapImage`.
- Treat the writers as terminal save helpers. They do not preserve vector structure and they are not zero-copy.
