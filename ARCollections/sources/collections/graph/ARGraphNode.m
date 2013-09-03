
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

#import "ARGraphNode.h"
#import "ARGraphEdge.h"

@implementation ARGraphNode

-(NSString*) description {
    return [NSString stringWithFormat:@"%@", self.value];
}

-(NSString*) longDescription {
    return [NSString stringWithFormat:@"value:%@, nodes_in:%@, nodes_out:%@", self.value, self.edgesIn, self.edgesOut];
}

- (id)initWithValue:(id)value {
    if( (self=[super init]) ) {
		_value = value;
        _edgesIn  = [NSMutableSet set];
        _edgesOut = [NSMutableSet set];
	}
    return self;
}

- (BOOL)isEqualToARGraphNode:(ARGraphNode*)other {
    // pointer equality
    if (self == other){
        return YES;
    }
    // property equality
    if ([[self value]isEqual:[other value]]){
        return YES;
    }
    return NO;
}

- (NSUInteger)inDegree {
    return [[self edgesIn] count];
}

- (NSUInteger)outDegree {
    return [[self edgesOut] count];    
}

- (BOOL)isSink {
    return [self inDegree] > 0;
}

- (BOOL)isSource {
    return [self outDegree] > 0;
}

- (NSMutableSet*)outNodes {
    NSMutableSet* set = [NSMutableSet setWithCapacity:[_edgesOut count]];
    for(ARGraphEdge* edge in [self.edgesOut objectEnumerator] ) {
        [set addObject: [edge toNode]];
    }
    return set;
}

- (NSMutableSet*)inNodes {
    NSMutableSet* set = [NSMutableSet setWithCapacity:[self.edgesIn count]];
    for( ARGraphEdge* edge in [self.edgesIn objectEnumerator] ) {
        [set addObject:[edge fromNode]];
    }
    return set;    
}

- (ARGraphEdge*)edgeConnectedTo:(ARGraphNode*)toNode {
    for(ARGraphEdge* edge in [self.edgesOut objectEnumerator]) {
        if([edge toNode] == toNode)
            return edge;
    }
    return nil;
}

- (ARGraphEdge*)edgeConnectedFrom:(ARGraphNode*)fromNode {
    for(ARGraphEdge* edge in [ _edgesIn objectEnumerator]) {
        if( [edge fromNode] == fromNode )
            return edge;
    }
    return nil;    
}


#pragma mark - Node linking

- (ARGraphEdge*)linkToNode:(ARGraphNode*)node {
    return [self linkToNode:node weight:0];
}

- (ARGraphEdge*)linkToNode:(ARGraphNode*)node weight:(float)weight {
    ARGraphEdge* edge = [[ARGraphEdge alloc] initWithFromNode:self toNode:node weight:weight];
    [self.edgesOut addObject:edge];
    [node.edgesIn  addObject:edge];
    return edge;
}

- (ARGraphEdge*)linkFromNode:(ARGraphNode*)node {
    return [self linkFromNode:node weight:0];
}

- (ARGraphEdge*)linkFromNode:(ARGraphNode*)node weight:(float)weight {
    ARGraphEdge* edge = [[ARGraphEdge alloc] initWithFromNode:node toNode:self weight:weight];
    [self.edgesIn  addObject:edge];
    [node.edgesOut addObject:edge];
    return edge;
}

- (void)unlinkToNode:(ARGraphNode*)node {
    ARGraphEdge* edge = [self edgeConnectedTo:node];
    ARGraphNode* from = [edge fromNode];
    ARGraphNode* to   = [edge toNode];
    [from.edgesOut removeObject:edge];
    [to.edgesIn    removeObject:edge];
}

- (void)unlinkFromNode:(ARGraphNode*)node {
    ARGraphEdge* edge = [self edgeConnectedFrom:node];
    ARGraphNode* from = [edge fromNode];
    ARGraphNode* to   = [edge toNode];
    [from.edgesOut removeObject:edge];
    [to.edgesIn    removeObject:edge];
}


#pragma mark - NSObject

- (id)init {
    return [self initWithValue:nil];
}


/* doesn't work in ARC because instance variables are already nil
   by the time this is called.
- (void)dealloc {
    // remove outgoing edges
    for (ARGraphEdge* edgeOut in self.edgesOut) {
        [edgeOut.toNode unlinkFromNode:self];
        NSLog(@"edgeOut.toNode.edgesIn: %@", edgeOut.toNode.edgesIn);
    }
    [self.edgesOut removeAllObjects];
    // remove incoming edges
    for (ARGraphEdge* edgeIn in self.edgesIn) {
        [edgeIn.fromNode unlinkToNode:self];
        NSLog(@"edgeIn.fromNode: %@", edgeIn.fromNode.edgesOut);
    }
    [self.edgesIn removeAllObjects];
}
*/


- (NSUInteger)hash {
    return [ _value hash];
}


- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToARGraphNode:other];
}

#pragma mark - NSCopying

-(id) copyWithZone:(NSZone*)zone {
    ARGraphNode *node = [[ARGraphNode allocWithZone: zone] initWithValue:_value];
    /* // copy edges in and out
     for (ARGraphEdge *edgeIn in self.edgesIn) {
     [node linkFromNode:edgeIn.fromNode weight:edgeIn.weight];
     }
     for (ARGraphEdge *edgeOut in self.edgesOut) {
     [node linkToNode:edgeOut.toNode weight:edgeOut.weight];
     } */
    return node;
}

@end
