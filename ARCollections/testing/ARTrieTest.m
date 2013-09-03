
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARTrie.h"

@interface ARTrieTest : SenTestCase
@end


@implementation ARTrieTest


- (void) testTrie1
{
    NSString * const key = @"sea";
    NSString * const value = @"blue";
    NSString * const prefix = [key substringToIndex:[key length]-1];
    
    ARTrie *trie = [ARTrie new];
    
    STAssertTrue([trie isEmpty], @"should be empty");
    
    // add key, check key exists, check prefix is not contained, check value
    [trie putKey:key value:value];
    STAssertTrue([trie containsKey:key], @"should contain key %@",key);
    STAssertFalse([trie containsKey:prefix], @"should NOT contain prefix %@",prefix);
    STAssertTrue([(NSString*) [trie trieValueForKey:key] isEqualToString:value], nil);
    
    // longest prefix of seashells is sea
    STAssertTrue([[trie longestPrefixOf:@"seashells"] isEqualToString:key],nil);
    
    // pattern s.. matches sea
    STAssertTrue([[[trie keysThatMatch:@"s.."]description] isEqualToString:key],nil);

    // delete key, check the tree is empty again
    [trie deleteKey:key];
    STAssertTrue([trie isEmpty], @"should be empty");
}


- (void) testTrie2
{
    ARTrie *trie = [ARTrie new];
    [trie putKey:@"christ"     value:@"christ"];
    [trie putKey:@"anti"       value:@"anti"];
    [trie putKey:@"antichrist" value:@"antichrist"];
    STAssertTrue([[trie keys] count]==3,nil); // anti,antichrist,christ
    STAssertTrue([[trie keysWithPrefix:@"anti"] count]==2,nil); // anti,antichrist[;
    STAssertTrue([[trie keysThatMatch:@"an.."] count]==1,nil); // anti
}


@end

