
// BSD License. Author: jano@jano.com.es

#import "ARTree.h"

@protocol ARBSTNode

typedef NSObject<ARBSTNode>  ARBSTNode;

@property (nonatomic,strong) ARBSTKey   *key;
@property (nonatomic,strong) ARBSTValue *value;
@property (nonatomic,strong) ARBSTNode  *left;
@property (nonatomic,strong) ARBSTNode  *right;
@property (nonatomic,assign) NSUInteger count;

-(id) initWithKey:(ARBSTKey*)key
            value:(ARBSTValue*)value;

#pragma mark - Iterate

-(void) preorder:    (void(^)(ARBSTNode* object)) block;  // node, left, right
-(void) postorder:   (void(^)(ARBSTNode* object)) block;  // left, right, node
-(void) inorder:     (void(^)(ARBSTNode* object)) block;  // left, node, right
-(void) breadthOrder:(void(^)(ARBSTNode* node))   block;  // each level in turn

// Same as the preorder:, postorder:, inorder:, but specifying the order in an enum.
-(void) each:(void(^)(ARBSTNode* node))block order:(ARTreeOrder)order;

// Same as the each: method, but collecting a reference to all the visited nodes.
-(NSObject<ARList>*) pathWithOrder:(ARTreeOrder)order;


@end