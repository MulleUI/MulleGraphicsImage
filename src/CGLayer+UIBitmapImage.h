#import "import.h"

@class UIBitmapImage;

@interface CGLayer( UIBitmapImage)

// get a "saveable" bitmap image out of a texture,
- (UIBitmapImage *) bitmapImage;

@end
