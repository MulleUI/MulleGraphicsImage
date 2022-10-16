#import <MulleUIImage/MulleUIImage.h>


int   main( int argc, char *argv[])
{
   char                   bytes[ 256];
   struct CGBitmapInfo    info;
   UIBitmapImage          *image;

   info  = CGBitmapInfoMakeWHRGBABytes( 8, 8);
   image = [UIBitmapImage imageWithBytes:bytes
                              bitmapInfo:info
                               allocator:NULL];
   return( 0);
}


/*
 * extension : mulle-sde/objc-test-library-demo
 * directory : demo/all
 * template  : .../noleak.m
 * Suppress this comment with `export MULLE_SDE_GENERATE_FILE_COMMENTS=NO`
 */
