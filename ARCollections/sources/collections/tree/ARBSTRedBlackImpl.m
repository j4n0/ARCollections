
// BSD License. Author: jano@jano.com.es

#import "ARBSTRedBlackImpl.h"

@interface ARBSTRedBlackImpl()
@property (nonatomic,assign,readwrite) NSUInteger count;
@end

@implementation ARBSTRedBlackImpl

@synthesize root = _root;


-(BOOL) isEmpty {
    return [self count]==0;
}

-(NSUInteger) count {
    return [self countOfNode:_root];
}

-(NSUInteger) countOfNode:(ARBSTRedBlackNode*)node {
    return node ? node.count : 0;
}

-(NSString*) description {
    NSMutableArray *array = [NSMutableArray new];
    [_root breadthOrder:^(NSObject<ARBSTRedBlackNode> *node) {
        [array addObject:node.key];
    }];
    
    NSMutableString *string = [NSMutableString string];
    [string appendFormat:@"nodes: [%@]",[array componentsJoinedByString:@" "]];
    [string appendFormat:@", isEmpty: %@",[self isEmpty]?@"yes":@"no"];
    [string appendFormat:@", count: %d",[self count]];
    [string appendFormat:@", height: %d.",[self height]];
    return string;
}

#pragma mark - search

// Return true if there is a node with the given key.
-(BOOL) contains:(ARBSTKey*)key {
    return [self objectForKey:key] != nil;
}

// Return true if there is a node with the given key,
// starting the search at the given node.
-(BOOL) contains:(ARBSTKey*)key fromNode:(ARBSTRedBlackNode*)node {
    return [self objectForKey:key fromNode:node] != nil;
}

// Return the node with the given key.
-(ARBSTRedBlackNode*) objectForKey:(ARBSTKey*)key {
    return [self objectForKey:key fromNode:_root];
}

// Return the node with the given key,
// starting the search from the given node.
-(ARBSTRedBlackNode*) objectForKey:(ARBSTKey*)key
                          fromNode:(ARBSTRedBlackNode*)node
{
    if (node == nil) return nil;
    NSComparisonResult cmp = [key compare:node.key];
    ARBSTRedBlackNode *object;
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
        self.root = [self insertKey:key value:value onNode:self.root];
        self.root.color = ARBSTLinkBlack;
        NSAssert([self check],@"The tree is inconsistent.");
    }
}


-(ARBSTRedBlackNode*) insertKey:(ARBSTKey*)key
                          value:(ARBSTValue*)value
                         onNode:(ARBSTRedBlackNode*)node
{
    if (node == nil){
        return [[ARBSTRedBlackNodeImpl alloc] initWithKey:key value:value color:ARBSTLinkRed count:1];
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
        
        // fix-up any right-leaning links
        if ([node.right isRed] && ![node.left isRed])      {  node = [self rotateLeft:node];   }
        if ([node.left isRed]  &&  [node.left.left isRed]) {  node = [self rotateRight:node];  }
        if ([node.left isRed]  &&  [node.right isRed])     {  [self flipColors:node];          }
        
        node.count = [self countOfNode:node.left] + 1 + [self countOfNode:node.right];
        
        return node;
    }
}


-(ARBSTRedBlackNode*) rotateLeft:(ARBSTRedBlackNode*)node
{
    NSAssert( (node!=nil) && [node.right isRed], @"inappropriate rotation");
    ARBSTRedBlackNode *n = node.right;
    node.right = n.left;
    n.left = node;
    n.color = n.left.color;
    n.left.color = ARBSTLinkRed;
    n.count = node.count;
    node.count = [self countOfNode:node.left] + [self countOfNode:node.right] + 1;
    return n;
}

// make a left-leaning link lean to the right
-(ARBSTRedBlackNode*) rotateRight:(ARBSTRedBlackNode*)n
{
    NSAssert( (n!=nil) && [n.left isRed], @"inappropriate rotation");
    ARBSTRedBlackNode* x = n.left;
    n.left = x.right;
    x.right = n;
    x.color = x.right.color;
    x.right.color = ARBSTLinkRed;
    x.count = n.count;
    n.count = [self countOfNode:n.left] + [self countOfNode:n.right] + 1;
    return x;
}

-(void) flipColors:(ARBSTRedBlackNode*)n
{
    // node must have opposite color of its two children
    NSAssert( (n != nil) && (n.left != nil) && (n.right != nil), @"node shouldn't flip colors");
    NSAssert( (![n isRed] && [n.left isRed] && [n.right isRed])
              || ([n isRed] && ![n.left isRed] && ![n.right isRed]), @"node shouldn't flip colors");
    n.color = !n.color;
    n.left.color = !n.left.color;
    n.right.color = !n.right.color;
}


#pragma mark - delete

// Delete the minimum key.
-(void) deleteMin
{
    NSAssert(![self isEmpty],@"The tree is empty.");
    // if both children of root are black, set root to red
    if (![_root.left isRed] && ![_root.right isRed]){
        _root.color = ARBSTLinkRed;
    }
    _root = [self deleteMin:_root];
    if (![self isEmpty]) {
        _root.color = ARBSTLinkBlack;
    }
    NSAssert([self check],@"The tree is inconsistent.");
}


// Delete the minimum key, starting the search at the given node.
// Return the new minimum key for this position.
-(ARBSTRedBlackNode*) deleteMin:(ARBSTRedBlackNode*)n
{
    if (n.left == nil) {
        return nil;
    }
    if (![n.left isRed] && ![n.left.left isRed]){
        n = [self moveRedLeft:n];
    }
    n.left = [self deleteMin:n.left];
    return [self balance:n];
}


// Delete the maximum key.
-(void) deleteMax
{
    NSAssert(![self isEmpty],@"The tree is empty.");
    // if both children of root are black, set root to red
    if (![_root.left isRed] && ![_root.right isRed]){
        _root.color = ARBSTLinkRed;
    }
    _root = [self deleteMax:_root];
    if (![self isEmpty]) {
        _root.color = ARBSTLinkBlack;
    }
    NSAssert([self check],@"The tree is inconsistent.");
}


// Return the node with the maximum key, starting the search at the given node.
-(ARBSTRedBlackNode*) deleteMax:(ARBSTRedBlackNode*)n
{    
    if ([n.left isRed]){
        n = [self rotateRight:n];
    }
    if (n.right == nil){
        return nil;
    }
    if (![n.right isRed] && ![n.right.left isRed]){
        n = [self moveRedRight:n];
    }
    n.right = [self deleteMax:n.right];
    return [self balance:n];
}


// Delete the exact key.
-(void) deleteKey:(ARBSTKey*)key
{
    if (![self contains:key]) {
        trace(@"symbol table does not contain %@",key);
        return;
    }
    
    // if both children of root are black, set root to red
    if (![_root.left isRed] && ![_root.right isRed]){
        _root.color = ARBSTLinkRed;
    }
    
    _root = [self deleteKey:key node:_root];
    if (![self isEmpty]) {
        _root.color = ARBSTLinkBlack;
    }
    
    NSAssert([self check],@"The tree is inconsistent.");
}


// Delete the exact key, starting the search at the given node.
-(ARBSTRedBlackNode*) deleteKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)n {
    
    NSAssert([self contains:key fromNode:n],@"The tree doesn't contain the key %@",key);
    
    if ([key compare:n.key] == NSOrderedAscending)  {
        if (![n.left isRed] && ![n.left.left isRed]){
            n = [self moveRedLeft:n];
        }
        n.left = [self deleteKey:key node:n.left];
    }
    else {
        if ([n.left isRed]){
            n = [self rotateRight:n];
        }
        if ([key compare:n.key] == 0 && (n.right == nil)){
            return nil;
        }
        if (![n.right isRed] && ![n.right.left isRed]){
            n = [self moveRedRight:n];
        }
        if ([key compare:n.key] == 0) {
            n.value = [self objectForKey:[self min:n.right].key fromNode:n.right];
            n.key = [self min:n.right].key;
            n.right = [self deleteMin:n.right];
        } else {
            n.right = [self deleteKey:key node:n.right];
        }
    }
    return [self balance:n];
}


// Assuming that h is red and both h.left and h.left.left
// are black, make h.left or one of its children red.
-(ARBSTRedBlackNode*) moveRedLeft:(ARBSTRedBlackNode*)n
{
    NSAssert(n != nil, @"Node is nil");
    NSAssert([n isRed] && ![n.left isRed] && ![n.left.left isRed], @"inappropriate operation");
    
    [self flipColors:n];
    if ([n.right.left isRed]) {
        n.right = [self rotateRight:n.right];
        n = [self rotateLeft:n];
    }
    return n;
}


// Assuming that h is red and both h.right and h.right.left
// are black, make h.right or one of its children red.
-(ARBSTRedBlackNode*) moveRedRight:(ARBSTRedBlackNode*)n
{
    NSAssert(n != nil, @"Node is nil");
    NSAssert( [n isRed] && ![n.right isRed] && ![n.right.left isRed], @"inappropriate operation");
    [self flipColors:n];
    if ([n.left.left isRed]) {
        n = [self rotateRight:n];
    }
    return n;
}


// restore red-black tree invariant
-(ARBSTRedBlackNode*) balance:(ARBSTRedBlackNode*)n
{
    NSAssert(n != nil, @"Node is nil");
    
    if ([n.right isRed])                       {  n = [self rotateLeft:n];    }
    if ([n.left isRed] && [n.left.left isRed]) {  n = [self rotateRight:n];   }
    if ([n.left isRed] && [n.right isRed])     {  [self flipColors:n];        }
    
    n.count = [self countOfNode:n.left]  + [self countOfNode:n.right] + 1;
    return n;
}


#pragma mark - min, max, floor, and ceiling

// Return the minimum key of the tree.
-(ARBSTKey*) min {
    if ([self isEmpty]) return nil;
    return [self min:_root].key;
}

// Return the node with the minimum key, starting the search from the given node.
-(ARBSTRedBlackNode*) min:(ARBSTRedBlackNode*)node {
    NSAssert(node!=nil,@"node is nil");
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
-(ARBSTRedBlackNode*) max:(ARBSTRedBlackNode*)node {
    NSAssert(node!=nil,@"node is nil");
    if (node.right == nil) {
        return node;
    } else {
        return [self max:node.right];
    }
}


// Return the largest key in the BST less than or equal to the given key.
-(ARBSTKey*) floorKey:(ARBSTKey*)key {
    ARBSTRedBlackNode* node = [self floorKey:key node:_root];
    if (node == nil) return nil; // nil root
    else return node.key;
}

// Return the node with the largest key in the BST less than or equal to the given key,
// starting the search from the given node.
-(ARBSTRedBlackNode*) floorKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node
{
    if (node == nil) {
        return nil;
    }
    ARBSTRedBlackNode *result;
    NSComparisonResult cmp = [key compare:node.key];
    switch (cmp) {
        case NSOrderedAscending:
            // 'key' less than node.key so keep looking on left branch
            result = [self floorKey:key node:node.left];
            break;
        case NSOrderedDescending: {
            // 'key' greater than node.key so keep looking on right branch
            ARBSTRedBlackNode* t = [self floorKey:key node:node.right];
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
    ARBSTRedBlackNode* node = [self ceilingKey:key node:_root];
    if (node == nil) return nil;
    else return node.key;
}

// Return the node with the smallest key in the BST greater than or equal to the given key,
// starting the search from the given node.
-(ARBSTRedBlackNode*) ceilingKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node {
    if (node == nil) {
        return nil;
    }
    ARBSTRedBlackNode *result;
    NSComparisonResult cmp = [key compare:node.key];
    switch (cmp) {
        case NSOrderedAscending: {
            ARBSTRedBlackNode *t = [self ceilingKey:key node:node.left];
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
    ARBSTRedBlackNode* node = [self selectRank:rank node:_root]; // start at root
    return node.key;
}

// Return the node containing the key of rank k
// (the key such that precisely k other keys in the BST are smaller).
-(ARBSTRedBlackNode*) selectRank:(NSInteger)rank node:(ARBSTRedBlackNode*)node
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
-(NSInteger) rankKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node
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
                            fromNode:(ARBSTRedBlackNode*) node
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

-(NSInteger) height:(ARBSTRedBlackNode*)node {
    if (node == nil) return 0;
    return 1 + imax([self height:node.left], [self height:node.right]);
}


#pragma mark - Check integrity

-(BOOL) check {
    if (![self isBST])            warn(@"Not in symmetric order");
    if (![self isSizeConsistent]) warn(@"Subtree counts not consistent");
    if (![self isRankConsistent]) warn(@"Ranks not consistent");
    if (![self is23])             warn(@"Not a 2-3 tree");
    if (![self isBalanced])       warn(@"Not balanced");
    return [self isBST] && [self isSizeConsistent] && [self isRankConsistent]
           && [self is23] && [self isBalanced];
}

// does this binary tree satisfy symmetric order?
// Note: this test also ensures that data structure is a binary tree since order is strict
-(BOOL) isBST {
    return [self isBST:_root minKey:nil maxKey:nil];
}

// Returns true if the subtree rooted at node is a BST with all keys strictly between min and max.
// If min or max is null, it is treated as an empty constraint.
-(BOOL) isBST:(ARBSTRedBlackNode*)node minKey:(ARBSTKey*)minKey maxKey:(ARBSTKey*)maxKey
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

-(BOOL) isSizeConsistent:(ARBSTRedBlackNode*)node {
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
-(BOOL) isRankConsistent
{
    for (NSUInteger i = 0; i < [self count]; i++)
    {
        ARBSTKey *k = [self selectRank:i];
        if (i != [self rankKey:k]) return NO;
    }
    for (ARBSTKey* key in [self keys])
    {
        NSInteger rank = [self rankKey:key];
        NSComparisonResult cmp = [key compare:[self selectRank:rank]];
        if (cmp != NSOrderedSame) return NO;
    }
    return YES;
}


// Does the tree have no red right links, and at most one (left)
// red links in a row on any path?
-(BOOL) is23 {
    return [self is23:_root];
}

-(BOOL) is23:(ARBSTRedBlackNode*)x {
    if (x == nil) {
        return YES;
    }
    if ([x.right isRed]) {
        return NO;
    }
    if (x != _root && [x isRed] && [x.left isRed]){
        return NO;
    }
    return [self is23:x.left] && [self is23:x.right];
}


// do all paths from root to leaf have same number of black edges?
-(BOOL) isBalanced
{
    NSUInteger black = 0; // number of black links on path from root to min
    ARBSTRedBlackNode* x = _root;
    while (x != nil) {
        if (![x isRed]) {
            black++;
        }
        x = x.left;
    }
    return [self isBalancedNode:_root blackLinks:black];
}


// does every path from the root to a leaf have the given number of black links?
-(BOOL) isBalancedNode:(ARBSTRedBlackNode*)x blackLinks:(NSUInteger)black
{
    if (x == nil) {
        return black == 0;
    }
    if (![x isRed]) {
        black--;
    }
    return [self isBalancedNode:x.left blackLinks:black]
           && [self isBalancedNode:x.right blackLinks:black];
}


@end
