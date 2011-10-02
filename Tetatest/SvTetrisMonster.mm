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
#import "SVSpawnedBody.h"
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
        abilityID=[[dict valueForKey:@"AbilityID"] retain];
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
    [abilityID release];
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
        return [NSNumber numberWithDouble:HP] ;
    if([valueName isEqualToString:@"HPMax"])
        return [NSNumber numberWithDouble:HPMax];
    if([valueName hasPrefix:@"Mana"])
    {
        NSString * st=[valueName stringByReplacingOccurrencesOfString:@"Mana" withString:@""];
        
        return [NSNumber numberWithDouble:[pool getMana:[st intValue]]] ;
    }

    if([valueName isEqualToString:@"Ghost"])
        return [NSNumber numberWithBool:ghostMode];
    if([valueName isEqualToString:@"Crushed"])
        return [NSNumber numberWithBool:wasCrushed] ;
    if([valueName isEqualToString:@"Orientation"])
        return [NSNumber numberWithInt:orientation];
    if([valueName isEqualToString:@"CanFly"])
        return [NSNumber numberWithBool:canFly] ;
    if([valueName isEqualToString:@"TouchingGround"])
        return [NSNumber numberWithBool:isTouchingGround] ;
    if([valueName isEqualToString:@"VelocityMagnitude"])
    {
        float fl= body->GetLinearVelocity().Length()*PTM_RATIO;
        return [NSNumber numberWithFloat:fl] ;
    }
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
        if(body->IsAwake())
        {
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
        else
            isTouchingGround=YES;
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
    
    SVStatusEffectInTime * temp=[[SVStatusEffectInTime alloc] initWithEffect:eff andOrientation:orientation andChargedPool:cpool andAdditionalParameters:nil];  
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
    
    SVStatusEffectInTime * temp=[[SVStatusEffectInTime alloc] initWithEffect:eff andOrientation:orientation andCharges:charges andAdditionalParameters:nil];  
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
- (id) getSpawnParameter:(NSString *)par forID:(NSString *)ID
{
    //Here there should be AI
    //but for now...
    CGPoint pt=[self getPosition];
    if([par isEqualToString:@"Target Body"]) return self;
    if([par isEqualToString:@"Target Position"]) 
    {
        return [NSValue valueWithCGPoint: CGPointMake(pt.x+arc4random()%100-50, pt.y-arc4random()%100)];
    }
    if( [par isEqualToString:@"Initial Position"])
        return [NSValue valueWithCGPoint:pt];
    if([par isEqualToString:@"Charges"])
        return [NSNumber numberWithInt:current_Charges];
    return nil;
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
    if(eff.effect.hasSpriteEffect)
    {
        SpriteEffect tm=eff.effect.spriteEffect;
        [animation setSpriteEffect:&tm];
    }
    if(eff.effect.hasForceComponent)
    {
        
            [eff applyForceToBody:body ];
        
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
        current_Charges=eff.charges;
        current_TCharges=eff.charges;
        
        [[SVSpawnedBody alloc]initAndSpawnOnScene:parentScene withID:eff.effect.bodyID byBody:self];
        
        ///TODO -needs body framework;
       // SVSpawnedBody * bdy;
      //  NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
      //  NSDictionary *rd=[NSDictionary dictionaryWithContentsOfFile:path];
      //  NSDictionary * bodies=[rd valueForKey:@"Spawned Bodies"];
      //  bdy=[[SVSpawnedBody alloc]initWithDictionary:[bodies valueForKey:eff.effect.bodyID]];
        
       // [movingBodies addObject:bdy];
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
