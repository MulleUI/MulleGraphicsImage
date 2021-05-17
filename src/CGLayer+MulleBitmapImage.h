#import "import.h"

@class MulleBitmapImage;

@interface CGLayer( MulleBitmapImage)

// get a "saveable" bitmap image out of a texture,
- (MulleBitmapImage *) bitmapImage;

@end
