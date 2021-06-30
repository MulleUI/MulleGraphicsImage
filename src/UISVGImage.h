#ifdef __has_include
# if __has_include( "UIImage.h")
#  import "UIImage.h"
# endif
#endif

#import "import.h"

struct NSVGimage;


//                            .------------.
//                            | CGDrawable |---.
//                            '------------'   |
//                                    |        |
//            .------------------.    |        |
//            | CGBitmapDrawable |<---'        |
//            '------------------'             |
//                      ^                      v
//                      |                 .------------------.
//                      |            .--->| CGVectorDrawable |
//            .------------------.   |    '------------------'
//       .--->| MulleBitmapImage |   |
//       |    '------------------'   |
//       |                           |
//   .---------.              .------------.
//   | UIImage |------------->| UISVGImage |
//   '---------'              '------------'
//
// SVGImage keeps a copy of the original SVG by default (if available).
//
@interface UISVGImage : UIImage <CGVectorDrawable>
{
   struct mulle_allocator   *_allocator;
}

@property( readonly) struct NSVGimage   *NSVGImage;

// svg encoded data
+ (instancetype) newWithFileCData:(struct mulle_data) data
                    sharingObject:(id) sharingObject
                        allocator:(struct mulle_allocator *) allocator;


// image will not be freed if allocator is NULL
- (instancetype) initWithNSVGImage:(struct NSVGimage *) image
                         allocator:(struct mulle_allocator *) allocator;

@end
