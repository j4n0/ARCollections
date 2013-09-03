
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "Archiver.h"
#import "ARMapEntry.h"


/** Test for the NSArray(Functional) category. */
@interface ARMapEntryTest : SenTestCase
@end

@implementation ARMapEntryTest

-(void) testDescription {
    ARMapEntry *entry1 = [[ARMapEntry alloc] initWithKey:@"key" value:@"value"];
    STAssertTrue([[entry1 description] isEqualToString:@"{key,value}"],nil);
}

-(void) testIsEqual {
    ARMapEntry *entry1 = [[ARMapEntry alloc] initWithKey:@"key" value:@"value"];
    ARMapEntry *entry2 = [[ARMapEntry alloc] initWithKey:@"key" value:@"value"];
    STAssertTrue([entry1 isEqual:entry2], nil);
}

-(void) testCopy {
    ARMapEntry *entry1 = [[ARMapEntry alloc] initWithKey:@"key" value:@"value"];
    ARMapEntry *entry2 = [entry1 copy];
    STAssertTrue([entry1 isEqual:entry2], nil);
}

-(void) testCoding {
    ARMapEntry *entry1 = [[ARMapEntry alloc] initWithKey:@"key" value:@"value"];
    
    NSString * const filename = @"filename";
    NSString * const key = @"key";
    [Archiver archive:entry1 key:key filename:filename];
    ARMapEntry *entry2 = (ARMapEntry*)[Archiver unarchiveKey:key fromFilename:filename];
    
    STAssertTrue([entry1 isEqual:entry2], nil);
}

@end
