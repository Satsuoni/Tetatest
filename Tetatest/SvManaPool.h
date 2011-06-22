//
//  SvManaPool.h
//  Tetatest
//
//  Created by Seva on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#define MANA_TYPES 5

@interface SvManaPool : NSObject {
    double mana[MANA_TYPES];
}
- (double) getMana:(int) mtype;
- (id) initWithPool: (double *) manapool;
- (void) addMana:(int) mana amount: (double) amount;
- (BOOL) canDraw: (SvManaPool *) drawpool;
- (BOOL) canDrawDouble: (double *) pool;
- (BOOL) isPoolValid;//all nonnegative
- (BOOL) drawFromPool: (SvManaPool *) amount;
- (BOOL) isEqualToPool: (SvManaPool *) pool;
- (BOOL) transferToPool: (SvManaPool *) receptacle amount: (SvManaPool *) mana;
- (SvManaPool *) Add: (SvManaPool *) pool;
- (SvManaPool *) Multiply: (double) d;
- (SvManaPool *) Subtract: (SvManaPool *) pool;
@end
