//
//  SvStatusEffect.m
//  Tetatest
//
//  Created by Seva on 6/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SvStatusEffect.h"

@implementation SVEffectParameters

//@synthesize orientation;
@synthesize overchargePool;
@synthesize overchargeAppliesToDamage;
@synthesize overchargeAppliesToDuration;
@synthesize orientationApplies;
@synthesize orientationFrameShift;
@synthesize orientationApplyTransform;
- (id) initWithDictionary:(NSDictionary *)dict
{
    if((self=[super init]))
    {
        overchargePool=[[SvManaPool alloc] initWithArray:[dict valueForKey:@"Overcharge"]];
        overchargeAppliesToDamage=[[dict valueForKey:@"Apply Charge To Damage"] boolValue];
        overchargeAppliesToDuration=[[dict valueForKey:@"Apply Charge To Duration"] boolValue];
        orientationApplyTransform=[[dict valueForKey:@"Orientation Apply Transform"] boolValue];
        orientationFrameShift=[[dict valueForKey:@"Orientation Frame Shift"] intValue];
        orientationApplies=[[dict valueForKey:@"Orientation"] boolValue];
    }
    return self;
}
- (void) dealloc
{
    [overchargePool release];
    [super dealloc];
}

@end
@implementation SvStatusEffect
@synthesize parameters;
@synthesize canRemoveEffect;
@synthesize effectPrefix;
@synthesize hasManaDamage;
@synthesize hasForceComponent;
@synthesize hasNormalDamage;
@synthesize hasDirectHPEffect;
@synthesize hasSecondaryEffect;
@synthesize canSpawnBody;
@synthesize DHPEPS;
@synthesize damage;
@synthesize manaDamage;
@synthesize bodyID;
@synthesize secondary;
@synthesize hasFrameChange;
@synthesize toFrame;
@synthesize permanent;
@synthesize oneTime;
@synthesize step;
@synthesize baseDuration;
@synthesize constant;
@synthesize name;
@synthesize hasGravityEffect;
@synthesize gravityEnabled;
@synthesize hasSpriteEffect;
@synthesize spriteEffect;
- (id) initWithDictionary :(NSDictionary *) dic
{
    if((self = [super init]))
    {
        name=[[dic valueForKey:@"Name"] retain];
        step=[[dic valueForKey:@"Step"] doubleValue];
        baseDuration=[[dic valueForKey:@"Duration"] doubleValue];
        parameters=[[SVEffectParameters alloc] initWithDictionary:[dic valueForKey:@"Parameters"]];
        NSString *type=[dic valueForKey:@"Type"];
        if([type isEqualToString:@"Permanent"])
        {
            oneTime=NO;
            permanent=YES;
        }
        else
            if([type isEqualToString:@"Once"])
            {
                oneTime=YES;
                permanent=NO;
            }
            else
            {
                oneTime=NO;
                permanent=NO;
            }
        constant =[[dic valueForKey:@"Constant"] boolValue];
        if([dic valueForKey:@"Gravity"]!=nil)
        {
            gravityEnabled=[[dic valueForKey:@"Gravity"] boolValue];
            hasGravityEffect=YES;
        }
        else
            hasGravityEffect=NO;
        if([dic valueForKey:@"SpriteEffect"]!=nil)
        {
            NSDictionary *tmp=[dic valueForKey:@"SpriteEffect"];
            spriteEffect.type=[[tmp valueForKey:@"Type"] intValue];
            spriteEffect.par1=[[tmp valueForKey:@"Parameter1"] intValue];
            spriteEffect.par2=[[tmp valueForKey:@"Parameter2"] intValue];
            NSArray *cl=[dic valueForKey:@"Color0"];
            for(int i=0;i<4;i++)
            {
                spriteEffect.colors[0].clr[i]=[[cl objectAtIndex:i] floatValue];
            }
            cl=[dic valueForKey:@"Color1"];
            for(int i=0;i<4;i++)
            {
                spriteEffect.colors[1].clr[i]=[[cl objectAtIndex:i] floatValue];
            }
            cl=[dic valueForKey:@"Color2"];
            for(int i=0;i<4;i++)
            {
                spriteEffect.colors[2].clr[i]=[[cl objectAtIndex:i] floatValue];
            }
            cl=[dic valueForKey:@"Color3"];
            for(int i=0;i<4;i++)
            {
                spriteEffect.colors[3].clr[i]=[[cl objectAtIndex:i] floatValue];
            }
            
            hasSpriteEffect=YES;
        }
        else
            hasSpriteEffect=NO;
        if([dic valueForKey:@"Force"]!=nil)
        {
            NSArray * arr=[dic valueForKey:@"Force"];
            force=b2Vec2([[arr objectAtIndex:0]floatValue],[[arr objectAtIndex:1]floatValue]);
            NSArray * acc=[dic valueForKey:@"Acceleration"];
            acceleration=b2Vec2([[acc objectAtIndex:0]floatValue],[[acc objectAtIndex:1]floatValue]);
            linearDamping=[[dic valueForKey:@"Linear Damping"] floatValue];
            
            hasForceComponent=YES;
        }
        else
            hasForceComponent=NO;
        if([dic valueForKey:@"Direct Damage"]!=nil)
        {
            DHPEPS=[[dic valueForKey:@"Direct Damage"] doubleValue];
            hasDirectHPEffect=YES;
        }
        else
            hasDirectHPEffect=NO; 
        if([dic valueForKey:@"Mana Damage"]!=nil)
        {
            manaDamage=[[SvManaPool alloc] initWithArray:[dic valueForKey:@"Mana Damage"]];
            hasManaDamage=YES;
        }
        else
            hasManaDamage=NO;
        if([dic valueForKey:@"Damage"]!=nil)
        {
            damage=[[SvManaPool alloc] initWithArray:[dic valueForKey:@"Damage"]];
            hasNormalDamage=YES;
        }
        else
            hasNormalDamage=NO; 
        if([dic valueForKey:@"Secondary Effect"]!=nil)
        {
            secondary=[[SvStatusEffect alloc] initWithDictionary:[dic valueForKey:@"Secondary Effect"]];
            hasSecondaryEffect =YES;
        }
        else
            hasSecondaryEffect=NO;
        if([dic valueForKey:@"Spawned Body"]!=nil)
        {
            bodyID=[[dic valueForKey:@"Spawned Body"] retain];
            canSpawnBody=YES;
        }
        else
            canSpawnBody=NO;
        if([dic valueForKey:@"Removed Effect"]!=nil)
        {
            effectPrefix=[[dic valueForKey:@"Removed Effect"] retain];
            canRemoveEffect=YES;
        }
        else
            canRemoveEffect=NO;
        if([dic valueForKey:@"Frame"]!=nil)
        {
            toFrame=[[dic valueForKey:@"Frame"] intValue];
            hasFrameChange=YES;
        }
        else
            hasFrameChange=NO;
    }
    return self;
}

- (void) applyForceToBody: (b2Body *) body withOrientation:(int)ori
{
    if(!hasForceComponent)return ;
    
    b2Vec2 p=b2Vec2(0.0,0.0);
    float mass=body->GetMass();
    if(ori==0)
    {
        body->ApplyForce(force, p);
        b2Vec2 ac=b2Vec2(mass*acceleration.x,mass*acceleration.y);
        body->ApplyForce(ac, p);
        body->SetLinearDamping(linearDamping);
    }
    else
    {
        b2Vec2 fr2=b2Vec2(force.x*ori,force.y*ori); 
        b2Vec2 ac=b2Vec2(mass*acceleration.x*ori,mass*acceleration.y*ori);
        body->ApplyForce(fr2, p);
        body->ApplyForce(ac, p);
        body->SetLinearDamping(linearDamping);
    }
}
-(void) dealloc
{
    [effectPrefix release];
    [bodyID release];
    [name release];
    [secondary release];
    [manaDamage release];
    [damage release];
    [parameters release];
    [super dealloc];
}
@end

@implementation SVStatusEffectInTime
@synthesize effect;
@synthesize charges;
- (id) initWithEffect:(SvStatusEffect *)effecta andOrientation:(int)ori andChargedPool:(SvManaPool *)pool
{
    if((self=[super init]))
    {
        effect=[effecta retain];
        orientation=ori;
        charges=0;
        if(effect.parameters.overchargeAppliesToDamage||effect.parameters.overchargeAppliesToDuration)
        {
            charges=[pool poolFits:effect.parameters.overchargePool];
            if(effect.parameters.overchargeAppliesToDuration)
                duration=effect.baseDuration*charges;
        }
        elapsedtime=0;
    }
    return self;
}
- (id) initWithEffect:(SvStatusEffect *)effecta andOrientation:(int)ori andCharges:(int)icharges
{
    if((self=[super init]))
    {
        effect=[effecta retain];
        orientation=ori;
        charges=0;
        if(effect.parameters.overchargeAppliesToDamage||effect.parameters.overchargeAppliesToDuration)
        {
            charges=icharges;
            if(effect.parameters.overchargeAppliesToDuration)
                duration=effect.baseDuration*charges;
        }
        elapsedtime=0;
    }
    return self;
}
- (int) toFrame
{
    if(effect.parameters.orientationApplies&&!effect.parameters.orientationApplyTransform)
    {
        if(orientation==-1)
            return effect.toFrame;
        else
            return effect.toFrame+effect.parameters.orientationFrameShift;
    }
    else
        return effect.toFrame;
}
- (double) DHPEPS
{
    if(effect.parameters.overchargeAppliesToDamage)
        return effect.DHPEPS*charges;
    else
        return effect.DHPEPS;
}
- (SvManaPool *) damage
{
    if(effect.parameters.overchargeAppliesToDamage)
        return [[effect.damage Multiply:  charges] autorelease];
    else
        return effect.damage;
}
- (SvManaPool *) manaDamage
{
    if(effect.parameters.overchargeAppliesToDamage)
        return [[effect.manaDamage Multiply:  charges] autorelease];
    else
        return effect.manaDamage;
}
- (void) dealloc
{
    [effect release];
    [super dealloc];
}
- (int) Update: (double) elapsed
{
    int crnt=floor(elapsedtime/effect.step);
    elapsedtime+=elapsed;
    int nxt=floor(elapsedtime/effect.step);
    return nxt-crnt;
}
- (BOOL) Expired
{
    if(effect.permanent) return NO;
    if(elapsedtime>=duration) return YES;
    return NO;
}

@end