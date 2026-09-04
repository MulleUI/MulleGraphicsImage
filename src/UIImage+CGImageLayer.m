//
//  UIImage+CGImageLayer.m
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



