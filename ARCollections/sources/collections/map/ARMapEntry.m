
// BSD License. Created by jano@jano.com.es

#import "ARMapEntry.h"

@implementation ARMapEntry

-(id) initWithKey:(NSObject<NSCopying>*)key value:(NSObject*)value {
    self = [super init];
    if (self){
        _key = key;
        _value = value;
    }
    return self;
}

-(NSString*) description {
    return [NSString stringWithFormat:@"{%@,%@}", _key, _value];
}

-(BOOL) isEqual:(id)object {
    if (self==object){
        return true;
    } else if (!object || ![object isKindOfClass:[self class]]) {
        return false;
    } else {
        return [self isEqualToAREntry:(ARMapEntry*)object];
    }
}

-(BOOL) isEqualToAREntry:(ARMapEntry*)entry {
    if (self == entry){
        return YES;
    }
    return [self.key isEqual:entry.key] && [self.value isEqual:entry.value];
}


#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    ARMapEntry *copy = [[ARMapEntry alloc] initWithKey:[_key copy] value:[_value copy]];
    return copy;
}

#pragma mark - NSCoding

NSString *const kARMapEntryKey = @"kARMapEntryKey";
NSString *const kARMapEntryValue = @"kARMapEntryValue";

- (void) encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:_key forKey:kARMapEntryKey];
	[encoder encodeObject:_value forKey:kARMapEntryValue];
}

- (id) initWithCoder:(NSCoder*)decoder {
    self = [super init];
	if (self) {
        _key = [decoder decodeObjectForKey:kARMapEntryKey];
        _value = [decoder decodeObjectForKey:kARMapEntryValue];
    }
	return self;
}

@end
