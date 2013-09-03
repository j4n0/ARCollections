
// BSD License. Author: jano@jano.com.es

#import "ARTree.h"
#import "ARList.h"

@protocol ARBSTRedBlackNode

typedef NSObject<ARBSTRedBlackNode>  ARBSTRedBlackNode;

typedef NS_ENUM(BOOL, ARBSTLinkColor) {
    ARBSTLinkBlack = NO,
    ARBSTLinkRed = YES
};

@property (nonatomic,strong) ARBSTKey           *key;
@property (nonatomic,strong) ARBSTValue         *value;
@property (nonatomic,strong) ARBSTRedBlackNode  *left;
@property (nonatomic,strong) ARBSTRedBlackNode  *right;
@property (nonatomic,assign) NSUInteger         count;
@property (nonatomic,assign) ARBSTLinkColor     color;

-(id) initWithKey:(ARBSTKey*)key
            value:(ARBSTValue*)value
            color:(ARBSTLinkColor)color
            count:(NSUInteger)count;

-(BOOL) isRed;

#pragma mark - Iterate

-(void) preorder:    (void(^)(ARBSTRedBlackNode* object)) block;  // node, left, right
-(void) postorder:   (void(^)(ARBSTRedBlackNode* object)) block;  // left, right, node
-(void) inorder:     (void(^)(ARBSTRedBlackNode* object)) block;  // left, node, right
-(void) breadthOrder:(void(^)(ARBSTRedBlackNode* node))   block;  // each level in turn

// Same as the preorder:, postorder:, inorder:, but specifying the order in an enum.
-(void) each:(void(^)(ARBSTRedBlackNode* node))block order:(ARTreeOrder)order;

// Same as the each: method, but collecting a reference to all the visited nodes.
-(NSObject<ARList>*) pathWithOrder:(ARTreeOrder)order;


@end