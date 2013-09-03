
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARBinaryTreeImpl.h"
#import "ARBinaryTree.h"
#import "ARArrayList.h"
#import "ARDequeList.h"

@interface ARBinaryTreeTest : SenTestCase
@end

@implementation ARBinaryTreeTest

// Create the following sample tree:
//    1
//   2 3
//  45 67
-(NSObject<ARBinaryTree>*) input {
    NSObject<ARBinaryTree> *tree;
    tree = [ARBinaryTreeImpl treeWithRoot:@1
                         left:[ARBinaryTreeImpl treeWithRoot:@2
                                            left:[ARBinaryTreeImpl treeWithRoot:@4 left:nil right:nil]
                                           right:[ARBinaryTreeImpl treeWithRoot:@5 left:nil right:nil]]
                        right:[ARBinaryTreeImpl treeWithRoot:@3
                                            left:[ARBinaryTreeImpl treeWithRoot:@6 left:nil right:nil]
                                           right:[ARBinaryTreeImpl treeWithRoot:@7 left:nil right:nil]]];
    return tree;
}

#pragma mark - each (pre|in|post)order


-(void) testPathWithOrder {
    id<ARBinaryTree> tree = [self input];
    id<ARList> path;
    ARArrayList *expected;
    
    //    1
    //   2 3
    //  45 67
    
    // pre 1 2 4 5 3 6 7
    path = [tree pathWithOrder:ARTreeOrderPreorder];
    expected = [ARArrayList createWithNSArray:@[@1, @2, @4, @5, @3, @6, @7]];
    STAssertTrue([path isEqual:expected], nil);
    
    // in 4 2 5 1 6 3 7
    path = [tree pathWithOrder:ARTreeOrderInorder];
    expected = [ARArrayList createWithNSArray:@[@4, @2, @5, @1, @6, @3, @7]];
    STAssertTrue([path isEqual:expected], nil);
    
    // pos 4 5 2 6 7 3 1
    path = [tree pathWithOrder:ARTreeOrderPostorder];
    expected = [ARArrayList createWithNSArray:@[@4, @5, @2, @6, @7, @3, @1]];
    STAssertTrue([path isEqual:expected], nil);
}


#pragma mark - each (pre|in|post)order

-(void) testEachPreorder {
    id<ARBinaryTree> tree = [self input];
    NSLog(@"PREORDER: node, left, right");
    NSLog(@"  1");
    NSLog(@" 2 3");
    NSLog(@"45 67");
    [tree each:^(id object) {
        // 1 2 4 5 3 6 7
    } order:ARTreeOrderPreorder];
}

-(void) testEachInorder {
    id<ARBinaryTree> tree = [self input];
    NSLog(@"INORDER: left, node, right");
    NSLog(@"  1");
    NSLog(@" 2 3");
    NSLog(@"45 67");
    [tree each:^(id object) {
        // 4 2 5 1 6 3 7
    } order:ARTreeOrderInorder];
}

-(void) testEachPostorder {
    id<ARBinaryTree> tree = [self input];
    NSLog(@"POSTORDER: left, right, node");
    NSLog(@"  1");
    NSLog(@" 2 3");
    NSLog(@"45 67");
    [tree each:^(id object) {
        // 4 5 2 6 7 3 1
    } order:ARTreeOrderPostorder];
}

@end
