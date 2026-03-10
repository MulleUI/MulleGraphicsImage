//
//  UIBitmapImage.m
//  MulleGraphicsImage
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
#import "UIBitmapImage+CGImage.h"

#import "import-private.h"


@implementation UIBitmapImage( CGImage)

/*
 * UGLY PART THAT NEEDS LOCKING
 */

// TODO: move to separate category outside of project to keep UIImage
//       "pure" ?
- (CGImage *) _cgImageWithContext:(CGContext *) context
                     textureFlags:(NSUInteger) desiredImageFlags
                   nameUTF8String:(char *) nameUTF8String
{
   struct CGBitmapInfo   bitmapInfo;
   CGImage               *image;
   void                  *bytes;
   int                   i;
   int                   j;
   NSUInteger            textureFlags;

   bitmapInfo = _bitmap.info;

   //
   // if textureFlags comes in asking for flipped and internal representation
   // is flipped already, then clear, otherwise set for "normal" display
   //
   textureFlags = desiredImageFlags;
   if( CGBitmapEncodingIsFlipped( bitmapInfo.encoding))
      textureFlags ^= NVG_IMAGE_FLIPY;

   // map textureFlags hopefully to a cachable index
   // we only care for lower 6 bits
   // also get cached image if present
   i     = -1;
   image = NULL;
   for( j = 0; j <_n_imageFlag_index; j++)
      if( _imageFlag_index[ j] == (textureFlags & 0x3F))
      {
         image = mulle__pointermap_get( &_context_map[ j], context);
         assert( image);
         return( image);
      }

   // create a new cacheable index if possible
   if( i == -1 && _n_imageFlag_index < UIBitmapImageNumberOfContextMappings)
      i = _n_imageFlag_index;

   if( ! image)
   {
      bytes = [self bytes];
      switch( bitmapInfo.encoding)
      {
      case CGBitmapEncodingRGBABytes :
      case CGBitmapEncodingFlipYRGBABytes :
         image = [[CGImage alloc] initWithRGBABytes:bytes
                                         bitmapSize:bitmapInfo.size
                                       textureFlags:textureFlags
                                     nameUTF8String:nameUTF8String
                                            context:context];
         break;

      default :
         abort();
         break;
      }

      if( ! image)
      {
         assert( 0);
         return( nil);
      }

      if( i != -1)
      {
         mulle__pointermap_set( &_context_map[ i],
                                context,
                                image,
                                MulleObjCInstanceGetAllocator( self));
         // we add ourselves to the resources to remove
         // that way we can remove the image from the context map
         // [context addToResources:self];
         _imageFlag_index[ i] = (textureFlags & 0x3F);
         _n_imageFlag_index++;
      }
      else
         image = [image autorelease];
   }
   return( image);
}


- (CGImage *) cgImageWithContext:(CGContext *) context
                    textureFlags:(NSUInteger) textureFlags
                  nameUTF8String:(char *) nameUTF8String
{
   CGImage   *image;

   mulle_thread_mutex_do( _lock)
   {
      image = [self _cgImageWithContext:context
                           textureFlags:textureFlags
                         nameUTF8String:NULL];
      assert( image);
      image = [[image retain] autorelease];
   }
   return( image);
}


- (CGImage *) cgImageWithContext:(CGContext *) context
                    textureFlags:(NSUInteger) textureFlags
{
   return( [self cgImageWithContext:context
                       textureFlags:textureFlags
                     nameUTF8String:NULL]);
}


- (void) didRemoveFromContext:(CGContext *) context
{
   CGImage        *image;
   unsigned int   i;

   mulle_thread_mutex_do( _lock)
   {
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
      // MEMO: this is wrong, because we have more contexts to unmap
      //      _n_imageFlag_index = 0;
   }
}


- (void) finalize
{
   [self releaseAllImages];
   [super finalize];
}

// usually same as canvas for bitmaps
- (CGRect) bounds
{
   return( CGRectMake( 0, 0, _bitmap.info.size.width, _bitmap.info.size.height));
}


- (CGRect) canvas
{
   // TODO: conceivably should DPI scale here ?
   return( CGRectMake( 0, 0, _bitmap.info.size.width, _bitmap.info.size.height));
}


- (BOOL) isRepeating
{
   return( NO);  // CGImages could say yes hmmm
}

- (void) releaseAllImages
{
   struct mulle__pointermapenumerator   rover;
   struct mulle__pointermap             tmp;
   CGImage                              *image;
   CGContext                            *context;
   unsigned int                         i;

   mulle_thread_mutex_do( _lock)
   {
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
}

@end


