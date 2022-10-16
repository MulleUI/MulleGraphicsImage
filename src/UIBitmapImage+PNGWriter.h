//
// Copyright (c) 2020 Nat!, Mulle kybernetiK
//
#ifdef __has_include
# if __has_include( "UIBitmapImage.h")
#  import "UIBitmapImage.h"
# endif
#endif

// we want "import.h" always anyway
#import "import.h"

//
// Used for UITextView and MulleTextStorage. At this point we are
// moving to NSData and NSString use. Chances are good, that the whole text
// system moves into its own library, with different dependencies
// PNG writing is right on the border of both libraries though...
//
@interface UIBitmapImage( PNGWriter)

- (struct mulle_data) PNGCData; // autoreleases
- (BOOL) writeToPNGUTF8String:(char *) filename;

@end


@interface CGImage( PNGWriter)

- (BOOL) writeToPNGUTF8String:(char *) filename;

@end 
