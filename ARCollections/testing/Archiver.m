
// BSD License. Author: jano@jano.com.es

#import "Archiver.h"

@interface Archiver (Private)
+(NSString*) createDirectory;
@end

@implementation Archiver


/** Directory where serialized files are saved to. */
+(NSString*) directory {
    static NSString *directory = nil;
    if (directory==nil) directory = [self createDirectory];
    return directory;
}


/** Create the directory where serialized files are saved to. */
+(NSString*) createDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *libraryDir = [paths objectAtIndex:0];
    NSString *directory = [libraryDir stringByAppendingPathComponent:@"Serialization"];
    
    BOOL dirExist = [[NSFileManager defaultManager] fileExistsAtPath:directory];
    if (!dirExist){
        NSError *error;
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:&error];
    }
    
    trace(@"Data directory is ...%@", directory);
    return directory;
    
}


/**
 * Archive an object.
 *
 * @param object   Object to serialize. Must conform to NSCoding.
 * @param key      Key to use when serializing the object.
 * @param filename Name of the file the object will be serialized to.
 */
+ (void) archive:(id<NSCoding>)object key:(NSString*)key filename:(NSString*)filename
{
    NSString *path = [[Archiver directory] stringByAppendingPathComponent:filename];
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:object forKey:key];
    [archiver finishEncoding];
    [data writeToFile:path atomically:YES];
    trace(@"%@, %d bytes written",[data length]>0 ? @"Object archived" : @"Archiving failed",[data length]);
}


/**
 * Unarchive an object.
 *
 * @param key Key used when the object was serialized.
 * @param filename Name of the file where the object is serialized.
 * @return The object.
 */
+ (id<NSCoding>) unarchiveKey:(NSString*)key fromFilename:(NSString*)filename
{
    // create path
    NSString *path = [[Archiver directory] stringByAppendingPathComponent:filename];
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!exists){
        warn(@"Attempted to unarchive a missing file: %@", filename);
        return nil;
    }
    
    // unarchive
    NSData *codedData = [[NSData alloc] initWithContentsOfFile:path];
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:codedData];
    id<NSCoding,NSObject> object = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    
    return object;
}

@end

