#import "import.h"


#define UIImageDataEncodingVector  0x80

#define mulle_multichar_constant2( a, b)  \
   (((uint32_t) (a) << 8) | (uint32_t) (b))

#define mulle_multichar_constant3( a, b, c)                          \
     mulle_multichar_constant2( mulle_multichar_constant2( a, b), c)

#define mulle_multichar_constant4( a, b, c, d)                    \
    mulle_multichar_constant2( mulle_multichar_constant2( a, b),  \
                               mulle_multichar_constant2( c, d))

#define ui_bitmap_encoding3( a, b, c)   \
    mulle_multichar_constant3( a, b, c)

#define ui_vector_encoding3( a, b, c)   \
    mulle_multichar_constant3( a, b, (c) | UIImageDataEncodingVector)


typedef NS_ENUM( NSUInteger, UIImageDataEncoding)
{
   UIImageDataEncodingUnknown = 0,
   UIImageDataEncodingRGBA = ui_bitmap_encoding3( 'R', 'G', 'B'),    // unwrapped and uncompressed
   UIImageDataEncodingPNG  = ui_bitmap_encoding3( 'P', 'N', 'G'),
   UIImageDataEncodingJPG  = ui_bitmap_encoding3( 'J', 'P', 'G'),
   UIImageDataEncodingBMP  = ui_bitmap_encoding3( 'B', 'M', 'P'),

   UIImageDataEncodingSVG  = ui_vector_encoding3( 'S', 'V', 'G')
};


static inline int   UIImageDataEncodingIsBitmapFormat( UIImageDataEncoding encoding)
{
   return( ! (encoding & UIImageDataEncodingVector));
}


static inline int   UIImageDataEncodingIsVectorFormat( UIImageDataEncoding encoding)
{
   return( encoding & UIImageDataEncodingVector);
}


typedef UIImageDataEncoding   UIImageDataDetector( struct mulle_data data);

//
// An UIImage is an image loaded from a file or intended to be written into
// a file. It can retain the file data read or set, so in the event
// that UIImage returns fileData it will not compress again.
//
// If you want to load decoded bitmap data, use UIBitmapImage
// directly (see BitmapBytes method) and create an UIImage with it.
//
//
// UIImage is actually a classcluster. You get either a UIBitmapImage
// or a UISVGImage back (currently)
//
@interface UIImage : NSObject < CGDrawable, MulleObjCClassCluster>
{
   id                       _fileDataSharingObject;
   struct mulle_data        _fileData;
   struct mulle_allocator   *_fileDataAllocator;
   UIImageDataEncoding      _fileEncoding;
}

+ (instancetype) imageWithContentsOfFileCString:(char *) s;
+ (instancetype) imageWithFileCData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator;
+ (instancetype) imageWithFileCData:(struct mulle_data) data
                     sharingObject:(id) sharingObject;

- (instancetype) initWithContentsOfFileCString:(char *) s;

// if allocator is NULL, data will not be freed
// otherwise allocator will be used to free. Use &mulle_allocator_stdlib
// for malloced data
- (instancetype) initWithFileCData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator;

// data belongs to sharingObject, which will be retained
- (instancetype) initWithFileCData:(struct mulle_data) data
                     sharingObject:(id) sharingObject;


+ (void) addImageDataDetector:(UIImageDataDetector) detector;

//
// Textures (images) in NVG can be created with different flags, for example
// REPEAT_X andREPEAT_Y. When we are asking the CGContext for a imageID
// for an image this will create such a NVG texture. As the context cashes the
// imageID for each UIImage it's simplest to store the imageFlags here
// (readonly) and to clone UIImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
//

- (UIImageDataEncoding) fileEncoding;

@end


@interface UIImage( CGImageLayer)

- (Class) preferredLayerClass;

@end


UIImageDataEncoding   UIImageDataEncodingFromCData(struct mulle_data data);
