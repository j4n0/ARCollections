
// BSD License. Author: jano@jano.com.es

#import "Comparable.h"

typedef NS_ENUM(unsigned char, ARTreeOrder) {
    ARTreeOrderPre,
    ARTreeOrderPost,
    ARTreeOrderIn,
    ARTreeOrderBreadth
};

typedef NSObject             ARBSTValue;
typedef NSObject<Comparable> ARBSTKey;

typedef void (^order_t)(id object);

// max/min for integers
#define imax(a,b) ({ __typeof__ (a) _a = (a); __typeof__ (b) _b = (b); _a > _b ? _a : _b; })
#define imin(a,b) ({ __typeof__ (a) _a = (a); __typeof__ (b) _b = (b); _a < _b ? _a : _b; })
