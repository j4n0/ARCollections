
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARMapImpl.h"
#import "ARArrayList.h"

@interface CarM : NSObject
@property(nonatomic,copy)NSString *name;
@end
@implementation CarM
@end


// Test for the DictionaryTest
@interface ARMapTest : SenTestCase
@end

@implementation ARMapTest

-(void) testAllKeys
{
    ARMapImpl *dic1 = [ARMapImpl new];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"green" value:@"turtle"]];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"blue" value:@"lagoon"]];
    ARArrayList *keys = [dic1 allKeys];
    STAssertTrue([[keys componentsJoinedByString:@","] isEqualToString:@"green,blue"], nil);
}

-(void) testAllValues
{
    ARMapImpl *dic1 = [ARMapImpl new];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"green" value:@"turtle"]];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"blue" value:@"lagoon"]];
    ARArrayList *values = [dic1 allValues];
    STAssertTrue([[values componentsJoinedByString:@","] isEqualToString:@"turtle,lagoon"], nil);
}

-(void) testInitWithData {
    
    ARMapImpl *dic1 = [ARMapImpl new];
    ARMapEntry *entry = [[ARMapEntry alloc] initWithKey:@"green" value:@"turtle"];
    [dic1 addEntry:entry];
    
    ARMapImpl *dic2 = [[ARMapImpl alloc] initWithData:[dic1 bytes]];
    //NSLog(@"dic: %@", [dic2 description]);
    STAssertTrue([[dic2 description] isEqualToString:@"{green,turtle}"], nil);
}


-(void) testFastEnumeration
{
    // create dictionary
    ARMapImpl *dic = [[ARMapImpl alloc] initWithCapacity:5];
    NSArray *array = @[@1,@2,@3,@4,@5,@6,@7,@8,@9,@0];
    for (id e in array){
        [dic addEntry:[[ARMapEntry alloc] initWithKey:e value:e]];
    }

    // iterate to build string representation
    NSMutableString *string = [NSMutableString string];
    for (ARMapEntry *e in dic) {
        [string appendFormat:@"%@", e];
    }
    
    STAssertTrue([dic entryForKey:@1]!=nil,nil);
    STAssertTrue([dic entryForKey:@0]!=nil,nil);
    STAssertTrue([dic count]==10,nil);
}


// addentry, removeEntry, count, description
-(void) testRemoveCountDescription
{
    ARMapImpl *dic = [[ARMapImpl alloc] initWithCapacity:0];
    ARMapEntry *entry = [[ARMapEntry alloc] initWithKey:@"A" value:@1];
    
    // remove non existant entry at capacity 0
    [dic removeEntry:entry];
    STAssertTrue([dic count]==0, nil);
    
    // add entry at capacity 0
    [dic addEntry:entry];
    STAssertTrue([dic count]==1, nil);
    
    // remove the only entry
    [dic removeEntry:entry];
    STAssertTrue([dic count]==0, nil);
    
    // add same entry twice
    [dic addEntry:entry];
    [dic addEntry:entry];
    STAssertTrue([dic count]==1, nil);
    
    STAssertTrue([[dic description] isEqualToString:@"{A,1}"], nil);
}


-(void) testDescription
{
    ARMapImpl *dic = [[ARMapImpl alloc] initWithCapacity:0];
    ARMapEntry *entry;
    
    entry = [[ARMapEntry alloc] initWithKey:@"A" value:@1];
    [dic addEntry:entry];
    STAssertTrue([dic count]==1,nil);
    
    entry = [[ARMapEntry alloc] initWithKey:@"B" value:@2];
    [dic addEntry:entry];
    STAssertTrue([dic count]==2,nil);
    
    entry = [[ARMapEntry alloc] initWithKey:@"C" value:@3];
    [dic addEntry:entry];
    STAssertTrue([dic count]==3,nil);
    
    entry = [[ARMapEntry alloc] initWithKey:@"D" value:@4];
    [dic addEntry:entry];
    STAssertTrue([dic count]==4,nil);
    
    STAssertTrue([dic entryForKey:@"A"]!=nil,nil);
    STAssertTrue([dic entryForKey:@"B"]!=nil,nil);
    STAssertTrue([dic entryForKey:@"C"]!=nil,nil);
    STAssertTrue([dic entryForKey:@"D"]!=nil,nil);
}


-(void) testCopy1
{
    ARMapImpl *dic1 = [[ARMapImpl alloc] initWithCapacity:0];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"A" value:@1]];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"B" value:@2]];
    ARMapImpl *dic2 = [dic1 copy];
    STAssertTrue([dic1 isEqual:dic2], nil);
}

-(void) testCopy2
{
    ARMapImpl *dic1 = [[ARMapImpl alloc] initWithCapacity:0];
    ARMapImpl *dic2 = [dic1 copy];
    STAssertTrue([dic1 isEqual:dic2], nil);
}

-(void) testCopy3
{
    ARMapImpl *dic1 = [[ARMapImpl alloc] initWithCapacity:10];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"A" value:@1]];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"G" value:@2]];
    [dic1 addEntry:[[ARMapEntry alloc] initWithKey:@"W" value:@3]];
    ARMapImpl *dic2 = [dic1 copy];
    STAssertTrue([dic1 isEqual:dic2], nil);
}


#pragma mark - Block Iterators

-(ARMapImpl*) input {
    ARMapImpl *dic = [[ARMapImpl alloc] initWithCapacity:3];
    [dic addEntry:[[ARMapEntry alloc] initWithKey:@"A" value:@1]];
    [dic addEntry:[[ARMapEntry alloc] initWithKey:@"B" value:@2]];
    [dic addEntry:[[ARMapEntry alloc] initWithKey:@"C" value:@3]];
    return dic;
}


- (void) testAnd
{
    // not all are multiples of 2
    ARMapImpl *input = [self input];
    BOOL test = [input and:^BOOL(ARMapEntry *entry) {
        return [(NSNumber*)entry.value intValue] % 2 == 0;
    }];
    STAssertFalse(test, nil);
    
    // not all are less than 4
    test = [input and:^BOOL(ARMapEntry *entry) {
        return [(NSNumber*)entry.value intValue] < 4;
    }];
    STAssertTrue(test, nil);
}


- (void) testOr
{
    // at least one is multiple of 2
    ARMapImpl *input = [self input];
    BOOL test = [input or:^BOOL(ARMapEntry *entry) {
        return [(NSNumber*)entry.value intValue] % 2 == 0;
    }];
    STAssertTrue(test, nil);
}


- (void) testEach
{
    ARMapImpl *input = [self input];
    __block NSInteger max;
    [input each:^(ARMapEntry *entry) {
        if (max<[(NSNumber*)entry.value intValue]){
            max = [(NSNumber*)entry.value intValue];
        }
    }];
    STAssertTrue((max==3), @"should be 3");
    STAssertThrows([[self input] each:nil], nil);
}


- (void) testFind
{
    ARMapImpl *input = [self input];
    ARMapEntry *entry = [input find:^BOOL(ARMapEntry *entry) {
        return [(NSNumber*)entry.value intValue] %2 == 0;
    }];
    STAssertTrue(([(NSNumber*)entry.value isEqualToNumber:@2]), nil);
    STAssertThrows([[self input] find:nil], nil);
}


- (void) testMap
{
    ARMapImpl *input = [self input];
    ARMapImpl *dic1 = [input map:^id(ARMapEntry *entry) {
        NSNumber *n = [NSNumber numberWithInt:[(NSNumber*)entry.value intValue]-1];
        return [[ARMapEntry alloc] initWithKey:entry.key value:n];
    }];
    
    ARMapImpl *dic2 = [[ARMapImpl alloc] initWithCapacity:10];
    [dic2 addEntry:[[ARMapEntry alloc] initWithKey:@"A" value:@0]];
    [dic2 addEntry:[[ARMapEntry alloc] initWithKey:@"B" value:@1]];
    [dic2 addEntry:[[ARMapEntry alloc] initWithKey:@"C" value:@2]];
    
    // NSLog(@"dic1: %@",dic1);
    // NSLog(@"dic2: %@",dic2);
    
    STAssertTrue( ([dic1 isEqualToARMap:dic2]), @"should be equal");
    STAssertThrows( ([[self input] map:nil]) , nil);
}


- (void) testPluck
{
    CarM *car = [CarM new];
    car.name = @"Ford Bronco";
    ARMapImpl *input = [ARMapImpl new];
    [input addEntry:[[ARMapEntry alloc]initWithKey:car.name value:car]];
    ARMapImpl *result = [input pluck:@"name"];
    ARMapEntry *e = [result entryForKey:car.name];
    STAssertTrue( [(NSString*)e.value isEqualToString:car.name], nil);
    STAssertThrows([[self input] pluck:nil], nil);
}


- (void)testSplit
{
    ARMapImpl *input = [self input];
    
    ARArrayList *result = [input split:3];
    STAssertTrue( ([(ARMapImpl*)[result objectAtIndex:0] count]==1), nil );
    STAssertTrue( ([(ARMapImpl*)[result objectAtIndex:1] count]==1), nil );
    STAssertTrue( ([(ARMapImpl*)[result objectAtIndex:2] count]==1), nil );
    
    result = [input split:0];
    STAssertTrue( ([result count]==0), nil);
}


- (void) testWhere
{
    ARMapImpl *input = [self input];
    ARMapImpl *result = [input where:^BOOL(ARMapEntry *entry) {
        return [(NSNumber*)entry.value intValue]%2==0;
    }];
    STAssertTrue(([result count]==1), nil);
    STAssertTrue( [(NSNumber*)[result entryForKey:@"B"].value intValue]==2, nil);
    STAssertThrows([[self input] where:nil], nil);
}


@end
