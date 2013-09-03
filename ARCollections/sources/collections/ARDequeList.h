
// BSD License. Author: jano@jano.com.es

#import "ARDeque.h"
#import "ARArrayList.h"

/**
 * A double ended queue backed by a list.
 * The front of the deque is the beginning of the array.
 */
@interface ARDequeList : ARArrayList <ARDeque>
@end
