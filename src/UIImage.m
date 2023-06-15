#import "UIImage.h"

#import "UISVGImage.h"
#import "UIBitmapImage.h"

#import "import-private.h"

#include <unistd.h>  // for ssize_t


static UIImageDataEncoding  png_detector( struct mulle_data data)
{
   // https://en.wikipedia.org/wiki/Portable_Network_Graphics
   static uint8_t   png_header[] = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0xA };

   if( data.length > sizeof( png_header) &&
      ! memcmp( data.bytes, png_header, sizeof( png_header)))
   {
      return( UIImageDataEncodingPNG);
   }
   return( UIImageDataEncodingUnknown);
}


static UIImageDataEncoding   svg_detector( struct mulle_data data)
{
   if( data.length >= 40)
   {
      if( ! strncmp( data.bytes, "<svg", 4))
         return( UIImageDataEncodingSVG);
   }
   return( UIImageDataEncodingUnknown);
}

static UIImageDataEncoding   jpg_detector( struct mulle_data data)
{
   uint8_t          *start;
   uint8_t          *end;

   start = data.bytes;
   end   = &start[ data.length];

   if( data.length >= 100)
   {
      if( start[ 0] == 0xFF && start[ 1] == 0xD8 &&
            end[ -2] == 0xFF && end[ -1] == 0xD9)
      {
         return( UIImageDataEncodingJPG);
      }
   }
   return( UIImageDataEncodingUnknown);
}

static UIImageDataEncoding   bmp_detector( struct mulle_data data)
{
   uint8_t   *start;

   start = data.bytes;

   if( data.length >= 32)
   {
      if( start[ 0] == 'B' && start[ 1] == 'M')
         return( UIImageDataEncodingBMP);
   }
   return( UIImageDataEncodingUnknown);
}


#pragma clang diagnostic ignored "-Wprotocol"


@implementation UIImage

struct decoder_entry
{
   UIImageDataDetector   *detector;  // function pointer, so wrap in struct for oneriness
};


static struct
{
   struct mulle__structarray  _detectors;
   struct mulle__pointermap   _encodingMap;
} Self ;


+ (void) load
{
   struct mulle_allocator  *allocator;
   struct decoder_entry    entry;

   allocator = MulleObjCClassGetAllocator( self);

   _mulle__structarray_init( &Self._detectors,
                             sizeof( struct decoder_entry),
                             alignof( struct decoder_entry),
                             16,
                             allocator);
   _mulle__pointermap_init( &Self._encodingMap,
                            16,
                            allocator);

   entry.detector = png_detector;
   _mulle__structarray_add( &Self._detectors, &entry, allocator);
   entry.detector = svg_detector;
   _mulle__structarray_add( &Self._detectors, &entry, allocator);
   entry.detector = jpg_detector;
   _mulle__structarray_add( &Self._detectors, &entry, allocator);
   entry.detector = bmp_detector;
   _mulle__structarray_add( &Self._detectors, &entry, allocator);
}


+ (void) unload
{
   struct mulle_allocator  *allocator;

   allocator = MulleObjCClassGetAllocator( self);

   _mulle__structarray_done( &Self._detectors, allocator);
   _mulle__pointermap_done( &Self._encodingMap, allocator);
}


+ (void) addImageDataDetector:(UIImageDataDetector) detector
{
   struct decoder_entry     entry;
   struct mulle_allocator   *allocator;

   if( ! detector)
      return;

   allocator = MulleObjCInstanceGetAllocator( self);
   entry.detector = detector;
   _mulle__structarray_add( &Self._detectors, &entry, allocator);
}


UIImageDataEncoding   UIImageDataEncodingFromCData( struct mulle_data data)
{
   struct decoder_entry  *entry;
   UIImageDataEncoding   encoding;

   encoding = UIImageDataEncodingUnknown;
   mulle__structarray_for( &Self._detectors, entry)
   {
      encoding = (*entry->detector)( data);
      if( encoding != UIImageDataEncodingUnknown)
         break;
   }
   return( encoding);
}



+ (void) registerClass:(Class) cls
        forDataEncoding:(UIImageDataEncoding) encoding
{
   struct mulle_allocator   *allocator;

   allocator = MulleObjCInstanceGetAllocator( self);
   mulle__pointermap_set( &Self._encodingMap,
                          (void *) encoding,
                          cls,
                          allocator);
}


+ (Class) classForDataEncoding:(UIImageDataEncoding) encoding
{
   Class    cls;

   cls = mulle__pointermap_get( &Self._encodingMap, (void *) encoding);
   if( cls)
      return( cls);

   switch( encoding)
   {
   case UIImageDataEncodingBMP :
   case UIImageDataEncodingJPG :
   case UIImageDataEncodingPNG : return( [UIBitmapImage class]);
   case UIImageDataEncodingSVG : return( [UISVGImage class]);
   default                     : return( nil);
   }
}


- (instancetype) initWithFileCData:(struct mulle_data) data
                     sharingObject:(id) sharingObject
                         allocator:(struct mulle_allocator *) allocator
{
   // currently hardcoded: future plugin architecture for subclasses
   // don't have NSNotificationCenter here yet
   UIImageDataEncoding   encoding;
   Class                 cls;

   encoding = UIImageDataEncodingFromCData( data);
   if( encoding == UIImageDataEncodingUnknown)
   {
      fprintf( stderr, "Can't figure out data format for image\n");
      [self release];
      return( nil);
   }

   cls = [[self class] classForDataEncoding:encoding];
   // TODO: rename to UIVectorImage
   return( [cls newWithFileCData:data
                   sharingObject:sharingObject
                       allocator:allocator]);
}


+ (instancetype) imageWithFileCData:(struct mulle_data) data
                          allocator:(struct mulle_allocator *) allocator
{
   return( [[[self alloc] initWithFileCData:data 
                                  allocator:allocator] autorelease]);
}  


+ (instancetype) imageWithFileCData:(struct mulle_data) data
                      sharingObject:(id) sharingObject
{
   return( [[[self alloc] initWithFileCData:data 
                              sharingObject:sharingObject] autorelease]);
}  


- (instancetype) initWithFileCData:(struct mulle_data) data
                         allocator:(struct mulle_allocator *) allocator
{
   return( [self initWithFileCData:data
                     sharingObject:nil
                         allocator:allocator]);
}


- (instancetype) initWithFileCData:(struct mulle_data) data
                     sharingObject:(id) sharingObject
{
   return( [self initWithFileCData:data
                     sharingObject:sharingObject
                         allocator:NULL]);
}


+ (instancetype) imageWithContentsOfFileCString:(char *) s
{
   return( [[[self alloc] initWithContentsOfFileCString:s] autorelease]);
}


- (instancetype) initWithContentsOfFileCString:(char *) filename
{
   FILE                     *fp;
	ssize_t                  actual_length;
   struct mulle_data        data;
   struct mulle_allocator   *allocator;

	fp = fopen( filename, "r");
	if( ! fp)
   {
//      [self release];  // classcluster, not needed
      return( nil);
   }

   fseek( fp, 0, SEEK_END);
   data.length   = ftell( fp);
   fseek( fp, 0, SEEK_SET);
   allocator     = MulleObjCInstanceGetAllocator( self);
   data.bytes    = mulle_allocator_malloc( allocator, data.length);
	actual_length = fread( data.bytes, 1, data.length, fp);
   fclose( fp);

   if( actual_length != data.length)
   {
//      [self release];  // classcluster, not needed
      return( nil);
   }

   return( [self initWithFileCData:data
                     sharingObject:nil
                         allocator:allocator]);
}


- (void) dealloc
{
   [_fileDataSharingObject release];
   if( _fileDataAllocator)
      mulle_allocator_free( _fileDataAllocator, _fileData.bytes);

   [super dealloc];
}


- (void) clearData
{
   if( _fileDataAllocator)
      mulle_allocator_free( _fileDataAllocator, _fileData.bytes);
   _fileData = mulle_data_make( 0, 0);
}


- (UIImageDataEncoding) fileEncoding
{
   return( _fileEncoding);
}

@end


#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation UIImage( CGImageLayer)

- (Class) preferredLayerClass
{
   return( [CAImageLayer class]);
}

@end
