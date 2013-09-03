
// BSD License. Author: jano@jano.com.es

#import "ARBSTNodeImpl.h"

@implementation ARBSTNodeImpl

@synthesize left  = _left;
@synthesize right = _right;
@synthesize key   = _key;
@synthesize value = _value;
@synthesize count = _count;

-(id) initWithKey:(ARBSTKey*)key
            value:(ARBSTValue*)value
{
    self = [super init];
    if (self){
        _key = key;
        _value = value;
        _count = 1;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"[k=%@,v=%@,c=%d]",_key,_value,_count];
}

#pragma mark - Iterators

-(void) preorder:(void(^)(ARBSTNode* node)) block {
    [self each:block order:ARTreeOrderPre];
}
-(void) postorder:(void(^)(ARBSTNode* node)) block {
    [self each:block order:ARTreeOrderPost];
}
-(void) inorder:(void(^)(ARBSTNode* node)) block {
    [self each:block order:ARTreeOrderIn];
}
-(void) breadthOrder:(void(^)(ARBSTNode* node)) block {
    [self each:block order:ARTreeOrderBreadth];
}


-(void) each:(void(^)(ARBSTNode* node))block order:(ARTreeOrder)order {
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
                ARBSTNode* n = [nodes dequeue];
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
            if (_left)  [(ARBSTNodeImpl*)_left  pathWithOrder:order results:array];
            if (_right) [(ARBSTNodeImpl*)_right pathWithOrder:order results:array];
            break;
        }
        case ARTreeOrderIn:{
            if (_left)  [(ARBSTNodeImpl*)_left pathWithOrder:order results:array];
            [array addObject:_value];
            if (_right) [(ARBSTNodeImpl*)_right pathWithOrder:order results:array];
            break;
        }
        case ARTreeOrderPost:{
            if (_left)  [(ARBSTNodeImpl*)_left  pathWithOrder:order results:array];
            if (_right) [(ARBSTNodeImpl*)_right pathWithOrder:order results:array];
            [array addObject:_value];
            break;
        }
        case ARTreeOrderBreadth:{
            NSObject<ARQueue>* nodes = [ARQueueList new];
            [nodes enqueue:self];
            while (![nodes isEmpty])
            {
                ARBSTNode* n = [nodes dequeue];
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
