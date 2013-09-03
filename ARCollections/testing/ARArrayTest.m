
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARArrayList.h"

typedef id (^map_t) (id object);


@interface Person : NSObject
@property(nonatomic,copy)NSString *name;
@end
@implementation Person
@end


/** Test for the NSARArray(Functional) category. */
@interface ARArrayTest : SenTestCase
@end

@implementation ARArrayTest

-(ARArrayList*)input {
    return [ARArrayList createWithNSArray:@[@1,@2,@3]];
}


#pragma mark - Block Iterators

- (void)testAnd
{
    ARArrayList *input = [self input];
    BOOL output = [input and:^BOOL(id object) {
        return [(NSNumber*)object intValue] % 2 == 0;
    }];
    STAssertFalse(output, nil);
}

- (void)testOr
{
    ARArrayList *input = [self input];
    BOOL output = [input or:^BOOL(id object) {
        return [(NSNumber*)object intValue] % 2 == 0;
    }];
    STAssertTrue(output, nil);
}

- (void)testEach
{
    ARArrayList *input = [self input];
    __block NSInteger max;
    [input each:^(id object) {
        if (max<[(NSNumber*)object intValue]){
            max = [(NSNumber*)object intValue];
        }
    }];
    STAssertTrue((max==3), @"should be 3");
    ARArrayList *list = [self input];
    STAssertThrows([list each:nil], nil);
}

- (void)testEachWithIndex
{
    ARArrayList *input = [self input];
    __block NSInteger max;
    const NSInteger size = [input count];
    [input eachWithIndex:^(id object, int index) {
        if (index==size-1) max = [(NSNumber*)object intValue];
    }];
    STAssertTrue((max==3), @"should be 3");
    STAssertThrows([[self input] eachWithIndex:nil], nil);
}

- (void)testFind
{
    ARArrayList *input = [self input];
    id output = [input find:^BOOL(id object) {
        return [(NSNumber*)object intValue] %2 == 0;
    }];
    STAssertTrue(([(NSNumber*)output isEqualToNumber:@2]), nil);
    STAssertThrows([[self input] find:nil], nil);
}

- (void)testHead
{
    ARArrayList *input = [self input];
    ARArrayList *output = [input head:2];
    STAssertTrue(([output isEqualToARArray:[ARArrayList createWithNSArray:@[@1,@2]]]), nil);
}

- (void)testMap
{
    ARArrayList *input = [self input];
    ARArrayList *output = [input map:^id(id object) {
        return [NSNumber numberWithInt:[(NSNumber*)object intValue]-1];
    }];
    STAssertTrue( ([output isEqualToARArray:[ARArrayList createWithNSArray:@[@0,@1,@2]]]), @"should be equal");
    STAssertThrows( ([[self input] map:nil]) , nil);
}

- (void)testPluck
{
    Person *person = [Person new];
    person.name = @"Alice";
    ARArrayList *input = [ARArrayList new];
    [input addObject:person];
    ARArrayList *result = [input pluck:@"name"];
    STAssertTrue(([(NSString*)[result lastObject] isEqualToString:@"Alice"]), nil);
    STAssertThrows([[self input] pluck:nil], nil);
}

- (void)testReduce
{
    ARArrayList *input = [self input];
    NSNumber *result = [input reduce:^(id a, id b){
        return [NSNumber numberWithInt:[a intValue]+[b intValue]];
    }];
    STAssertTrue(([result intValue]==6), @"should be 6");
    STAssertThrows([[self input] reduce:nil], nil);
}

- (void)testSplit
{
    ARArrayList *input = [ARArrayList createWithNSArray:@[ @1, @2, @3, @4, @5, @6, @7, @8 ]];
    ARArrayList *result = [input split:3];
    STAssertTrue( ([(ARArrayList*)[result objectAtIndex:0] isEqualToARArray:[ARArrayList createWithNSArray:@[@1,@2,@3]]]), nil );
    STAssertTrue( ([(ARArrayList*)[result objectAtIndex:1] isEqualToARArray:[ARArrayList createWithNSArray:@[@4,@5,@6]]]), nil );
    STAssertTrue( ([(ARArrayList*)[result objectAtIndex:2] isEqualToARArray:[ARArrayList createWithNSArray:@[@7,@8]]]), nil );
    result = [input split:0];
    STAssertTrue( ([result count]==0), nil);
}

- (void)testTail
{
    ARArrayList *input = [self input];
    ARArrayList *output = [input tail:2];
    STAssertTrue(([output isEqualToARArray:[ARArrayList createWithNSArray:@[@2,@3]]]), nil);
}

- (void)testUntil
{
    ARArrayList *input = [self input];
    [input until:^(id object) {
        BOOL result = [(NSNumber*)object intValue] %2 == 0;
        if (!result) NSLog(@"until %@",object);
        return result;
    }];
    STAssertThrows([[self input] until:nil], nil);
}

- (void)testWhere
{
    ARArrayList *input = [self input];
    ARArrayList *result = [input where:^BOOL(id object) {
        return [(NSNumber*)object intValue]%2==0;
    }];
    STAssertTrue(([result count]==1), nil);
    STAssertTrue( [[result firstObject] isEqualToNumber:@2], nil);
    STAssertThrows([[self input] where:nil], nil);
}


#pragma mark ARArray

-(void) testComponentsJoinedByString
{
    ARArrayList *array;
    NSString *result;
    
    array = [ARArrayList createWithNSArray:@[]];
    result = [array componentsJoinedByString:@","];
    STAssertTrue( [result isEqualToString:@""], @"it was %@", result);
    
    array = [ARArrayList createWithNSArray:@[@1]];
    result = [array componentsJoinedByString:@","];
    STAssertTrue( [result isEqualToString:@"1"], @"it was %@", result);
    
    array = [ARArrayList createWithNSArray:@[@1, @2]];
    result = [array componentsJoinedByString:@","];
    STAssertTrue( [result isEqualToString:@"1,2"], @"it was %@", result);
    
    array = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    result = [array componentsJoinedByString:@","];
    STAssertTrue( [result isEqualToString:@"1,2,3"], @"it was %@", result);
}

-(void) testCreateWithNSArray
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    id first = [array firstObject];
    id last = [array lastObject];
    STAssertTrue( (array.count == 3), nil);
    STAssertTrue( [array.firstObject isEqualToNumber:first], nil);
    STAssertTrue( [array.lastObject isEqualToNumber:last], nil);
    STAssertTrue( [[array description] isEqualToString:@"1,2,3"], nil);
}

-(void) testInitWithARArray
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    STAssertTrue( array.count ==3, nil);
    STAssertTrue( [array.firstObject isEqualToNumber:@1], nil);
    STAssertTrue( [array.lastObject isEqualToNumber:@3], nil);
    STAssertTrue( [[array description] isEqualToString:@"1,2,3"], nil);
}

-(void) testReverseARARArray
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    ARArrayList *newArray = [array inverseARArray];
    STAssertTrue( [[newArray description] isEqualToString:@"3,2,1"], nil);
}

-(void) testCreateUsingBlock
{
    //  (take 25 (squares-of (integers)))
    generator_t integers = ^id(NSUInteger index) {
        return [NSNumber numberWithLong:index+1];
    };
    
    map_t squaresOf = ^id(id object) {
        long n = [(NSNumber*)object longValue];
        return [NSNumber numberWithLong:n*n];
    };
    ARArrayList *result = [[ARArrayList create:25 usingBlock:integers] map:squaresOf];
    STAssertTrue([[result lastObject] longValue]==(25*25), @"%ld",[[result lastObject] longValue]);
}

#pragma mark List

-(void) testInit
{
    ARArrayList *array = [ARArrayList new];
    STAssertTrue( ([array count] == 0), nil);
    STAssertTrue( ([array firstObject] == nil), nil);
    STAssertTrue( ([array lastObject] == nil), nil);
}

-(void) testInitWithARList
{
    ARArrayList *onetwothree = [ARArrayList createWithNSArray:@[@1, @2, @3]];
    ARArrayList *array = [[ARArrayList alloc] initWithARList:onetwothree];
    id first = [array firstObject];
    id last = [array lastObject];
    STAssertTrue( ([array count] == 3), nil);
    STAssertTrue( [[array firstObject] isEqualToNumber:first], nil);
    STAssertTrue( [[array lastObject] isEqualToNumber:last], nil);
    STAssertTrue( [[array description] isEqualToString:@"1,2,3"], nil);
}


#pragma mark Insert

-(void) testInsertObjectAtIndex
{
    ARArrayList *array = [ARArrayList new];
    id one = @1;
    [array insertObjectAtBeginning:one];
    id two = @2;
    [array insertObject:two atIndex:0];
    STAssertTrue( ([array count]==2), nil);
    STAssertTrue( ([[array firstObject] isEqualToNumber:two]), nil);
    STAssertTrue( ([[array lastObject] isEqualToNumber:one]), nil);
}

-(void) testInsertObjectAtBeginning
{
    ARArrayList *array = [ARArrayList new];
    id object = @1;
    [array insertObjectAtBeginning:object];
    STAssertTrue( ([array count]==1),nil);
    STAssertTrue( ([[array firstObject] isEqualToNumber:object]), nil);
    STAssertTrue( ([[array lastObject] isEqualToNumber:object]), nil);
}


-(void) testInsertObjectAtEnd
{
    ARArrayList *array = [ARArrayList new];
    id object = @1;
    [array insertObjectAtEnd:object];
    STAssertTrue( ([array count] == 1), nil);
    STAssertTrue( ([[array firstObject] isEqualToNumber:object]), nil);
    STAssertTrue( ([[array lastObject] isEqualToNumber:object]), nil);
}


#pragma mark Replace

-(void) testSetObjectAtIndex
{
    ARArrayList *array = [ARArrayList new];
    id one = @1;
    [array insertObjectAtEnd:one];
    id two = @2;
    [array setObject:two atIndex:0];
    STAssertTrue( ([array count] == 1), nil);
    STAssertTrue( ([[array firstObject] isEqualToNumber:two]), nil);
}


#pragma mark Retrieve

-(void) testFirstObject
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2]];
    STAssertTrue( ([array count] == 2), nil);
    STAssertTrue( ([[array firstObject] isEqualToNumber:@1]), nil);
}


-(void) testLastObject
{
    id one = @1;
    ARArrayList *array = [ARArrayList createWithNSArray:@[one, @2]];
    STAssertTrue( ([array count] == 2), nil);
    STAssertTrue( ([[array firstObject] isEqualToNumber:one]), nil);
}


-(void) testObjectAtIndex
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2]];
    STAssertTrue( ([array count] == 2), nil);
    STAssertTrue( ([[array objectAtIndex:1] isEqualToNumber:@2]), nil);
    STAssertThrows( [[ARArrayList new]objectAtIndex:1000], nil);
}


#pragma mark Remove

-(void) testRemoveAllObjects
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2]];
    [array removeAllObjects];
    STAssertTrue( ([array count] == 0), nil);

    array = [ARArrayList createWithNSArray:@[]];
    [array removeAllObjects];
    STAssertTrue( ([array count]==0), nil);
}


-(void) testRemoveFirstObject
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2]];
    id firstObject = [array removeFirstObject];
    STAssertTrue( ([[array firstObject] isEqualToNumber:@2]), nil);

    STAssertTrue( [firstObject isEqualToNumber:@1], nil);
    STAssertTrue( ([array count] == 1), nil);
    STAssertTrue( [[array objectAtIndex:0] isEqualToNumber:@2], nil);

    array = [ARArrayList createWithNSArray:@[]];
    firstObject = [array removeFirstObject];
    STAssertTrue( (firstObject == nil), nil);
}


-(void) testRemoveLastObject
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2]];
    id lastObject = [array removeLastObject];
    STAssertTrue( [lastObject isEqualToNumber:@2], nil);
    STAssertTrue( ([array count] == 1), nil);
    STAssertTrue( [[array objectAtIndex:0] isEqualToNumber:@1], nil);

    array = [ARArrayList createWithNSArray:@[]];
    id firstObject = [array removeFirstObject];
    STAssertTrue( (firstObject == nil) ,nil);
}


-(void) testRemoveObjectAtIndex
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1, @2]];
    STAssertTrue( [[array removeObjectAtIndex:0] isEqualToNumber:@1], nil);
    STAssertTrue( ([array count] == 1), nil);
    STAssertTrue( ([[array objectAtIndex:0] isEqualToNumber:@2]), nil);

    STAssertThrows([[ARArrayList new]removeObjectAtIndex:1000], nil);
}


#pragma mark NSCopying

-(void) testCopyWithZone
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    ARArrayList *copy = [array copy];
    STAssertTrue( [array isEqualToARArray:copy], nil);
}


#pragma mark NSCoding

-(void) testEncodeWithCoder
{
    ARArrayList *array = [ARArrayList createWithNSArray:@[@1,@2,@3]];
    
    NSString *key = @"key";
    
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:array forKey:key];
    [archiver finishEncoding];
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    ARArrayList *decodedARArrayList = [unarchiver decodeObjectForKey:key];
    [unarchiver finishDecoding];
    
    BOOL isEqual = [array isEqualToARArray:decodedARArrayList];
    STAssertTrue(isEqual, nil);
}


#pragma mark NSObject

-(void) testDescription
{
    ARArrayList *array = [ARArrayList new];
    id one = @1;
    [array insertObjectAtBeginning:one];
    id two = @2;
    [array insertObjectAtBeginning:two];
    STAssertTrue( ([[array description] length]==3), nil);
}


#pragma mark NSFastEnumeration

-(void) testNSFastEnumeration
{
    ARArrayList *array = [ARArrayList new];
    id one = @1;
    [array insertObjectAtBeginning:one];
    id two = @2;
    [array insertObjectAtBeginning:two];
    BOOL check = true;
    for (id object in array){
        check = check && (object==one || object==two);
    }
    STAssertTrue(check, nil);
}

                        
@end
