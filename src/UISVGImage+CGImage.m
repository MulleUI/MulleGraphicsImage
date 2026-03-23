#import "UISVGImage+CGImage.h"

#import "import-private.h"

#import <MulleImage/nanosvg.h>


@implementation UISVGImage( CGImage)


static CGColor getSVGColor( uint32_t color)
{
   return CGColorMakeWithRGBABytes(
      (color >> 0) & 0xff,
      (color >> 8) & 0xff,
      (color >> 16) & 0xff,
      (color >> 24) & 0xff);
}


- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   CGAffineTransform   xform;
   CGColor             color;
   float               *p;
   int                 i;
   NSVGpath            *path;
   NSVGshape           *shape;

   if( ! options)
      options = &CGDrawableOptionsDefault;

   assert( options->cornerInsets.topLeft == 0.0);  // we can't do this for vector
   assert( options->scale == NO);          // we too lazy to do this for vector
   assert( options->rotation == 0.0);      // we too lazy to do this for vector

   xform = CGAffineTransformMakeProjection( rect, [self bounds]);
   CGContextSave( context);
   {
      CGContextTransform( context, &xform);

      for( shape = _NSVGImage->shapes; shape != NULL; shape = shape->next)
      {
         if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
            continue;

         CGContextStrokeWidth( context, shape->strokeWidth);

         color = getSVGColor( shape->fill.color);
         color = CGColorMultiplyAlpha( color, options->alpha);
         CGContextFillColor( context, color);

         color = getSVGColor( shape->stroke.color);
         color = CGColorMultiplyAlpha( color, options->alpha);
         CGContextStrokeColor( context, color);

         for( path = shape->paths; path != NULL; path = path->next)
         {
            CGContextBeginPath( context);

            CGContextMoveTo( context, CGPointMake( path->pts[0], path->pts[1]));
            for (i = 0; i < path->npts-1; i += 3)
            {
               p = &path->pts[i*2];
               CGContextBezierTo( context,
                                  CGPointMake( p[2], p[3]),
                                  CGPointMake( p[4], p[5]),
                                  CGPointMake( p[6], p[7]));
            }

            if( path->closed)
               CGContextLineTo( context, CGPointMake( path->pts[0], path->pts[1]));

            if( shape->fill.type)
               CGContextFill( context);

            if( shape->stroke.type)
               CGContextStroke( context);
         }
      }
   }
   CGContextRestore( context);
}

@end
