#ifdef __has_include
# if __has_include( "UIImage.h")
#  import "UIImage.h"
# endif
#endif

#import "import.h"

struct NSVGimage;


//
// SVGImage keeps a copy of the original SVG by default (if available)
// subclass from MulleVectorImage
//
@interface MulleSVGImage : UIImage <CGVectorImage>
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
