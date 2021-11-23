#import "CGLayer+UIBitmapImage.h"

#import "import-private.h"

#import "UIBitmapImage.h"


@implementation CGLayer( UIBitmapImage)

- (UIBitmapImage *) bitmapImage
{
   struct mulle_data     data;
   UIBitmapImage         *image;
   struct CGBitmapInfo   bitmapInfo;

   data = [self readRGBACData:&mulle_default_allocator];
   if( ! data.length)
      return( nil);

   bitmapInfo          = [self bitmapInfo];
   bitmapInfo.encoding = CGBitmapEncodingRGBABytes;

   image = [[[UIBitmapImage alloc] initWithBytes:data.bytes
                                      bitmapInfo:bitmapInfo
                                       allocator:&mulle_default_allocator] autorelease];
   return( image);
}

@end

