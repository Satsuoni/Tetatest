//
//  SvManaPool.m
//  Tetatest
//
//  Created by Seva on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SvManaPool.h"


@implementation SvManaPool

- (int) poolFits:(SvManaPool *)pool
{
    int mn=-1;
    for(int i=0;i<MANA_TYPES;i++)
    {
        if([pool getMana:i]!=0)
        {
            int dtmn=floor(mana[i]/[pool getMana:i]);
            if(dtmn<10000&&dtmn>0)
                if(dtmn<mn||mn==-1) mn=dtmn;
        }
    }
    if(mn==-1) return 0;
    return mn;
}
-(double) Dot:(SvManaPool *)pool
{
    double sm=0;
    for(int i=0;i<MANA_TYPES;i++)
    {
        sm+=mana[i]*[pool getMana:i];
    }
    return sm;
}
- (id) initWithPool: (double *) manapool
{
    if((self=[super init]))
    {
        for(int i=0;i<MANA_TYPES;i++)
        {
            mana[i]=manapool[i];
        }
    }
    return self;
}
-(id) initWithArray:(NSArray *)manapool
{
    if((self=[super init]))
    {
        if(manapool==nil) return self;
        for(int i=0;i<MANA_TYPES;i++)
        {
            mana[i]=[[manapool objectAtIndex:i] doubleValue];
        }
    }
    return self;
}
- (void) addMana:(int) manat amount: (double) amount
{
    if(manat<0||manat>=MANA_TYPES)
        return;
    mana[manat]+=amount;
}
- (BOOL) canDraw: (SvManaPool *) drawpool
{
    for(int i=0;i<MANA_TYPES;i++)
    {
        if([drawpool getMana:i]>mana[i]) return NO;
    }
    return YES;
}
- (double) getMana: (int) mtype
{
    if(mtype<0||mtype>=MANA_TYPES)
        return 0;
    return mana[mtype]; 
}
- (BOOL) canDrawDouble: (double *) pool
{
    for(int i=0;i<MANA_TYPES;i++)
    {
        if(pool[i]>mana[i]) return NO;
    }
    return YES;
}
- (BOOL) isPoolValid
{
    for(int i=0;i<MANA_TYPES;i++)
    {
        if(mana[i]<0) return NO;
    }
    return YES;
}
- (BOOL) drawFromPool: (SvManaPool *) amount
{
    if(![self canDraw :amount]) return NO;
    for(int i=0;i<MANA_TYPES;i++)
    {
    mana[i]-=[amount getMana:i];
    }
    return YES;
}
- (BOOL) isEqualToPool: (SvManaPool *) pool
{
    for(int i=0;i<MANA_TYPES;i++)
    {
        if([pool getMana:i]!=mana[i]) return NO;
    }
    return YES; 
}
- (BOOL) transferToPool: (SvManaPool *) receptacle amount: (SvManaPool *) manap
{
    BOOL suc=YES;
    for(int i=0;i<MANA_TYPES;i++)
    {
        if([manap getMana:i]>mana[i])
        {
            [receptacle addMana:i amount:mana[i]];
            mana[i]=0;
            suc=NO;
        }
        else
        {
            mana[i]-=[manap getMana:i];
            [receptacle addMana:i amount:[manap getMana:i]];
        }
    }
    return suc;
}
- (SvManaPool *) Add:(SvManaPool *)pl
{
    double dt[MANA_TYPES];
       for(int i=0;i<MANA_TYPES;i++)
       {
           dt[i]=[pl getMana:i]+mana[i];
       }
    SvManaPool *ret=[[SvManaPool alloc] initWithPool:dt];
    return [ret autorelease];
}
- (SvManaPool *) Multiply:(double)d
{
    double dt[MANA_TYPES];
    for(int i=0;i<MANA_TYPES;i++)
    {
        dt[i]=d*mana[i];
    }
    SvManaPool *ret=[[SvManaPool alloc] initWithPool:dt];
    return [ret autorelease];
}
- (SvManaPool *) MultiplyBy:(SvManaPool *)pool
{
    double dt[MANA_TYPES];
    for(int i=0;i<MANA_TYPES;i++)
    {
        dt[i]=[pool getMana:i]*mana[i];
    }
    SvManaPool *ret=[[SvManaPool alloc] initWithPool:dt];
    return [ret autorelease];
}
- (SvManaPool *) Subtract:(SvManaPool *)pl
{
    double dt[MANA_TYPES];
    for(int i=0;i<MANA_TYPES;i++)
    {
        dt[i]=mana[i]-[pl getMana:i];
    }
    SvManaPool *ret=[[SvManaPool alloc] initWithPool:dt];
    return [ret autorelease];
}
-(void) Drain
{
    for(int i=0;i<MANA_TYPES;i++)
    {
        mana[i]=0;
    }
}
-(void) DrainIntoPool: (SvManaPool *)pool
{
    for(int i=0;i<MANA_TYPES;i++)
    {
        [pool addMana:i amount: mana[i]];
        mana[i]=0;
    }
}
@end
