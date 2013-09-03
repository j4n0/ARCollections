
// BSD License. Created by jano@jano.com.es

#import "ARMapImpl.h"


/** Expand capacity when the dictionary is this percent full. */
const float kMapLoadFactor = 0.75;

/** Default number of elements to initialize the dictionary with. */
const NSUInteger kMapDefaultCapacity = 10;

/* ARMapEntry wrapper with a link to the next element. Internal class. */
@interface _MapBucket : NSObject
@property (nonatomic,strong) ARMapEntry* entry;
@property (nonatomic,strong) _MapBucket* next;
-(id) initWithARMapEntry:(ARMapEntry*)entry;
@end

@implementation _MapBucket
-(id) initWithARMapEntry:(ARMapEntry*)entry {
    self = [super init];
    if (self){
        _entry = entry;
    }
    return self;
}
@end


@interface ARMapImpl()
@property (nonatomic,assign,readwrite) NSUInteger count;
-(NSUInteger) indexForKey:(NSObject*)key;
-(float) currentLoad;
@end


@implementation ARMapImpl {
    id __strong *_objs;       // array
    NSUInteger _capacity;     // array length
    unsigned long _mutations; // modification counter
    NSUInteger _slotsFilled;  // filled-in array positions 
    CGFloat _loadFactor;
}


#pragma mark - Block iterators


+(ARMapImpl*) emptyMutable {
    return [ARMapImpl new];
}

- (BOOL) and: (BOOL(^)(ARMapEntry* object))block {
    NSParameterAssert(block != nil);
    BOOL result = YES;
    for (id object in self) {
        if (!block(object)){
            result = NO;
            break;
        }
    }
    return result;
}

- (BOOL) or: (BOOL(^)(ARMapEntry* object))block {
	NSParameterAssert(block != nil);
    BOOL result = NO;
    for (id object in self) {
        if (block(object)){
            result = YES;
            break;
        }
    }
    return result;
}

- (void) each: (void (^)(ARMapEntry* object))block {
    NSParameterAssert(block != nil);
    for (id object in self) {
        block(object);
    }
}

- (id) find: (BOOL(^)(ARMapEntry* object))block {
	NSParameterAssert(block != nil);
    id result;
    for (id object in self) {
        if (block(object)){
            result = object;
            break;
        }
    }
    return result;
}

- (instancetype) where: (BOOL(^)(ARMapEntry* object))block {
	NSParameterAssert(block != nil);
    id result = [[self class] emptyMutable];
    for (ARMapEntry *entry in self){
        if (block(entry)==YES){
            [result addEntry:entry];
        }
    }
	return result;
}

- (instancetype) map: (ARMapEntry*(^)(ARMapEntry* entry))block {
    NSParameterAssert(block != nil);
    id result = [[self class] emptyMutable];
    for (id entry in self){
        ARMapEntry *e = block(entry);
        [result addEntry:e];
    }
    return result;
}

- (instancetype) pluck: (NSString*)keyPath {
    NSParameterAssert(keyPath != nil);
    return [self map:^id(ARMapEntry *entry) {
        id value = [entry.value valueForKeyPath:keyPath];
        ARMapEntry *e = [[ARMapEntry alloc] initWithKey:entry.key value:value];
        return e;
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
    for (ARMapEntry *entry in self){
        [subcollection addEntry:entry];
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
    return [self initWithCapacity:kMapDefaultCapacity];
}

-(BOOL) isEmpty {
    return _count == 0;
}


#pragma mark - ARMapProtocol


// Initialize


- (id) initWithCapacity:(NSUInteger)capacity {
    self = [super init];
    if (self){
        _loadFactor = kMapLoadFactor;
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


-(void) addEntry:(ARMapEntry*)entry {
    _mutations++;
    
    if ([self currentLoad]>_loadFactor){
        [self expandCapacity];
    }
    
    NSUInteger index = [self indexForKey:entry.key];
    if (_objs[index]==nil){
        // empty, save it there
        _objs[index] = [[_MapBucket alloc] initWithARMapEntry:entry];
        _slotsFilled++; // filling an array entry
        _count++;
    } else {
        // not empty, try to move forward to an entry with same key
        _MapBucket *bucket = _objs[index];
        while (![bucket.entry.key isEqual:entry.key] && (bucket.next!=nil)){
            bucket = bucket.next;
        }
        if ([bucket.entry.key isEqual:entry.key]){
            // entry with same key, replace value
            bucket.entry.value = entry.value;
        } else {
            // entry with different key, add bucket
            bucket.next = [[_MapBucket alloc] initWithARMapEntry:entry];
            _count++;
        }
    }
}


-(ARArrayList*) allKeys {
    ARArrayList *keys = [[ARArrayList alloc] initWithCapacity:[self count]];
    for (NSUInteger i=0; i<_capacity; i++) {
        if (_objs[i]!=nil) {
            _MapBucket *entry = _objs[i];
            if (entry!=nil){
                do {
                    [keys addObject:[entry.entry.key copy]];
                    entry = entry.next;
                } while (entry!=nil);
            }
        }
    }
    return keys;
}


-(ARArrayList*) allValues {
    ARArrayList *values = [[ARArrayList alloc] initWithCapacity:[self count]];
    for (NSUInteger i=0; i<_capacity; i++) {
        if (_objs[i]!=nil) {
            _MapBucket *entry = _objs[i];
            if (entry!=nil){
                do {
                    [values addObject:entry.entry.value];
                    entry = entry.next;
                } while (entry!=nil);
            }
        }
    }
    return values;
}


-(ARMapEntry*) entryForKey:(NSObject*)key {
    NSUInteger index = [self indexForKey:key];
    _MapBucket* entry = _objs[index];
    if (entry!=nil){
        // spot filled, move to the right key in the linked list
        while ((entry!=nil) && (![entry.entry.key isEqual:key])){
            entry = entry.next;
        }
    }
    return entry.entry;
}


-(BOOL) hasEntry:(ARMapEntry*)entry {
    ARMapEntry *e = [self entryForKey:entry.key];
    return e!=nil && [e.value isEqual:entry.value];
}


-(void) removeEntry:(ARMapEntry*)entry {
    _mutations++;
    NSUInteger index = [self indexForKey:entry.key];
    if (_objs[index]==nil){
        // not found, warning
        //warn(@"No entry for key %@", entry.key);
    } else {
        // found
        if ([((_MapBucket*)_objs[index]).entry.key isEqual:entry.key]){
            // same key, jump or nil the node
            if (((_MapBucket*)_objs[index]).next==nil){
                // no next, nil the node
                _objs[index] = nil;
                _count--;
                _slotsFilled--;
            } else {
                // next, jump the node
                _objs[index] = ((_MapBucket*)_objs[index]).next;
                _count--;
            }
        } else {
            // different key, move to the node with the right key
            _MapBucket *prev = _objs[index];
            while (prev.next!=nil && ![prev.next.entry.key isEqual:entry.key]){
                prev = prev.next;
            }
            if (prev==nil){
                // not found, warning
                warn(@"No entry for key %@", entry.key);
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
    if (!other || ![other conformsToProtocol:@protocol(ARMap)]) {
        return NO;
    }
    return [self isEqualToARMap:other];
}


-(BOOL) isEqualToARMap:(ARMapImpl*)map {
    if (self == map){
        return YES;
    }
    return [self and:^BOOL(NSObject*entry) {
        return [map hasEntry:(ARMapEntry*)entry];
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
            _MapBucket *entry = _objs[i];
            if (entry!=nil){
                do {
                    [mString appendString:[entry.entry description]];
                    entry = entry.next;
                } while (entry!=nil);
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
            _MapBucket *entry = _objs[i];
            entry = entry.next;
            while (entry!=nil){
                _count++;
                entry = entry.next;
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
        for (ARMapEntry *entry in self) {
            NSUInteger index = [entry.key hash] % newCapacity;
            if (newObjs[index]==nil){
                // empty, save it there
                newObjs[index] = [[_MapBucket alloc] initWithARMapEntry:entry];
                newSlotsFilled++; // filling an array entry
            } else {
                // not empty, try to move forward to an entry with same key
                _MapBucket *e = newObjs[index];
                while (![e.entry.key isEqual:entry.key] && (e.next!=nil)){
                    e = e.next;
                }
                if ([e.entry.key isEqual:entry.key]){
                    // entry with same key
                    e.entry.value = entry.value;
                } else {
                    // entry with different key
                    e.next = [[_MapBucket alloc] initWithARMapEntry:entry];
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


-(NSUInteger) indexForKey:(NSObject*)key {
    return _capacity>0 ? ([key hash] % _capacity) : 1;
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
    ARMapImpl *copy = [[ARMapImpl alloc] initWithData:data];
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
        _MapBucket *e = (__bridge _MapBucket *)(state->extra[1]==0 ? nil : (void*)state->extra[1]); // last element read
        do {
            // walk the element (if any)
            while (e!=nil){
                stackbuf[index] = e.entry;
                e = e.next;
                state->extra[1] = (NSUInteger)e; // save pointer to the next entry
                index++;
                if (index==count) break;
            }
            if (index==count) {
                break;
            } else {
                // walk the array
                e = _objs[p];
                state->extra[1] = (NSUInteger)e; // save pointer to the next entry
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
