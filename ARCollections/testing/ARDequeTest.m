
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARArrayList.h"
#import "ARDequeList.h"

/** Test for the NSArray(Functional) category. */
@interface ARDequeTest : SenTestCase
@end

@implementation ARDequeTest

-(void) testPalindrome {
    NSString *radar = @"radar";
    id<ARDeque>deque = [ARDequeList new];
    for (NSUInteger i=0; i<[radar length]; i++) {
        NSRange range = NSMakeRange(i, 1);
        [deque addFront:[radar substringWithRange:range]];
    }
    BOOL isPalindrome = YES;
    while ([deque count]>1){
        NSString *a = [deque removeFront];
        NSString *b = [deque removeRear];
        isPalindrome &= [a isEqualToString:b];
    }
    STAssertTrue(isPalindrome, @"should be true");
}


#pragma mark - Deque

-(void) testInitWithARList {
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    id<ARDeque> sl = [[ARDequeList alloc]initWithARList:array];
    STAssertTrue( ([sl count]==3), nil);
    id top = [sl removeFront];
    STAssertTrue( ([(NSNumber*)top isEqualToNumber:@1]), nil);
}

-(void) testAddFront {
    id<ARDeque> sl = [ARDequeList new];
    STAssertTrue( ([sl count]==0), nil);
    [sl addFront:@1];
    [sl addFront:@2];
    [sl addFront:@3];
    STAssertTrue( ([(NSNumber*)[sl removeFront] isEqualToNumber:@3]), nil);
    STAssertTrue( ([sl count]==2), nil);
}

-(void) testRemoveFront {
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    id<ARDeque> sl = [[ARDequeList alloc]initWithARList:array];
    STAssertTrue( ([(NSNumber*)[sl removeFront] isEqualToNumber:@1]), nil);
    STAssertTrue( ([(NSNumber*)[sl removeFront] isEqualToNumber:@2]), nil);
    STAssertTrue( ([(NSNumber*)[sl removeFront] isEqualToNumber:@3]), nil);
}

-(void) testAddRear {
    id<ARDeque> sl = [ARDequeList new];
    STAssertTrue( ([sl count]==0), nil);
    [sl addRear:@1];
    [sl addRear:@2];
    [sl addRear:@3];
    STAssertTrue( ([(NSNumber*)[sl removeRear] isEqualToNumber:@3]), nil);
    STAssertTrue( ([sl count]==2), nil);
}

-(void) testRemoveRear {
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    id<ARDeque> sl = [[ARDequeList alloc]initWithARList:array];
    STAssertTrue( ([(NSNumber*)[sl removeRear] isEqualToNumber:@3]), nil);
    STAssertTrue( ([(NSNumber*)[sl removeRear] isEqualToNumber:@2]), nil);
    STAssertTrue( ([(NSNumber*)[sl removeRear] isEqualToNumber:@1]), nil);
}

#pragma mark ARStackList

-(void) testcreateWithNSArray {
    id<ARDeque> stack = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([stack count]==3), nil);
    STAssertTrue([[stack description] isEqualToString:@"1,2,3"],[stack description]);
}


#pragma mark NSObject

-(void) testDescription {
    id<ARDeque> stack = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue([[stack description] isEqualToString:@"1,2,3"],[stack description]);
}

-(void) testIsEqual {
    id<ARDeque> a = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    id<ARDeque> b = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([a isEqual:b]) ,nil);
}

-(void) testIsEqualToARDeque {
    id<ARDeque> a = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    id<ARDeque> b = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue([a isEqualToARDeque:b], nil);
}


#pragma mark ARContainer

-(void) testInit {
    id<ARDeque> stacklist = [ARDequeList new];
    STAssertTrue( ([stacklist count]==0), nil);
    STAssertTrue( ([stacklist removeFront]==nil), nil);
}

-(void) testCount {
    id<ARDeque> sl = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([sl count]==3), nil);
}

-(void) testIsEmpty {
    id<ARDeque> sl = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[]]];
    STAssertTrue( ([sl isEmpty]), nil);
}


#pragma mark NSCopying

-(void) testCopyWithZone {
    ARArrayList *list = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    id<ARDeque> ql = [[ARDequeList alloc]initWithARList:list];
    id<ARDeque> qlCopy = [ql copy];
    STAssertTrue( ([ql isEqual:qlCopy]), nil);
}


#pragma mark NSCoding

-(void) testEncodeWithCoder {
    id<ARDeque> sl = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];

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
    id<ARDeque> sl = [[ARDequeList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1,@2]]];
    BOOL check = true;
    for (id object in sl){
        check = check && ([object isEqualToNumber:@1] || [object isEqualToNumber:@2]);
    }
    STAssertTrue(check, nil);
}


@end
