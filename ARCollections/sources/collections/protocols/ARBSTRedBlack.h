
// BSD License. Author: jano@jano.com.es

#import "ARBSTRedBlackNode.h"
#import "ARQueue.h"


@protocol ARBSTRedBlack

@property (nonatomic,strong) ARBSTRedBlackNode *root;

typedef NSObject<ARBSTRedBlack> ARBSTRedBlack;


-(BOOL) isEmpty;
-(NSUInteger) count;
-(NSUInteger) countOfNode:(ARBSTRedBlackNode*)node;

-(NSInteger) height;
-(NSInteger) height:(ARBSTRedBlackNode*)node;

#pragma mark - search

-(BOOL) contains:(ARBSTKey*)key;
-(BOOL) contains:(ARBSTKey*)key fromNode:(ARBSTRedBlackNode*)node;
-(ARBSTRedBlackNode*) objectForKey:(ARBSTKey*)key;
-(ARBSTRedBlackNode*) objectForKey:(ARBSTKey*)key fromNode:(ARBSTRedBlackNode*)node;

#pragma mark - insert

-(void) insertKey:(ARBSTKey*)key value:(ARBSTValue*)value;
-(ARBSTRedBlackNode*) insertKey:(ARBSTKey*)key value:(ARBSTValue*)value onNode:(ARBSTRedBlackNode*)node;

#pragma mark - delete

-(void) deleteMax;
-(void) deleteMin;
-(ARBSTRedBlackNode*) deleteMax:(ARBSTRedBlackNode*)node;
-(ARBSTRedBlackNode*) deleteMin:(ARBSTRedBlackNode*)node;
-(void) deleteKey:(ARBSTKey*)key;
-(ARBSTRedBlackNode*) deleteKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node;

#pragma mark - min, max, floor, and ceiling

-(ARBSTKey*) min;
-(ARBSTKey*) max;
-(ARBSTRedBlackNode*) min:(ARBSTRedBlackNode*)node;
-(ARBSTRedBlackNode*) max:(ARBSTRedBlackNode*)node;
-(ARBSTKey*) floorKey:(ARBSTKey*)key;
-(ARBSTRedBlackNode*) floorKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node;
-(ARBSTKey*) ceilingKey:(ARBSTKey*)key;
-(ARBSTRedBlackNode*) ceilingKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node;

#pragma mark - Rank and selection

-(ARBSTKey*)  selectRank:(NSInteger)rank;
-(ARBSTRedBlackNode*) selectRank:(NSInteger)rank node:(ARBSTRedBlackNode*)node;
-(NSInteger) rankKey:(ARBSTKey*)key;
-(NSInteger) rankKey:(ARBSTKey*)key node:(ARBSTRedBlackNode*)node;

#pragma mark - Range count and range search

-(NSObject<ARQueue>*) keys;
-(NSObject<ARQueue>*) keysBetweenLow:(ARBSTKey*)lo andHi:(ARBSTKey*)hi;
-(NSInteger) sizeKeylo:(ARBSTKey*)lo hi:(ARBSTKey*)hi;

#pragma mark - Check integrity

-(BOOL) check;
-(BOOL) isBST;
-(BOOL) isBST:(ARBSTRedBlackNode*)node minKey:(ARBSTKey*)minKey maxKey:(ARBSTKey*)maxKey;
-(BOOL) isSizeConsistent;
-(BOOL) isSizeConsistent:(ARBSTRedBlackNode*)node;
-(BOOL) isRankConsistent;

@end
