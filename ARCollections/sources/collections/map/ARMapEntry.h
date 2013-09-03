
// BSD License. Created by jano@jano.com.es

/** Map entry. */
@interface ARMapEntry : NSObject <NSCopying, NSCoding>

/** Key */
@property (nonatomic,strong) NSObject<NSCopying>* key;

/** Value */
@property (nonatomic,strong) NSObject* value;

/** Initialize with key and value. */
-(id) initWithKey:(NSObject<NSCopying>*)key value:(NSObject*)value;

/** Description. */
-(NSString*) description;

@end