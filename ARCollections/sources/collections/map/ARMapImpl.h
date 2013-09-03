
// BSD License. Created by jano@jano.com.es

#import "ARArrayList.h"
#import "ARContainer.h"
#import "ARMapEntry.h"
#import "ARMap.h"

//  ARBlockIterators: and:, or:, each:, find:, map:, pluck:, split:, where:
//       ARContainer: count, init, isEmpty
//     ARMapProtocol: initWithCapacity:, initWithData:, entryForKey:, addEntry:, removeEntry:, isEqual:, isEqualToARMap:
//          NSCoding: encodeWithCoder:, initWithCoder:
//         NSCopying: copyWithZone:
// NSFastEnumeration: countByEnumeratingWithState:objects:count:

/** 
 * Hash table implementation with separate chaining. 
 * Read Θ(1). Set/remove Θ(1+n/m) assuming uniform distribution, or O(n) worst case.
 */
@interface ARMapImpl : NSObject <ARContainer, ARMap, NSCoding, NSCopying, NSFastEnumeration>

@property (nonatomic,assign,readonly) NSUInteger count;

@end
