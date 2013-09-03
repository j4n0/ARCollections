
// BSD License. Created by jano@jano.com.es

#import "ARArrayList.h"

/** Set protocol. */
@protocol ARSet <ARContainer>

#pragma mark - Block iterators

+ (instancetype) emptyMutable;  // Return a mutable version of this container.
-         (BOOL)   and: (BOOL (^) (NSObject* object)) block;  // Returns `true` when `block(object)` returns `true` for every collection's object.
-         (BOOL)    or: (BOOL (^) (NSObject* object)) block;  // Return `true` when `block(object)` returns `true` for at least one collection's object.
-         (void)  each: (void (^) (NSObject* object)) block;  // Pass each of the collection objects to the given block.
-           (id)  find: (BOOL (^) (NSObject* object)) block;  // Returns the first object for which the block returns true.
- (instancetype)   map: (NSObject<NSCopying>*(^)(NSObject* entry))block;  // Apply the block to each object and return the results in a collection of the same type.
- (instancetype) pluck: (NSString*)  keypath;                 // Returns a collection containing the objects for the given key path.
-     (ARArrayList*) split: (NSUInteger) numberOfPartitions;      // Split the collection in the given number of partitions.
- (instancetype) where: (BOOL (^) (NSObject* object)) block;  // Return the objects for which the block returns true.

#pragma mark - Initialize

-(id) initWithCapacity:(NSUInteger)capacity;
-(id) initWithData:(NSData*)data;

#pragma mark - Read, add, remove

//-(ARArray*) allKeys;
//-(ARArray*) allValues;
//-(ARSetEntry*) entryForKey:(NSObject*)key;
//-(void) addEntry:(ARSetEntry*)entry;
//-(void) removeEntry:(ARSetEntry*)entry;

-(ARArrayList*) allObjects;
-(void) removeObject:(NSObject*)object;
-(void) addObject:(NSObject*)object;
-(NSObject*) member:(NSObject*)object;


#pragma mark - Equality

-(BOOL) isEqual:(id)other;
-(BOOL) isEqualToARSet:(id<ARSet>)Set;

#pragma mark - Other

-(NSData*) bytes;
-(NSString*) componentsJoinedByString:(NSString*)string;
-(NSString*) description;
-(void) enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
-(NSUInteger) hash;

@end