### 0.0.3


* nanosvg.h and nanosvgrast.h are no longer re-exported through ``_MulleGraphicsImage-provide.h`;` include them directly when needed
* **BREAKING**: consumers that relied on the umbrella header to transitively obtain the nanosvg headers must add an explicit include
* remove the nanosvg headers from the public headers and include directories

### 0.0.2





* document UIImage as a CGDrawable usable with CAImageLayer
* add PNG/BMP/GIF writer usage examples to the README
