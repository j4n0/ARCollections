
// BSD License. Author: jano@jano.com.es

#import "ARDequeList.h"

@implementation ARDequeList

-(void) addFront:(id)item {
    [self insertObjectAtBeginning:item];
}

-(id) removeFront {
    return [self count]>0 ? [self removeObjectAtIndex:0] : nil;
}

-(void) addRear:(id)item {
    [self insertObjectAtEnd:item];
}

-(id) removeRear {
    return [self count]>0 ? [self removeLastObject] : nil;
}

- (BOOL) isEqual:(id)dequeList
{
    BOOL isEqual = NO;
    if (self==dequeList){
        isEqual = YES;
    } else if ([dequeList conformsToProtocol:@protocol(ARList)]){
        isEqual = [self isEqualToARDeque:dequeList];
    }
    return isEqual;
}

-(BOOL) isEqualToARDeque:(NSObject<ARDeque>*)deque {
    BOOL isEqual = NO;
    if ([deque isKindOfClass:[ARDequeList class]]){
        ARDequeList *dequeList = (ARDequeList*)deque;
        isEqual = [dequeList isEqualToARArray:self];
    } else {
        [[deque allObjects] isEqual:self];
    }
    return isEqual;
}

-(id<ARList>) allObjects {
    return [self copy];
}

-(id) initWithARList:(id<ARList>)list {
    self = [self initWithCapacity:[list count]];
    if (self){
        for (id object in list) {
            [self addRear:object];
        }
    }
    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"%@",[self componentsJoinedByString:@","]];
}

- (id) copyWithZone:(NSZone*)zone {
    ARDequeList *list = [[ARDequeList alloc] initWithCapacity:[self count]];
    for (id object in self) {
        [list insertObjectAtEnd:[object copy]];
    }
    return list;
}

@end
