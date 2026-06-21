//
// UIBitmapImage+CGImageLayer.m
// MulleGraphicsImage
//
#import "UIBitmapImage+CGImage.h"

#import <MulleCG/CGDrawable.h>
#import <MulleCG/CGContext+Drawing.h>
#import <MulleCG/CGPaint+Drawing.h>

#import "import-private.h"


@implementation UIBitmapImage( CGImageLayer)

- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   CGContextDrawBitmapDrawableInRect( context, self, rect, rect, options);
}


- (void) fillWithBounds:(CGRect) rect
                options:(struct CGFillOptions *) options
                context:(CGContext *) context
{
   CGImage     *image;
   CGTextureID  textureID;

   assert( options);

   image     = [self cgImageWithContext:context
                           textureFlags:[self textureFlags]];
   textureID = [image textureID];
   if( ! context || textureID == CGTextureIDInvalid)
      return;

   CGContextSetFillImagePattern( context, textureID, rect,
                                 options->paint.rotation,
                                 options->paint.alpha);
   CGContextFill( context);
}


- (void) strokeWithBounds:(CGRect) rect
              strokeWidth:(CGFloat) strokeWidth
                  options:(struct CGStrokeOptions *) options
                  context:(CGContext *) context
{
   CGImage     *image;
   CGTextureID  textureID;

   assert( options);
   assert( strokeWidth > 0.0f);

   image     = [self cgImageWithContext:context
                           textureFlags:[self textureFlags]];
   textureID = [image textureID];
   if( ! context || textureID == CGTextureIDInvalid)
      return;

   CGContextSetStrokeImagePattern( context, textureID, rect,
                                   options->paint.rotation,
                                   options->paint.alpha);
   CGContextStrokeWidth( context, strokeWidth);
   CGContextStroke( context);
}

@end
