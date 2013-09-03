
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARDiGraphImpl.h"


/** Test for the ARGraphEdge. */
@interface ARGraphEdgeTest : SenTestCase
@end

@implementation ARGraphEdgeTest


-(void)testInit {
    ARGraphEdge *edge = [ARGraphEdge new];
    STAssertTrue( ([edge fromNode]==nil), nil);
    STAssertTrue( ([edge toNode]==nil), nil);
    STAssertTrue( ([edge edgeWeight]==0), nil);
}


-(void)testInitWithFromNodeToNodeWeight {
    ARGraphNode *from = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *to = [[ARGraphNode alloc] initWithValue:@"B"];
    ARGraphEdge *edge = [[ARGraphEdge alloc]initWithFromNode:from toNode:to weight:1.0];
    STAssertTrue( ([edge.fromNode isEqualToARGraphNode:from]), nil);
    STAssertTrue( ([edge.toNode isEqualToARGraphNode:to]), nil);
    STAssertTrue( (edge.edgeWeight==1.0), nil);;
    ARGraphEdge *otherEdge = [[ARGraphEdge alloc]initWithFromNode:from toNode:to weight:1.0];
    STAssertTrue( ([edge isEqualToARGraphEdge:otherEdge]), nil);
}


-(void)testInitWithFromNodeToNode {
    ARGraphNode *from = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *to = [[ARGraphNode alloc] initWithValue:@"B"];
    ARGraphEdge *edge = [[ARGraphEdge alloc]initWithFromNode:from toNode:to];
    STAssertTrue( ([edge.fromNode isEqualToARGraphNode:from]), nil);
    STAssertTrue( ([edge.toNode isEqualToARGraphNode:to]), nil);
    STAssertTrue( (edge.edgeWeight==0.0), nil);
}


-(void)testIsEqualToARGraphEdge {
    ARGraphEdge *edge = [ARGraphEdge new];
    ARGraphEdge *otherEdge = [ARGraphEdge new];
    STAssertTrue( ([edge isEqualToARGraphEdge:otherEdge]), nil);
}


-(void)testCopy {
    ARGraphNode *from = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *to = [[ARGraphNode alloc] initWithValue:@"B"];
    ARGraphEdge *edge = [[ARGraphEdge alloc]initWithFromNode:from toNode:to weight:1.0];
    STAssertTrue( ([edge isEqualToARGraphEdge:[edge copy]]), nil);
}

@end
