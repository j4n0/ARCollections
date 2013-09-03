
// BSD License. Author: jano@jano.com.es

#import "ARLinkedListImpl.h"

@interface ARLinkedListImpl()
@property (nonatomic,assign,readwrite) NSUInteger count;
@property (nonatomic,strong,readwrite) ARLinkedListNode *head;
@property (nonatomic,strong,readwrite) ARLinkedListNode *tail;
@end


@implementation ARLinkedListImpl {
    unsigned long _mutations;
}


-(BOOL) isEmpty {
    return _count==0;
}


-(ARLinkedListNode*) nodeAtIndex:(NSUInteger)index {
    ARLinkedListNode *node = _head;
    NSUInteger i = 0;
    while (i<index){
        node = node.next;
        i++;
    }
    return node;
}


-(NSObject*) objectAtIndex:(NSUInteger)index {
    NSParameterAssert(index<_count);
    return [self nodeAtIndex:index].value;
}


-(void) removeObjectAtIndex:(NSUInteger)index {
    NSParameterAssert(index<_count);
    _mutations++;
    ARLinkedListNode *object = [self nodeAtIndex:index];
    object.prev.next = object.next;
    if (index==0){
        _head = object;
    } else if (index==_count-1){
        _tail = object.prev;
    }
    _count--;
}


-(void) insertObject:(NSObject*)object atIndex:(NSUInteger)index {
    NSParameterAssert(index<_count);
    _mutations++;
    ARLinkedListNode *newNode = [[ARLinkedListNode alloc] initWithValue:object];
    ARLinkedListNode *nodeAtIndex = [self nodeAtIndex:index];
    nodeAtIndex.prev.next = newNode;
    newNode.next = nodeAtIndex;
    if (index==0){
        _head = newNode;
    } else if (index==_count-1){
        _tail = newNode;
    }
    _count++;
}


-(void) addObject:(NSObject*)object {
    _mutations++;
    ARLinkedListNode *newNode = [[ARLinkedListNode alloc] initWithValue:object];
    if (_count==0){
        _head = newNode;
        _tail = newNode;
    } else {
        _tail.next = newNode;
        newNode.prev = _tail;
        _tail = newNode;
    }
    _count++;
}


#pragma mark - Other


-(NSString*) description {
    NSMutableString *string = [NSMutableString new];
    for (NSObject *object in self) {
        [string appendFormat:@"%@",object];
    }
    return string;
}


-(NSString*) longDescription {
    NSMutableString *string = [NSMutableString new];
    ARLinkedListNode *node = _head;
    while (node){
        [string appendFormat:@"\n%@",[node description]];
        node=node.next;
    }
    return string;
}


#pragma mark - NSFastEnumeration


- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state
                                   objects: (id __unsafe_unretained*)stackbuf
                                     count: (NSUInteger)len
{
    state->mutationsPtr = &_mutations;
    
    NSInteger count = MIN(len, [self count] - state->state);
    if (count > 0)
    {
        IMP	imp = [self methodForSelector: @selector(objectAtIndex:)];
        int	p = state->state;
        int	i;
        for (i = 0; i < count; i++, p++) {
            id obj = (*imp)(self, @selector(objectAtIndex:), p);
            stackbuf[i] = obj;
        }
        state->state += count;
    }
    else
    {
        count = 0;
    }
    state->itemsPtr = stackbuf;
    return count;
}


@end
