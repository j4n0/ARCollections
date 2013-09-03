
// BSD License. Created by jano@jano.com.es

@protocol Comparable
- (NSComparisonResult)compare:(NSObject*)object;
@end

@interface NSString()<Comparable>
@end
