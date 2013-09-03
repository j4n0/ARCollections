
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

@class ARGraphNode;

/** Weighted edge between two nodes. */
@interface ARGraphEdge : NSObject<NSCopying>

@property (nonatomic, readonly, strong) ARGraphNode *fromNode;
@property (nonatomic, readonly, strong) ARGraphNode *toNode;
@property (nonatomic, readwrite, assign) float edgeWeight;

#pragma mark - Initialize
- (id)init;
- (id)initWithFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode;
- (id)initWithFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode weight:(float)weight;

#pragma mark - Other
- (BOOL)isEqual:(id)other;
- (NSString*) description;
- (NSString*) longDescription;
- (NSUInteger) hash;

/**
 * Returns true if the edges connect the same nodes (even if both are nil), 
 * disregarding the weight.
 */
- (BOOL)isEqualToARGraphEdge:(ARGraphEdge*)other;

@end
