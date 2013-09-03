
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARBSTNodeImpl.h"
#import "ARBST.h"
#import "ARBSTImpl.h"


/** Test for the NSArray(Functional) category. */
@interface ARBSTImplTest : SenTestCase
@end


@implementation ARBSTImplTest


// Test an empty tree.
-(void) testEmpty {
    ARBSTImpl *tree = [ARBSTImpl new];
    STAssertTrue  ([tree isEmpty],          nil);
    STAssertTrue  ([tree count]==0,         nil);
    STAssertTrue  ([tree height]==0,        nil);
    STAssertTrue  ([tree isBST],            nil);
    // [tree deleteMax] // no effect
    // [tree deleteMin] // no effect
    STAssertNil   ([tree min],              nil);
    STAssertNil   ([tree max],              nil);
    STAssertFalse ([tree contains:nil],     nil); // contains:nil is always false
    STAssertNil   ([tree objectForKey:nil], nil);
    STAssertNil   ([tree floorKey:nil],     nil);
    STAssertNil   ([tree ceilingKey:nil],   nil);
    STAssertNil   ([tree selectRank:0],     nil); // rank 0 of an empty tree is nil
    STAssertTrue  ([tree rankKey:nil]==0,   nil); // the rank of a nil node is 0
    STAssertTrue  ([[tree keys]count]==0,   nil);
}


-(ARBST*) input_sexamh {
    ARBST *tree = [ARBSTImpl new];
    [tree insertKey:@"S" value:@"S"];
    [tree insertKey:@"E" value:@"E"];
    [tree insertKey:@"X" value:@"X"];
    [tree insertKey:@"A" value:@"A"];
    [tree insertKey:@"M" value:@"M"];
    [tree insertKey:@"H" value:@"H"];
    return tree;
}


/* worst case
-(ARBST*) input_abcdef {
    ARBST *tree = [ARBSTImpl new];
    [tree insertKey:@"A" value:@"A"];
    [tree insertKey:@"B" value:@"B"];
    [tree insertKey:@"C" value:@"C"];
    [tree insertKey:@"D" value:@"D"];
    [tree insertKey:@"E" value:@"E"];
    [tree insertKey:@"F" value:@"F"];
    return tree;
}
*/


-(void) testInput {
    ARBST *tree = [self input_sexamh];
    ARBSTNode* root = tree.root;
    STAssertTrue(![tree isEmpty],  nil);  // not empty
    STAssertTrue([root count]==6,  nil);  // 6 nodes
    STAssertTrue([tree height]==4, nil);  // 4 levels: S | EX | AM | H
    STAssertTrue([tree check],     nil);  // integrity
    STAssertTrue([[tree min]isEqual:@"A"],nil);
    STAssertTrue([[tree max]isEqual:@"X"],nil);
    
    STAssertTrue([[tree floorKey:@"F"]isEqual:@"E"],nil);
    STAssertTrue([[tree ceilingKey:@"F"]isEqual:@"H"],nil);
    
    ARBSTNode *node = [tree objectForKey:@"H"];
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


-(void) testKeys {
    ARBST *tree = [self input_sexamh];
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
    ARBSTImpl *tree = [ARBSTImpl new];
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
    [tree.root preorder:^(ARBSTNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"S E A M X "], nil);
    
    printf("\n  Inorder: ");
    string = [NSMutableString string];
    [tree.root inorder:^(ARBSTNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"A E M S X "], nil);
    
    printf("\nPostorder: ");
    string = [NSMutableString string];
    [tree.root postorder:^(ARBSTNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"A M E X S "], nil);
    
    printf("\n  Breadth: ");
    string = [NSMutableString string];
    [tree.root breadthOrder:^(ARBSTNode* node) {
        [string appendFormat:@"%@ ",node.key];
    }];
    printf("%s",[string cStringUsingEncoding:NSUTF8StringEncoding]);
    STAssertTrue([string isEqualToString:@"S E X A M "], nil);
    
    printf("\n\n");
}


@end
