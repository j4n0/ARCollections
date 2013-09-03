
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARDiGraphImpl.h"


/** Test for the ARGraphNode. */
@interface ARGraphNodeTest : SenTestCase
@end

@implementation ARGraphNodeTest

#pragma mark - NSObject

-(void) testHash {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    STAssertFalse( ([nodeA hash]==[nodeB hash]), nil);
}

-(void) testIsEqual {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"A"];
    STAssertTrue( ([nodeA hash] == [nodeB hash]), nil);
    nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    STAssertFalse( ([nodeA hash] == [nodeB hash]), nil);
}

-(void) testIsEqualToARGraphNode {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"A"];
    STAssertTrue( ([nodeA isEqualToARGraphNode:nodeB]), nil);
}


#pragma mark - Edges

-(void) testEdgeConnectedTo {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkToNode:nodeB];
    ARGraphEdge *edge = [nodeA edgeConnectedTo:nodeB];
    STAssertTrue( ([edge.toNode isEqualToARGraphNode:nodeB]), nil);
    STAssertTrue( ([edge.fromNode isEqualToARGraphNode:nodeA]), nil);
}

-(void) testEdgeConnectedFrom {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkToNode:nodeB];
    ARGraphEdge *edge = [nodeB edgeConnectedFrom:nodeA];
    STAssertTrue( ([edge.toNode isEqualToARGraphNode:nodeB]), nil);
    STAssertTrue( ([edge.fromNode isEqualToARGraphNode:nodeA]), nil);
}


#pragma mark - Initialize

-(void) testInit {
    ARGraphNode *node = [ARGraphNode new];
    STAssertFalse( (node.isSource), nil);
    STAssertFalse( (node.isSink), nil);
    STAssertTrue( ([node.outNodes count]==0), nil);
    STAssertTrue( ([node.inNodes count]==0), nil);
    STAssertTrue( (node.inDegree==0), nil);
    STAssertTrue( (node.outDegree==0), nil);
}

-(void) testInitWithValue {
    ARGraphNode *node = [[ARGraphNode alloc] initWithValue:@"A"];
    STAssertFalse( (node.isSource), nil);
    STAssertFalse( (node.isSink), nil);
    STAssertTrue( ([node.outNodes count]==0), nil);
    STAssertTrue( ([node.inNodes count]==0), nil);
    STAssertTrue( (node.inDegree==0), nil);
    STAssertTrue( (node.outDegree==0), nil);
    STAssertTrue( ([node.value isEqualToString:@"A"]), nil);
}


#pragma mark - Linking

-(void) testLinkToNode {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkToNode:nodeB];
    [nodeB linkToNode:nodeA];
    STAssertTrue( ([[nodeA outNodes] count]==1), nil);
    STAssertTrue( ([[[nodeA outNodes] anyObject] isEqualToARGraphNode:nodeB]), nil);
    ARGraphEdge* edgeToB = (ARGraphEdge*)[[nodeA edgesOut] anyObject];
    ARGraphNode *node = [edgeToB toNode];
    STAssertTrue( ([node isEqualToARGraphNode:nodeB]), nil);
}

-(void) testLinkToNodeWeight {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkToNode:nodeB weight:1.0];
    [nodeB linkToNode:nodeA weight:2.0];
    STAssertTrue( ([[nodeA outNodes] count]==1), nil);
    STAssertTrue( ([[[nodeA outNodes] anyObject] isEqualToARGraphNode:nodeB]), nil);
    ARGraphEdge* edgeToB = (ARGraphEdge*)[[nodeA edgesOut] anyObject];
     STAssertTrue( (edgeToB.edgeWeight==1.0), @"%d",edgeToB.edgeWeight);
}

-(void) testLinkFromNode {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkFromNode:nodeB];
    STAssertTrue( ([[nodeB outNodes] count]==1), nil);
    STAssertTrue( ([[[nodeB outNodes] anyObject] isEqualToARGraphNode:nodeA]), nil);
    ARGraphEdge* edgeToA = (ARGraphEdge*)[[nodeB edgesOut] anyObject];
    ARGraphNode *node = [edgeToA toNode];
    STAssertTrue( ([node isEqualToARGraphNode:nodeA]), nil);
}

-(void) testLinkFromNodeWeight {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkFromNode:nodeB weight:1.0];
    STAssertTrue( ([[nodeB outNodes] count]==1), nil);
    STAssertTrue( ([[[nodeB outNodes] anyObject] isEqualToARGraphNode:nodeA]), nil);
    ARGraphEdge* edgeToA = (ARGraphEdge*)[[nodeB edgesOut] anyObject];
    ARGraphNode *node = [edgeToA toNode];
    STAssertTrue( ([node isEqualToARGraphNode:nodeA]), nil);
    STAssertTrue( (edgeToA.edgeWeight==1.0), nil);
}

-(void) testUnlinkFromNode {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkFromNode:nodeB];
    STAssertTrue( ([[[nodeB outNodes] anyObject] isEqualToARGraphNode:nodeA]), @"%@",[[nodeB outNodes] anyObject]);
    [nodeA unlinkFromNode:nodeB];
    STAssertTrue( ([[nodeB outNodes] count]==0), @"%d",[[nodeB outNodes] count]);
    ARGraphEdge* edgeToA = (ARGraphEdge*)[[nodeB edgesOut] anyObject];
    STAssertTrue( (edgeToA==nil), nil);
}

-(void) testUnLinkToNode {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkToNode:nodeB];
    [nodeA unlinkToNode:nodeB];
    STAssertTrue( ([[nodeA outNodes] count]==0), nil);
    STAssertTrue( ([[[nodeA outNodes] anyObject] isEqual:nodeB]==0), nil);
    ARGraphEdge* edgeToB = (ARGraphEdge*)[[nodeA edgesOut] anyObject];
    STAssertTrue( (edgeToB==nil), nil);
}


#pragma mark - NSCopying

-(void) testCopyWithZone {
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [nodeA linkToNode:nodeB weight:1.0];
    [nodeB linkToNode:nodeA weight:2.0];
    debug(@"nodeA: %@",nodeA);
    // note: edges are not copied or considered for equality
    STAssertTrue( ([nodeA isEqualToARGraphNode:[nodeA copy]]), nil);
}


@end
