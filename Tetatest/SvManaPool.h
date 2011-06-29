//
//  SvManaPool.h
//  Tetatest
//
//  Created by Seva on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MANA_TYPES 6
#define MANA_SUN 0
#define MANA_MOUNTAINS 1
#define MANA_FOREST 2
#define MANA_SEA 3
#define MANA_SWAMP 4
#define MANA_SPIRIT 5

@interface SvManaPool : NSObject {
    double mana[MANA_TYPES];
}
- (double) getMana:(int) mtype;
- (id) initWithPool: (double *) manapool;
- (id) initWithArray: (NSArray *) manapool;
- (void) addMana:(int) mana amount: (double) amount;
- (BOOL) canDraw: (SvManaPool *) drawpool;
- (BOOL) canDrawDouble: (double *) pool;
- (BOOL) isPoolValid;//all nonnegative
- (BOOL) drawFromPool: (SvManaPool *) amount;
- (BOOL) isEqualToPool: (SvManaPool *) pool;
- (BOOL) transferToPool: (SvManaPool *) receptacle amount: (SvManaPool *) mana;
- (void) Drain;
- (void) DrainIntoPool: (SvManaPool *)pool;
- (SvManaPool *) Add: (SvManaPool *) pool;
- (SvManaPool *) Multiply: (double) d;
- (SvManaPool *) Subtract: (SvManaPool *) pool;
- (double) Dot: (SvManaPool *)pool;
- (SvManaPool *) MultiplyBy:(SvManaPool*)pool;
- (int) poolFits: (SvManaPool *)pool;
@end
