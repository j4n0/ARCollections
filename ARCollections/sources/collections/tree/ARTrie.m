
// BSD License. Author: jano@jano.com.es

#import "ARTrie.h"

NSUInteger kAlphabetSize = 256;


@implementation ARTrieNode

-(id) init {
    self = [super init];
    if (self){
        next = (id __strong *) calloc(kAlphabetSize,sizeof(*next));
    }
    return self;
}

- (void) dealloc {
    free(next);
}

@end


@implementation ARTrie {
    ARTrieNode *root;
}


-(NSString*)description {
    return [[self keys] description];
}


-(BOOL) isEmpty {
    return root==nil;
}


// Is the key in the symbol table?
-(BOOL)containsKey:(NSString*)key
{
    return [self trieValueForKey:key] != nil;
}


-(ARTrieValue*)trieValueForKey:(NSString*)key
{
    ARTrieNode *node = [self getNode:root key:key index:0];
    if (node == nil) return nil;
    return (ARTrieValue*) node->value;
}


-(ARTrieNode*) getNode:(ARTrieNode*) node
                   key:(NSString*)   key
                 index:(NSUInteger)  index
{
    if (node == nil) return nil;
    if (index == [key length]) return node;
    unichar c = [key characterAtIndex:index];
    return [self getNode:node->next[c] key:key index:index+1];
}


-(void) putKey:(NSString*)key value:(ARTrieValue*)value
{
    root = [self putNode:root key:key value:value index:0];
}


// The value will be set in the node pointed to by the key.
-(ARTrieNode*)putNode:(ARTrieNode*)  node
                  key:(NSString*)    key
                value:(ARTrieValue*) value
                index:(NSUInteger)   index
{
    if (node == nil) {
        node = [ARTrieNode new];
    }

    if (index == [key length]) {
        node->value = value;
        return node;
    }

    unichar c = [key characterAtIndex:index];
    ARTrieNode *n = [self putNode:node->next[c]
                              key:key
                            value:value
                            index:index+1];
    node->next[c] = n;
    return node;
}


// find the key that is the longest prefix of s
-(NSString*) longestPrefixOf:(NSString*)query
{
    NSUInteger length = [self longestPrefixOfNode:root query:query index:0 length:0];
    return [query substringWithRange:NSMakeRange(0, length)];
}


// Find the key in the subtrie rooted at node that is the longest
// prefix of the query string, starting at the index character.
-(NSUInteger) longestPrefixOfNode:(ARTrieNode*) node
                            query:(NSString*)   query
                            index:(NSUInteger)  index
                           length:(NSUInteger)  length
{
    if (node == nil) return length;
    if (node->value != nil) length = index;
    if (index == [query length]) return length;
    unichar c = [query characterAtIndex:index];
    return [self longestPrefixOfNode:node->next[c]
                               query:query
                               index:index+1
                              length:length];
}


-(ARQueueList*) keys
{
    return [self keysWithPrefix:@""];
}


-(ARQueueList*) keysWithPrefix:(NSString*)prefix
{
    ARTrieNode *node = [self getNode:root key:prefix index:0];
    ARQueueList *queue = [ARQueueList new];
    [self collectKeysFromNode:node key:prefix queue:queue];
    return queue;
}


-(void) collectKeysFromNode:(ARTrieNode*)  node
                        key:(NSString*)    key
                      queue:(ARQueueList*) queue
{
    if (node == nil) return;
    if (node->value != nil) {
        [queue enqueue:key];
    }
    for (NSUInteger c = 0; c < kAlphabetSize; c++)
        if (node->next[c]){
            // recursive call with key = (key + current character)
            [self collectKeysFromNode:node->next[c]
                          key:[NSString stringWithFormat:@"%@%c",key,c]
                        queue:queue];
        }
}


-(ARQueueList*) keysThatMatch:(NSString*)pattern
{
    ARQueueList *queue = [ARQueueList new];
    [self collectKeysFromNode:root prefix:@"" pattern:pattern queue:queue];
    return queue;
}


-(void)collectKeysFromNode:(ARTrieNode *) node
                    prefix:(NSString *)   prefix
                   pattern:(NSString *)   pattern
                     queue:(ARQueueList*) queue
{
    if (node == nil) return;
    if ([prefix length] == [pattern length] && node->value != nil) [queue enqueue:prefix];
    if ([prefix length] == [pattern length]) return;
    unichar next = [pattern characterAtIndex:[prefix length]];
    for (NSUInteger c = 0; c < kAlphabetSize; c++)
        if (next == '.' || next == c)
            [self collectKeysFromNode:node->next[c]
                       prefix:[NSString stringWithFormat:@"%@%c", prefix, c]
                      pattern:pattern
                        queue:queue];
}


-(void) deleteKey:(NSString*)key
{
    root = [self deleteNode:root key:key index:0];
}


-(ARTrieNode*) deleteNode:(ARTrieNode*) node
                      key:(NSString*)   key
                    index:(NSUInteger)  index
{
    if (node == nil) return nil;
    if (index == [key length]) node->value = nil;
    else {
        unichar c = [key characterAtIndex:index];
        ARTrieNode *n = [self deleteNode:node->next[c] key:key index:index +1];
        node->next[c] = n;
    }
    if (node->value != nil) return node;
    for (NSUInteger c = 0; c < kAlphabetSize; c++)
        if (node->next[c] != nil)
            return node;
    return nil;
}


@end