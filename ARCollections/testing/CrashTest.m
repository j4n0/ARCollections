
// BSD License. Author: jano@jano.com.es

#import <SenTestingKit/SenTestingKit.h>
#import "ARArrayList.h"
#import "ARDiGraphImpl.h"
#import "ARDiGraphImpl.h"


@interface CrashTest : SenTestCase
@end

@implementation CrashTest

-(void) testCrash
{
    ARDiGraphImpl *graph = [ARDiGraphImpl new];
    
    [graph :graph :@"1" :@1  :@"2"];
    [graph :graph :@"1" :@1  :@"3"];
    [graph :graph :@"2" :@1  :@"4"];
    [graph :graph :@"2" :@1  :@"5"];
    [graph :graph :@"3" :@1  :@"6"];
    [graph :graph :@"3" :@1  :@"7"];
    
    ARGraphNode *one = [graph nodeByValue:@"1"];
    
    ARArrayList *path = [graph breadthFirstSearchForValue:@"7" start:one];
    ARGraphNode *node = [path lastObject];
    STAssertTrue([node.value isEqualToString:@"7"],nil);
}

@end
