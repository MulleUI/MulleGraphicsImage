#ifdef __has_include
# if __has_include( "UISVGImage.h")
#  import "UISVGImage.h"
# endif
#endif

#import "import.h"


@interface UISVGImage( CGImage) <CGVectorDrawable>

- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context;

@end
