
// BSD License. Author: jano@jano.com.es

#import "ARBSTRedBlackNodeImpl.h"

@implementation ARBSTRedBlackNodeImpl

@synthesize left  = _left;
@synthesize right = _right;
@synthesize key   = _key;
@synthesize value = _value;
@synthesize count = _count;
@synthesize color = _color;

//x
-(id) initWithKey:(ARBSTKey*)key
            value:(ARBSTValue*)value
            color:(ARBSTLinkColor)color
            count:(NSUInteger)count
{
    self = [super init];
    if (self){
        _key = key;
        _value = value;
        _count = count;
        _color = color;
    }
    return self;
}

//x
-(NSString*)description {
    return [NSString stringWithFormat:@"[k=%@,v=%@,c=%d,c=%@]",
            _key,_value,_count,[self isRed]?@"red":@"black"];
}

//x
-(BOOL) isRed {
    return _color==ARBSTLinkRed;
}

#pragma mark - Iterators

-(void) preorder:(void(^)(ARBSTRedBlackNode* node)) block {
    [self each:block order:ARTreeOrderPre];
}
-(void) postorder:(void(^)(ARBSTRedBlackNode* node)) block {
    [self each:block order:ARTreeOrderPost];
}
-(void) inorder:(void(^)(ARBSTRedBlackNode* node)) block {
    [self each:block order:ARTreeOrderIn];
}
-(void) breadthOrder:(void(^)(ARBSTRedBlackNode* node)) block {
    [self each:block order:ARTreeOrderBreadth];
}


-(void) each:(void(^)(ARBSTRedBlackNode* node))block order:(ARTreeOrder)order {
    switch (order) {
        case ARTreeOrderPre:{
            block(self);
            if (_left)  [_left  each:block order:order];
            if (_right) [_right each:block order:order];
            break;
        }
        case ARTreeOrderIn:{
            if (_left)  [_left  each:block order:order];
            block(self);
            if (_right) [_right each:block order:order];
            break;
        }
        case ARTreeOrderPost:{
            if (_left)  [_left  each:block order:order];
            if (_right) [_right each:block order:order];
            block(self);
            break;
        }
        case ARTreeOrderBreadth:{
            NSObject<ARQueue>* nodes = [ARQueueList new];
            [nodes enqueue:self];
            while (![nodes isEmpty])
            {
                ARBSTRedBlackNode* n = [nodes dequeue];
                if (n == nil) continue;
                block(n);
                if (n.left)  [nodes enqueue:n.left];
                if (n.right) [nodes enqueue:n.right];
            }
            break;
        }
    }
}


-(NSObject<ARList>*) pathWithOrder:(ARTreeOrder)order
{
    id<ARList> array = [ARArrayList new];
    return [self pathWithOrder:order results:array];
}


-(NSObject<ARList>*) pathWithOrder:(ARTreeOrder)order results:(NSObject<ARList>*)array {
    switch (order) {
        case ARTreeOrderPre:{
            [array addObject:_value];
            if (_left)  [(ARBSTRedBlackNodeImpl*)_left  pathWithOrder:order results:array];
            if (_right) [(ARBSTRedBlackNodeImpl*)_right pathWithOrder:order results:array];
            break;
        }
        case ARTreeOrderIn:{
            if (_left)  [(ARBSTRedBlackNodeImpl*)_left pathWithOrder:order results:array];
            [array addObject:_value];
            if (_right) [(ARBSTRedBlackNodeImpl*)_right pathWithOrder:order results:array];
            break;
        }
        case ARTreeOrderPost:{
            if (_left)  [(ARBSTRedBlackNodeImpl*)_left  pathWithOrder:order results:array];
            if (_right) [(ARBSTRedBlackNodeImpl*)_right pathWithOrder:order results:array];
            [array addObject:_value];
            break;
        }
        case ARTreeOrderBreadth:{
            NSObject<ARQueue>* nodes = [ARQueueList new];
            [nodes enqueue:self];
            while (![nodes isEmpty])
            {
                ARBSTRedBlackNode* n = [nodes dequeue];
                if (n == nil) continue;
                [array addObject:n];
                if (n.left)  [nodes enqueue:n.left];
                if (n.right) [nodes enqueue:n.right];
            }
            break;
        }
    }
    return array;
}


@end
