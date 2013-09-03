
// BSD License. Author: jano@jano.com.es

#import "ARQueue.h"
#import "ARStack.h"

/** Ordered collection where elements are inserted and removed from both sides. */
@protocol ARDeque <ARContainer>

// Adds the given elements to the rear.
// First element of the array will be the one in the front.
-(id) initWithARList:(id<ARList>)array;

-(BOOL) isEqualToARDeque:(NSObject<ARDeque>*)stack;
-(id) copy;

-(id<ARList>) allObjects;

-(void) addFront:(id)item;
-(id) removeFront;
-(void) addRear:(id)item;
-(id) removeRear;

@end