
// BSD License. Author: jano@jano.com.es

@interface Archiver : NSObject
+ (NSString*) directory;
+ (void) archive:(id<NSCoding>) object
             key:(NSString*)    key
        filename:(NSString*)    filename;
+ (id<NSCoding>) unarchiveKey:(NSString*) key
                 fromFilename:(NSString*) filename;
@end

