
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARLinkedListImpl.h"

@interface ARLinkedListTest : SenTestCase
@end

@implementation ARLinkedListTest

-(void) testStuff {
    ARLinkedListImpl *list = [ARLinkedListImpl new];
    
    // isEmpty
    STAssertTrue([list isEmpty],nil);
    
    // add
    [list addObject:@"A"];
    [list addObject:@"B"];
    [list addObject:@"C"];
    STAssertTrue([[list description]isEqualToString:@"ABC"], nil);
    
    // head
    STAssertTrue([(NSString*)[list objectAtIndex:0] isEqualToString:@"A"], nil);
    STAssertTrue([(NSString*)[list head].value isEqualToString:@"A"], nil);
    
    // count
    STAssertTrue([list count]==3,nil);
    
    // remove
    [list removeObjectAtIndex:[list count]-1];
    STAssertTrue([list count]==2,nil);
    STAssertTrue([(NSString*)[list tail].value isEqualToString:@"B"], [[list tail]description]);
    
    // insert
    [list insertObject:@"X" atIndex:1];
    STAssertTrue([[list description]isEqualToString:@"AXB"], nil);
    
    // fast enumeration
    NSMutableString *s = [NSMutableString new];
    for (NSString *string in list) {
        [s appendFormat:@"%@",string];
    }
    STAssertTrue([s isEqualToString:@"AXB"], nil);
    
}

@end
