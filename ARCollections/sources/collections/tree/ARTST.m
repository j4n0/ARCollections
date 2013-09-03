// BSD License. Author: jano@jano.com.es
#import "ARTST.h"

@implementation ARTSTNode
@end


@implementation ARTST


-(BOOL) isEmpty {
    return self.root==nil;
}


-(BOOL) containsKey:(NSString*)key
{
    return [self trieValueForKey:key] != nil;
}


// Find and return the longest prefix of the given string.
-(NSString*) longestPrefixOf:(NSString*)string
{
    if (string == nil || [string length] == 0) {
        return nil;
    }

    NSUInteger length = 0;
    ARTSTNode*n = self.root;
    NSUInteger index = 0;
    while (n != nil && index < [string length])
    {
        unichar c = [string characterAtIndex:index];
        if      (c < n.c) n = n.left;   // less than
        else if (c > n.c) n = n.right;  // greater than
        else {                                   // equal (found one character)
            index++;                             // advance to next character
            if (n.value != nil) length = index;  // save max length found
            n = n.mid;                           // continue
        }
    }

    // return the substring for the max length found
    return [string substringWithRange:NSMakeRange(0, length)];
}


#pragma mark - node, put


-(ARTSTValue*) trieValueForKey:(NSString*)key
{
    // return nil if 
    BOOL isInvalidKey = key==nil || [key length]==0;
    if (isInvalidKey) return nil;

    // return the value of the node with the given key, or nil if not found
    return [self nodeWithKey:key index:0 fromNode:self.root].value;
}


// Return the subtrie corresponding to the given key.
-(ARTSTNode*) nodeWithKey:(NSString*)  k
                    index:(NSUInteger) i
                 fromNode:(ARTSTNode*) n
{
    // return nil if the key or node are nil, or if the key is 0 characters
    BOOL isInvalidKey = k == nil || [k length] == 0;
    if (isInvalidKey || n ==nil) return nil;

    unichar c = [k characterAtIndex:i];
    ARTSTNode *result;
    if (c < n.c)                result = [self nodeWithKey:k index:i fromNode:n.left];     // less than
    else if (c > n.c)           result = [self nodeWithKey:k index:i fromNode:n.right];    // greater than
    else if (i < [k length]-1)  result = [self nodeWithKey:k index:i + 1 fromNode:n.mid];  // equal (character found), move to the next
    else                        result = n;                                                // end of the string, return the node

    return result;
}


-(void) putKey:(NSString*)string value:(ARTSTValue*)value
{
    if (string==nil || [string length]==0 || value==nil){
        NSLog(@"refusing to add invalid key-value: %@-%@",string,value);
        return;
    }
    if (![self containsKey:string]) {
        _numberOfKeys++;
    }
    _root = [self putKey:string value:value index:0 atNode:self.root];
}


-(ARTSTNode*) putKey:(NSString*)   k
               value:(ARTSTValue*) v
               index:(NSUInteger)  i
              atNode:(ARTSTNode*)  n
{
    unichar c = [k characterAtIndex:i];

    // create the node if needed
    if (n == nil) {
        n = [ARTSTNode new];
        n.c = c;
    }

    // recursive search
    if      (c < n.c)          n.left  = [self putKey:k value:v index:i atNode:n.left];     // less than
    else if (c > n.c)          n.right = [self putKey:k value:v index:i atNode:n.right];    // greater than
    else if (i < [k length]-1) n.mid   = [self putKey:k value:v index:i + 1 atNode:n.mid];  // equal (character found), move to the next
    else                       n.value = v;                                                 // end of the string, set the value

    return n;
}


#pragma mark - keys


// all keys in symbol table
-(ARQueueList*) keys
{
    ARQueueList* queue = [ARQueueList new];
    [self collectKeysFromNode:self.root prefix:@"" queue:queue];
    return queue;
}


// all keys starting with given prefix
-(ARQueueList*) keysWithPrefix:(NSString*)prefix
{
    return [self keysWithPrefix:prefix limit:0];
}


-(ARQueueList*) keysWithPrefix:(NSString*)prefix limit:(NSUInteger)limit
{
    ARQueueList* queue = [ARQueueList new];
    ARTSTNode*node = [self nodeWithKey:prefix index:0 fromNode:self.root];
    if (node == nil) {
        return queue;
    }
    if (node.value != nil) {
        [queue enqueue:prefix];
    }
    [self collectKeysFromNode:node.mid prefix:prefix queue:queue limit:limit];
    return queue;
}


// return all keys matching given wilcard pattern
-(ARQueueList*) keysThatMatch:(NSString*)pattern
{
    ARQueueList* queue = [ARQueueList new];
    [self collectKeysFromNode:self.root prefix:@"" index:0 pattern:pattern queue:queue];
    return queue;
}


#pragma mark - collect


// all keys in subtrie rooted at node with given prefix.
-(void) collectKeysFromNode:(ARTSTNode*)   n
                     prefix:(NSString*)    p
                      queue:(ARQueueList*) q
{
    [self collectKeysFromNode:n prefix:p queue:q limit:0];
}


// all keys in subtrie rooted at node with given prefix.
-(void) collectKeysFromNode:(ARTSTNode*)   n
                     prefix:(NSString*)    prefix
                      queue:(ARQueueList*) q
                      limit:(NSUInteger)   limit
{
    if (n == nil) {
        return;
    }

    [self collectKeysFromNode:n.left prefix:prefix queue:q limit:limit];

    // collect the char for the current node
    NSString *tmpKey = [NSString stringWithFormat:@"%@%c",prefix, n.c];
    if (limit>0 && [q count]==limit) {
        return;
    } else if (n.value != nil) {
        [q enqueue:tmpKey];
    }

    [self collectKeysFromNode:n.mid   prefix:tmpKey queue:q limit:limit];
    [self collectKeysFromNode:n.right prefix:prefix queue:q limit:limit];
}


-(void) collectKeysFromNode:(ARTSTNode*)   n
                     prefix:(NSString*)    p
                      index:(NSUInteger)   i
                    pattern:(NSString*)    pat
                      queue:(ARQueueList*) q
{
    if (n == nil) return;
    unichar c = [pat characterAtIndex:i];
    BOOL isWildcard = c == '.';

    if (isWildcard || c < n.c) {
        [self collectKeysFromNode:n.left prefix:p index:i pattern:pat queue:q];
    }

    if (isWildcard || c == n.c) {
        NSString *tmpKey = [NSString stringWithFormat:@"%@%c", p, n.c];
        if (i == [pat length]-1 && n.value != nil) {
            [q enqueue:tmpKey];
        }
        if (i < [pat length]-1) {
            [self collectKeysFromNode:n.mid prefix:tmpKey index:i + 1 pattern:pat queue:q];
        }
    }

    if (isWildcard || c > n.c) {
        [self collectKeysFromNode:n.right prefix:p index:i pattern:pat queue:q];
    }
}


@end
