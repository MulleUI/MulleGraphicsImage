#import "import.h"


// currently supported types, not very dynamically expandable (yet)...
enum UIImageDataEncoding
{
   UIImageDataEncodingUnknown = 0,
   UIImageDataEncodingRGBA,    // unwrapped and uncompressed
   UIImageDataEncodingPNG,
   UIImageDataEncodingJPG,
   UIImageDataEncodingBMP,
   UIImageDataEncodingSVG
};

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
   id                         _fileDataSharingObject;
   struct mulle_data          _fileData;
   struct mulle_allocator     *_fileDataAllocator;
   enum UIImageDataEncoding   _fileEncoding;
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


//
// Textures (images) in NVG can be created with different flags, for example
// REPEAT_X andREPEAT_Y. When we are asking the CGContext for a imageID
// for an image this will create such a NVG texture. As the context cashes the
// imageID for each UIImage it's simplest to store the imageFlags here
// (readonly) and to clone UIImages for different flags. The actual image
// data can be shared w/o a problem. The default is 0:
//

- (enum UIImageDataEncoding) fileEncoding;

@end



enum UIImageDataEncoding   UIImageDataEncodingFromCData(struct mulle_data data);
