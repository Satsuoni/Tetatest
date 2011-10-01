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
#import "SvStatusEffect.h"
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
    NSString* abilityID;
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
