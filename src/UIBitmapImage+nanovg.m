#import "UIBitmapImage+nanovg.h"

#import "import-private.h"

#import "UIBitmapImage+CGImage.h"

@implementation UIBitmapImage( nanovg)

- (NVGpaint) NVGpaintWithBounds:(CGRect) rect
                   paintOptions:(struct CGPaintOptions *) options
                        context:(CGContext *) context

{
   CGImage   *image;

   assert( options);
   assert( options->alpha >= 0.0 && options->alpha <= 1.0);

   image  = [self cgImageWithContext:context
                        textureFlags:options->textureFlags];
   return( [image NVGpaintWithBounds:rect
                        paintOptions:options
                             context:context]);
}


- (CGImage *) image
{
   return( nil);
}


- (CGImage *) otherImage
{
   return( nil);
}

@end
