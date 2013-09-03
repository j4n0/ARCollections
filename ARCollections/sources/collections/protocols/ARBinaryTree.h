
// BSD License. Author: jano@jano.com.es

#import "ARContainer.h"
#import "ARTreeIterator.h"

/* A binary tree with a value and a left and right child. */
@protocol ARBinaryTree <ARTreeIterator> //<ARContainer> // NSObject

@property (nonatomic,strong) NSObject *value;                // node value
@property (nonatomic,strong) NSObject<ARBinaryTree> *left;   // left subtree
@property (nonatomic,strong) NSObject<ARBinaryTree> *right;  // right subtree

// Create a new tree with the given value, left subtree, right subtree.
+(NSObject<ARBinaryTree>*) treeWithRoot:(NSObject*) root
                                   left:(NSObject<ARBinaryTree>*) left
                                  right:(NSObject<ARBinaryTree>*) right;

// Set the given 'node' as left child.
// If there is already a left child, push it down to left child of the given 'node'.
-(void) insertLeft:(NSObject<ARBinaryTree>*)node;

// Set node as right child.
// If there is already a right child, push it down to left child of the given 'node'.
-(void) insertRight:(NSObject<ARBinaryTree>*)node;

@end
