
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "MaxPQArray.h"

@interface MaxPQArrayTest : SenTestCase
@end


@implementation MaxPQArrayTest

- (void) testMaxPQArray
{
    MaxPQArray *array = [[MaxPQArray alloc] initWithCapacity:0 comparator:nil];
    [array addObject:@"X"];
    NSLog(@"description: %@",array);
}

@end

