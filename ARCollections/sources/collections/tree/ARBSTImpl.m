
// BSD License. Author: jano@jano.com.es

#import "ARBSTImpl.h"

@interface ARBSTImpl()
@property (nonatomic,assign,readwrite) NSUInteger count;
@end

@implementation ARBSTImpl

@synthesize root = _root;

-(BOOL) isEmpty {
    return [self count]==0;
}

-(NSUInteger) count {
    return [self countOfNode:_root];
}

-(NSUInteger) countOfNode:(ARBSTNode*)node {
    return node ? node.count : 0;
}

-(NSString*) description {
    NSMutableArray *array = [NSMutableArray new];
    [_root breadthOrder:^(NSObject<ARBSTNode> *node) {
        [array addObject:node.key];
    }];
    return [array componentsJoinedByString:@" "];
}

#pragma mark - search

// Return true if there is a node with the given key.
-(BOOL) contains:(ARBSTKey*)key {
    return [self objectForKey:key] != nil;
}

// Return true if there is a node with the given key,
// starting the search at the given node.
-(BOOL) contains:(ARBSTKey*)key fromNode:(ARBSTNode*)node {
    return [self objectForKey:key fromNode:node] != nil;
}

// Return the node with the given key.
-(ARBSTNode*) objectForKey:(ARBSTKey*)key {
    return [self objectForKey:key fromNode:_root];
}

// Return the node with the given key,
// starting the search from the given node.
-(ARBSTNode*) objectForKey:(ARBSTKey*)key
                  fromNode:(ARBSTNode*)node
{
    if (node == nil) return nil;
    NSComparisonResult cmp = [key compare:node.key];
    ARBSTNode *object;
    switch (cmp) {
        case NSOrderedAscending:
            object = [self objectForKey:key fromNode:node.left];
            break;
        case NSOrderedDescending:
            object = [self objectForKey:key fromNode:node.right];
            break;
        default:
            object = node;
            break;
    }
    return object;
}

#pragma mark - insert

// Note: If value is nil, the node with the given key is deleted.
-(void) insertKey:(ARBSTKey*)key value:(ARBSTValue*)value {
    if (value == nil) {
        [self delete:key];
    } else {
        _root = [self insertKey:key value:value onNode:_root];
        NSAssert([self check],@"The tree is inconsistent.");
    }
}

-(ARBSTNode*) insertKey:(ARBSTKey*)key value:(ARBSTValue*)value onNode:(ARBSTNode*)node
{
    if (node == nil){
        return [[ARBSTNodeImpl alloc] initWithKey:key value:value];
    } else {
        NSComparisonResult cmp = [key compare:node.key];
        switch (cmp) {
            case NSOrderedAscending: // key < node.key
                node.left  = [self insertKey:key value:value onNode:node.left];
                break;
            case NSOrderedDescending: // node.key < key
                node.right = [self insertKey:key value:value onNode:node.right];
                break;
            default: // same
                node.value = value;
                break;
        }
        // 'count' is always 1 (for the current node) plus number of nodes on left and right,
        // but if nil nodes are not allowed, this update is only needed on the first two cases.
        node.count = [self countOfNode:node.left] + 1 + [self countOfNode:node.right];
        return node;
    }
}

#pragma mark - delete

// Delete the minimum key.
-(void) deleteMin {
    if (![self isEmpty]){
        _root = [self deleteMin:_root];
        NSAssert([self check],@"The tree is inconsistent.");
    }
}


// Example:
//   E     deleteMin(E) will set M as the left child of S, and skip A,
//  S X    which is the minimum key of the tree rooted at E.
// A
//  M

// Delete the minimum key, starting the search at the given node.
// Return the new minimum key for this position.
-(ARBSTNode*) deleteMin:(ARBSTNode*)node {
    ARBSTNode *result;
    if (node) {
        if (node.left == nil) {
            // Whether there is a right or not, returning right to the assigment
            // on the line 'node.left=' below, skips (deletes) the current node.
            result = node.right;
        } else {
            node.left = [self deleteMin:node.left]; // assigment to the result of the recursive call
            node.count = [self countOfNode:node.left] + 1 + [self countOfNode:node.right]; // update count
            result = node;
        }
    }
    return result;
}

// Delete the maximum key.
-(void) deleteMax {
    if (![self isEmpty]){
        _root = [self deleteMax:_root];
        NSAssert([self check],@"The tree is inconsistent.");
    }
}

// Return the node with the maximum key, starting the search at the given node.
-(ARBSTNode*) deleteMax:(ARBSTNode*)node {
    ARBSTNode* result;
    if (node){
        if (node.right == nil) {
            result = node.left;
        } else {
            node.right = [self deleteMax:node.right];
            node.count = [self countOfNode:node.left] + [self countOfNode:node.right] + 1;
            result = node;
        }
    }
    return result;

}

// Delete the exact key.
-(void) deleteKey:(ARBSTKey*)key {
    _root = [self deleteKey:key node:_root];
    NSAssert([self check],@"The tree is inconsistent.");
}

// Delete the exact key, starting the search at the given node.
-(ARBSTNode*) deleteKey:(ARBSTKey*)key node:(ARBSTNode*)node {
    if (node == nil) return nil;
    NSComparisonResult cmp = [key compare:node.key];
    switch (cmp) {
        case NSOrderedAscending:
            node.left  = [self deleteKey:key node:node.left];
            break;
        case NSOrderedDescending:
            node.right = [self deleteKey:key node:node.right];
            break;
        default: { // found the node with the key to delete
            if (node.right == nil) return node.left;
            if (node.left  == nil) return node.right;
            ARBSTNode *t = node;
            node = [self min:t.right];
            node.right = [self deleteMin:t.right];
            node.left = t.left;
            break;
        }
    }
    node.count = [self countOfNode:node.left] + [self countOfNode:node.right] + 1;
    return node;
}

#pragma mark - min, max, floor, and ceiling

// Return the minimum key of the tree.
-(ARBSTKey*) min {
    if ([self isEmpty]) return nil;
    return [self min:_root].key;
}

// Return the node with the minimum key, starting the search from the given node.
-(ARBSTNode*) min:(ARBSTNode*)node {
    if (node.left == nil) {
        // if there is no left (the 'less than' branch), the result is node
        return node;
    } else {
        // otherwise keep recursing through the left branch
        return [self min:node.left];
    }
}


// Return the maximum key of the tree.
-(ARBSTKey*) max {
    if ([self isEmpty]) return nil;
    return [self max:_root].key;
}

// Return the node with the maximum key, starting the search from the given node.
-(ARBSTNode*) max:(ARBSTNode*)node {
    if (node.right == nil) return node;
    else return [self max:node.right];
}


// Return the largest key in the BST less than or equal to the given key.
-(ARBSTKey*) floorKey:(ARBSTKey*)key {
    ARBSTNode* node = [self floorKey:key node:_root];
    if (node == nil) return nil; // nil root
    else return node.key;
}

// Return the node with the largest key in the BST less than or equal to the given key,
// starting the search from the given node.
-(ARBSTNode*) floorKey:(ARBSTKey*)key node:(ARBSTNode*)node
{
    if (node == nil) {
        return nil;
    }
    ARBSTNode *result;
    NSComparisonResult cmp = [key compare:node.key];
    switch (cmp) {
        case NSOrderedAscending:
            // 'key' less than node.key so keep looking on left branch
            result = [self floorKey:key node:node.left];
            break;
        case NSOrderedDescending: {
            // 'key' greater than node.key so keep looking on right branch
            ARBSTNode* t = [self floorKey:key node:node.right];
            result = t!=nil ? t : node;
            break;
        }
        default: {
            // key equals node.key, we are done.
            result = node;
            break;
        }
    }
    return result;
}


// Return the smallest key in the BST greater than or equal to the given key.
-(ARBSTKey*) ceilingKey:(ARBSTKey*)key {
    ARBSTNode* node = [self ceilingKey:key node:_root];
    if (node == nil) return nil;
    else return node.key;
}

// Return the node with the smallest key in the BST greater than or equal to the given key,
// starting the search from the given node.
-(ARBSTNode*) ceilingKey:(ARBSTKey*)key node:(ARBSTNode*)node {
    if (node == nil) {
        return nil;
    }
    ARBSTNode *result;
    NSComparisonResult cmp = [key compare:node.key];
    switch (cmp) {
        case NSOrderedAscending: {
            ARBSTNode *t = [self ceilingKey:key node:node.left];
            result = t!=nil ? t : node;
            break;
        }
        case NSOrderedDescending: {
            result = [self ceilingKey:key node:node.right];
            break;
        }
        default: {
            result = node;
            break;
        }
    }
    return result;
}


#pragma mark - Rank and selection


// Return the key of rank k (the key such that precisely k other keys in the BST are smaller).
-(ARBSTKey*) selectRank:(NSInteger)rank
{
    if (rank < 0 || rank >= [self count])  {
        return nil; // rank sought after is invalid
    }
    ARBSTNode* node = [self selectRank:rank node:_root]; // start at root
    return node.key;
}

// Return the node containing the key of rank k
// (the key such that precisely k other keys in the BST are smaller).
-(ARBSTNode*) selectRank:(NSInteger)rank node:(ARBSTNode*)node
{
    if (node == nil) return nil;
    NSInteger t = [self countOfNode:node.left];
    if      (t > rank) return [self selectRank:rank node:node.left];
    else if (t < rank) return [self selectRank:rank-t-1 node:node.right];
    else               return node;
}


// Return the number of keys in the tree that are less than the given key.
-(NSInteger) rankKey:(ARBSTKey*)key {
    return [self rankKey:key node:_root];
}

// Return the number of keys in the given subtree that are less than the given key.
-(NSInteger) rankKey:(ARBSTKey*)key node:(ARBSTNode*)node
{
    if (node == nil) return 0;
    NSInteger cmp = [key compare:node.key];
    if      (cmp == NSOrderedAscending)  return [self rankKey:key node:node.left];
    else if (cmp == NSOrderedDescending) return [self countOfNode:node.left] + 1 + [self rankKey:key node:node.right];
    else                                 return [self countOfNode:node.left];
}


#pragma mark - Range count and range search

// Returns all the keys.
-(NSObject<ARQueue>*) keys {
    return [self keysBetweenLow:[self min] andHi:[self max]];
}

// Returns all the keys in the range [low...high].
-(NSObject<ARQueue>*) keysBetweenLow:(ARBSTKey*)lo andHi:(ARBSTKey*)hi {
    ARQueueList* queue = [ARQueueList new];
    [self keysBetweenLow:lo andHi:hi fromNode:_root queue:queue];
    return queue;
}

// Returns all the keys in the range [low...high], starting at the given node.
-(NSObject<ARQueue>*) keysBetweenLow:(ARBSTKey*) lo
                               andHi:(ARBSTKey*) hi
                            fromNode:(ARBSTNode*) node
                               queue:(NSObject<ARQueue>*) queue
{
    if (node == nil) {
        return queue;
    }
    NSInteger cmpLo = [lo compare:node.key];
    NSInteger cmpHi = [hi compare:node.key];
    if (cmpLo == NSOrderedAscending) {
        [self keysBetweenLow:lo andHi:hi fromNode:node.left queue:queue];
    }
    if ( (cmpLo == NSOrderedSame || cmpLo == NSOrderedAscending) &&
         (cmpHi == NSOrderedSame || cmpHi == NSOrderedDescending)){
        [queue enqueue:node.key];
    }
    if (cmpHi == NSOrderedDescending) {
        [self keysBetweenLow:lo andHi:hi fromNode:node.right queue:queue];
    }
    return queue;
}


-(NSInteger) sizeKeylo:(ARBSTKey*)lo hi:(ARBSTKey*)hi {
    if ([lo compare:hi] == NSOrderedDescending) return 0;
    if ([self contains:hi]) return [self rankKey:hi] - [self rankKey:lo] + 1;
    else                    return [self rankKey:hi] - [self rankKey:lo];
}


// Return the height of this BST. A one-node tree has height 1.
-(NSInteger) height {
    return [self height:_root];
}

-(NSInteger) height:(ARBSTNode*)node {
    if (node == nil) return 0;
    return 1 + imax([self height:node.left], [self height:node.right]);
}


#pragma mark - Check integrity

-(BOOL) check {
    if (![self isBST])            warn(@"Not in symmetric order");
    if (![self isSizeConsistent]) warn(@"Subtree counts not consistent");
    if (![self isRankConsistent]) warn(@"Ranks not consistent");
    return [self isBST] && [self isSizeConsistent] && [self isRankConsistent];
}

// does this binary tree satisfy symmetric order?
// Note: this test also ensures that data structure is a binary tree since order is strict
-(BOOL) isBST {
    return [self isBST:_root minKey:nil maxKey:nil];
}

// Returns true if the subtree rooted at node is a BST with all keys strictly between min and max.
// If min or max is null, it is treated as an empty constraint.
-(BOOL) isBST:(ARBSTNode*)node minKey:(ARBSTKey*)minKey maxKey:(ARBSTKey*)maxKey
{
    if (node == nil) return true;
    if (minKey != nil && [node.key compare:minKey] <= 0) return false;
    if (maxKey != nil && [node.key compare:maxKey] >= 0) return false;
    return [self isBST:node.left minKey:minKey maxKey:node.key] &&
           [self isBST:node.right minKey:node.key maxKey:maxKey];
}


// are the size fields correct?
-(BOOL) isSizeConsistent {
    return [self isSizeConsistent:_root];
}

-(BOOL) isSizeConsistent:(ARBSTNode*)node {
    if (node == nil) {
        return true;
    }
    // check this node
    if (node.count != [self countOfNode:node.left] + [self countOfNode:node.right] + 1) {
        return false;
    }
    // check the subtrees
    return [self isSizeConsistent:node.left] && [self isSizeConsistent:node.right];
}


// check that ranks are consistent
-(BOOL) isRankConsistent {
    for (int i = 0; i < [self count]; i++){
        ARBSTKey *k = [self selectRank:i];
        if (i != [self rankKey:k]) return false;
    }
    for (ARBSTKey* key in [self keys]){
        NSInteger rank = [self rankKey:key];
        NSComparisonResult cmp = [key compare:[self selectRank:rank]];
        if (cmp != NSOrderedSame) return false;
    }
    return true;
}

@end
