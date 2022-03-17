#import "CGImage+UIBitmapImage.h"

#import "import-private.h"

#import "UIBitmapImage.h"


@implementation CGImage( UIBitmapImage)

- (UIBitmapImage *) bitmapImage
{
   UIBitmapImage     *image;
   struct CGBitmap   bitmap;

   bitmap = [self RGBABytesBitmap:&mulle_default_allocator];
   image  = [[[UIBitmapImage alloc] initWithBitmap:&bitmap] autorelease];
   return( image);
}

@end

