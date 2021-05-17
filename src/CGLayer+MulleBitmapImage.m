#import "CGLayer+MulleBitmapImage.h"

#import "import-private.h"

#import "MulleBitmapImage.h"


@implementation CGLayer( MulleBitmapImage)

- (MulleBitmapImage *) bitmapImage
{
   struct mulle_data        data;
   MulleBitmapImage         *image;
   struct MulleBitmapInfo   bitmapInfo;

   data = [self readRGBACData:&mulle_stdlib_allocator];
   if( ! data.length)
      return( nil);

   bitmapInfo.size             = [self bitmapInfo].size;
   bitmapInfo.nColorComponents = 4;
   bitmapInfo.encoding         = MulleBitmapEncodingRGBABytes;

   image = [[[MulleBitmapImage alloc] initWithCData:data
                                         bitmapInfo:bitmapInfo
                                          allocator:&mulle_stdlib_allocator
                                      nvgImageFlags:[self nvgImageFlags]] autorelease];
   return( image);
}

@end

