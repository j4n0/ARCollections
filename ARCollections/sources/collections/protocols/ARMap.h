
// BSD License. Created by jano@jano.com.es

#import "ARArrayList.h"

/** Map protocol. */
@protocol ARMap

#pragma mark - Block iterators

+ (id) emptyMutable;  // Return a mutable version of this container.
-         (BOOL)   and: (BOOL (^) (ARMapEntry* object)) block;  // Returns `true` when `block(object)` returns `true` for every collection's object.
-         (BOOL)    or: (BOOL (^) (ARMapEntry* object)) block;  // Return `true` when `block(object)` returns `true` for at least one collection's object.
-         (void)  each: (void (^) (ARMapEntry* object)) block;  // Pass each of the collection objects to the given block.
-           (id)  find: (BOOL (^) (ARMapEntry* object)) block;  // Returns the first object for which the block returns true.
- (instancetype) where: (BOOL (^) (ARMapEntry* object)) block;  // Return the objects for which the block returns true.
- (instancetype) map:   (ARMapEntry*(^)(ARMapEntry* entry))block;  // Apply the block to each object and return the results in a collection of the same type.
- (instancetype) pluck: (NSString*)  keypath;             // Returns a collection containing the objects for the given key path.
-     (ARArrayList*) split: (NSUInteger) numberOfPartitions;  // Split the collection in the given number of partitions.

#pragma mark - Initialize

-(id) initWithCapacity:(NSUInteger)capacity;
-(id) initWithData:(NSData*)data;

#pragma mark - Read, add, remove

-(ARArrayList*) allKeys;
-(ARArrayList*) allValues;
-(ARMapEntry*) entryForKey:(NSObject*)key;
-(void) addEntry:(ARMapEntry*)entry;
-(void) removeEntry:(ARMapEntry*)entry;

#pragma mark - Equality

-(BOOL) isEqual:(id)other;
-(BOOL) isEqualToARMap:(id<ARMap>)map;

#pragma mark - Other

-(NSData*) bytes;
-(NSString*) componentsJoinedByString:(NSString*)string;
-(NSString*) description;
-(void) enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block;
-(NSUInteger) hash;

@end