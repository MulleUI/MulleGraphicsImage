//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#import "CGImage+PNGWriter.h"

#import "import-private.h"

#import "CGImage+UIBitmapImage.h"



@implementation CGImage( PNGWriter)

- (BOOL) writeToPNGUTF8String:(char *) filename
{
   return( [[self bitmapImage] writeToPNGUTF8String:filename]);
}

@end


