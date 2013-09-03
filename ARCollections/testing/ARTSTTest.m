
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARTST.h"

@interface ARTSTTest : SenTestCase
@end


@implementation ARTSTTest


- (void) testTrie1
{
    NSString * const key = @"sea";
    NSString * const value = @"blue";

    // create trie
    ARTST *trie = [ARTST new];

    // check it's empty
    STAssertTrue([trie isEmpty], @"should be empty");

    // add key
    [trie putKey:key value:value];

    // check it contains key
    STAssertTrue([trie containsKey:key], nil);

    // longest prefix of seashells is sea
    STAssertTrue([[trie longestPrefixOf:@"seashells"] isEqualToString:key],nil);
    
    // pattern s.. matches sea
    STAssertTrue([[[trie keysThatMatch:@"s.."]description] isEqualToString:key],nil);

    // delete key, check the tree is empty again
    // [trie deleteKey:key];
    // STAssertTrue([trie isEmpty], @"should be empty");
}


- (void) testTrie2
{
    ARTST *trie = [ARTST new];
    [trie putKey:@"christ"     value:@"christ"];
    [trie putKey:@"anti"       value:@"anti"];
    [trie putKey:@"antichrist" value:@"antichrist"];
    STAssertTrue([[trie keys] count]==3,nil); // anti,antichrist,christ
    STAssertTrue([[trie keysWithPrefix:@"anti"] count]==2,nil); // anti,antichrist[;
    STAssertTrue([[trie keysThatMatch:@"an.."]  count]==1,nil); // anti
}


@end

