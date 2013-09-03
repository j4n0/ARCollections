
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

#import "ARGraphNode.h"
#import "ARGraphEdge.h"
#import "ARContainer.h"
#import "ARArrayList.h"

/** Abstract graph protocol. */
@protocol ARDiGraph <ARContainer>

-(id)initWithNodes:(NSSet*)nodes;
-(BOOL) hasNode:(ARGraphNode*)node;

#pragma mark - Read
-(ARGraphNode*)nodeByValue:(id)value;
-(NSSet*) nodes;

#pragma mark - Add
-(ARGraphEdge*) addEdgeFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode withWeight:(float)weight;
-(ARGraphEdge*) addEdgeFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode;
-(ARGraphNode*) addNode:(ARGraphNode*)node;

#pragma mark - Remove
-(void) removeEdge:(ARGraphEdge*)edge;
-(void) removeNode:(ARGraphNode*)node;

@end
