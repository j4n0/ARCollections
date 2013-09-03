
// BSD License. Created by jano@jano.com.es

#import "MaxPQArray.h"

@implementation MaxPQArray


- (void) addObject:(MaxPQKey)object
{
    NSParameterAssert(object!=nil);
    if ((_pqCount+1)==_pqCapacity){
        [self expandCapacity];
    }
    _pq[_pqCount+1] = object;
    _pqCount++;
}


#pragma mark - initializers


// Create an empty priority queue with the given initial capacity, using the given comparator.
-(instancetype) initWithCapacity:(NSUInteger)capacity comparator:(compare_t)comparator {
    self = [super init];
    if (self){
        if (capacity==0) capacity=1;
        _pq = (id __strong *)calloc(capacity,sizeof(*_pq));
        _pqCapacity = capacity;
        _pqCount = 0;
        _comparator = comparator;
        _pq[0] = @"⌘";
    }
    return self;
}


#pragma mark - internal array methods


-(void) expandCapacity
{
    // start allocating with 16 elements, then double the capacity
    NSUInteger newCapacity = MAX(16u, _pqCapacity * 2);
    id __strong *newObjs = (id __strong *)calloc(newCapacity,sizeof(*newObjs));
    if (_pq!=nil){
        
        // copy old array to new array
        for (NSUInteger i = 0; i<_pqCapacity; i++) {
            newObjs[i] = _pq[i];
            _pq[i] = nil;
        }
        free(_pq);
    }
    // set the new data
    _pq = newObjs;
    _pqCapacity = newCapacity;
}


#pragma mark - NSFastEnumeration


- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state
                                   objects: (id __unsafe_unretained*)stackbuf
                                     count: (NSUInteger)len
{
    state->mutationsPtr = (unsigned long *) &_pqCount;
    
    NSInteger count = MIN(len, _pqCount - state->state);
    if (count > 0)
    {
        int	p = state->state;
        for (int i = 1; i < count+1; i++, p++) {
            id obj = _pq[i];
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


-(NSString*) description {
    NSMutableString *mString = [NSMutableString new];
    for (MaxPQKey key in self) {
        [mString appendFormat:@"%@ ",key];
    }
    return mString;
}


@end
