#import "CGLayer+UIBitmapImage.h"

#import "import-private.h"

#import "UIBitmapImage.h"


@implementation CGLayer( UIBitmapImage)

- (UIBitmapImage *) bitmapImage
{
   void                  *bytes;
   UIBitmapImage         *image;
   struct CGBitmapInfo   bitmapInfo;

   bytes = [self readRGBABytes:&mulle_default_allocator];
   if( ! bytes)
      return( nil);

   bitmapInfo          = [self bitmapInfo];
   bitmapInfo.encoding = CGBitmapEncodingRGBABytes;

   image = [[[UIBitmapImage alloc] initWithBytes:bytes
                                      bitmapInfo:bitmapInfo
                                       allocator:&mulle_default_allocator] autorelease];
   return( image);
}

@end

