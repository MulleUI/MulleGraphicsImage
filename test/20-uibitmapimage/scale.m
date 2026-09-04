#import <MulleGraphicsImage/MulleGraphicsImage.h>


int   main( int argc, char *argv[])
{
   char                   *bytes;
   struct CGBitmapInfo    info;
   UIBitmapImage          *image;
   UIBitmapImage          *scaled;

   bytes = mulle_calloc( 1, 256);
   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:&mulle_default_allocator];

   scaled = [image bitmapImageForBitmapInfo:CGBitmapInfoMakeWHRGBABytes( 4, 4)
                                  allocator:NULL];
   printf( "%s\n", CGPixelSizeUTF8String( CGBitmapInfoGetSize( [scaled bitmapInfo])));
   return( 0);
}


/*
 * extension : mulle-sde/objc-test-library-demo
 * directory : demo/all
 * template  : .../noleak.m
 * Suppress this comment with `export MULLE_SDE_GENERATE_FILE_COMMENTS=NO`
 */
