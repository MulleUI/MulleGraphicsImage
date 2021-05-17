//
//  MulleBitmapImage.m
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
#import "MulleBitmapImage.h"

#import "import-private.h"

// the MulleCG include is handcrafted and doesn't want to expose stb
// by default, so we grab it directly
#include <MulleCG/stb_image.h>


@implementation MulleBitmapImage


static const struct mulle_allocator    stbi_allocator;


+ (void) load
{
   stbi_set_unpremultiply_on_load(1);
   stbi_convert_iphone_png_to_rgb(1);
}

+ (void) unload
{
}



+ (instancetype) newWithFileCData:(struct mulle_data) data
                    sharingObject:(id) sharingObject
                        allocator:(struct mulle_allocator *) allocator
{
   int                w;
   int                h;
   int                n;
   void               *bytes;
   MulleBitmapImage   *obj;

   bytes = stbi_load_from_memory( data.bytes, (int) data.length, &w, &h, &n, 4);
   if( ! bytes || ! w || ! h || ! n)
      return( nil);

   obj = [self new];

   obj->_fileDataSharingObject = [sharingObject retain];
   obj->_fileData              = data;
   obj->_fileDataAllocator     = allocator;
   obj->_fileEncoding          = UIImageDataEncodingFromCData( data);

   obj->_bitmapInfo.size.width       = w;
   obj->_bitmapInfo.size.height      = h;
   obj->_bitmapInfo.nColorComponents = n;

   obj->_decodedCData = mulle_data_make( bytes, data.length);
   obj->_allocator    = (void *) &stbi_allocator;

   return( obj);
}


- (void) dealloc
{
   if( _allocator == &stbi_allocator)
      stbi_image_free( _decodedCData.bytes);
   [super dealloc];
}

@end
