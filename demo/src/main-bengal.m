#import "import-private.h"

static char   bengal_jpg[] = 
#include "bengal.jpg.inc"
;
#define s_bengal_jpg  (sizeof( bengal_jpg) - 1)

// #define MULTI_THREADED


// scale stuff for stream

static UIWindow  *create_window( UIImage *tigerBitmap)
{
   CAImageLayer    *imageLayer;
   CGRect          frame;
   CGRect          windowFrame;
   CGRect          bounds;
   UIWindow        *window;
   UIView          *view;
   UIView          *contentView;
   UIScrollView    *scroller;
   UIImageView     *imageView;

   // WINDOW
   windowFrame = CGRectMake( 0.0, 200.0, 640, 400.0);
   window      = [UIWindow windowWithFrame:windowFrame];
   assert( window);

   [window setBackgroundColor:[UIColor yellowColor]];


   // BUTTON IN SCROLLVIEW


   imageLayer = [[[CAImageLayer alloc] initWithImage:tigerBitmap] autorelease];
   imageView  = [[[UIImageView alloc] initWithLayer:imageLayer] autorelease];

   fprintf( stderr, "view: %p f=[%s] c=[%s]\n", 
                        imageView, 
                        CGRectUTF8String( [imageView frame]),
                        CGRectUTF8String( [imageView contentRect]));

   fprintf( stderr, "layer: %p f=[%s] c=[%s]\n", 
                        imageLayer, 
                        CGRectUTF8String( [imageLayer frame]),
                        CGRectUTF8String( [imageLayer canvas]));

   // SCROLLVIEW
   frame    = CGRectMake( 20.0, 20.0, 640 - 40.0, 400.0 - 40.0);
   scroller = [UIScrollView viewWithFrame:frame];
   [scroller setZoomEnabled:YES];
   [scroller setContentSize:[imageView frame].size];
   [[scroller contentView] addSubview:imageView];
   [[window contentPlane] addSubview:scroller];

   return( window);
}



int   main( int argc, char *argv[])
{
   UIImage         *tigerBitmap;
   UIWindow        *window;
   UIApplication   *app;

   tigerBitmap = [UIImage imageWithFileCData:mulle_data_make( bengal_jpg, s_bengal_jpg)
                                  allocator:NULL];
   assert( tigerBitmap);

   app = [UIApplication sharedInstance];
   {
      window = create_window( tigerBitmap);
      assert( window);

      [app addWindow:window];
   }
   return( [app run]);
}

