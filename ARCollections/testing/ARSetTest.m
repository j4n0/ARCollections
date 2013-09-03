
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARSetImpl.h"
#import "ARArrayList.h"

@interface CarS : NSObject
@property(nonatomic,copy)NSString *name;
@end
@implementation CarS
-(NSString*)description {
    return _name;
}
@end


// Test for the DictionaryTest
@interface ARSetTest : SenTestCase
@end

@implementation ARSetTest

-(void) testAllObjects
{
    ARSetImpl *set = [ARSetImpl new];
    [set addObject:@"turtle"];
    [set addObject:@"lagoon"];
    ARArrayList *values = [set allObjects];
    STAssertTrue([[values componentsJoinedByString:@","] isEqualToString:@"turtle,lagoon"], nil);
}

-(void) testInitWithData {
    
    ARSetImpl *set = [ARSetImpl new];
    [set addObject:@"turtle"];
    
    ARSetImpl *dic2 = [[ARSetImpl alloc] initWithData:[set bytes]];
    STAssertTrue([[dic2 description] isEqualToString:@"turtle"], [dic2 description]);
}


-(void) testFastEnumeration
{
    // create dictionary
    ARSetImpl *set = [[ARSetImpl alloc] initWithCapacity:5];
    NSArray *array = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@0];
    for (id value in array){
        [set addObject:value];
    }
    
    STAssertTrue([set member:@1]!=nil, nil);
    STAssertTrue([set member:@0]!=nil, nil);
}


// addentry, removeEntry, count, description
-(void) testRemoveCountDescription
{
    ARSetImpl *set = [[ARSetImpl alloc] initWithCapacity:0];
    NSObject *object = @1;
    
    // remove non existant entry at capacity 0
    [set removeObject:object];
    STAssertTrue([set count]==0, nil);
    
    // add entry at capacity 0
    [set addObject:object];
    STAssertTrue([set count]==1, nil);
    
    // remove the only entry
    [set removeObject:object];
    STAssertTrue([set count]==0, nil);
    
    // add same entry twice
    [set addObject:object];
    [set addObject:object];
    STAssertTrue([set count]==1, nil);
    
    NSString *s = [set description];
    STAssertTrue([s isEqualToString:@"1"], s);
}


-(void) testDescription
{
    ARSetImpl *set = [[ARSetImpl alloc] initWithCapacity:0];
    NSObject<NSCopying> *object;
    
    object = @1;
    [set addObject:object];
    STAssertTrue([set count]==1,nil);
    
    object = @2;
    [set addObject:object];
    STAssertTrue([set count]==2,nil);
    
    object = @3;
    [set addObject:object];
    STAssertTrue([set count]==3,nil);
    
    object = @4;
    [set addObject:object];
    STAssertTrue([set count]==4,nil);
    
    NSString *s = [set description];
    STAssertTrue([s isEqualToString:@"4,1,2,3"], s);
}


-(void) testCopy1
{
    ARSetImpl *set1 = [[ARSetImpl alloc] initWithCapacity:0];
    [set1 addObject:@1];
    [set1 addObject:@2];
    ARSetImpl *set2 = [set1 copy];
    STAssertTrue([set1 isEqual:set2], nil);
}

-(void) testCopy2
{
    ARSetImpl *set1 = [[ARSetImpl alloc] initWithCapacity:0];
    ARSetImpl *set2 = [set1 copy];
    STAssertTrue([set1 isEqual:set2], nil);
}

-(void) testCopy3
{
    ARSetImpl *set1 = [[ARSetImpl alloc] initWithCapacity:10];
    [set1 addObject:@1];
    [set1 addObject:@2];
    [set1 addObject:@3];
    ARSetImpl *set2 = [set1 copy];
    STAssertTrue([set1 isEqual:set2], nil);
}


#pragma mark - Block Iterators

-(ARSetImpl*) input {
    ARSetImpl *dic = [[ARSetImpl alloc] initWithCapacity:3];
    [dic addObject:@1];
    [dic addObject:@2];
    [dic addObject:@3];
    return dic;
}


- (void) testAnd
{
    // not all are multiples of 2
    ARSetImpl *input = [self input];
    BOOL test = [input and:^BOOL(NSObject<NSCopying> *object) {
        return [(NSNumber*)object intValue] % 2 == 0;
    }];
    STAssertFalse(test, nil);
    
    // not all are less than 4
    test = [input and:^BOOL(NSObject<NSCopying> *object) {
        return [(NSNumber*)object intValue] < 4;
    }];
    STAssertTrue(test, nil);
}


- (void) testOr
{
    // at least one is multiple of 2
    ARSetImpl *input = [self input];
    BOOL test = [input or:^BOOL(NSObject<NSCopying> *object) {
        return [(NSNumber*)object intValue] % 2 == 0;
    }];
    STAssertTrue(test, nil);
}


- (void) testEach
{
    ARSetImpl *input = [self input];
    __block NSInteger max;
    [input each:^(NSObject<NSCopying> *object) {
        if (max<[(NSNumber*)object intValue]){
            max = [(NSNumber*)object intValue];
        }
    }];
    STAssertTrue((max==3), @"should be 3");
    STAssertThrows([[self input] each:nil], nil);
}


- (void) testFind
{
    ARSetImpl *input = [self input];
    NSObject<NSCopying> *object = [input find:^BOOL(NSObject<NSCopying> *object) {
        return [(NSNumber*)object intValue] %2 == 0;
    }];
    STAssertTrue(([(NSNumber*)object isEqualToNumber:@2]), nil);
    STAssertThrows([[self input] find:nil], nil);
}


- (void) testMap
{
    ARSetImpl *input = [self input];
    ARSetImpl *dic1 = [input map:^id(NSObject<NSCopying> *object) {
        NSNumber *n = [NSNumber numberWithInt:[(NSNumber*)object intValue]-1];
        return n;
    }];
    
    ARSetImpl *dic2 = [[ARSetImpl alloc] initWithCapacity:10];
    [dic2 addObject:@0];
    [dic2 addObject:@1];
    [dic2 addObject:@2];
    
    // NSLog(@"dic1: %@",dic1);
    // NSLog(@"dic2: %@",dic2);
    
    STAssertTrue( ([dic1 isEqualToARSet:dic2]), @"should be equal");
    STAssertThrows( ([[self input] map:nil]) , nil);
}


- (void) testPluck
{
    CarS *car = [CarS new];
    car.name = @"Ford Bronco";
    ARSetImpl *input = [ARSetImpl new];
    [input addObject:car];
    ARSetImpl *result = [input pluck:@"name"];
    [result addObject:car];
    CarS *object = (CarS *)[result member:car];
    STAssertTrue([@"Ford Bronco" isEqualToString:[object description]], nil);
    STAssertThrows([[self input] pluck:nil], nil);
}


- (void)testSplit
{
    ARSetImpl *input = [self input];
    
    ARArrayList *result = [input split:3];
    STAssertTrue( ([(ARSetImpl*)[result objectAtIndex:0] count]==1), nil );
    STAssertTrue( ([(ARSetImpl*)[result objectAtIndex:1] count]==1), nil );
    STAssertTrue( ([(ARSetImpl*)[result objectAtIndex:2] count]==1), nil );
    
    result = [input split:0];
    STAssertTrue( ([result count]==0), nil);
}


- (void) testWhere
{
    ARSetImpl *input = [self input];
    ARSetImpl *result = [input where:^BOOL(NSObject<NSCopying>* object) {
        return [(NSNumber*)object intValue]%2==0;
    }];
    STAssertTrue(([result count]==1), nil);
    STAssertTrue( [(NSNumber*)[result member:@2] intValue]==2, nil);
    STAssertThrows([[self input] where:nil], nil);
}


@end
