
// BSD License. Author: jano@jano.com.es

#import "MaxPQ.h"
#import "ARArrayList.h"


@implementation MaxPQ {
@private
    __strong id * _pq;          // store items at indices 1 to N
    NSUInteger    _pqCapacity;
    NSUInteger    _pqCount;     // number of items on priority queue

    compare_t _comparator;      // optional Comparator
}


#pragma mark - internal array methods

-(void) _expandCapacity
{
    // start allocating with 16 elements, then double the capacity
    NSUInteger newCapacity = MAX(16, _pqCapacity * 2);
    id __strong *newObjs = (id __strong *)calloc(newCapacity,sizeof(*newObjs));
    if (_pq!=nil){

        // copy old array to new array
        for (NSUInteger i = 1; i<_pqCapacity+1; i++) {
            newObjs[i] = _pq[i];
            _pq[i] = nil;
        }
        [self _freePointers:_pq size:_pqCapacity];
    }
    // set the new data
    _pq = newObjs;
    _pqCapacity = newCapacity;
}


-(void) _freePointers:(__strong id*)pointers size:(NSUInteger)size {
    free(pointers);
}


- (void) _addObject:(MaxPQKey)object {
    NSParameterAssert(object!=nil);
    if (_pqCount==_pqCapacity){
        [self _expandCapacity];
    }
    _pq[_pqCount+1] = object; 
    _pqCount++;
}


- (void) _insertObject:(MaxPQKey)object atIndex:(NSUInteger)index
{
    NSParameterAssert(object!=nil);
    NSAssert(index<_pqCount, @"Index out of range (%d) for an array with %d elements", index, _pqCount);
    if (_pqCount==_pqCapacity){
        [self _expandCapacity];
    }
    if (index!=_pqCount){
        for (NSInteger i = _pqCount; i!=index; i--) {
            _pq[i]=_pq[i-1];
        }
    }
    _pq[index] = object;
    _pqCount++;
}


- (MaxPQKey) _objectAtIndex:(NSUInteger)index {
    NSAssert(index<_pqCount, @"Index out of range (%d) for an array with %d elements", index, _pqCount);
    return _pq[index];
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
        IMP	imp = [self methodForSelector: @selector(objectAtIndex:)];
        int	p = state->state;
        int	i;
        for (i = 1; i < count+1; i++, p++) { // _pq[0] is unused
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


-(NSString*) description {
    NSMutableString *mString = [NSMutableString new];
    for (MaxPQKey key in self) {
        [mString appendFormat:@"%@ ",key];
    }
    return mString;
}


#pragma mark - initializers

// Create an empty priority queue with the given initial capacity.
-(instancetype) initWithCapacity:(NSUInteger) capacity {
    return [self initWithCapacity:capacity comparator:nil];
}


// Create an empty priority queue with the given initial capacity.
-(instancetype) init {
    return [self initWithCapacity:1 comparator:nil]; // _pq[0] is unused
}


// Create an empty priority queue with the given initial capacity, using the given comparator.
-(instancetype) initWithCapacity:(NSUInteger)capacity comparator:(compare_t)comparator {
    self = [super init];
    if (self){
        _pq = (id __strong *)calloc(capacity+1,sizeof(*_pq)); // _pq[0] is unused
        _pqCapacity = capacity;
        _pqCount = 0;
        _comparator = comparator;
    }
    return self;
}


// Create an empty priority queue using the given comparator.
-(instancetype) initWithComparator:(compare_t)comparator {
    return [self initWithCapacity:1 comparator:comparator]; // _pq[0] is unused
}


/**
  * Create a priority queue with the given items.
  * Takes time proportional to the number of items using sink-based heap construction.
  */
-(instancetype) initWithKeys:(ARArrayList*) keys
{
    self = [self initWithCapacity:[keys count]];
    if (self){
        for (MaxPQKey key in keys) {
            [self _addObject:key];
        }
        for (NSUInteger k = _pqCount/2; k >= 1; k--){ // _pq[0] is unused
            [self sink:k];
        }
        NSAssert([self isMaxHeap],@"Not a max heap");
    }
    return self;
}


#pragma mark - Other


// Is the priority queue empty?
-(BOOL) isEmpty {
    return _pqCount == 0;
}


// Return the number of items on the priority queue.
-(NSUInteger) size {
    return _pqCount;
}


// Return the largest key on the priority queue.
// Returns nil if the queue is empty.
-(MaxPQKey) max {
    return [self isEmpty] ? nil : [self _objectAtIndex:1];  // _pq[0] is unused
}


// Add a new key to the priority queue.
-(void) insert:(MaxPQKey)x
{
    // add x, and percolate it up to maintain heap invariant
    [self _addObject:x];
    [self swim:_pqCount];

    NSAssert([self isMaxHeap],@"Not a max heap");
}


// Delete and return the largest key on the priority queue.
// Returns nil if the queue is empty.
-(MaxPQKey) delMax
{
    if ([self isEmpty]) return nil;
    MaxPQKey max = [self _objectAtIndex:1];  // _pq[0] is unused
    [self exchThis:1 that:_pqCount--];
    [self sink:1];
    //[self _insertObject:nil atIndex:_pqCount+1]; // to avoid loiterig and help with garbage collection
    //if ((_pqCount > 0) && (_pqCount == (pq.length - 1) / 4)) resize(pq.length / 2);
    NSAssert([self isMaxHeap],@"Not a max heap");
    return max;
}

#pragma mark - private

-(void) swim:(NSUInteger) k {
    while (k > 1 && [self lessThis:k/2 that:k]) { // _pq[0] is unused
        [self exchThis:k that:k/2];
        k = k/2;
    }
}


-(void) sink:(NSUInteger)k {
    while (2*k <= _pqCount) {
        NSUInteger j = 2*k;
        if (j < _pqCount && [self lessThis:j that:j+1]) j++;
        if (![self lessThis:k that:j]) break;
        [self exchThis:k that:j];
        k = j;
    }
}


#pragma mark - Helper functions for compares and swaps


-(BOOL) lessThis:(NSUInteger)i that:(NSUInteger)j
{
    MaxPQKey k1 = [self _objectAtIndex:i];
    MaxPQKey k2 = [self _objectAtIndex:j];
    if (_comparator == nil) {
        NSAssert([k1 respondsToSelector:NSSelectorFromString(@"compare:")],
                 @"No comparator defined and the key doesn't support compare:");
        return [k1 compare:k2] == NSOrderedAscending;
    }
    else {
        return _comparator(k1, k2)  == NSOrderedAscending;
        return _comparator([self _objectAtIndex:i], [self _objectAtIndex:i]) == NSOrderedAscending;
    }
}


-(void) exchThis:(NSUInteger)i that:(NSUInteger)j
{
    MaxPQKey swap = [self _objectAtIndex:i];
    [self _insertObject:[self _objectAtIndex:j] atIndex:i];
    [self _insertObject:swap atIndex:j];
}


// is pq[1..N] a max heap?
-(BOOL) isMaxHeap {
    return [self isMaxHeap:1];
}


// is subtree of pq[1..N] rooted at k a max heap?
-(BOOL) isMaxHeap:(NSUInteger)k
{
    if (k > _pqCount) return true;
    int left = 2*k, right = 2*k + 1;
    if (left  <= _pqCount && [self lessThis:k that:left])  return false;
    if (right <= _pqCount && [self lessThis:k that:right]) return false;
    return [self isMaxHeap:left] && [self isMaxHeap:right];
}


@end