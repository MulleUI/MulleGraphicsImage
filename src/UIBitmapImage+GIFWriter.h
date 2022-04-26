//
//  UIBitmapImage+GIFWriter.m
//  MulleUIImage
//
//  Copyright (c) 2022 Nat! - Mulle kybernetiK.
//  Copyright (c) 2022 Codeon GmbH.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
// prefer a local UIBitmapImage over one in import.h
#ifdef __has_include
# if __has_include( "UIBitmapImage.h")
#  import "UIBitmapImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

#include <stdio.h>
#include <stdint.h>

// https://github.com/charlietangora/gif-h
// gif.h
// by Charlie Tangora
// Public domain.
// Email me : ctangora -at- gmail -dot- com
//
// This file offers a simple, very limited way to create animated GIFs directly in code.
//
struct UIGIFWriter
{
    FILE      *f;
    uint8_t   *oldImage;
    BOOL      firstFrame;
};


@interface UIAnimatedGIF : NSObject
{
   struct UIGIFWriter   _writer;
}

@property( assign) struct CGBitmapSize        bitmapSize;
@property( assign) CGFloat                    frameRate;
// @property( assign) NSUInteger                 bitDepth; // fixed to 8
@property( assign, getter=isDithering) BOOL   dithering;

+ (instancetype) animatedGIFUTF8String:(char *) filename
                                              bitmapSize:(struct CGBitmapSize) bitmapSize
                                               frameRate:(CGFloat) frameRate;
- (instancetype) initWithUTF8String:(char *) filename
                                       bitmapSize:(struct CGBitmapSize) bitmapSize
                                        frameRate:(CGFloat) frameRate;
- (BOOL) writeBytes:(void *) bytes;
- (BOOL) close;

- (BOOL) addBitmap:(struct CGBitmap *) bitmap
      freeWhenDone:(BOOL) flag;
- (BOOL) addBitmapImage:(UIBitmapImage *) image;

@end


@interface UIBitmapImage( GIFWriter)

- (BOOL) writeToGIFUTF8String:(char *) filename;
- (BOOL) writeToAnimatedGIF:(UIAnimatedGIF *) gif;

@end
