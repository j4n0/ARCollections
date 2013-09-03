
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARArrayList.h"
#import "ARStackList.h"

/** Test for the NSArray(Functional) category. */
@interface ARStackTest : SenTestCase
@end

@implementation ARStackTest


-(void) testBaseConversion
{
    __block id<ARStack>stack = [ARStackList new];
    void (^__block convert) (NSUInteger n,NSUInteger base);
    void (^__block __weak weakConvert) (NSUInteger n,NSUInteger base);
    weakConvert = convert = ^void(NSUInteger n, NSUInteger base){
        NSString *const digits = @"0123456789ABCDEF";
        if (n<base){
            [stack push:[digits substringWithRange:NSMakeRange(n,1)]];
        } else {
            [stack push:[digits substringWithRange:NSMakeRange(n%base,1)]];
            weakConvert(n/base,base);
        }
    };
    convert(1456,16);
    STAssertTrue( [[stack componentsJoinedByString:@""] isEqualToString:@"5B0"], nil);
}


#pragma mark - ARStack

-(void) testInit {
    id<ARStack> stacklist = [ARStackList new];
    STAssertTrue( ([stacklist count]==0), nil);
    STAssertTrue( ([stacklist peek]==nil), nil);
}

-(void) testInitWithARArrayList {
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    id<ARStack> sl = [[ARStackList alloc]initWithARList:array];
    STAssertTrue( ([sl count]==3), nil);
    id top = [sl peek];
    STAssertTrue( ([(NSNumber*)top isEqualToNumber:@3]), nil);
}

-(void) testPeek {
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    id<ARStack> sl = [[ARStackList alloc]initWithARList:array];
    STAssertTrue( ([(NSNumber*)[sl peek] isEqualToNumber:@3]), nil);
}

-(void) testPush {
    id<ARStack> sl = [ARStackList new];
    STAssertTrue( ([sl count]==0), nil);
    [sl push:@1];
    [sl push:@2];
    [sl push:@3];
    STAssertTrue( ([(NSNumber*)[sl peek] isEqualToNumber:@3]), nil);
    STAssertTrue( ([sl count]==3), nil);
}

-(void) testPop {
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    id<ARStack> sl = [[ARStackList alloc]initWithARList:array];
    STAssertTrue( ([(NSNumber*)[sl pop] isEqualToNumber:@3]), nil);
    STAssertTrue( ([(NSNumber*)[sl pop] isEqualToNumber:@2]), nil);
    STAssertTrue( ([(NSNumber*)[sl pop] isEqualToNumber:@1]), nil);
}


#pragma mark - ARStackList

-(void) testcreateWithNSArray {
    id<ARStack> stack = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([stack count]==3), nil);
    STAssertTrue([[stack description] isEqualToString:@"3,2,1"],[stack description]);
}


#pragma mark - NSObject

-(void) testDescription {
    id<ARStack> stack = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue([[stack description] isEqualToString:@"3,2,1"],[stack description]);
}

-(void) testIsEqual {
    id<ARStack> a = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    id<ARStack> b = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([a isEqual:b]) ,nil);
}

-(void) testIsEqualToARStackList {
    id<ARStack> a = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    id<ARStack> b = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue([a isEqualToARStack:b], nil);
}


#pragma mark - ARCollection

-(void) testCount {
    id<ARStack> sl = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([sl count]==3), nil);
}

-(void) testIsEmpty {
    id<ARStack> sl = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[]]];
    STAssertTrue( ([sl isEmpty]), nil);
}


#pragma mark - NSCopying

-(void) testCopyWithZone {
    ARArrayList *list = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    id<ARStack> ql = [[ARStackList alloc]initWithARList:list];
    id<ARStack> qlCopy = [ql copy];
    STAssertTrue( ([ql isEqual:qlCopy]), nil);
}


#pragma mark NSCoding

-(void) testEncodeWithCoder {
    id<ARStack> sl = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];

    NSString *key = @"key";
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:sl forKey:key];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    ARArrayList *decodedARArrayList = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];

    BOOL isEqual = [sl isEqual:decodedARArrayList];
    STAssertTrue(isEqual, nil);
}


#pragma mark NSFastEnumeration

-(void) testNSFastEnumeration {
    id<ARStack> sl = [[ARStackList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1,@2]]];
    BOOL check = true;
    for (id object in sl){
        check = check && ([object isEqualToNumber:@1] || [object isEqualToNumber:@2]);
    }
    STAssertTrue(check, nil);
}


@end
