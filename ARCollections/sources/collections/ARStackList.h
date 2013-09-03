
// BSD License. Author: jano@jano.com.es

#import "ARArrayList.h"
#import "ARStack.h"

/** 
 * A stack backed by a list.
 *
 * Array based implementation where the end of the array is the top of the stack.
 * That is, elements are added and removed at the end of the array.
 * Performance is Θ(1) for add/remove/read. Expanding the array is Θ(n).
 */
@interface ARStackList : ARArrayList <ARStack>
@end
