
// BSD License. Author: jano@jano.com.es

#import "ARArrayList.h"

typedef id MaxPQKey;
typedef NSComparisonResult (^compare_t) (id obj1, id obj2);

/**
 *  The <tt>MaxPQ</tt> class represents a priority queue of generic keys.
 *  It supports the usual <em>insert</em> and <em>delete-the-maximum</em>
 *  operations, along with methods for peeking at the maximum key,
 *  testing if the priority queue is empty, and iterating through
 *  the keys.
 *  <p>
 *  The <em>insert</em> and <em>delete-the-maximum</em> operations take
 *  logarithmic amortized time.
 *  The <em>max</em>, <em>size</em>, and <em>is-empty</em> operations take constant time.
 *  Construction takes time proportional to the specified capacity or the number of
 *  items used to initialize the data structure.
 *  <p>
 *  This implementation uses a binary heap.
 *  <p>
 *  For additional documentation, see <a href="http://algs4.cs.princeton.edu/24pq">Section 2.4</a> of
 *  <i>Algorithms, 4th Edition</i> by Robert Sedgewick and Kevin Wayne.
 */
@interface MaxPQ : NSObject <NSFastEnumeration>

-(instancetype) init;
-(instancetype) initWithCapacity:(NSUInteger)capacity;
-(instancetype) initWithCapacity:(NSUInteger)capacity comparator:(compare_t)comparator;
-(instancetype) initWithComparator:(compare_t)comparator;
-(instancetype) initWithKeys:(ARArrayList*) keys;

-(BOOL) isEmpty;
-(NSUInteger) size;
-(MaxPQKey) max;
-(void) insert:(MaxPQKey)x;
-(MaxPQKey) delMax;

@end