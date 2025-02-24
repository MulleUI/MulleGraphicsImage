//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "CGImage.h")
#  import "CGImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"


@interface CGImage( PNGWriter)

- (BOOL) writeToPNGUTF8String:(char *) filename;

@end 
