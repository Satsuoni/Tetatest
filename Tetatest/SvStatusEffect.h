//
//  SvStatusEffect.h
//  Tetatest
//
//  Created by Seva on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SvManaPool.h"
#import "Box2D.h"
#import "OpenGLView.h"
//#import "SvTetrisMonster.h"
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
    NSDictionary *bodyParameters;
    ///////
    BOOL hasFrameChange;
    int toFrame;
    ///////////
    BOOL canRemoveEffect;
    NSString * effectPrefix;
    /////
    BOOL hasGravityEffect;
    BOOL gravityEnabled;
    //////
    BOOL hasSpriteEffect;
    SpriteEffect spriteEffect;
}
@property (nonatomic, readonly) SpriteEffect spriteEffect;
@property (nonatomic, readonly) BOOL hasSpriteEffect;
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
