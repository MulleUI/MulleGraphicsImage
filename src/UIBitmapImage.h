//
//  UIBitmapImage.m
//  MulleUIImage
//
//  Copyright (c) 2021 Nat! - Mulle kybernetiK.
//  Copyright (c) 2021 Codeon GmbH.
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
#ifdef __has_include
# if __has_include( "UIImage.h")
#  import "UIImage.h"
# endif
#endif

#import "import.h"

//                            .------------.
//                            | CGDrawable |--------.
//                            '------------'        |
//                                   |              |
//                                   |              |
//                                   |              |
//                                   |              |
//                                   |              |
//                                   |              |
//                                   |              |
//            .------------------.   |              |
//            | CGBitmapDrawable |<--'              |
//            '------------------'                  |
//                      ^                           |
//                      |                           |
//                      |                           |
//                      |                           |
//                      |                           v
//                      |                 .------------------.
//                      |             .-->| CGVectorDrawable |
//            .------------------.    |   '------------------'
//        .-->| UIBitmapImage    |
//        |   '------------------'    |
//        |                           |
//        |                           |
//        |                           |
//   .---------.              .------------.
//   | UIImage |------------->| UISVGImage |
//   '---------'              '------------'
//
//
// UIBitmapImage should, for all intents and purposes, be immutable.
// If you want mutability, use a subclass (and block copying and
// sharing methods)
//
// UIBitmapImage can be used by multiple contexts, it will create
// a CGTextureImage on demand.
// TODO: need a lock for context_map and imageFlag
//
#define UIBitmapImageNumberOfContextMappings  4

@interface UIBitmapImage : UIImage <CGBitmapDrawable, CGContextResource>
{
   struct CGBitmap            _bitmap;

   //
   // currently there are 64 imageflag combination, each will yield a
   // different CGImage. Each CGImage is only valid in its own CGContext.
   //
   // We assume combinations are pretty much the same always, so we only
   // cache a few different imageFlags combination for each context.
   //
   int                        _n_imageFlag_index;
   int                        _imageFlag_index[ UIBitmapImageNumberOfContextMappings];
   struct mulle__pointermap   _context_map[ UIBitmapImageNumberOfContextMappings];
}


// Pass in a bitmap and if freeWhenDone is set to NO, then the allocator of the
// UIBitmapImage is set to NULL, which will keep the bitmap intact. If the
// bitmap has no allocator, freeWhenDone=YES will assert.
//
+ (instancetype) imageWithBitmap:(struct CGBitmap) bitmap
                    freeWhenDone:(BOOL) flag;

// if allocator is NULL, then no free on release
+ (instancetype) imageWithBytes:(void *) bytes
                     bitmapInfo:(struct CGBitmapInfo) bitmapInfo
                      allocator:(struct mulle_allocator *) allocator;

+ (instancetype) newWithFileCData:(struct mulle_data) data
                    sharingObject:(id) sharingObject
                        allocator:(struct mulle_allocator *) allocator;

- (instancetype) initWithBitmap:(struct CGBitmap) bitmap
                   freeWhenDone:(BOOL) flag;

// if allocator is NULL, then no free on release
- (instancetype) initWithBytes:(void *) bytes
                    bitmapInfo:(struct CGBitmapInfo) bitmapInfo
                     allocator:(struct mulle_allocator *) allocator;

- (CGImage *) cgImageWithContext:(CGContext *) context
                      imageFlags:(NSUInteger) imageFlags;

- (struct CGBitmapInfo) bitmapInfo;
- (struct mulle_allocator *)  bitmapAllocator;
- (void *) bytes;

// will return NULL if bitmap is not in RGBA format
- (void *) RGBABytes;

// will have length zero if no RGBA format available
- (struct mulle_data) RGBACData;


// vertically flipped that is
- (UIBitmapImage *) flippedBitmapImageWithAllocator:(struct mulle_allocator *) allocator;
- (UIBitmapImage *) flippedBitmapImage;
- (UIBitmapImage *) bitmapImage; // will return self

- (BOOL) isFlipped;
- (BOOL) isFullyTransparent;  // if all bytes alpha is 0 it is fully transparent

//
// This can resize and reencode bitmap images. It's very generic and very
// slow on resize and also of low quality. Reencoding by keeping the bitmapSize
// can be more useful.
//
- (UIBitmapImage *) bitmapImageForBitmapInfo:(struct CGBitmapInfo) convertedBitmapInfo
                                   allocator:(struct mulle_allocator *) allocator;

@end
