
// Forked from Aaron Qian's https://github.com/aq1018/digraph
// MIT License https://github.com/aq1018/digraph/blob/master/LICENSE.txt

#import "ARGraphEdge.h"
#import "ARGraphNode.h"

// See http://www.mikeash.com/pyblog/friday-qa-2010-06-18-implementing-equality-and-hashing.html
#define NSUINT_BIT (CHAR_BIT * sizeof(NSUInteger))
#define NSUINTROTATE(val, howmuch) ((((NSUInteger)val) << howmuch) | (((NSUInteger)val) >> (NSUINT_BIT - howmuch)))


@interface ARGraphEdge()

// Redefine fromNode to read-write.
@property (nonatomic, readwrite, strong) ARGraphNode *fromNode;

// Redefine toNode to read-write.
@property (nonatomic, readwrite, strong) ARGraphNode *toNode;

@end


@implementation ARGraphEdge

- (id)init {
    return [self initWithFromNode:nil toNode:nil weight:0];
}

- (id)initWithFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode {
    return [self initWithFromNode:fromNode toNode:toNode weight:0];
}

- (id)initWithFromNode:(ARGraphNode*)fromNode toNode:(ARGraphNode*)toNode weight:(float)weight {
    self = [super init];
    if (self) {
        _fromNode = fromNode;
        _toNode = toNode;
        _edgeWeight = weight;
    }
    return self;
}

/** Return a human readable description showing just the weight. */
-(NSString*) description {
    return [NSString stringWithFormat:@"%@-%.f->%@", _fromNode.value, self.edgeWeight, _toNode.value];
}

/** Return a human readable description showing the nodes and weight. */
-(NSString*) longDescription {
    return [NSString stringWithFormat:@"%@ -- %2.0f --> %@", self.fromNode.value, self.edgeWeight, self.toNode.value];
}

/**
 * Calculates the hash based on the source and target node.
 * @return The hash.
 */
- (NSUInteger)hash
{
    NSUInteger h = 0;
    NSUInteger p[] = { [self.fromNode hash], [self.toNode hash] };
    
    for (short i = 0; i < 2; i++ ) {
        h += p[i];
        h += ( h << 10 );
        h ^= ( h >> 6 );
    }
    
    h += ( h << 3 );
    h ^= ( h >> 11 );
    h += ( h << 15 );
    
    return h;
}

/**
 * Returns true if this edge is equal to the given edge.
 * @param other The other edge to compare with.
 * @return true if this edge is equal to the given edge.
 */
- (BOOL)isEqual:(id)other
{
    // See Cocoa Fundamentals Guide > Cocoa Objects > Introspection > Object Comparison.
    
    // pointer equality
    if (other == self) {
        return YES;
    }
    // class equality
    if (!other || ![other isKindOfClass:[self class]]) {
        return NO;
    }
    // object comparator
    return [self isEqualToARGraphEdge:other];
}

- (BOOL)isEqualToARGraphEdge:(ARGraphEdge*)other {
    if (self == other){
        return YES;
    }
    if (([self fromNode]==nil) && ([other fromNode]==nil)){
        return YES;
    }
    if (![[self fromNode] isEqualToARGraphNode: [other fromNode]]){
        return NO;
    }
    if (![[self toNode] isEqualToARGraphNode: [other toNode]]){
        return NO;
    }
    return YES;
}

#pragma mark - NSCopying

-(ARGraphEdge*) copyWithZone: (NSZone*) zone {
    return [[ARGraphEdge allocWithZone:zone] initWithFromNode:_fromNode toNode:_toNode weight:_edgeWeight];
}


@end
