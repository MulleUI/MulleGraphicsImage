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
#import "UIBitmapImage.h"

#import "import-private.h"

// the MulleCG include is handcrafted and doesn't want to expose stb
// by default, so we grab it directly
#include <MulleCG/stb_image.h>


@implementation UIBitmapImage


static const struct mulle_allocator    stbi_allocator;


+ (void) load
{
   stbi_set_unpremultiply_on_load( 1);
   stbi_convert_iphone_png_to_rgb( 1);
}


+ (void) unload
{
}


- (instancetype) initWithBytes:(void *) bytes
                    bitmapInfo:(struct CGBitmapInfo) bitmapInfo
                     allocator:(struct mulle_allocator *) allocator
{
   _bitmapInfo    = bitmapInfo;
   _bytes         = bytes;
   _allocator     = allocator;

// we don't need to do this, as its just a memset 0
//   for( i = 0; i < 0x4ß; i++)
//   _mulle__pointermap_init( &_context_map[ i], 0, MulleObjCInstanceGetAllocator( self));

   return( self);
}


+ (instancetype) newWithFileCData:(struct mulle_data) data
                    sharingObject:(id) sharingObject
                        allocator:(struct mulle_allocator *) allocator
{
   int             w;
   int             h;
   int             n;
   void            *bytes;
   UIBitmapImage   *obj;

   bytes = stbi_load_from_memory( data.bytes, (int) data.length, &w, &h, &n, 4);
   if( ! bytes || ! w || ! h || ! n)
      return( nil);

   obj = [self new];

   obj->_fileDataSharingObject  = [sharingObject retain];
   obj->_fileData               = data;
   obj->_fileDataAllocator      = allocator;
   obj->_fileEncoding           = UIImageDataEncodingFromCData( data);

   obj->_bitmapInfo.size.width  = w;
   obj->_bitmapInfo.size.height = h;
   obj->_bitmapInfo.encoding    = CGBitmapEncodingRGBABytes;

   obj->_bytes                  = bytes;
   obj->_allocator              = (void *) &stbi_allocator;

   return( obj);
}


- (void) releaseAllImages
{
   struct mulle__pointermapenumerator   rover;
   struct mulle__pointermap             tmp;
   CGImage                              *image;
   CGContext                            *context;
   unsigned int                         i;

   for( i = 0; i < _n_imageFlag_index; i++)
   {
      tmp = _context_map[ i];
      _mulle__pointermap_init( &_context_map[ i], 0, MulleObjCInstanceGetAllocator( self));

      rover = mulle__pointermap_enumerate( &tmp);
      while( _mulle__pointermapenumerator_next( &rover,
                                                (void **) &context,
                                                (void **) &image))
      {
         [image autorelease];
      }
      mulle__pointermapenumerator_done( &rover);

      _mulle__pointermap_done( &tmp, MulleObjCInstanceGetAllocator( self));
   }

   memset( &_context_map[ 0], 0, sizeof( _context_map));
   _n_imageFlag_index = 0;
}


- (void) finalize
{
   [self releaseAllImages];
   [super finalize];
}


- (void) dealloc
{
   if( _allocator == &stbi_allocator)
      stbi_image_free( _bytes);
   else
      if( _allocator)
         mulle_allocator_free( _allocator, _bytes);
   [super dealloc];
}


- (void *) bytes
{
   return( _bytes);
}

- (NSUInteger) length
{
   return( CGBitmapInfoGetAllocationSize( _bitmapInfo));
}


- (BOOL) isFlipped
{
   return( CGBitmapEncodingIsFlipped( _bitmapInfo.encoding));
}


- (UIBitmapImage *) flippedImage
{
   UIBitmapImage            *flipped;
   struct mulle_allocator   *allocator;
   struct CGBitmapInfo      bitmapInfo;
   struct mulle_data        src_data;
   struct mulle_data        data;
   NSInteger                line_length;
   uint8_t                  *src;
   uint8_t                  *dst;
   uint8_t                  *sentinel;

   // don't use _allocator, could be the stbi one
   bitmapInfo  = [self bitmapInfo];
   bitmapInfo.encoding = CGBitmapEncodingByFlipping( bitmapInfo.encoding);

   src_data.bytes  = [self bytes];
   src_data.length = CGBitmapInfoGetAllocationSize( bitmapInfo);
   line_length     = CGBitmapInfoGetLineLength( bitmapInfo);

   allocator   = MulleObjCInstanceGetAllocator( self);
   data.length = src_data.length;
   data.bytes  = mulle_allocator_malloc( allocator, data.length);
   dst         = data.bytes;
   sentinel    = &dst[ data.length - line_length];

   src         = src_data.bytes;
   src         = &src[ line_length * bitmapInfo.size.height];

   while( dst <= sentinel)
   {
      src = &src[ -line_length];

      memcpy( dst, src, line_length);

      dst = &dst[ line_length];
   }

   flipped   = [[[UIBitmapImage alloc] initWithCData:data
                                          bitmapInfo:bitmapInfo
                                           allocator:allocator] autorelease];
   return( flipped);
}


- (CGImage *) cgImageWithContext:(CGContext *) context
                      imageFlags:(NSUInteger) imageFlags
{
   struct CGBitmapInfo   bitmapInfo;
   NSInteger             imageID;
   CGImage               *image;
   void                  *bytes;
   int                   i;
   int                   j;

   bitmapInfo = [self bitmapInfo];

   //
   // if imageFlags comes in asking for flipped and internal representation
   // is flipped already, then clear, otherwise set for "normal" display
   if( CGBitmapEncodingIsFlipped( _bitmapInfo.encoding))
      imageFlags ^= NVG_IMAGE_FLIPY;

   // map imageFlags hopefully to a cachable index
   // we only care for lower 6 bits
   // also get cached image if present
   i     = -1;
   image = NULL;
   for( j = 0; j <_n_imageFlag_index; j++)
      if( _imageFlag_index[ j] == (imageFlags & 0x3F))
      {
         i     = _imageFlag_index[ j];
         image = mulle__pointermap_get( &_context_map[ i], context);
         break;
      }

   // create a new cacheable index if possible
   if( i == -1 && _n_imageFlag_index < UIBitmapImageNumberOfContextMappings)
   {
      i                    = _n_imageFlag_index;
      _imageFlag_index[ i] = (imageFlags & 0x3F);
      _n_imageFlag_index++;
   }

   if( ! image)
   {
      bytes = [self bytes];
      switch( bitmapInfo.encoding)
      {
      case CGBitmapEncodingRGBABytes :
      case CGBitmapEncodingFlipYRGBABytes :
         image = [[CGImage alloc] initWithRGBABytes:bytes
                                         bitmapSize:bitmapInfo.size
                                         imageFlags:imageFlags
                                            context:context];
      default :
         break;
      }

      if( ! image)
         return( nil);

      if( i != -1)
      {
         mulle__pointermap_set( &_context_map[ i],
                                context,
                                image,
                                MulleObjCInstanceGetAllocator( self));

         // we add ourselves to the resources to remove
         // that way we can remove the image from the context map
         [context addToResources:self];
      }
   }
   return( image);
}


- (NSInteger) nvgImageWithContext:(CGContext *) context
                        imageFlags:(NSUInteger) imageFlags
{
   CGImage   *image;

   image = [self cgImageWithContext:context
                         imageFlags:imageFlags];
   if( ! image)
      return( -1);

   return( [image nvgImageWithContext:context
                           imageFlags:imageFlags]);
}


- (void) contextDidRemoveObject:(CGContext *) context
{
   CGImage        *image;
   unsigned int   i;

   for( i = 0; i < _n_imageFlag_index; i++)
   {
      image = _mulle__pointermap_get( &_context_map[ i], context);
      if( image)
      {
         _mulle__pointermap_remove( &_context_map[ i],
                                    context,
                                    MulleObjCInstanceGetAllocator( self));
         [image autorelease];
      }
   }
}

@end
