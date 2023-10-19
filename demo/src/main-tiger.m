#import "import-private.h"

#import <string.h>


// #define MULTI_THREADED
static char   tiger_data[] =
#include "Ghostscript_Tiger.svg.inc"
;
#define s_tiger_data  (sizeof( tiger_data) - 1)

// scale stuff for stream

static UIWindow  *create_window( void)
{
   CAImageLayer       *imageLayer;
   CGRect             frame;
   CGRect             windowFrame;
   CGRect             bounds;
   UIWindow           *window;
   UIView             *view;
   UIView             *contentView;
   UIButton           *button;
   UIScrollView       *scroller;
   UIImageView        *imageView;
   UIImage            *tigerImage;
   NSUInteger         styleMask;

   // WINDOW
   windowFrame = CGRectMake( 0.0, 200.0, 640, 400.0);

   styleMask  = UIWindowStyleMaskDefault;
   styleMask &= ~UIWindowStyleRetained;
   window = [UIWindow windowWithFrame:windowFrame
                      titleUTF8String:"Demo"
                            styleMask:styleMask];
   assert( window);

   [window setBackgroundColor:[UIColor yellowColor]];

   // BUTTON IN SCROLLVIEW

   tigerImage = [UIImage imageWithFileCData:mulle_data_make( tiger_data, s_tiger_data)
                                  allocator:NULL];
   if( ! tigerImage)
      abort();

   imageLayer = [CAImageLayer layerWithImage:tigerImage];
   imageView  = [UIImageView viewWithLayer:imageLayer];

   fprintf( stderr, "view: %p f=[%s] c=[%s]\n", 
                        imageView, 
                        CGRectUTF8String( [imageView frame]),
                        CGRectUTF8String( [imageView contentRect]));

   fprintf( stderr, "layer: %p f=[%s] c=[%s]\n", 
                        imageLayer, 
                        CGRectUTF8String( [imageLayer frame]),
                        CGRectUTF8String( [imageLayer canvas]));

   // SCROLLVIEW
   frame    = CGRectInset( windowFrame, 20.0, 20.0);
   scroller = [UIScrollView viewWithFrame:frame];
   [scroller setMargins:UIEdgeInsetsMake( 20.0, 20.0, 20.0, 20.0)];
   [scroller setAutoresizingMask:UIViewAutoresizingScaleToFill];
   [scroller setZoomEnabled:YES];
   [scroller setContentSize:[imageView frame].size];
   [[scroller contentView] addSubview:imageView];
   [[window contentView] addSubview:scroller];

   [window dump];
   return( window);
}



int   main( int argc, char *argv[])
{
   CGContext       *context;
   UIWindow        *window;
   UIApplication   *application;

   application = [UIApplication sharedInstance];

   // WINDOW
   window = create_window();
   assert( window);

   [application addWindow:window];
#ifdef MULTI_THREADED   
   [NSThread detachNewThreadSelector:@selector( runInApplication:)
                            toTarget:window
                          withObject:application];

   window = create_window( tigerBitmap, sealieBitmap);
   assert( window);
   [application addWindow:window];
   [NSThread detachNewThreadSelector:@selector( runInApplication:)
                            toTarget:window
                          withObject:application];
#else
   [application run];
#endif   
   return( 0);
}

