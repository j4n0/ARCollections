
// BSD License. Author: jano@jano.com.es

#import "ARTree.h"

@protocol ARBST

@property (nonatomic,strong) ARBSTNode *root;

typedef NSObject<ARBST> ARBST;


-(BOOL) isEmpty;
-(NSUInteger) count;
-(NSUInteger) countOfNode:(ARBSTNode*)node;

-(NSInteger) height;
-(NSInteger) height:(ARBSTNode*)node;

#pragma mark - search

-(BOOL) contains:(ARBSTKey*)key;
-(BOOL) contains:(ARBSTKey*)key fromNode:(ARBSTNode*)node;
-(ARBSTNode*) objectForKey:(ARBSTKey*)key;
-(ARBSTNode*) objectForKey:(ARBSTKey*)key fromNode:(ARBSTNode*)node;

#pragma mark - insert

-(void) insertKey:(ARBSTKey*)key value:(ARBSTValue*)value;
-(ARBSTNode*) insertKey:(ARBSTKey*)key value:(ARBSTValue*)value onNode:(ARBSTNode*)node;

#pragma mark - delete

-(void) deleteMax;
-(void) deleteMin;
-(ARBSTNode*) deleteMax:(ARBSTNode*)node;
-(ARBSTNode*) deleteMin:(ARBSTNode*)node;
-(void) deleteKey:(ARBSTKey*)key;
-(ARBSTNode*) deleteKey:(ARBSTKey*)key node:(ARBSTNode*)node;

#pragma mark - min, max, floor, and ceiling

-(ARBSTKey*)  min;
-(ARBSTKey*)  max;
-(ARBSTNode*) min:(ARBSTNode*)node;
-(ARBSTNode*) max:(ARBSTNode*)node;
-(ARBSTKey*)  floorKey:(ARBSTKey*)key;
-(ARBSTNode*) floorKey:(ARBSTKey*)key node:(ARBSTNode*)node;
-(ARBSTKey*)  ceilingKey:(ARBSTKey*)key;
-(ARBSTNode*) ceilingKey:(ARBSTKey*)key node:(ARBSTNode*)node;

#pragma mark - Rank and selection

-(ARBSTKey*)  selectRank:(NSInteger)rank;
-(ARBSTNode*) selectRank:(NSInteger)rank node:(ARBSTNode*)node;
-(NSInteger)  rankKey:(ARBSTKey*)key;
-(NSInteger)  rankKey:(ARBSTKey*)key node:(ARBSTNode*)node;

#pragma mark - Range count and range search

-(NSObject<ARQueue>*) keys;
-(NSObject<ARQueue>*) keysBetweenLow:(ARBSTKey*)lo andHi:(ARBSTKey*)hi;
-(NSInteger) sizeKeylo:(ARBSTKey*)lo hi:(ARBSTKey*)hi;

#pragma mark - Check integrity

-(BOOL) check;
-(BOOL) isBST;
-(BOOL) isBST:(ARBSTNode*)node minKey:(ARBSTKey*)minKey maxKey:(ARBSTKey*)maxKey;
-(BOOL) isSizeConsistent;
-(BOOL) isSizeConsistent:(ARBSTNode*)node;
-(BOOL) isRankConsistent;

@end
