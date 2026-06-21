<!-- Keywords: quirks, immutability, context cache, flip, SVG options, MulleObjCDeps -->
# Quirks

## `UIBitmapImage` is shared, not mutable

- `src/UIBitmapImage+CGImage.h` explicitly treats `UIBitmapImage` as effectively immutable.
- Do not mutate the backing bytes after creation and then expect cached `CGImage` textures to stay correct.
- If the pixels, size, or encoding need to change, make another `UIBitmapImage`.

## Ownership is encoded in the allocator argument

- `allocator:&mulle_default_allocator` means the image owns heap memory and may free it later.
- `allocator:NULL` means the caller owns the storage and must keep it alive long enough.
- The repository uses `NULL` for compiled-in file bytes and stack/static bitmap bytes in `demo/src/main-bengal.m`, `demo/src/main-tiger.m`, and `test/20-uibitmapimage/static.m`.

## `CGImage` caching is per context

- `src/UIBitmapImage+CGImage.m` caches `CGImage` instances by `CGContext` and texture flags.
- Do not move a `CGImage` created for one context into another context; ask the bitmap for a fresh one there.
- Reusing the same `UIBitmapImage` is the supported sharing strategy.

## Flip handling is already normalized

- `src/UIBitmapImage+CGImage.m` toggles `CGImageFlagFlipY` when the bitmap encoding is already flipped.
- Do not pre-flip bitmap data and also compensate again in the requested texture flags unless you really want the double inversion.

## `UIImage+CGImageLayer` is abstract glue

- `src/UIImage+CGImageLayer.m` fixes `canvas` and `bounds` to `(0, 0, size.width, size.height)`.
- `isRepeating` and `drawRect:options:context:` are subclass-required there.
- If you add a new `UIImage` subclass in this repository, implement those methods instead of relying on the base category.

## Local SVG drawing supports only a narrow option set

- `src/UISVGImage+CGImage.m` asserts that `cornerInsets.topLeft == 0.0`, `options->scale == NO`, and `options->rotation == 0.0`.
- That means the current vector path handles projection into the destination rect plus alpha, but not rounded-corner clipping, extra scaling, or rotation-aware drawing.
- Extend that method first if your change depends on those options.

## `CGImage` export is always a bitmap flattening step

- The local `writeToPNGUTF8String:`, `writeToGIFUTF8String:`, and `writeToBMPUTF8String:` methods all call `[self bitmapImage]` first.
- Treat them as final save helpers. They are not zero-copy and they do not preserve vector structure.

## Do not hand-edit the dependency loader

- `src/MulleObjCDeps+MulleGraphicsImage.m` pulls in generated `objc-deps.inc`.
- `src/MulleObjCDeps+MulleGraphicsImage.h` stays public so dependent libraries can declare loader dependencies.
- If the dependency list changes, regenerate it through the normal build flow instead of editing the generated include logic by hand.
