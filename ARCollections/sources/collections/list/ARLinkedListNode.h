
// BSD License. Author: jano@jano.com.es

@interface ARLinkedListNode : NSObject

@property (nonatomic,strong) NSObject *value;
@property (nonatomic,strong) ARLinkedListNode *next;
@property (nonatomic,strong) ARLinkedListNode *prev;

-(id) initWithValue:(NSObject*)value;

@end