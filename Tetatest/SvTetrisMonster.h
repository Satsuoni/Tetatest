//
//  SvTetrisMonster.h
//  Tetatest
//
//  Created by Seva on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVTetrisBody.h"
#import "OpenGLView.h"
#import "SvManaPool.h"
////////////////////
//#define SV_ABILITY_NORMAL 0
//#define SV_ABILITY_CONSTANT 1
///these should be status effects
@interface SVCondition : NSObject {
@private
    NSArray * conditions;
}
- (id) initWithArray: (NSArray *) arr;
+ (id) CreateWithArray: (NSArray *) arr;

@end

@interface SVEffectParameters : NSObject {
  
    int orientationFrameShift;
    BOOL orientationApplyTransform;
    SvManaPool * overchargePool;
   
    BOOL orientationApplies;
    BOOL overchargeAppliesToDamage;
    BOOL overchargeAppliesToDuration;
}
@property (nonatomic,readonly) int orientationFrameShift;
@property (nonatomic,readonly) BOOL orientationApplyTransform;
@property (nonatomic,readonly) BOOL orientationApplies;
@property (nonatomic,readonly) BOOL overchargeAppliesToDamage;
@property (nonatomic,readonly) BOOL overchargeAppliesToDuration;
@property (nonatomic,readonly)  SvManaPool * overchargePool;
//@property (nonatomic,readwrite) int orientation;
- (id) initWithDictionary: (NSDictionary *)dict;
@end

@interface SvStatusEffect : NSObject {
@public
    SVEffectParameters * parameters;
    NSString * name;
    double step;
    double baseDuration;
    BOOL permanent;
    BOOL oneTime;// one time only
    BOOL constant;
    //////////
    BOOL hasForceComponent;
    b2Vec2 force;
    b2Vec2 acceleration;
    float linearDamping;
    
    //////////
    BOOL hasDirectHPEffect;//directly affects hp
    double DHPEPS;//direct hp effect per step;
    /////////////
    BOOL hasSecondaryEffect; //secondary status effect; for abilities
    SvStatusEffect *secondary;
    ////////
    BOOL hasNormalDamage;//per step
    SvManaPool * damage;
    ////////////
    BOOL hasManaDamage;
    SvManaPool * manaDamage;
    ///////////
    BOOL canSpawnBody;
    NSString * bodyID;
    ///////
    BOOL hasFrameChange;
    int toFrame;
    ///////////
    BOOL canRemoveEffect;
    NSString * effectPrefix;
    /////
    BOOL hasGravityEffect;
    BOOL gravityEnabled;
}
@property (nonatomic, readonly)  NSString *name;
@property (nonatomic, readonly) BOOL constant;
@property (nonatomic, readonly) BOOL hasGravityEffect;
@property (nonatomic, readonly) BOOL gravityEnabled;
@property (nonatomic, readonly) double baseDuration;
@property (nonatomic, readonly) SVEffectParameters *parameters;
@property (nonatomic, readonly) double step;
@property (nonatomic, readonly) BOOL canRemoveEffect;
@property (nonatomic, readonly) NSString * effectPrefix;
@property (nonatomic, readonly) BOOL permanent; 
@property (nonatomic, readonly) BOOL oneTime;
@property (nonatomic, readonly) BOOL hasForceComponent;
@property (nonatomic, readonly) BOOL hasDirectHPEffect;
@property (nonatomic, readonly) BOOL hasSecondaryEffect;
@property (nonatomic, readonly) BOOL hasNormalDamage;
@property (nonatomic, readonly) BOOL hasManaDamage;
@property (nonatomic, readonly) BOOL canSpawnBody;
@property (nonatomic, readonly) BOOL hasFrameChange;
@property (nonatomic, readonly) int toFrame;
@property (nonatomic, readonly) double DHPEPS;
@property (nonatomic, readonly) SvStatusEffect *secondary;
@property (nonatomic, readonly) SvManaPool * damage;
@property (nonatomic, readonly) SvManaPool * manaDamage;
@property (nonatomic, readonly)  NSString * bodyID;
- (id) initWithDictionary :(NSDictionary *) dic;

- (void) applyForceToBody: (b2Body *) body withOrientation :(int) ori;
@end
@interface SVStatusEffectInTime : NSObject {
    SvStatusEffect * effect;
    double duration;
    NSTimeInterval elapsedtime;
    int orientation;
    int charges;
}
@property (nonatomic, readonly) SvStatusEffect * effect;
@property (nonatomic, readonly) int toFrame;
@property (nonatomic, readonly) double DHPEPS;
@property (nonatomic, readonly) SvManaPool * damage;
@property (nonatomic, readonly) SvManaPool * manaDamage;
@property (nonatomic, readonly) int charges;

- (id) initWithEffect: (SvStatusEffect *) effect andOrientation: (int) ori andChargedPool: (SvManaPool *) pool;
- (id) initWithEffect: (SvStatusEffect *) effect andOrientation: (int) ori andCharges: (int ) charges;
- (int) Update: (double) elapsed;
- (BOOL) Expired;

@end
typedef enum
{
    kSVInternal,
    kSVSelf,
    kSVBlock,
    kSVMonster,//can target any monster, self included
    kSVTouchingBody
}
SVAbilityTargets;
@interface SVAbilityStep : NSObject {
@public
    BOOL canBeSuspended;
    BOOL canBeStopped;
    BOOL cblo;
    BOOL canBeLooped;
    int loops;
    int maxLoops;
    SvStatusEffect *changes;//one-time applied se
    SVCondition * condition;
    NSTimeInterval duration;
    int next;
    int loop;
    int reset;
    int interrupt;
}
@property (nonatomic, readonly) BOOL canBeSuspended;
@property (nonatomic, readonly) BOOL canBeStopped;
@property (nonatomic, readonly) BOOL canBeLooped;
@property (nonatomic, readonly) SVCondition * condition;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) int next;
@property (nonatomic, readonly) int loop;
@property (nonatomic, readonly) int reset;
@property (nonatomic, readonly) int interrupt;
- (id) initWithDictionary: (NSDictionary *) dict;
- (void) addLoop;
- (void) resetLoop;
- (SvStatusEffect *) getEffect;
@end
@class SvTetrisMonster;
@interface SvAbility :NSObject
{
    unsigned int type;
    BOOL interruptedByCrushing;
    BOOL interruptedByDamage;
    BOOL interruptedByInsufficientMana;
    BOOL interruptedByOtherAction;
    BOOL complete;
    unsigned int mask;
    SVCondition * initialCondition;
    SvManaPool * charged;
   // int currentLoop;
    int nextStep;
    NSArray * abilitySteps;
    SVAbilityStep * currentStep;
    NSTimeInterval elapsed;
    SVAbilityTargets target;// target type: internal, self
    NSMutableDictionary * application;
    SVTetrisBody * selectedTarget;//unless internal
     SvTetrisMonster * owner;
  
}
@property (nonatomic,readonly) BOOL interruptedByCrushing;
@property (nonatomic,readonly)BOOL interruptedByDamage;
@property (nonatomic,readonly)  BOOL interruptedByInsufficientMana;
@property (nonatomic,readonly) BOOL interruptedByOtherAction;
@property (nonatomic,readwrite) unsigned int type;
@property (nonatomic,readonly) BOOL complete;
@property (nonatomic,readonly) SVCondition * initialCondition;
@property (nonatomic,readonly) SVAbilityTargets target;
@property (nonatomic,readonly) unsigned int mask;
- (void) setSelectedTarget: (SVTetrisBody *) target;
- (BOOL) Update: (double) elapsedTime; //returns YES if in need of decision: loop or continue;
- (void) decide: (BOOL) loop; //if yes is returned by Update
- (BOOL) tryCancelling;
- (BOOL) trySuspending;
- (void) interrupt;
- (id) initWithDictionary: (NSDictionary *) dict;
- (void) Reset;
- (void) setOwner: (SvTetrisMonster *)owner;
@end

@interface SvTetrisMonster : SVTetrisBody {
    double HP;
    double HPMax;
    SvManaPool * pool;
    SVAnimatedSprite * animation;
    SvManaPool *combinedArmor;
    SvManaPool *combinedManaArmor;
    BOOL ghostMode;
    BOOL wasCrushed;
    int orientation;
    unsigned int currentMask;
    BOOL canFly;
    NSMutableArray * abilities;
    NSMutableArray * runningAbilities;
    int currentFrame;
    SpriteEffect currentEffect;
    BOOL isTouchingGround;
    NSMutableArray * effects;
      NSMutableArray *rem;
}
- (id) initWithDictionary: (NSDictionary *) dict;
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (void) Draw;
- (NSNumber *) getValue:(NSString *) valueName;
- (void) applyEffect: (SvStatusEffect *) eff withPool: (SvManaPool *)pool;
- (void) applyEffect: (SvStatusEffect *) eff withCharges: (int)charges;
- (void) applyEffectStep: (SVStatusEffectInTime *) eff;
@end
