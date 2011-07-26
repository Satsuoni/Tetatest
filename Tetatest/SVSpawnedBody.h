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

@interface SVFixtureDef : NSObject {
    int shape;//0 -box, 1 -polygon, 2-circle;
    float restitution;
    float density;
    float friction;
    float angle;
    NSMutableArray* vertices;
    CGPoint  offset;
    //NSArray * params;
}
- (id) initWithDictionary: (NSDictionary *) dct;
- (b2FixtureDef) getFixtureDefWithOwner: (SVTetrisBody *) owner;

- (void) addToBody: (b2Body *) body asOwner: (SVTetrisBody *) bdy andSensor:(BOOL) sen;
@end

@interface SVPhysicalAspect : NSObject {
    BOOL isSensor;
    int collisionMask;
    BOOL interactWithPassthrough;
    BOOL fixRotation;
    NSMutableArray * fixtures;//svfixturesdefs
    b2Body * body;//a copy don't dealloc
    SVTetrisBody *owner;
}
@property (nonatomic, readonly) BOOL isSensor;
@property (nonatomic, readonly) int collisionMask;
@property (nonatomic, readonly) BOOL interactWithPassthrough;
- (id) initWithDictionary: (NSDictionary * )dict;
- (b2Body *) createBodyInWorld: (b2World *) world forOwner: (SVTetrisBody* )own atPos: (CGPoint) pos;
- (void) addFixtureToBody: (SVFixtureDef *)fixture;
@end

@interface SVMovementAspect :NSObject
{
    int initialPosition;//0 -body attach ,1 -target attach, 2 -target position 
    BOOL useCenter;
    BOOL useGravity;
    //CGPoint shiftFromCenter;
    CGPoint shift;
    BOOL orientationInverse;
    CGPoint targetPos;
    CGPoint iniPos;
    SVTetrisBody * targetBody;
    SVTetrisBody * attachedBody;
    SVTetrisBody * spawner;
    int moveType;// 0 -move with body, 1- move according to physics, in a way
    BOOL useTarget; //use target body at all
    BOOL useTargetBody;
    //BOOL pursueTarget; //pursue target?
    float targetForce;//force in the dir of target
    float ctf;
    float ttangentForce;//tangential to target
    float targetForceIncrease;//per second
    float targetVelocity;//fixed velocity in the target direction;
    CGPoint appliedAccel;// aceleration constantly applied
    CGPoint appliedVelocity;//always applied velocity
    CGPoint minRandomForce, maxRandomForce;//random forces
    CGPoint minRandomVelOnce, maxRandomVelOnce;//random initial velocities
}
- (id) initWithDictionary: (NSDictionary *) dct;
- (void) setTargetBody: (SVTetrisBody *) bdy;
- (void) setTargetPos: (CGPoint) pos;
- (void) setInitPos: (CGPoint) pos;
- (void) setSpawner: (SVTetrisBody *) bdy;
- (CGPoint) getInitialPosition: (int) orientation;
- (void) applyToBody: (b2Body *) body inTime: (double) time;
@end

@interface SVLifeAspect:NSObject
{
    double fHPMax;
    double fHP;
    SvManaPool * armor;
    SvStatusEffect * onDeathSpawner;
    SVTetrisBody * spawner;
    double timeStep;
    double timeLoss;
    double elapsed;
    int charges;
}
- (id) initWithDictionary: (NSDictionary *) dct;
- (void) setCharges: (int) ch;
- (void) setSpawner: (SVTetrisBody *) bdy;
- (BOOL) isDead;
- (void) applyDirectDamage: (double) dam;
- (void) applyManaic: (SvManaPool *) dam;
- (void) updateTime:(double) time;
- (SvStatusEffect *) getEffect;

@end

@interface SVTouchAspect : NSObject {
    SvStatusEffect * onSelf;
    SvStatusEffect * onParent;
    SvStatusEffect * onTouchingBody;
}
- (id) initWithDictionary: (NSDictionary *) dct;
- (void) applyToSelf: (SVTetrisBody *) body;
- (void) applyToParent: (SVTetrisBody *) parent;
- (void) applyToTouching: (SVTetrisBody *) touching;
@end

@interface SVAnimationAspect : NSObject {
@private
    SVAnimatedSprite * sprite;
    BOOL usesAddedFixtures;
    NSMutableArray * timeline;
    NSArray * fixtures;
    
}
- (id) initWithDictionary: (NSDictionary *) dict;
- (void) Update:(NSTimeInterval) time;

@end
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
    SVPhysicalAspect * physics;
    SVMovementAspect *movement;
    SVLifeAspect * life;
    SVTouchAspect * onTouch;
    SVAnimationAspect * animation;
}
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (BOOL) canContactMode:(unsigned int) mode;
- (BOOL) canContact: (SVTetrisBody *) body;
@end
