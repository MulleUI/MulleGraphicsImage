//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "UIBitmapImage+PNGWriter.h"

#import "import-private.h"

#include <zlib.h>

// stolen from https://github.com/DanielGibson/stb/commit/1dae231b1ec01b403a937ffe04421ca4e287efc2
static unsigned char  *compress_for_stbiw( unsigned char *data,
                                           int data_len,
                                           int *out_len,
                                           int quality)
{
   uLongf          bufSize = compressBound( data_len);
   unsigned char   *buf = malloc(bufSize);

   if( buf == NULL)
      return( buf);

   if( compress2( buf, &bufSize, data, data_len, quality) != Z_OK)
   {
      free( buf);
      return( NULL);
   }
   *out_len = bufSize;

   return( buf);
}

// stb_image is owned by nanovg, but we own stb_image_write
#define STBIW_ZLIB_COMPRESS compress_for_stbiw
#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"


@implementation UIBitmapImage ( PNGWriter)

- (BOOL) writeToPNGFileWithSystemRepresentation:(char *) filename
{
   int                   rval;
   struct CGBitmapInfo   bitmapInfo;
   void                  *bytes;

   if( [self isFlipped])
      return( [[self flippedBitmapImage] writeToPNGFileWithSystemRepresentation:filename]);

   bytes = [self bytes];
   if( ! bytes)
      return( NO);

   bitmapInfo = [self bitmapInfo];
   if( bitmapInfo.encoding != CGBitmapEncodingRGBABytes)
      return( NO);

   rval = stbi_write_png( filename,
                          bitmapInfo.size.width,
                          bitmapInfo.size.height,
                          4,
                          bytes,
                          bitmapInfo.size.width * 4);
   return( rval != 0);
}


static void   append_data(void *context, void *data, int size)
{
   mulle_buffer_add_bytes( context, data, size);
}


- (struct mulle_data) PNGCData
{
   int                   rval;
   NSUInteger            lineLength;
   struct mulle_buffer   buffer;
   struct CGBitmapInfo   bitmapInfo;
   void                  *bytes;
   struct mulle_data     data;

   bitmapInfo = [self bitmapInfo];
   bytes      = [self bytes];
   if( ! bytes)
      return( mulle_data_make_invalid());

   lineLength = CGBitmapInfoGetLineSize( bitmapInfo);

   mulle_buffer_init_with_capacity( &buffer,
                                    1024 + bitmapInfo.size.width * lineLength,
                                    &mulle_stdlib_allocator);
   rval = stbi_write_png_to_func( append_data,
                                  &buffer,
                                  bitmapInfo.size.width,
                                  bitmapInfo.size.height,
                                  4,
                                  bytes,
                                  lineLength);
   if( rval == 0)
   {
      mulle_buffer_done( &buffer);
      return( mulle_data_make_invalid());
   }

   mulle_buffer_size_to_fit( &buffer);
   data = mulle_buffer_extract_data( &buffer);
   mulle_buffer_done( &buffer);

   return( data);
}

@end
