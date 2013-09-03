
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARDiGraphImpl.h"
#import "ARDiGraph.h"


/** Test for the ARDiGraph. */
@interface ARDiGraphTest : SenTestCase
@end

@implementation ARDiGraphTest


-(void)testNodes
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    STAssertTrue(([graph.nodes count]==2),nil);
}

-(void)testNodeByValue
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    STAssertTrue( ([[graph nodeByValue:@"A"] isEqualToARGraphNode:nodeA]),nil);
    STAssertTrue( ([[graph nodeByValue:@"B"] isEqualToARGraphNode:nodeB]),nil);
}


#pragma mark Graph

-(void)testInit
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    STAssertTrue( ([[graph nodes]count]==0), nil);
}

-(void)testHasNode
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    STAssertTrue( ([graph hasNode:nodeA]),nil);
    STAssertTrue( ([graph hasNode:nodeB]),nil);
}

-(void)testAddEdgeFromNodeToNodeWithWeight
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    ARGraphEdge *edge = [graph addEdgeFromNode:nodeA toNode:nodeB withWeight:1.0];
    STAssertTrue( ([[nodeB edgeConnectedFrom:nodeA] isEqualToARGraphEdge:edge]), nil);
    STAssertTrue( ([edge edgeWeight]),nil);
}

-(void)testAddEdgeFromNodeToNode
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    ARGraphEdge *edge = [graph addEdgeFromNode:nodeA toNode:nodeB];
    STAssertTrue( ([[nodeB edgeConnectedFrom:nodeA] isEqualToARGraphEdge:edge]), nil);
    STAssertTrue( ([edge edgeWeight]==0), @"it's %d",[edge edgeWeight]);
}

-(void)testRemoveEdge
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    ARGraphEdge *edge = [graph addEdgeFromNode:nodeA toNode:nodeB withWeight:1.0];
    STAssertTrue( ([nodeA.outNodes count]==1), @"it's %d",[nodeA.outNodes count]);
    [graph removeEdge:edge];
    STAssertTrue( ([nodeA.outNodes count]==0), @"it's %d",[nodeA.outNodes count]);
}

-(void)testRemoveNode
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    ARGraphNode *nodeA = [[ARGraphNode alloc] initWithValue:@"A"];
    ARGraphNode *nodeB = [[ARGraphNode alloc] initWithValue:@"B"];
    [graph addNode:nodeA];
    [graph addNode:nodeB];
    STAssertTrue(([graph.nodes count]==2), nil);
    [graph removeNode:nodeA];
    STAssertTrue(([graph.nodes count]==1), nil);
    [graph removeNode:nodeB];
    STAssertTrue(([graph.nodes count]==0), nil);
}


#pragma mark Graph traversal


-(void)testShortestPathTo
{
    // (1) --2--> (4) --1--> (3)
    // (1) --1--> (2) --3--> (3)
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    [graph :graph :@"1" :@1  :@"2"];
    [graph :graph :@"1" :@2  :@"4"];
    [graph :graph :@"2" :@1  :@"1"];
    [graph :graph :@"2" :@3  :@"3"];
    [graph :graph :@"3" :@1  :@"4"];
    [graph :graph :@"3" :@3  :@"2"];
    [graph :graph :@"4" :@2  :@"1"];
    [graph :graph :@"4" :@1  :@"3"];
    
    ARGraphNode *start = [graph nodeByValue:@"1"];
    ARGraphNode *end = [graph nodeByValue:@"3"];
    ARArrayList *array = [graph shortestPathFrom:start to:end];
    STAssertTrue([array count]==3,nil);
    trace(@"Path to 4: %@",array)
}


-(void)testDepthFirstSearchForValueStart
{
    //       1
    //      2 3
    //     45 67
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    [graph :graph :@"1" :@1  :@"2"];
    [graph :graph :@"1" :@1  :@"3"];
    [graph :graph :@"2" :@1  :@"4"];
    [graph :graph :@"2" :@1  :@"5"];
    [graph :graph :@"3" :@1  :@"6"];
    [graph :graph :@"3" :@1  :@"7"];
    ARGraphNode *one = [graph nodeByValue:@"1"];
    ARArrayList *path = [graph depthFirstSearchForValue:@"4" start:one];
    ARGraphNode *node = [path lastObject];
    STAssertTrue([node.value isEqualToString:@"4"],nil);
    trace(@"Path to 4: %@",path)
}


-(void)testBreadthFirstSearchForValueStart
{
    //       1
    //      2 3
    //     45 67
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    [graph :graph :@"1" :@1  :@"2"];
    [graph :graph :@"1" :@1  :@"3"];
    [graph :graph :@"2" :@1  :@"4"];
    [graph :graph :@"2" :@1  :@"5"];
    [graph :graph :@"3" :@1  :@"6"];
    [graph :graph :@"3" :@1  :@"7"];
    ARGraphNode *one = [graph nodeByValue:@"1"];
    ARArrayList *path = [graph breadthFirstSearchForValue:@"7" start:one];
    ARGraphNode *node = [path lastObject];
    STAssertTrue([node.value isEqualToString:@"7"],nil);
    trace(@"Path to 7: %@",path)
}


@end
