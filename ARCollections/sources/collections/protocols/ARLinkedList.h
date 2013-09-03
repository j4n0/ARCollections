
// BSD License. Author: jano@jano.com.es

#import "ARLinkedListNode.h"

@protocol ARLinkedList <NSObject,NSFastEnumeration>

@property (nonatomic,assign,readonly) NSUInteger count;
@property (nonatomic,strong,readonly) ARLinkedListNode *head;
@property (nonatomic,strong,readonly) ARLinkedListNode *tail;

-(void) addObject:(NSObject*)object;
-(void) insertObject:(NSObject*)object atIndex:(NSUInteger)index;
-(BOOL) isEmpty;
-(NSObject*) objectAtIndex:(NSUInteger)index;
-(void) removeObjectAtIndex:(NSUInteger)index;

@end
