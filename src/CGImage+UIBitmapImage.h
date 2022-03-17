#import "import.h"

@class UIBitmapImage;

@interface CGImage( UIBitmapImage)

// get a "saveable" bitmap image out of a texture,
- (UIBitmapImage *) bitmapImage;

@end
