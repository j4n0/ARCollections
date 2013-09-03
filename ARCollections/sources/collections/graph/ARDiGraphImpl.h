
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

#import "ARArrayList.h"
#import "ARDiGraph.h"
#import "ARGraphEdge.h"
#import "ARGraphNode.h"
#import "ARQueueList.h"
#import "ARStackList.h"

/** 
 * A directed graph with weighted edges.
 * Node's children are unordered.
 */
@interface ARDiGraphImpl : NSObject <ARDiGraph>

/** Shortcut for addEdgeFromNode:toNode:withWeight: */
-(void) :(id<ARDiGraph>)g :(NSString*)from :(NSNumber*)e :(NSString*)to;

@end


@interface ARDiGraphImpl(Traversal)

 /* Return the shortest path from the source node to the target node or nil. 
  */
-(ARArrayList*) shortestPathFrom:(ARGraphNode*)source to:(ARGraphNode*)target;

/**
 * Return a node with the given value starting from the given start node
 * using the depth-first algorithm (which goes as deep as possible before
 * visiting neighbour nodes). Returns nil if the node is not found.
 */
-(ARArrayList*) depthFirstSearchForValue:(id)value start:(ARGraphNode*)start;

/**
 * Return a node with the given value starting from the given start node
 * using the breadth-first algorithm (which visits neighbour nodes before going
 * deep into the branch). Returns nil if the node is not found.
 */
-(ARArrayList*) breadthFirstSearchForValue:(id)value start:(ARGraphNode*)start;

@end
