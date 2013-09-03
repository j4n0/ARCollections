
// BSD License. Author: jano@jano.com.es

#import "ARBinaryTreeImpl.h"


@interface ARBinaryTreeImpl()
-(NSObject<ARList>*) pathWithOrder:(ARTreeOrder)order results:(NSObject<ARList>*)array;
@end


@implementation ARBinaryTreeImpl

#pragma mark - ARBinaryTree

@synthesize left = _left;
@synthesize right = _right;
@synthesize value = _value;


+(NSObject<ARBinaryTree>*) treeWithRoot:(NSObject*)root
                                   left:(NSObject<ARBinaryTree>*)left
                                  right:(NSObject<ARBinaryTree>*)right {
    NSObject<ARBinaryTree> *tree = [ARBinaryTreeImpl new];
    tree.value = root;
    tree.left = left;
    tree.right = right;
    return tree;
}


-(id) initWithValue:(NSObject*)value {
    self = [super init];
    if (self){
        _value = value;
    }
    return self;
}

-(NSString*)description {
    return [_value description];
}

#pragma mark - ARBinaryTree: insert

-(void) insertLeft:(NSObject<ARBinaryTree>*)node {
    if (_left){
        node.left = _left;
        _left = node;
    } else {
        _left = node;
    }
}

-(void) insertRight:(NSObject<ARBinaryTree>*)node {
    if (_right){
        node.left = _right;
        _right = node;
    } else {
        _right = node;
    }
}

#pragma mark - ARBinaryTree: iteration

-(void) preorder:(void(^)(id object)) block {
    [self each:block order:ARTreeOrderPreorder];
}
-(void) postorder:(void(^)(id object)) block {
    [self each:block order:ARTreeOrderPostorder];
}
-(void) inorder:(void(^)(id object)) block {
    [self each:block order:ARTreeOrderInorder];
}

-(void) each:(void(^)(id object))block order:(ARTreeVisitingOrder)order {
    switch (order) {
        case ARTreeOrderPreorder:{
            block(_value);
            if (_left)  [_left  each:block order:order];
            if (_right) [_right each:block order:order];
            break;
        }
        case ARTreeOrderInorder:{
            if (_left)  [_left  each:block order:order];
            block(_value);
            if (_right) [_right each:block order:order];
            break;
        }
        case ARTreeOrderPostorder:{
            if (_left)  [_left  each:block order:order];
            if (_right) [_right each:block order:order];
            block(_value);
            break;
        }
    }
}


-(NSObject<ARList>*) pathWithOrder:(ARTreeVisitingOrder)order {
    id<ARList> array = [ARArrayList new];
    return [self pathWithOrder:order results:array];
}

-(NSObject<ARList>*) pathWithOrder:(ARTreeVisitingOrder)order results:(NSObject<ARList>*)array {
    switch (order) {
        case ARTreeOrderPreorder:{
            [array addObject:_value];
            if (_left)  [(ARBinaryTreeImpl*)_left  pathWithOrder:order results:array];
            if (_right) [(ARBinaryTreeImpl*)_right pathWithOrder:order results:array];
            break;
        }
        case ARTreeOrderInorder:{
            if (_left)  [(ARBinaryTreeImpl*)_left pathWithOrder:order results:array];
            [array addObject:_value];
            if (_right) [(ARBinaryTreeImpl*)_right pathWithOrder:order results:array];
            break;
        }
        case ARTreeOrderPostorder:{
            if (_left)  [(ARBinaryTreeImpl*)_left  pathWithOrder:order results:array];
            if (_right) [(ARBinaryTreeImpl*)_right pathWithOrder:order results:array];
            [array addObject:_value];
            break;
        }
    }
    return array;
}

#pragma mark - ARContainer

-(id) init {
    self = [super init];
    if (self){
        _value = nil;
    }
    return self;
}

-(BOOL) isEmpty {
    return _value==nil;
}

@end
