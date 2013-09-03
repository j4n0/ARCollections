
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

#import "ARDiGraphImpl.h"

@implementation ARDiGraphImpl {
    NSMutableSet *_mNodes;
}

@synthesize count = _count;

-(NSString*) description {
    NSMutableString *string = [NSMutableString string];
    for (ARGraphNode *node in self.nodes) {
        [string appendFormat:@"%@\n",[node longDescription]];
        for (ARGraphEdge *edge in node.edgesOut) {
            [string appendFormat:@"  %@\n",[edge longDescription]];
        }
    }
    return string;
}


/** @name ARDiGraph */

- (id)initWithNodes:(NSSet*)nodes {
    self = [super init];
    if (self) {
        _mNodes = [NSMutableSet setWithSet:nodes];
    }
    return self;
}

- (BOOL)hasNode:(ARGraphNode*)node {
    // !! collapses the returned object to a BOOL,
    // it's like [self.mNodes member:node]!=nil
    return !![_mNodes member:node];
}

-(ARGraphNode*)nodeByValue:(id)value {
    for(ARGraphNode *n in self.nodes){
        if ([n.value isEqual:value]){
            return n;
        }
    }
    return nil;
}

-(NSSet*)nodes {
    return [NSSet setWithSet:_mNodes];
}


#pragma mark - Add

- (ARGraphEdge*) addEdgeFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode withWeight:(float)weight {
    fromNode = [self addNode:fromNode];
    toNode   = [self addNode:toNode];
    return [fromNode linkToNode:toNode weight:weight];
}

- (ARGraphEdge*) addEdgeFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode {
    fromNode = [self addNode:fromNode];
    toNode   = [self addNode:toNode];
    return [fromNode linkToNode:toNode];
}

- (ARGraphNode*) addNode:(ARGraphNode*)node {
    ARGraphNode* existing = [_mNodes member:node];
    if (!existing) {
        [_mNodes addObject:node];
        existing = node;
    }
    return existing;
}

-(void) :(id<ARDiGraph>)g :(NSString*)from :(NSNumber*)e :(NSString*)to {
    [g addEdgeFromNode:[[ARGraphNode alloc] initWithValue:from]
                toNode:[[ARGraphNode alloc] initWithValue:to]
            withWeight:[e floatValue]];
}


#pragma mark - Remove

- (void)removeEdge:(ARGraphEdge*)edge {
    [[edge fromNode] unlinkToNode:[edge toNode]];
}

- (void)removeNode:(ARGraphNode*)node {
    [_mNodes removeObject:node];
}


#pragma mark - ARContainer

-(NSUInteger) count {
    return [_mNodes count];
}

- (id)init {
    self = [super init];
    if (self) {
        _mNodes = [NSMutableSet set];
    }
    return self;
}

-(BOOL) isEmpty {
    return [_mNodes count]==0;
}


#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_mNodes forKey:NSStringFromClass([self class])];
}

- (id)initWithCoder:(NSCoder*)coder {
    self = [self init];
    if (self) {
        _mNodes = [coder decodeObjectForKey:NSStringFromClass([self class])];
    }
    return self;
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone*)zone {
    ARDiGraphImpl *graph = [[ARDiGraphImpl alloc] initWithNodes:[_mNodes copy]];
    return graph;
}


#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id __unsafe_unretained [])buffer
                                    count:(NSUInteger)len {
    return [_mNodes countByEnumeratingWithState:state objects:buffer count:len];
}

@end


// BSD License. Author: jano@jano.com.es
@implementation ARDiGraphImpl(Traversal)

/* Using Dijkstra's algorithm to find shortest path.
 * See http://en.wikipedia.org/wiki/Dijkstra%27s_algorithm
 *
 * 1. Set every node weight to infinity.
 * 2. Set 'source' weight to 0.
 * 3. Set 'currentNode' to 'source'.
 * 4. For all adjacent nodes,
 *        - calculate the weight from the 'currentNode',
 *        - if the weight is smaller then
 *              - update the adjacent node with the new weight
 *              - store the node we came from to reach the adjacent node (use the 'prevDic' dictionary for this)
 * 5. If we updated the weight of the node we were looking for, then there is a solution.
 * 6. Use the 'prevDic' dictionary to gather all the previous node to the node we were looking for.
 */
- (ARArrayList*)shortestPathFrom:(ARGraphNode*)source to:(ARGraphNode*)target
{
    // sanity check
    if (![self.nodes containsObject:source] || ![self.nodes containsObject:target]) {
        warn(@"Source and/or target not in the graph");
        return nil; // a node is not in the graph
    }
    if ([source isEqual:target]){
        warn(@"Same source and target");
        return [ARArrayList new]; // source and target are the same
    }
    
    // This dictionary stores the node we came from when setting the minimum weight.
    // key=node with the minimum weight, object=node we came from.
    NSMutableDictionary *prevDic = [NSMutableDictionary dictionaryWithCapacity:[self.nodes count]];
    
    // set the min weight to infinity for all nodes
    NSMutableDictionary *minWeightDic = [NSMutableDictionary dictionaryWithCapacity:[self.nodes count]];
    for(ARGraphNode* node in self.nodes){
        [minWeightDic setObject:[NSNumber numberWithFloat:INFINITY] forKey:node];
    }
    
    // keep track of the unvisited nodes
    NSMutableSet *unvisited = [NSMutableSet setWithSet:self.nodes];
    
    // set weight of the initial node to 0
    [minWeightDic setObject:@0 forKey:source];

    // start at the source
    ARGraphNode *currentNode = source;
    do {
        // set the tentative distance on the adjacent nodes
        // (unless there is a previous smaller tentative distance)
        
        //trace(@"current: %@", currentNode);
        
        //ARGraphNode *minNode;
        float minWeight = INFINITY;
        
        for (ARGraphEdge *edge in [currentNode edgesOut])
        {
            // skip the adjacent node if already visited
            ARGraphNode *adjacentNode = edge.toNode;
            if (![unvisited member:adjacentNode]){
                continue;
            }
            
            // weight of the current node
            float currentNodeWeight = [[minWeightDic objectForKey:currentNode] floatValue];
            float tentativeWeight = currentNodeWeight + edge.edgeWeight;
            float existingWeight = [[minWeightDic objectForKey:adjacentNode] floatValue];
            
            // if we can improve the weight
            if (tentativeWeight < existingWeight){
                // save the new weight, and the node we came from
                [minWeightDic setObject:[NSNumber numberWithFloat:tentativeWeight] forKey:adjacentNode];
                [prevDic setObject:currentNode forKey:adjacentNode];
            }
            
            // keep track of the adjacent node with the less weight
            if (edge.edgeWeight < minWeight){
                minWeight = edge.edgeWeight;
                //minNode = adjacentNode;
            }
            
            //trace(@"prevDic: %@",prevDic);
            //trace(@"minWeightDic: %@",minWeightDic);
            //trace(@"minNode: %@",minNode);
        }
        
        // mark visited
        [unvisited removeObject:currentNode];
        
        // visit any of the remaining nodes with a tentative weight set
        ARGraphNode *next = nil;
        for (ARGraphNode *n in unvisited) {
            if ([[minWeightDic objectForKey:n]floatValue]!=INFINITY){
                next = n;
                break;
            }
        }
        
        // nodes left to visit, but no next node
        if (next==nil && [unvisited count]>0){
            warn(@"some nodes are unreachable");
            break;
        } else {
            currentNode = next;
        }
        
    } while ([unvisited count]>0);
    
    // did we reach the target node?
    if ([[minWeightDic objectForKey:target] floatValue]==INFINITY){
        warn(@"target node is unreachable");
        return nil;
    }
    
    // we start at target going back through the minimap paths we stored
    ARArrayList* pathArray = [ARArrayList new];
    [pathArray insertObjectAtEnd:target];
    ARGraphNode* temp = target;
    while ([prevDic objectForKey:temp]) {
        ARGraphNode *prev = [prevDic objectForKey:temp];
        [pathArray insertObjectAtEnd:prev];
        temp = prev;
    }
    
    // reverse the array so it goes from initial to target
    pathArray = [pathArray inverseARArray];
    
    return pathArray;
}


/* This visits each level of the graph in order (that is, siblings before children).
 *
 *   1. Queue the root,
 *   2. Dequeue an element and enqueue its children.
 *   3. Repeat 2.
 */
-(ARArrayList*) breadthFirstSearchForValue:(id)value start:(ARGraphNode*)start {

    // path to the node we are looking for
    ARArrayList *path = [[ARArrayList alloc] initWithCapacity:[self.nodes count]];
    
    ARQueueList *queue = [ARQueueList new];
    NSMutableSet *unvisited = [NSMutableSet setWithSet:self.nodes]; // this avoids repeating nodes

    // queue start
    [queue enqueue:start];
    [unvisited removeObject:start];
    
    while (![queue isEmpty])
    {
        // dequeue and add to path
        ARGraphNode *n = [queue dequeue];
        [path insertObjectAtEnd:n];
        if ([n.value isEqual:value])
        {
            debug(@"Found after dequeu'ing %@", [path componentsJoinedByString:@","]);
            return path;
        }

        // queue children (but only if they are unvisited)
        for (ARGraphEdge *edge in n.edgesOut){
            ARGraphNode *to = edge.toNode;
            if ([unvisited member:to]){
                [queue enqueue:to];
                [unvisited removeObject:to];
            }
        }
    }
    
    return nil;
}


// Same as the BFS but adding the children to a stack,
// so it traverses to the bottom of the graph first.
-(ARArrayList*) depthFirstSearchForValue:(id)value start:(ARGraphNode*)start {

    // path to the node we are looking for
    ARArrayList *path = [[ARArrayList alloc] initWithCapacity:[self.nodes count]];
    
    ARStackList *stack = [ARStackList new];
    NSMutableSet *unvisited = [NSMutableSet setWithSet:self.nodes];

    // push root
    [stack push:start];
    [unvisited removeObject:start];
    
    while (![stack isEmpty])
    {
        // pop and add to path
        ARGraphNode *n = [stack pop];
        [path insertObjectAtEnd:n];
        if ([n.value isEqual:value])
        {
            debug(@"Found after pop'ing %@",[path componentsJoinedByString:@","]);
            return path;
        }

        // push children (but only if they are unvisited)
        for (ARGraphEdge *edge in n.edgesOut){
            ARGraphNode *to = edge.toNode;
            if ([unvisited member:to]){
                [stack push:to];
                [unvisited removeObject:to];
            }
        }
    }
    
    return nil;
}

@end

