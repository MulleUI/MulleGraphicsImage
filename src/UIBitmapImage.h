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
// UIBitmapImage should be for all intents and purposes be immutable.
// If you want mutability, use a subclass (and block copying and
// sharing methods)
//
// UIBitmapImage can be used by multiple contexts, it will create
// a CGTextureImage on demand.
//
#define UIBitmapImageNumberOfContextMappings  4

@interface UIBitmapImage : UIImage <CGBitmapDrawable, CGContextResource>
{
   struct mulle_allocator     *_allocator;

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

@property( readonly) struct CGBitmapInfo   bitmapInfo;
@property( readonly) struct mulle_data     decodedCData;

// vertically flipped that is
- (UIBitmapImage *) flippedImage;
- (BOOL) isFlipped;

- (instancetype) initWithCData:(struct mulle_data) data
                    bitmapInfo:(struct CGBitmapInfo) bitmapInfo
                     allocator:(struct mulle_allocator *) allocator;

+ (instancetype) newWithFileCData:(struct mulle_data) data
                    sharingObject:(id) sharingObject
                        allocator:(struct mulle_allocator *) allocator;

- (int) textureIDWithContext:(CGContext *) context
                  imageFlags:(NSUInteger) imageFlags;
@end
