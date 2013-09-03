
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

@class ARGraphEdge;

/** 
 * Node of the graph. It has a set of incoming and outgoing edges, and a value.
 */
@interface ARGraphNode : NSObject<NSCopying>

@property (nonatomic, readonly, strong) NSMutableSet *edgesIn;
@property (nonatomic, readonly, strong) NSMutableSet *edgesOut;
@property (nonatomic, readonly, strong) id value;


#pragma mark - Edges

- (ARGraphEdge*)edgeConnectedTo:(ARGraphNode*)toNode;
- (ARGraphEdge*)edgeConnectedFrom:(ARGraphNode*)fromNode;


#pragma mark - Initialize

- (id)init;
- (id)initWithValue:(id)value;


#pragma mark - Linking

- (void) unlinkToNode:(ARGraphNode*)node;
- (void) unlinkFromNode:(ARGraphNode*)node;

// Attempting to creating dupe edge (same source and target, weight doesn't matter) is ignored.
- (ARGraphEdge*) linkFromNode:(ARGraphNode*)node;
- (ARGraphEdge*) linkToNode:(ARGraphNode*)node;
- (ARGraphEdge*) linkToNode:(ARGraphNode*)node weight:(float)weight;
- (ARGraphEdge*) linkFromNode:(ARGraphNode*)node weight:(float)weight;


#pragma mark - NSCopying

-(id)copyWithZone:(NSZone*)zone;


#pragma mark - Other 

-(NSString*) description;
-(NSUInteger) hash;
-(BOOL) isEqualToARGraphNode:(ARGraphNode*)otherNode; // only the value is compared!
-(NSString*) longDescription;


#pragma mark - Properties

- (BOOL)isSource;          // has outgoing edges
- (BOOL)isSink;            // has incoming edges
- (NSMutableSet*)outNodes; // nodes pointed to by this node
- (NSMutableSet*)inNodes;  // nodes pointing to this node
- (NSUInteger)inDegree;    // incoming edges
- (NSUInteger)outDegree;   // outgoing edges

@end
