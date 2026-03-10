// prefer a local UIBitmapImage over one in import.h
#ifdef __has_include
# if __has_include( "UIBitmapImage.h")
#  import "UIBitmapImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface UIBitmapImage( nanovg) < CGPaintable>
@end 
