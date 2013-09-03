
// BSD License. Created by jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "MaxPQ.h"

@interface ARTSTTest : SenTestCase
@end


@implementation ARTSTTest

- (void) testMaxPQ
{
    MaxPQ *q = [[MaxPQ alloc] init];
    
    // insert PQE
    [q insert:@"P"];
    [q insert:@"Q"];
    [q insert:@"E"];
    NSLog(@"insert PQE: %@",q);
    
    // remove max (Q)
    [q delMax];
    NSLog(@"remove max (Q): %@",q);
    
    // insert XAM
    [q insert:@"X"];
    [q insert:@"A"];
    [q insert:@"M"];
    NSLog(@"insert XAM: %@",q);
    
    // remove max (X)
    [q delMax];
    NSLog(@"remove max (X): %@",q);
    
    // insert PLE
    [q insert:@"P"];
    [q insert:@"L"];
    [q insert:@"E"];
    NSLog(@"insert PLE: %@",q);
    
    // remove max (P)
    [q delMax];
    NSLog(@"remove max (P): %@",q);
}

@end

