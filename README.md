# 👓 MulleUIImage

#### 👓 MulleUIImage defines UIImage and provides some image file formats


### You are here

```
  .--------------------------------.
  | MulleUIFoundation              |
  '--------------------------------'
  .--------------------------------.
  | MulleUIViews                   |
  '--------------------------------'

  .==============.
  | MulleUIImage |
  .=====.========'
  | png |          .---------------.
  | svg |          | MulleUICore   |
  '-----'          '---------------'
  .--------------------------------.
  | MulleGraphics                  |
  '--------------------------------'
  .--------------. .---------------.
  | MulleCG      | | MulleCA       |
  '--------------' '---------------'
  .--------------------------------.
  | MulleLayout                    |
  '--------------------------------'

```

## Add

Use [mulle-sde](//github.com/mulle-sde) to add MulleUIImage to your project:

``` console
mulle-sde dependency add --c --github MulleUI MulleUIImage
```

## Install

### mulle-sde

Use [mulle-sde](//github.com/mulle-sde) to build and install MulleUIImage
and all its dependencies:

```
mulle-sde install --prefix /usr/local \
   https://github.com/MulleUI/MulleUIImage/archive/latest.tar.gz
```

### Manual Installation


Install the requirements:

Requirements                                      | Description
--------------------------------------------------|-----------------------
[some-requirement](//github.com/some/requirement) | Some requirement

Install into `/usr/local`:

```
mkdir build 2> /dev/null
(
   cd build ;
   cmake -DCMAKE_INSTALL_PREFIX=/usr/local \
         -DCMAKE_PREFIX_PATH=/usr/local \
         -DCMAKE_BUILD_TYPE=Release .. ;
   make install
)
```

### Steal

Read [STEAL.md](//github.com/mulle-c11/dox/STEAL.md) on how to steal the
source code and incorporate it in your own projects.
