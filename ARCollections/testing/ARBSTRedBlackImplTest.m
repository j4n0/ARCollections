
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARBSTNodeImpl.h"
#import "ARBSTRedBlackImpl.h"


/** Test for the NSArray(Functional) category. */
@interface ARBSTRedBlackImplTest : SenTestCase
@end


@implementation ARBSTRedBlackImplTest


-(void) testEmpty
{
    ARBSTRedBlack *tree = [ARBSTRedBlackImpl new];
    STAssertTrue   ([tree isEmpty],          nil);
    STAssertTrue   ([tree count]==0,         nil);
    STAssertTrue   ([tree height]==0,        nil);
    STAssertTrue   ([tree isBST],            nil);
    //STAssertThrows ([tree deleteMax],        nil);
    //STAssertThrows ([tree deleteMin],        nil);
    STAssertNil    ([tree min],              nil);
    STAssertNil    ([tree max],              nil);
    STAssertFalse  ([tree contains:nil],     nil);
    STAssertNil    ([tree objectForKey:nil], nil);
    STAssertNil    ([tree floorKey:nil],     nil);
    STAssertNil    ([tree ceilingKey:nil],   nil);
    STAssertNil    ([tree selectRank:0],     nil);
    STAssertTrue   ([tree rankKey:nil]==0,   nil);
    STAssertTrue   ([[tree keys]count]==0,   nil);
}


-(ARBSTRedBlack*)input
{
    ARBSTRedBlack *tree = [ARBSTRedBlackImpl new];
    [tree insertKey:@"S" value:@"S"];
    [tree insertKey:@"E" value:@"E"];
    [tree insertKey:@"X" value:@"X"];
    [tree insertKey:@"A" value:@"A"];
    [tree insertKey:@"M" value:@"M"];
    [tree insertKey:@"H" value:@"H"];
    return tree;
}


-(void) testInput
{
    ARBSTRedBlack *tree = [self input];
    ARBSTRedBlackNode* root = tree.root;
    STAssertTrue(![tree isEmpty],  nil);  // not empty
    STAssertTrue([root count]==6,  nil);  // 6 nodes
    STAssertTrue([tree height]==4, nil);  // 4 levels: S | EX | AM | H
    STAssertTrue([tree check],     nil);  // integrity
    STAssertTrue([[tree min]isEqual:@"A"],nil);
    STAssertTrue([[tree max]isEqual:@"X"],nil);
    
    STAssertTrue([[tree floorKey:@"F"]isEqual:@"E"],nil);
    STAssertTrue([[tree ceilingKey:@"F"]isEqual:@"H"],nil);
    
    ARBSTRedBlackNode *node = [tree objectForKey:@"H"];
    STAssertTrue([node.key isEqual:@"H"],nil);

    STAssertTrue([tree contains:@"H"], nil);
    [tree deleteKey:@"H"];
    STAssertFalse([tree contains:@"H"], nil);
    STAssertTrue([root count]==5, nil);  // 5 nodes
    STAssertNil([tree objectForKey:@"H"], nil);
    
    [tree deleteMax];
    
    STAssertFalse([tree contains:@"X"],nil);
    [tree deleteMin];
    STAssertFalse([tree contains:@"A"],nil);
}


-(void) testKeys
{
    ARBSTRedBlack *tree = [self input];
    STAssertTrue([[[tree keys] description] isEqual:@"A,E,H,M,S,X"],nil);
    STAssertTrue([[[tree keysBetweenLow:@"E" andHi:@"M"]description]isEqual:@"E,H,M"],nil);
    
    STAssertTrue([tree rankKey:@"E"]==1,nil);
    STAssertTrue([tree rankKey:@"X"]==5,nil);
    
    STAssertTrue([tree selectRank:-1]==nil,nil);
    STAssertTrue([[tree selectRank:0]isEqual:@"A"],[[tree selectRank:0]description]);
    STAssertTrue([[tree selectRank:3]isEqual:@"M"],[[tree selectRank:3]description]);
    STAssertTrue([[tree selectRank:5]isEqual:@"X"],[[tree selectRank:5]description]);
}


-(void) testIteration
{
    ARBSTRedBlack *tree = [ARBSTRedBlackImpl new];
    [tree insertKey:@"S" value:@"S"];
    [tree insertKey:@"E" value:@"E"];
    [tree insertKey:@"X" value:@"X"];
    [tree insertKey:@"A" value:@"A"];
    [tree insertKey:@"M" value:@"M"];
    
    printf("\n              S   ");
    printf("\n            E   X ");
    printf("\n           A M    ");
    printf("\n");
    
    NSMutableString *string;
    
    printf("\n Preorder: ");
    string = [NSMutableString string];
    [tree.root preorder:^(ARBSTRedBlackNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"S E A M X "], nil);
    
    printf("\n  Inorder: ");
    string = [NSMutableString string];
    [tree.root inorder:^(ARBSTRedBlackNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"A E M S X "], nil);
    
    printf("\nPostorder: ");
    string = [NSMutableString string];
    [tree.root postorder:^(ARBSTRedBlackNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"A M E X S "], nil);
    
    printf("\n  Breadth: ");
    string = [NSMutableString string];
    [tree.root breadthOrder:^(ARBSTRedBlackNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"S E X A M "], nil);
    
    printf("\n\n");
}

#warning Red-Black tests pending


@end
