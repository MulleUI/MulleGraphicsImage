#import "UIImage+CGImageLayer.h"

#import "import-private.h"



@implementation UIImage( CGImageLayer)

- (Class) preferredImageLayerClass
{
   return( [CAImageLayer class]);
}

@end
