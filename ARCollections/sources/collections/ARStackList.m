
// BSD License. Author: jano@jano.com.es

#import "ARStackList.h"

@implementation ARStackList

-(void) push:(id)item {
    [self insertObjectAtEnd:item];
}

-(id) pop {
    return [self removeLastObject];
}

-(id) peek {
    return [self lastObject];
}

-(id<ARList>) allObjects {
    return [self copy];
}

-(id) initWithARList:(id<ARList>)list {
    self = [self initWithCapacity:[list count]];
    if (self){
        for (id object in list) {
            [self insertObjectAtEnd:object];
        }
    }
    return self;
}

-(NSString*) componentsJoinedByString:(NSString *)string {
    return [NSString stringWithFormat:@"%@",[[self inverseARArray]componentsJoinedByString:string]];
}

-(NSString*) description {
    return [NSString stringWithFormat:@"%@",[[self inverseARArray]description]];
}

- (BOOL) isEqual:(id)object
{
    BOOL isEqual = NO;
    if (self==object){
        isEqual = YES;
    } else if ([object conformsToProtocol:@protocol(ARStack)]){
        isEqual = [self isEqualToARStack:object];
    }
    return isEqual;
}

-(BOOL) isEqualToARStack:(NSObject<ARStack>*)stack {
    BOOL isEqual = NO;
    if ([stack isKindOfClass:[ARStackList class]]){
        ARStackList *stackList = (ARStackList*)stack;
        isEqual = [stackList isEqualToARArray:self];
    } else {
        [[stack allObjects] isEqual:self];
    }
    return isEqual;
}

- (id) copyWithZone:(NSZone*)zone {
    ARStackList *list = [[ARStackList alloc] initWithCapacity:[self count]];
    for (id object in self) {
        [list insertObjectAtEnd:[object copy]];
    }
    return list;
}

@end
