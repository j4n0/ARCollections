
// BSD License. Author: jano@jano.com.es

#import "ARContainer.h"
#import "ARList.h"

/** Ordered collection where elements are inserted and removed at the top. */
@protocol ARStack <ARContainer>

-(id) initWithARList:(id<ARList>)array;
-(BOOL) isEqualToARStack:(id<ARStack>)stack;
-(id) copy;
-(NSString*) componentsJoinedByString:(NSString *)string;

-(id<ARList>) allObjects;

-(id) peek;             // Returns the item on top.
-(id) pop;              // Removes and returns the item on top.
-(void) push:(id)item;  // Adds an element on top.

@end