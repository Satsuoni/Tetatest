//
//  SVSpawnedBody.h
//  Tetatest
//
//  Created by Seva on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVTetrisBody.h"
#import "SvStatusEffect.h"
#import "SvManaPool.h"
#import "OpenGLView.h"
typedef enum
{
    kSVfixed,
    kSVselected,
    kSVfixedtoBody
} SVSPPosType;
typedef enum
{
    kSVphysics,
    kSVhoming,
    kSVunmoving,
    kSVlinear
} SVSPMovementType;
@interface SVSpawnedBody : SVTetrisBody {
    SVTetrisBody * parent;
    BOOL sensor;
    BOOL interactFriend;
    BOOL interactBlock;
    BOOL interactFoe;
    BOOL fixedVelocity;
    BOOL fixedAccel;
    SVAnimatedSprite * animation;
    NSArray * delayRates;
    NSArray * frameNums;
    SVSPPosType positionType;
    BOOL isDistanceLimited;
    BOOL orientationDependent;
    float distanceLimit;
    CGPoint fixpoint;
    CGPoint orientationShift;
    BOOL gravityON;
    SVSPMovementType movementType;
    b2Vec2 initialForce;
    //status effects on touch
   // BOOL destroyedOnTouch;
    SvStatusEffect * onSelf;
    SvStatusEffect * onParent;
    SvStatusEffect * onTouchingBody;
    float FHP;//fake hp
    SvManaPool * farmor;//fake armor
}
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (BOOL) canContactMode:(unsigned int) mode;
- (BOOL) canContact: (SVTetrisBody *) body;
@end
