//
//  UISVGImage+CGImage.m
//  MulleGraphicsImage
//
//  Copyright (c) 2025 Nat! - Mulle kybernetiK.
//  All rights reserved.
//
//
//  Redistribution and use in source and binary forms, with or without
//  modification, are permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this
//  list of conditions and the following disclaimer.
//
//  Redistributions in binary form must reproduce the above copyright notice,
//  this list of conditions and the following disclaimer in the documentation
//  and/or other materials provided with the distribution.
//
//  Neither the name of Mulle kybernetiK nor the names of its contributors
//  may be used to endorse or promote products derived from this software
//  without specific prior written permission.
//
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
//  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
//  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
//  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
//  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
//  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
//  POSSIBILITY OF SUCH DAMAGE.
//
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
