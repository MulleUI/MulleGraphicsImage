#import "UISVGImage+CGImage.h"

#import "import-private.h"

#import <MulleImage/nanosvg.h>
#import <errno.h>
#import <stdio.h>


@implementation UISVGImage( CGImage)



static NVGcolor getSVGColor( uint32_t color)
{
   return nvgRGBA(
      (color >> 0) & 0xff,
      (color >> 8) & 0xff,
      (color >> 16) & 0xff,
      (color >> 24) & 0xff);
}


//static CGDrawableOptions  defaultOptions =
//{
//   .alpha             = 1.0f,
//   .cornerInsets      = (MulleCornerInsets) { 0.0f, 0.0f, 0.0f, 0.0f },
//   .rotation          = CGRotationNone,
//   .scale             = CGScaleNone,
//   .flags.flip        = CGFlipNone,
//   .flags.repeat      = CGRepeatAsIs,
//   .flags.contentMode = CGContentModeCenterPoint
//};
//


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
   NVGcontext          *vg;

   if( ! options)
      options = &CGDrawableOptionsDefault;

   assert( options->cornerInsets.topLeft == 0.0);  // we can't do this for vector
   assert( options->scale == NO);          // we too lazy to do this for vector
   assert( options->rotation == 0.0);      // we too lazy to do this for vector

   vg = CGContextGetNVGContext( context);

   xform = CGAffineTransformMakeProjection( rect, [self bounds]);
   nvgSave( vg);
   {
      nvgTransform( vg, xform.a, xform.b, xform.c, xform.d, xform.tx, xform.ty);

      nvgBezierTessellation( vg, NVG_TESS_AFD); // patched nanovg function

      for( shape = _NSVGImage->shapes; shape != NULL; shape = shape->next)
      {
         if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
            continue;

         nvgStrokeWidth( vg, shape->strokeWidth);

         color = getSVGColor( shape->fill.color);
         color = CGColorMultiplyAlpha( color, options->alpha);
         nvgFillColor( vg, color);

         color = getSVGColor( shape->stroke.color);
         color = CGColorMultiplyAlpha( color, options->alpha);
         nvgStrokeColor( vg, color);

         for( path = shape->paths; path != NULL; path = path->next)
         {
            nvgBeginPath( vg);

            nvgMoveTo( vg, path->pts[0], path->pts[1]);
            for (i = 0; i < path->npts-1; i += 3)
            {
               p = &path->pts[i*2];
               nvgBezierTo( vg, p[2], p[3], p[4], p[5], p[6], p[7]);
            }

            if( path->closed)
               nvgLineTo( vg, path->pts[0], path->pts[1]);

            if( shape->fill.type)
               nvgFill( vg);

            if( shape->stroke.type)
               nvgStroke( vg);
         }
      }
   }
   nvgRestore( vg);
}

@end
