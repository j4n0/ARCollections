
// BSD License. Created by jano@jano.com.es

#import "ARSetImpl.h"


/** Expand capacity when the dictionary is this percent full. */
const float kSetLoadFactor = 0.75;

/** Default number of elements to initialize the dictionary with. */
const NSUInteger kSetDefaultCapacity = 10;

/* ARSetEntry wrapper with a link to the next element. Internal class. */
@interface _SetBucket : NSObject
@property (nonatomic,strong) NSObject<NSCopying>* value;
@property (nonatomic,strong) _SetBucket* next;
-(id) initWithValue:(NSObject<NSCopying>*)value;
@end

@implementation _SetBucket
-(id) initWithValue:(NSObject<NSCopying>*)value {
    self = [super init];
    if (self){
        _value = value;
    }
    return self;
}
@end


@interface ARSetImpl()
@property (nonatomic,assign,readwrite) NSUInteger count;
-(NSUInteger) indexForValue:(NSObject*)key;
-(float) currentLoad;
@end


@implementation ARSetImpl {
    id __strong *_objs;       // array
    NSUInteger _capacity;     // array positions
    unsigned long _mutations; // modification counter
    NSUInteger _slotsFilled;  // array positions filled-in
    CGFloat _loadFactor;
}


#pragma mark - Block iterators


+(ARSetImpl*) emptyMutable {
    return [ARSetImpl new];
}


- (BOOL) and: (BOOL(^)(NSObject* object))block {
    NSParameterAssert(block != nil);
    BOOL result = YES;
    for (NSObject* object in self) {
        if (!block(object)){
            result = NO;
            break;
        }
    }
    return result;
}


- (BOOL) or: (BOOL(^)(NSObject* object))block {
	NSParameterAssert(block != nil);
    BOOL result = NO;
    for (NSObject* object in self) {
        if (block(object)){
            result = YES;
            break;
        }
    }
    return result;
}


- (void) each: (void (^)(NSObject* object))block {
    NSParameterAssert(block != nil);
    for (NSObject* object in self) {
        block(object);
    }
}


- (id) find: (BOOL(^)(NSObject* object))block {
	NSParameterAssert(block != nil);
    id result;
    for (NSObject* object in self) {
        if (block(object)){
            result = object;
            break;
        }
    }
    return result;
}


- (instancetype) where: (BOOL(^)(NSObject* object))block {
	NSParameterAssert(block != nil);
    id result = [[self class] emptyMutable];
    for (NSObject* object in self){
        if (block(object)==YES){
            [result addObject:object];
        }
    }
	return result;
}


- (instancetype) map: (NSObject<NSCopying>*(^)(NSObject* object))block {
    NSParameterAssert(block != nil);
    id result = [[self class] emptyMutable];
    for (NSObject* object in self){
        [result addObject:block(object)];
    }
    return result;
}


- (instancetype) pluck: (NSString*)keyPath {
    NSParameterAssert(keyPath != nil);
    return [self map:^NSObject<NSCopying> *(NSObject *object) {
        NSObject<NSCopying> *value = [object valueForKeyPath:keyPath];
        return value;
    }];
}


-(ARArrayList*) split:(NSUInteger)numberOfPartitions
{
    if (numberOfPartitions==0) {
        return [ARArrayList new];
    }
    
    NSUInteger elementsPerPartition = [self count]/numberOfPartitions;
    if (elementsPerPartition==0){
        ARArrayList *array = [ARArrayList new];
        [array addObject:self];
        return array;
    }
    
    ARArrayList *array = [[ARArrayList alloc] initWithCapacity:numberOfPartitions];
    id subcollection = [[self class] emptyMutable];
    for (NSObject *object in self){
        [subcollection addObject:object];
        if ([subcollection count]==elementsPerPartition){
            [array addObject:subcollection];
            subcollection = [[self class] emptyMutable];
        }
    }
    
    return array;
}


#pragma mark - ARContainer


-(NSUInteger) count {
    return _count;
}


- (id)init {
    return [self initWithCapacity:kSetDefaultCapacity];
}


-(BOOL) isEmpty {
    return _count == 0;
}


#pragma mark - ARSetProtocol


// Initialize


- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self){
        _loadFactor = kSetLoadFactor;
        _capacity = capacity;
        _objs = (id __strong *)calloc(capacity,sizeof(*_objs));
        _count = 0;
        _mutations = 0;
    }
    return self;
}


-(id) initWithData:(NSData*)data {
    self = [super init];
    if (self){
        [self updateWithData:data];
    }
    return self;
}


// Read, add, remove


-(ARArrayList*) allObjects {
    return [self allValues];
}


-(void) removeObject:(NSObject<NSCopying>*)object {
    [self removeValue:object];
}


-(void) addObject:(NSObject<NSCopying>*)object {
    [self addValue:object];
}



-(void) addValue:(NSObject<NSCopying>*)value {
    _mutations++;
    
    if ([self currentLoad]>_loadFactor){
        [self expandCapacity];
    }
    
    NSUInteger index = [self indexForValue:value];
    if (_objs[index]==nil){
        // empty, save it there
        _objs[index] = [[_SetBucket alloc] initWithValue:value];
        _slotsFilled++; // filling an array entry
        _count++;
    } else {
        // not empty, try to move forward to an entry with same key
        _SetBucket *bucket = _objs[index];
        while (![bucket.value isEqual:value] && (bucket.next!=nil)){
            bucket = bucket.next;
        }
        if ([bucket.value isEqual:value]){
            // entry with same key
            bucket.value = value;
        } else {
            // entry with different key
            bucket.next = [[_SetBucket alloc] initWithValue:value];
            _count++;
        }
    }
}


-(ARArrayList*) allValues {
    ARArrayList *values = [[ARArrayList alloc] initWithCapacity:[self count]];
    for (NSUInteger i=0; i<_capacity; i++) {
        if (_objs[i]!=nil) {
            _SetBucket *bucket = _objs[i];
            if (bucket!=nil){
                do {
                    [values addObject:bucket.value];
                    bucket = bucket.next;
                } while (bucket!=nil);
            }
        }
    }
    return values;
}


-(NSObject<NSCopying>*) member:(NSObject<NSCopying>*)value {
    NSUInteger index = [self indexForValue:value];
    _SetBucket* bucket = _objs[index];
    if (bucket!=nil){
        // spot filled, move to the right key in the linked list
        while ((bucket!=nil) && (![bucket.value isEqual:value])){
            bucket = bucket.next;
        }
    }
    return bucket.value;
}


-(void) removeValue:(NSObject<NSCopying>*)value {
    _mutations++;
    NSUInteger index = [self indexForValue:value];
    if (_objs[index]==nil){
        // not found, warning
        //warn(@"No entry for key %@", entry.key);
    } else {
        // found
        if ([((_SetBucket*)_objs[index]).value isEqual:value]){
            // same key, jump or nil the node
            if (((_SetBucket*)_objs[index]).next==nil){
                // no next, nil the node
                _objs[index] = nil;
                _count--;
                _slotsFilled--;
            } else {
                // next, jump the node
                _objs[index] = ((_SetBucket*)_objs[index]).next;
                _count--;
            }
        } else {
            // different key, move to the node with the right key
            _SetBucket *prev = _objs[index];
            while (prev.next!=nil && ![prev.next.value isEqual:value]){
                prev = prev.next;
            }
            if (prev==nil){
                // not found, warning
                warn(@"No entry for key %@", value);
            } else {
                // found, jump or nil the node
                prev.next = (prev.next.next==nil) ? nil : prev.next.next;
                _slotsFilled--;
            }
        }
    }
}


// Equality


-(BOOL) isEqual:(id)other {
    if (other == self) {
        return YES;
    }
    if (!other || ![other conformsToProtocol:@protocol(ARSet)]) {
        return NO;
    }
    return [self isEqualToARSet:other];
}


-(BOOL) isEqualToARSet:(ARSetImpl*)set {
    if (self == set){
        return YES;
    }
    return [self and:^BOOL(NSObject*value) {
        return [set member:value]!=nil;
    }];
}


// Other


-(NSData*) bytes {
    size_t bytesToCopy = _capacity * sizeof(*_objs);
    NSData *data = [NSData dataWithBytes:_objs length:bytesToCopy];
    return data;
}


-(NSString*) componentsJoinedByString:(NSString*)string
{
    NSMutableString *mString = [NSMutableString new];
    for (NSUInteger i=0; i<_capacity; i++) {
        if (_objs[i]!=nil) {
            _SetBucket *bucket = _objs[i];
            if (bucket!=nil){
                do {
                    [mString appendString:[bucket.value description]];
                    bucket = bucket.next;
                } while (bucket!=nil);
            }
        }
        // separator
        if ((i+1)<_slotsFilled) [mString appendString:string];
    }
    return mString;
}


-(NSString*) description {
    return [self componentsJoinedByString:@","];
}


- (void)enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block {
    BOOL stop = false;
    NSUInteger i = 0;
    for (id object in self){
        block(object, i, &stop);
        i++;
        if (stop) break;
    }
}


- (NSUInteger) hash {
    return [[self bytes] hash];
}


#pragma mark - Internal


-(void) freePointers:(__strong id*)pointers size:(NSUInteger)size {
    for (NSUInteger i=0; i<size; i++) {
        //pointers[i] = nil;
    }
    free(pointers);
}


-(void) updateWithData:(NSData*)data
{
    _capacity = [data length] / sizeof(*_objs);
    
    // replace current bytes with data
    id __strong *newObjs = (id __strong *)calloc(_capacity,sizeof(*_objs));
    [data getBytes:newObjs];
    id __strong *oldObjs = _objs;
    _objs = newObjs;
    
    // nil and free
    if (oldObjs!=nil) {
        [self freePointers:oldObjs size:_capacity];
    }
    
    // update variables
    _count = 0;
    _slotsFilled = 0;
    for (NSUInteger i=0; i<_capacity; i++) {
        if (_objs[i]!=nil) {
            _slotsFilled++;
            _count++;
            _SetBucket *bucket = _objs[i];
            bucket = bucket.next;
            while (bucket!=nil){
                _count++;
                bucket = bucket.next;
            }
        }
    }
}


-(float) currentLoad {
    return _capacity>0 ? _slotsFilled/(float)_capacity : 1.0;
}


- (void) dealloc {
    [self freePointers:_objs size:_capacity];
}



-(void) expandCapacity
{
    // start allocating with 16 elements, then double the capacity
    NSUInteger newCapacity = _capacity>0 ? _capacity*2 : 1;
    id __strong *newObjs = (id __strong *)calloc(newCapacity,sizeof(*newObjs));
    if (_objs!=nil){
        
        NSUInteger newSlotsFilled = 0;
        for (NSObject<NSCopying> *value in self) {
            NSUInteger index = [value hash] % newCapacity;
            if (newObjs[index]==nil){
                // empty, save it there
                newObjs[index] = [[_SetBucket alloc] initWithValue:value];
                newSlotsFilled++; // filling an array entry
            } else {
                // not empty, try to move forward to an entry with same key
                _SetBucket *bucket = newObjs[index];
                while (![bucket.value isEqual:value] && (bucket.next!=nil)){
                    bucket = bucket.next;
                }
                if ([bucket.value isEqual:value]){
                    // entry with same key
                    bucket.value = value;
                } else {
                    // entry with different key
                    bucket.next = [[_SetBucket alloc] initWithValue:value];
                }
            }
        }
        
        // set the new data
        id __strong *old = _objs;
        _objs = newObjs;
        [self freePointers:old size:_capacity];
        _capacity = newCapacity;
        _slotsFilled = newSlotsFilled;
    }
}


-(NSUInteger) indexForValue:(NSObject*)value {
    return _capacity>0 ? ([value hash] % _capacity) : 1;
}


-(NSString*) longDescription {
    NSMutableString *mString = [NSMutableString new];
    [mString appendFormat:@"count: %d, capacity: %d, load: %f, slotsFilled: %d, %@",
     _count, _capacity, [self currentLoad], _slotsFilled, [self description]];
    return mString;
}


#pragma mark - NSCoding


- (void)encodeWithCoder:(NSCoder*)coder {
    NSData *data = [self bytes];
    [coder encodeObject:data forKey:NSStringFromClass([self class])];
}


- (id)initWithCoder:(NSCoder*)coder {
    self = [self init];
    if (self) {
        NSData *data = [coder decodeObjectForKey:NSStringFromClass([self class])];
        [self updateWithData:data];
    }
    return self;
}


#pragma mark - NSCopying


- (id)copyWithZone:(NSZone*)zone {
    NSData *data = [self bytes];
    ARSetImpl *copy = [[ARSetImpl alloc] initWithData:data];
    return copy;
}


#pragma mark - NSFastEnumeration


- (NSUInteger) countByEnumeratingWithState: (NSFastEnumerationState*)state
                                   objects: (id __unsafe_unretained*)stackbuf
                                     count: (NSUInteger)len
{
    // modification guard
    state->mutationsPtr = (unsigned long *) &_mutations;
    
    // fetch either len objects, or whatever is left on the collection
    NSInteger count = MIN(len, [self count] - state->state);
    
    if (count>0){
        NSUInteger index = 0; // stackbuf index
        NSUInteger p = state->extra[0]; // array position
        _SetBucket *bucket = (__bridge _SetBucket *)(state->extra[1]==0 ? nil : (void*)state->extra[1]); // last element read
        do {
            // walk the element (if any)
            while (bucket!=nil){
                stackbuf[index] = bucket.value;
                bucket = bucket.next;
                state->extra[1] = (NSUInteger)bucket; // save pointer to the next entry
                index++;
                if (index==count) break;
            }
            if (index==count) {
                break;
            } else {
                // walk the array
                bucket = _objs[p];
                state->extra[1] = (NSUInteger)bucket; // save pointer to the next entry
                p++;
                state->extra[0] = p; // save pointer to the next array position
            }
        } while (!(p>_capacity));
    }
    
    state->itemsPtr = stackbuf; // pointer to the buffer
    state->state += count;      // number of values read
    return count;
}


@end
