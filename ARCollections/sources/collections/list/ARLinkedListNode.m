
// BSD License. Author: jano@jano.com.es

#import "ARLinkedListNode.h"

@implementation ARLinkedListNode

-(id) initWithValue:(NSObject*)value {
    self = [super init];
    if (self){
        _value = value;
    }
    return self;
}

-(NSString*)description {
    return [NSString stringWithFormat:@"[value:%@,prev:%@,next:%@]",_value,_prev.value,_next.value];
}

@end