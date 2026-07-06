# MulleGraphicsImage

#### 📸 MulleGraphicsImage defines UIImage and provides some image file formats


# 📸 MulleUIImage

#### 📸 MulleUIImage defines UIImage and provides some image file formats





| Release Version                                       | Release Notes  | AI Documentation
|-------------------------------------------------------|----------------|---------------
| ![Mulle kybernetiK tag](https://img.shields.io/github/tag/MulleUI/MulleGraphicsImage.svg) [![Build Status](https://github.com/MulleUI/MulleGraphicsImage/workflows/CI/badge.svg)](//github.com/MulleUI/MulleGraphicsImage/actions) | [RELEASENOTES](RELEASENOTES.md) | [DeepWiki for MulleGraphicsImage](https://deepwiki.com/MulleUI/MulleGraphicsImage)






### You are here

![Overview](overview.dot.svg)





## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleGraphicsImage to your project:

``` sh
mulle-sde add github:MulleUI/MulleGraphicsImage
```

To only add the sources of MulleGraphicsImage with dependency
sources use [clib](https://github.com/clibs/clib):


``` sh
clib install --out src/MulleUI MulleUI/MulleGraphicsImage
```

Add `-isystem src/MulleUI` to your `CFLAGS` and compile all the sources that were downloaded with your project.


## Install

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleGraphicsImage and all dependencies:

``` sh
mulle-sde install --prefix /usr/local \
   https://github.com/MulleUI/MulleGraphicsImage/archive/latest.tar.gz
```

### Legacy Installation

Install the requirements:

| Requirements                                 | Description
|----------------------------------------------|-----------------------
| [MulleGraphics](https://github.com/MulleUI/MulleGraphics)             | 🌠 MulleGraphics provides CALayer subclasses
| [MulleImage](https://github.com/MulleUI/MulleImage)             | 📸 MulleImage defines UIImage and provides some image file formats
| [mulle-objc-list](https://github.com/mulle-objc/mulle-objc-list)             | 📒 Lists mulle-objc runtime information contained in executables.

Download the latest [tar](https://github.com/MulleUI/MulleGraphicsImage/archive/refs/tags/latest.tar.gz) or [zip](https://github.com/MulleUI/MulleGraphicsImage/archive/refs/tags/latest.zip) archive and unpack it.

Install **MulleGraphicsImage** into `/usr/local` with [cmake](https://cmake.org):

``` sh
PREFIX_DIR="/usr/local"
cmake -B build                               \
      -DMULLE_SDK_PATH="${PREFIX_DIR}"       \
      -DCMAKE_INSTALL_PREFIX="${PREFIX_DIR}" \
      -DCMAKE_PREFIX_PATH="${PREFIX_DIR}"    \
      -DCMAKE_BUILD_TYPE=Release &&
cmake --build build --config Release &&
cmake --install build --config Release
```


## Author

[Nat!](https://mulle-kybernetik.com/weblog) for Mulle kybernetiK  



