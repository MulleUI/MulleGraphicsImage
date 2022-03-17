#import "UISVGImage.h"

#import "import-private.h"

#define NANOSVG_IMPLEMENTATION

#import "nanosvg.h"
#import <errno.h>
#import <stdio.h>



static NVGcolor getSVGColor( uint32_t color)
{
   return nvgRGBA(
      (color >> 0) & 0xff,
      (color >> 8) & 0xff,
      (color >> 16) & 0xff,
      (color >> 24) & 0xff);
}

/*
 * the nsvg parser modifies the data and needs a trailing zero.
 * SVG text read from a file will not have this zero. Also for
 * UITextView we want to keep the SVG text intact. Therefore
 * always operate on a copy of the incoming data for parsing
 */

@implementation UISVGImage

static const struct mulle_allocator   nsvgAllocator;


+ (instancetype) newWithFileCData:(struct mulle_data) data
                     sharingObject:(id) sharingObject
                         allocator:(struct mulle_allocator *) allocator
{
   UISVGImage   *obj;
   NSVGimage    *image;
   BOOL         hasZero;
   char         *tmp;

   if( ! data.bytes || ! data.length)
   {
      errno = EINVAL;
      return( nil);
   }

   // must be 0 terminated
   hasZero = ! ((char *) data.bytes)[ data.length - 1];

   tmp = mulle_malloc( data.length + (hasZero ? 0 : 1));
   memcpy( tmp, data.bytes, data.length);
   if( ! hasZero)
      tmp[ data.length] = 0;

   // parser is destructive, so we give it a copy
   image = nsvgParse( tmp, "px", 96.0);   // make this flexible
   mulle_free( tmp);

   // check that parser sets errno again
   if( ! image)
   {
//      errno = EACCESS;
      return( nil);
   }

   obj = [self new];
   obj->_fileDataSharingObject = [sharingObject retain];
   obj->_fileData              = data;
   obj->_fileDataAllocator     = allocator;
   obj->_fileEncoding          = UIImageDataEncodingSVG;
   obj->_allocator             = (void *) &nsvgAllocator;
   obj->_NSVGImage             = image;

   return( obj);
}


- (instancetype) initWithNSVGImage:(struct NSVGimage *) image
                         allocator:(struct mulle_allocator *) allocator
{
   if( ! image)
   {
      [self release];
      return( nil);
   }

   _NSVGImage = image;
   _allocator = allocator;
   return( self);
}


- (void) dealloc
{
   if( _allocator == &nsvgAllocator)
      nsvgDelete( _NSVGImage);
   [super dealloc];
}


- (CGSize) size
{
   CGSize   size;

   size.width  = _NSVGImage->width;
   size.height = _NSVGImage->height;

#if DEBUG
   fprintf( stderr, "%s size= %.1f,%.1f\n",
                     __PRETTY_FUNCTION__,
                     size.width,
                     size.height);
#endif
   return( size);
}


- (CGRect) bounds
{
	NSVGshape   *shape;
   CGRect      bounds;
   CGRect      box;
   CGFloat     overdraw;

   bounds = CGRectZero;

	for( shape = _NSVGImage->shapes; shape != NULL; shape = shape->next)
	{
	   if( ! (shape->flags & NSVG_FLAGS_VISIBLE))
   	   continue;

      overdraw        = shape->strokeWidth / 2.0;
      box.origin.x    = shape->bounds[ 0] - overdraw;
      box.origin.y    = shape->bounds[ 1] - overdraw;
      box.size.width  = shape->bounds[ 2] - shape->bounds[ 0] + 1 + shape->strokeWidth;
      box.size.height = shape->bounds[ 3] - shape->bounds[ 1] + 1 + shape->strokeWidth;
#if 0
      fprintf( stderr, "+ %.1f,%.1f,%.1f,%.1f\n",
                        box.origin.x,
                        box.origin.y,
                        box.size.width,
                        box.size.height);
#endif
      bounds = CGRectUnion( bounds, box);
   }
#if 0
   fprintf( stderr, "visibleBounds= %.1f,%.1f,%.1f,%.1f\n",
                     bounds.origin.x,
                     bounds.origin.y,
                     bounds.size.width,
                     bounds.size.height);
#endif
   return( bounds);
}


static CGDrawableOptions  defaultOptions =
{
   0.0f, 1.0f, 0.0f, NO
};


- (void) drawRect:(CGRect) rect
          options:(CGDrawableOptions *) options
          context:(CGContext *) context
{
   float               *p;
   NSVGpath            *path;
   NSVGshape           *shape;
   CGColor             color;
   CGPoint             scale;
   CGRect              rect;
   int                 i;
   NVGcontext          *vg;
   CGAffineTransform   xform;

   if( ! options)
      options = &defaultOptions;


   assert( options->cornerRadius == 0.0);  // we can't do this for vector
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
         color = CGColorByMultiplyingAlpha( color, options->alpha);
         nvgFillColor( vg, color);

         color = getSVGColor( shape->stroke.color);
         color = CGColorByMultiplyingAlpha( color, options->alpha);
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
