//
//  UIBitmapImage+CGImageLayer.m
//  MulleGraphicsImage
//
//  Copyright (c) 2026 Nat! - Mulle kybernetiK.
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
