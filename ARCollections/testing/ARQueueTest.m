
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARArrayList.h"
#import "ARQueueList.h"

/** Test for the QueueTest. */
@interface ARQueueTest : SenTestCase
@end

@implementation ARQueueTest

-(void) testcreateWithNSArray {
    ARQueueList *queueList = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue(([queueList count]==3), nil);
    STAssertTrue( ([[queueList description] isEqualToString:@"1,2,3"]), [queueList description]);
}


#pragma mark NSObject

-(void) testDescription {
    ARQueueList *queueList = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([[queueList description] length]==5), nil);
}


#pragma mark Queue

-(void) testInit {
    ARQueueList *queueList = [ARQueueList new];
    STAssertTrue(([queueList count]==0), nil);
    STAssertTrue( ([queueList peek]==nil), nil);
}


-(void) testInitWithArrayARList {
    ARQueueList *ql = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue( ([[ql description] isEqualToString:@"1,2,3"]), [ql description]);
    STAssertTrue(([ql count]==3), nil);
    STAssertTrue( ([[ql dequeue] isEqualToNumber:@1]), nil);
    STAssertTrue(([ql count]==2), nil);
    STAssertTrue( ([[ql dequeue] isEqualToNumber:@2]), nil);
    STAssertTrue(([ql count]==1), nil);
    STAssertTrue( ([[ql dequeue] isEqualToNumber:@3]), nil);
    STAssertTrue(([ql count]==0), nil);
}

-(void) testDequeue {
    ARQueueList *ql = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue(([ql count]==3), nil);
    STAssertTrue( ([[ql dequeue] isEqualToNumber:@1]), nil);
    STAssertTrue(([ql count]==2), nil);
    STAssertTrue( ([[ql dequeue] isEqualToNumber:@2]), nil);
    STAssertTrue(([ql count]==1), nil);
    STAssertTrue( ([[ql dequeue] isEqualToNumber:@3]), nil);
    STAssertTrue(([ql count]==0), nil);
}

-(void) testEnqueue {
    ARQueueList *ql = [ARQueueList new];
    STAssertTrue(([ql count]==0), nil);
    [ql enqueue:@1];
    STAssertTrue( ([[ql peek] isEqualToNumber:@1]), nil);
    STAssertTrue(([ql count]==1), nil);
    [ql enqueue:@2];
    [ql enqueue:@3];
    STAssertTrue(([ql count]==3), nil);
}

-(void) testPeek {
    ARQueueList *ql = [ARQueueList new];
    STAssertTrue(([ql count]==0), nil);
    [ql enqueue:@1];
    STAssertTrue( ([[ql peek] isEqualToNumber:@1]), nil);
    STAssertTrue(([ql count]==1), nil);
}


#pragma mark Collection

-(void) testCount {
    ARQueueList *ql = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    STAssertTrue(([ql count]==3), nil);
}

-(void) testEmpty {
    ARQueueList *ql = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[]]];
    STAssertTrue( ([ql isEmpty]), nil);
}


#pragma mark NSCopying

-(void) testCopyWithZone {
    ARArrayList *list = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    ARQueueList *ql = [[ARQueueList alloc]initWithARList:list];
    ARQueueList *qlCopy = [ql copy];
    STAssertTrue( ([ql isEqual:qlCopy]), nil);
}


#pragma mark NSCoding

-(void) testEncodeWithCoder {
    ARQueueList *ql = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2, @3]]];
    
    NSString *key = @"key";
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:ql forKey:key];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    ARQueueList *decodedQueue = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    
    BOOL isEqual = [ql isEqual:decodedQueue];
    STAssertTrue(isEqual, nil);
}


#pragma mark NSFastEnumeration

-(void) testNSFastEnumeration {
    ARQueueList *ql = [[ARQueueList alloc ]initWithARList:[ARArrayList createWithNSArray:@[@1, @2]]];
    BOOL check = true;
    for (id object in ql){
        check = check && ([object isEqualToNumber:@1] || [object isEqualToNumber:@2]);
    }
    STAssertTrue(check, nil);
}


@end
