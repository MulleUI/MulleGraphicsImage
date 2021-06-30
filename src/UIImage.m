#import "UIImage.h"

#import "UISVGImage.h"
#import "UIBitmapImage.h"

#import "import-private.h"

#include <unistd.h>  // for ssize_t


enum UIImageDataEncoding   UIImageDataEncodingFromCData(struct mulle_data data)
{
   // stb can't do this, because stbi__context is unavailable as are the
   // various test methods

   // https://en.wikipedia.org/wiki/Portable_Network_Graphics
   static uint8_t   png_header[] = { 0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0xA };
   uint8_t          *start;
   uint8_t          *end;

   if( data.length > sizeof( png_header) &&
      ! memcmp( data.bytes, png_header, sizeof( png_header)))
   {
      return( UIImageDataEncodingPNG);
   }

   // https://stackoverflow.com/questions/4550296/how-to-identify-contents-of-a-byte-is-a-jpeg
   if( data.length > 4)
   {

      if( ! strncmp( data.bytes, "<svg", 4))
         return( UIImageDataEncodingSVG);

      start = data.bytes;
      end   = &start[ data.length];
      if( start[ 0] == 0xFF && start[ 1] == 0xD8 &&
          end[ -2] == 0xFF && end[ -1] == 0xD9)
      {
         return( UIImageDataEncodingJPG);
      }

      if( start[ 0] == 'B' && start[ 1] == 'M')
         return( UIImageDataEncodingBMP);
   }

   return( UIImageDataEncodingUnknown);
}




@implementation UIImage( CGImageLayer)

#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

- (Class) preferredLayerClass
{
	return( [CAImageLayer class]);
}

@end


@implementation UIImage

- (instancetype) initWithFileCData:(struct mulle_data) data
                     sharingObject:(id) sharingObject
                         allocator:(struct mulle_allocator *) allocator
{
   // currently hardcoded: future plugin architecture for subclasses
   // don't have NSNotificationCenter here yet
   enum UIImageDataEncoding   encoding;

   encoding  = UIImageDataEncodingFromCData( data);
   if( encoding == UIImageDataEncodingSVG)
      return( [UISVGImage newWithFileCData:data
                                sharingObject:sharingObject
                                     allocator:allocator]);
   return( [UIBitmapImage newWithFileCData:data
                                sharingObject:sharingObject
                                    allocator:allocator]);
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


- (enum UIImageDataEncoding) fileEncoding
{
   return( _fileEncoding);
}

@end
