//
//  SvTetrisMonster.m
//  Tetatest
//
//  Created by Seva on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SvTetrisMonster.h"
#import "SVTetrisBody.h"
#import "SVTetris.h"
SpriteEffect ghostEffect={{{0,0.3,0,0},{0,0.3,0,0},{0,0.3,0,0},{0,0.3,0,0}},0.3,0.3,1};
@interface SVCondition (extend)
- (BOOL) checkWithMonster:(SvTetrisMonster *) mns;
@end
@implementation SVCondition
+ (id) CreateWithArray:(NSArray *)arr
{
    SVCondition * ret=[[SVCondition alloc] initWithArray:arr];
    return  [ret autorelease];
}
-(id) initWithArray:(NSArray *)arr
{
    if((self=[super init]))
    {
    conditions =[arr retain];  
    }
    return self;
}
- (void) dealloc
{
    [conditions release];
    [super dealloc];
}
- (BOOL) checkWithMonster:(SvTetrisMonster *)mns
{
    if(mns==nil) return YES;
    for( NSDictionary * dic in conditions)
    {
        NSString * value=[dic valueForKey:@"Value"];
        NSNumber * mv=[mns getValue:value];
        NSNumber * com=[dic valueForKey:@"CompareTo"];
        NSComparisonResult res=[mv compare:com];
        NSString * how=[dic valueForKey:@"Comparison"];
        if([how isEqualToString:@"Equal"]&&res!=NSOrderedSame) return NO;
        if([how isEqualToString:@"Less"]&&res!=NSOrderedAscending) return NO;
        if([how isEqualToString:@"More"]&&res!=NSOrderedDescending) return NO;
        if([how isEqualToString:@"LessEqual"]&&res==NSOrderedDescending) return NO;
        if([how isEqualToString:@"MoreEqual"]&&res==NSOrderedAscending) return NO;

    }
    return YES;
}
@end
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
@implementation SVAbilityStep
@synthesize canBeLooped;
@synthesize canBeStopped;
@synthesize canBeSuspended;
@synthesize condition;
@synthesize duration;
@synthesize reset;
@synthesize interrupt;
@synthesize loop;
@synthesize next;
- (id) initWithDictionary: (NSDictionary *) dict
{
  if((self=[super init]))
  {
      changes=[[SvStatusEffect alloc] initWithDictionary:[dict valueForKey:@"Changes"]];
      condition=[[SVCondition alloc] initWithArray:[dict valueForKey:@"Condition"]];
      
      canBeSuspended=[[dict valueForKey:@"Suspendable"] boolValue];
      canBeStopped=[[dict valueForKey:@"Stoppable"] boolValue];
      canBeLooped=[[dict valueForKey:@"Loopable"] boolValue];
      maxLoops=[[dict valueForKey:@"Loops"] intValue];
      duration=[[dict valueForKey:@"Duration"] doubleValue];
      next=[[dict valueForKey:@"Next"] intValue];
      loop=[[dict valueForKey:@"Loop"] intValue];
      reset=[[dict valueForKey:@"Reset"] intValue];
      interrupt=[[dict valueForKey:@"Interrupt"] intValue];
      loops=0;
      cblo=canBeLooped;
  }
    return self;
}
- (void) dealloc
{
    [changes release];
    [condition release];
    [super dealloc];
}
- (SvStatusEffect *) getEffect
{
    return changes;
}
- (void) addLoop
{
    loop++;
    if(loop>maxLoops) canBeLooped=NO;
}
- (void) resetLoop
{
    loop=0;
    canBeLooped=cblo;
}
@end

@implementation SvAbility
@synthesize mask;
@synthesize initialCondition;
@synthesize target;
@synthesize type;
@synthesize complete;
@synthesize interruptedByCrushing;
@synthesize interruptedByDamage;
@synthesize interruptedByOtherAction;
@synthesize interruptedByInsufficientMana;
- (void) setOwner:(SvTetrisMonster *)owneri
{
    owner=owneri;   
}
- (BOOL) Update:(double)elapsedTime
{
    complete=NO;
    elapsed+= elapsedTime;
    while (elapsed>=currentStep.duration)
    {
        elapsed-=currentStep.duration;
    if([currentStep.condition checkWithMonster:owner])
    {//condition met ,executing
        if(target==kSVInternal)
        {
            SvStatusEffect * ef=[currentStep getEffect];
            if(ef.hasManaDamage)
            {
                [charged drawFromPool:ef.manaDamage];
            }
        }
        else
        {
            [application setValue:[currentStep getEffect] forKey:@"Effect"];
             [application setValue:charged forKey:@"Pool"];
            [selectedTarget Apply:application];
        }
        if(currentStep.canBeLooped)
            return YES;
        if(currentStep.next!=-1)
        {
            currentStep=[abilitySteps objectAtIndex:currentStep.next];
        }
        else
        {
            [self Reset];
            return NO;
        }
    } 
        else
        {//condition not met, going to reset branch
            if(currentStep.reset!=-1)
            {
                currentStep=[abilitySteps objectAtIndex:currentStep.reset];
                return [self Update:0];  
                
            }
            else
            {
                [self Reset]; 
                return NO;
            }
        }
    }
    return NO;
}
- (void) setSelectedTarget:(SVTetrisBody *)targetW
{
    selectedTarget=[targetW retain];
}
-(void) decide:(BOOL)loop
{
    if(loop)
    {
        [currentStep addLoop];
        currentStep=[abilitySteps objectAtIndex:currentStep.loop];
        [self Update:0];
    }
    else
    {
        [currentStep resetLoop];
        if(currentStep.next!=-1)
        {
        currentStep=[abilitySteps objectAtIndex:currentStep.next];
        [self Update:0];  
        }
        else
            [self Reset];
    }
}
-(void) Reset
{
    for (SVAbilityStep *st in abilitySteps) {
        [st resetLoop];
    }
   
    [selectedTarget release];
    selectedTarget=nil;
    [charged Drain];
    currentStep=[abilitySteps objectAtIndex:0];
    elapsed=0;
     complete=YES;
}
-(BOOL) tryCancelling
{
    if(currentStep.canBeStopped)
    {
        if(currentStep.reset!=-1)
        {
            currentStep=[abilitySteps objectAtIndex:currentStep.reset];
            [self Update:0];  
        }
        else
            [self Reset];
        return YES;
    }
    else
        return NO;
    return YES;
}
- (BOOL) trySuspending
{
    
    if(currentStep.canBeSuspended)
    {
        elapsed=0;
        return YES;
    }
    else
        return NO;
    return YES;   
}
- (void) interrupt
{
        if(currentStep.interrupt!=-1)
        {
            currentStep=[abilitySteps objectAtIndex:currentStep.interrupt];
            [self Update:0];  
        }
        else
            [self Reset];
}
-(id) initWithDictionary:(NSDictionary *)dict
{
    if((self=[super init]))
    {
        NSDictionary * inter=[dict valueForKey:@"Interruptions"];
        if([inter valueForKey:@"Crushing"]!=nil)
            interruptedByCrushing=YES;
        else
            interruptedByCrushing=NO;
        if([inter valueForKey:@"Damage"]!=nil)
            interruptedByDamage=YES;
        else
            interruptedByDamage=NO;
        if([inter valueForKey:@"Action"]!=nil)
            interruptedByOtherAction=YES;
        else
            interruptedByOtherAction=NO;
        interruptedByInsufficientMana=YES;
        complete=YES;
        mask=[[dict valueForKey:@"Mask"] intValue];
        initialCondition=[[SVCondition alloc] initWithArray:[dict valueForKey:@"Condition"]];
        charged=[[SvManaPool alloc]init];
        nextStep=0;
        NSArray *abs=[dict valueForKey:@"Steps"];
        NSMutableArray *ar=[[NSMutableArray alloc] initWithCapacity:[abs count]];
        for(NSDictionary * abdic in abs)
        {
            SVAbilityStep * step=[[SVAbilityStep alloc] initWithDictionary:abdic];
            [ar addObject:step];
            [step release];
        }
        abilitySteps=[[NSArray alloc] initWithArray:ar];
        [ar release];
        currentStep=[abilitySteps objectAtIndex:0];
        elapsed=0;
        NSString * targetName=[dict valueForKey:@"Target"];
        target=kSVSelf;
        if([targetName isEqualToString:@"Internal"])
        {
            target=kSVInternal;
        }
        else
            if([targetName isEqualToString:@"Self"])
               { target=kSVSelf;}
        else
            if([targetName isEqualToString:@"Block"])
            { target=kSVBlock;}
        else
        if([targetName isEqualToString:@"Touching"])
        { target=kSVTouchingBody;}
        else
        if([targetName isEqualToString:@"Monster"])
        { target=kSVMonster;}
       application=[[NSMutableDictionary alloc] initWithCapacity:2];
        selectedTarget=nil; 
    }
    return self;
}
- (void) dealloc
{
    [abilitySteps release];
    [application release];
    [selectedTarget release];
    [initialCondition release];
    [charged release];
    [super dealloc];
}
@end
@implementation SvTetrisMonster
- (NSNumber *) getValue:(NSString *)valueName
{
    if([valueName isEqualToString:@"HP"])
        return [[NSNumber numberWithDouble:HP] autorelease];
    if([valueName isEqualToString:@"HPMax"])
        return [[NSNumber numberWithDouble:HPMax] autorelease];
    if([valueName hasPrefix:@"Mana"])
    {
        NSString * st=[valueName stringByReplacingOccurrencesOfString:@"Mana" withString:@""];
        
        return [[NSNumber numberWithDouble:[pool getMana:[st intValue]]] autorelease];
    }

    if([valueName isEqualToString:@"Ghost"])
        return [[NSNumber numberWithBool:ghostMode] autorelease];
    if([valueName isEqualToString:@"Crushed"])
        return [[NSNumber numberWithBool:wasCrushed] autorelease];
    if([valueName isEqualToString:@"Orientation"])
        return [[NSNumber numberWithInt:orientation] autorelease];
    if([valueName isEqualToString:@"CanFly"])
        return [[NSNumber numberWithBool:canFly] autorelease];
    if([valueName isEqualToString:@"TouchingGround"])
        return [[NSNumber numberWithBool:isTouchingGround] autorelease];
    return nil;
}
- (void) Draw
{
    animation.ul_position=[self getPosition];
    animation.virt_frame=[self getBoundingBox].size;
    animation.layoutPos=1;
    [animation setFrame:currentFrame];
    [animation setSpriteEffect:&currentEffect];
    [animation Draw];
    animation.effect=0;
}
- (id) initWithDictionary:(NSDictionary *)dict
{
    b2Template temp;
    temp.type=b2_dynamicBody;
    temp.isSensor=[[dict valueForKey:@"Sensor"] boolValue];
    temp.restitution =[[dict valueForKey:@"Restitution"] floatValue];
     temp.density =[[dict valueForKey:@"Density"] floatValue];
     temp.friction =[[dict valueForKey:@"Friction"] floatValue];
    temp.isBullet=YES;
    NSArray * rectar=[dict valueForKey:@"Rect"];
    CGRect rect=CGRectMake([[rectar objectAtIndex:0] floatValue], [[rectar objectAtIndex:1] floatValue], [[rectar objectAtIndex:2] floatValue], [[rectar objectAtIndex:3] floatValue]);
   if((self= [super initWithRect:rect andTemplate:temp inWorld:(b2World *)[[dict valueForKey:@"World"] pointerValue] withName:[dict valueForKey:@"Name"] andType:@"Monster"]))
   {
       animation=[[dict valueForKey:@"Sprite"] retain];
       ghostMode=NO;
       contactMode=1;
       wasCrushed=NO;
       currentFrame=0;
       animation.effect=0;
       rem=[[NSMutableArray alloc]init ];
       runningAbilities=[[NSMutableArray alloc]init ];
       abilities=[[NSMutableArray alloc]initWithArray:[dict valueForKey:@"Abilities"]];
       orientation=-1;
       
   };
    return self;
    
}
- (void) dealloc
{
    [animation release];
    [rem release];
    [abilities release];
    [runningAbilities release];
    [effects release];
    [super dealloc];  
}
- (void) Update:(double)time
{
    body->SetLinearDamping(0.15);
    if(ghostMode)
    {
        if([touchingBodies count]==0&&[passingBodies count]==0)
        {
            ghostMode=NO;
            [self setContactMode:1];
            currentEffect.type=0;
             body->applyGravity=true;
        }
        else
        {
            b2Vec2 force=b2Vec2(0,-1);
            if([touchingBodies count]>0)
                force=b2Vec2(2,-1);
            b2Vec2 point=b2Vec2(0,0);
           body->ApplyLinearImpulse(force, point);
            currentEffect=ghostEffect;
        }
    }
    else
    {
        isTouchingGround=NO;
        CGRect cbb=[self getBoundingBox];
        for(SVTetrisBody *bd in touchingBodies)
        {
            CGRect bb=[bd getBoundingBox];
            
            CGRect inter= CGRectIntersection(cbb, bb);
            if(inter.size.width>=3&&cbb.origin.y+cbb.size.height/2<bb.origin.y)
            {
                isTouchingGround=YES;
                break;
            }
        }
    }
    if(currentMask!=1)
    {
        if([abilities count]>0)
        {
        SvAbility *walk=[abilities objectAtIndex:0];
        if(walk!=nil)
        {
        if([walk.initialCondition checkWithMonster:self])
        {
            orientation=(arc4random()%2)*2-1;
        [walk setOwner:self];
        [walk setSelectedTarget:self];
        [walk Update:0];
        [runningAbilities addObject:walk];
        currentMask+=walk.mask;
        }
        }
        }
    }
    for(SVStatusEffectInTime * ste in effects)
    {
        if(ste.effect.constant)
        {
           [self applyEffectStep:ste]; 
        }
        else
        {
        int reps=[ste Update:time];
            for(int i=0;i<reps;i++)
                [self applyEffectStep:ste];
            if([ste Expired]) [rem addObject:ste]; 
        }
    }
    [effects removeObjectsInArray:rem];
    [rem removeAllObjects];
    for(SvAbility * ab in runningAbilities)
    {
        [ab Update:time];
    }
    for(SvAbility * ab in runningAbilities)
    {
        if(ab.complete) 
        {
            [rem addObject:ab];
            currentMask=currentMask-(currentMask&ab.mask);
        }
        
    }
    [runningAbilities removeObjectsInArray:rem];
    [rem removeAllObjects];
    
}
- (void) Apply:(NSDictionary *)thing
{
    NSNumber* cr=[thing valueForKey:@"Crush"];
    if(cr!=nil)
    {
        if([cr boolValue])
        {
            wasCrushed=YES;
            ghostMode=YES;
            [self setContactMode:2];
            b2Vec2 force=b2Vec2(rndup(50.0)-25.0,-25);
            b2Vec2 point=b2Vec2(0,0);
            body->ApplyLinearImpulse(force, point);
            body->applyGravity=false;
        }
    }
    SvStatusEffect * eff=[thing valueForKey:@"Effect"];
    if(eff!=nil)
    {
        [self applyEffect:eff withPool:[thing valueForKey:@"Pool"]];   
    }
}
-(void) applyEffect:(SvStatusEffect *)eff withPool:(SvManaPool *)cpool
{
    
    SVStatusEffectInTime * temp=[[SVStatusEffectInTime alloc] initWithEffect:eff andOrientation:orientation andChargedPool:cpool];  
    if(eff.oneTime)
    {
        [self applyEffectStep:temp];
    }
    else
    {
        [effects addObject:temp];
    }
    [temp release];
}
-(void) applyEffect:(SvStatusEffect *)eff withCharges:(int)charges
{
    
    SVStatusEffectInTime * temp=[[SVStatusEffectInTime alloc] initWithEffect:eff andOrientation:orientation andCharges:charges];  
    if(eff.oneTime)
    {
        [self applyEffectStep:temp];
    }
    else
    {
        [effects addObject:temp];
    }
    [temp release];
}

- (void) applyEffectStep:(SVStatusEffectInTime *)eff
{
     double dam=0;
    if(eff.effect.hasGravityEffect)
    {
    if(eff.effect.gravityEnabled)
        body->applyGravity=true;
    else
        body->applyGravity=false;
    }
    if(eff.effect.hasDirectHPEffect)
    {
       
       dam+=eff.DHPEPS;
    }
    if(eff.effect.hasForceComponent)
    {
        if(eff.effect.parameters.orientationApplies)
            [eff.effect  applyForceToBody:body withOrientation:orientation];
         else
             [eff.effect applyForceToBody:body withOrientation:0];
    }
    if(eff.effect.hasSecondaryEffect)
    {
        [self applyEffect:eff.effect.secondary withCharges:eff.charges];  
    }
    if(eff.effect.hasManaDamage)
    {
        [pool drawFromPool:[eff.manaDamage MultiplyBy:combinedManaArmor]];
    }
    if(eff.effect.hasNormalDamage)
    {
        dam+=[combinedArmor Dot:eff.damage];
    }
    if(eff.effect.canRemoveEffect)
    {
       // NSMutableArray * rem=[[NSMutableArray alloc]init ];
        for(SVStatusEffectInTime *tme in effects)
        {
            if([tme.effect.name hasPrefix:eff.effect.effectPrefix])
                [rem addObject:tme];
        }
        [effects removeObjectsInArray:rem];
        [rem removeAllObjects];
       // [rem release];
    }
    if(eff.effect.hasFrameChange)
    {
        currentFrame=eff.toFrame;
    }
    if(eff.effect.canSpawnBody)
    {
        ///TODO -needs body framework;
    }
    HP-=dam;
    if(dam>0) //check for damage interrupted abilities
    {
      for( SvAbility * ab in runningAbilities)
      {
          if(ab.interruptedByDamage)
          {
              [ab interrupt];
          }
      }
    }
}
- (NSDictionary *) getStatus
{
    NSMutableDictionary *ret=[[NSMutableDictionary alloc] initWithCapacity:1];
    [ret setValue:[NSNumber numberWithBool:wasCrushed] forKey:@"Crushed"];
    wasCrushed=NO;
    return [ret autorelease];
}
@end
