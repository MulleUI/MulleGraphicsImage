#import "UIImage+CGImageLayer.h"

#import "import-private.h"



@implementation UIImage( CGImageLayer)

// always 0,0, size
- (CGRect) canvas
{
   return( CGRectMakeWithSize( [self size]));
}


- (CGRect) bounds
{
   return( CGRectMakeWithSize( [self size]));
}


- (BOOL) isRepeating
{
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
}


- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   MULLE_C_UNUSED( rect);
   MULLE_C_UNUSED( options);
   MULLE_C_UNUSED( context);
   MULLE_OBJC_SUBCLASS_REQUIRES_IMPLEMENTATION;
}

@end



