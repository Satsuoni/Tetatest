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

@interface SVATimeline : NSObject {
    int type; //0 -frame change, 1 -fixture add, 2 -fixture remove (probable)
    int change; //number of added fixture/next frame
    double duration;
}
@property (nonatomic, readonly) int type;
@property (nonatomic, readonly) int change;
@property (nonatomic, readonly) double duration;
- (id) initWithDictionary: (NSDictionary *) dct;

@end
@interface SVFixtureDef : NSObject {
    int shape;//0 -box, 1 -polygon, 2-circle;
    float restitution;
    float density;
    float friction;
    float angle;
    NSMutableArray* vertices;
    CGPoint  offset;
    SVAnimatedSprite * animation;
    NSMutableArray * timeline;// loops?
    
    double ctime;
    int ctml;
    b2Fixture * localFixture;
    //NSArray * params;
}
@property (nonatomic,readonly) SVAnimatedSprite * animation;
@property (nonatomic,readwrite) b2Fixture* localFixture;
- (id) initWithDictionary: (NSDictionary *) dct;
- (b2FixtureDef) getFixtureDefWithOwner;

- (void) addToBody: (b2Body *) body asOwner: (SVTetrisBody *) bdy andSensor:(BOOL) sen;
- (void) updateTime: (NSTimeInterval) time;
@end

@interface SVPhysicalAspect : NSObject {
    BOOL isSensor;
    int collisionMask;
    BOOL interactWithPassthrough;
    BOOL fixRotation;
    NSMutableArray * fixtures;//svfixturesdefs
    NSMutableArray * addedFixtures;
    b2Body * body;//a copy don't dealloc
    SVTetrisBody *owner;
    BOOL loop;
    NSTimeInterval elapsed;
    NSMutableArray * timeline;//for adding/removing fixtures...
    double ctime;
    int ctml;
}
@property (nonatomic, readonly) BOOL isSensor;
@property (nonatomic, readonly) int collisionMask;
@property (nonatomic, readonly) BOOL interactWithPassthrough;
- (id) initWithDictionary: (NSDictionary * )dict;
- (b2Body *) createBodyInWorld: (b2World *) world forOwner: (SVTetrisBody* )own atPos: (CGPoint) pos;
- (void) addFixtureToBody: (SVFixtureDef *)fixture;
- (void) Update :(NSTimeInterval) time;
- (void) Draw;
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
    BOOL useTargetBody; //pursue target body
    BOOL useTargetVelocity; //use velocity instead of force
    //BOOL pursueTarget; //pursue target?
    float targetForce;//force in the dir of target
    float ctf;
    float ttangentForce;//tangential to target
    float targetForceIncrease;//per second
    float targetVelocity;//fixed velocity in the target direction;
    BOOL fixedVelocity;
    CGPoint appliedAccel;// aceleration constantly applied
    CGPoint appliedVelocity;//always applied velocity
    CGPoint minRandomForce, maxRandomForce;//random forces
    BOOL initDone;
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
    SvStatusEffect * onDeathSpawner;//effect of body destruction on spawner body
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
    SvStatusEffect * onPassingBody;
    // SvStatusEffect * onPassingSelf;
    NSMutableDictionary  *application;
    int ch;
    BOOL touchParent;
    BOOL touchEnemy;
    BOOL touchBlocks;
}
@property (nonatomic,readonly) BOOL touchParent;
@property (nonatomic,readonly) BOOL touchEnemy;
@property (nonatomic,readonly) BOOL touchBlocks;
- (id) initWithDictionary: (NSDictionary *) dct;
- (void) applyToSelf: (SVTetrisBody *) body;
- (void) applyToParent: (SVTetrisBody *) parent;
- (void) applyToTouching: (SVTetrisBody *) touching;
- (void) applyToPassing: (SVTetrisBody *) passing;
- (void) setTouchCharges: (int) cha;
@end


@interface SVAnimationAspect : NSObject {
@private
    SVAnimatedSprite * sprite;
    BOOL usesAddedFixtures;
    NSMutableArray * timeline;
    NSArray * fixtures;
    double elapsed;
    int currentTimelinePos;
    
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
    BOOL spawned;
    //SVAnimationAspect * animation;
}
@property (nonatomic,retain) SVTetrisBody * parent;
- (id) initWithDictionary:(NSDictionary *)dct;
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (BOOL) canContactMode:(unsigned int) mode;
- (BOOL) canContact: (SVTetrisBody *) body;
- (BOOL) SpawnWithParameters: (NSDictionary *) parameters;
- (void) Draw;
@end
