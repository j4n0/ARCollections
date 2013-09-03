
// BSD License. Author: jano@jano.com.es

#import "ARArrayList.h"
#import "ARQueueList.h"

extern NSUInteger kAlphabetSize;

typedef NSObject ARTrieValue;

@interface ARTrieNode : NSObject {
@public
    ARTrieValue *value;
    id __strong *next;
}
@end


/**
 * Trie.
 *
 * Algorithms from “5.2 Tries” of “Algorithms” by Sedgewick & Wayne.
 *
 * What is it?
 *   - A Trie is a tree specialized in storing strings.
 *   - Each node has a value and as many outgoing links as the alphabet size.
 *   - The value is either null, or the string associated with the string leading to it.
 *
 * Properties
 *   - The space is 'alphabetSize' times the number of characters of the string.
 *     eg: 26*6 to store 'borneo' (assuming only lowercase).
 *   - The number of operations to search/insert a key is the lenght of the key.
 *   - The number of operations in a search miss is: ~logN where log base = alphabet size.
 *
 * A trie provides excellent performance at a great space cost.
 */
@interface ARTrie : NSObject

// YES if the trie is empty.
-(BOOL) isEmpty;

// YES if there is a value for the given key.
-(BOOL) containsKey:(NSString*)key;

// Longest key that is a prefix of the given string.
-(NSString*) longestPrefixOf:(NSString*)query;

-(void) collectKeysFromNode:(ARTrieNode *) n
                     prefix:(NSString *)   p
                    pattern:(NSString *)   pat
                      queue:(ARQueueList*) q;

#pragma mark - keys

// All keys in the table.
-(ARQueueList*) keys;

// All keys with the given prefix.
-(ARQueueList*) keysWithPrefix:(NSString*)prefix;

// All keys that match the given pattern.
// A period (.) in the pattern matches any character.
-(ARQueueList*) keysThatMatch:(NSString*)pattern;

#pragma mark put, get, delete

// Add key-value pair. Remove key if value is nil.
-(void) putKey:(NSString*)key value:(ARTrieValue*)value;

// Value for key. Returns nil if not found.
-(ARTrieValue*) trieValueForKey:(NSString*)key;

/** Remove key-value pair. */
-(void) deleteKey:(NSString*)key;

@end