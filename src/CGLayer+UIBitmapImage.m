#import "CGLayer+UIBitmapImage.h"

#import "import-private.h"

#import "UIBitmapImage.h"


@implementation CGLayer( UIBitmapImage)

- (UIBitmapImage *) bitmapImage
{
   struct mulle_data     data;
   UIBitmapImage         *image;
   struct CGBitmapInfo   bitmapInfo;

   data = [self readRGBACData:&mulle_stdlib_allocator];
   if( ! data.length)
      return( nil);

   bitmapInfo.size             = [self bitmapInfo].size;
   bitmapInfo.encoding         = CGBitmapEncodingRGBABytes;

   image = [[[UIBitmapImage alloc] initWithCData:data
                                      bitmapInfo:bitmapInfo
                                       allocator:&mulle_stdlib_allocator] autorelease];
   return( image);
}

@end

