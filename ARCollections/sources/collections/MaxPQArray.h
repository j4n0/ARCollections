
// BSD License. Created by jano@jano.com.es

typedef id MaxPQKey;
typedef NSComparisonResult (^compare_t) (id obj1, id obj2);


// Position 0 is unused.
@interface MaxPQArray : NSObject {
@private
    __strong id * _pq;          // store items at indices 1 to N
    NSUInteger    _pqCapacity;
    NSUInteger    _pqCount;     // number of items on priority queue
    compare_t     _comparator;  // optional Comparator
}

-(instancetype) initWithCapacity:(NSUInteger)capacity comparator:(compare_t)comparator;
-(NSString*) description;
-(void) addObject:(MaxPQKey)object;

@end
