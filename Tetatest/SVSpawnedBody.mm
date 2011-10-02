//
//  SVSpawnedBody.m
//  Tetatest
//
//  Created by Seva on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVSpawnedBody.h"
#import "Box2D.h"
#import "OpenGLView.h"
#import "SVTetris.h"
#import "CC3Math.h"
#import "SvTetrisMonster.h"
@implementation SVFixtureDef
@synthesize animation;
- (id) init
{
    return nil;
}
- (void) updateTime:(NSTimeInterval)time
{
    if(timeline==nil) return;
    if([timeline count]==0) return;
    ctime+=time;
   SVATimeline* cdur=[timeline objectAtIndex:ctml];
    double dur=cdur.duration;
    while(ctime>=dur)
    {
        ctime-=dur; 
        ctml++;
        if(ctml>=[timeline count]) ctml=0;
        
        cdur=[timeline objectAtIndex:ctml];
        [animation setFrame:cdur.change];
        dur=cdur.duration;
    }
}
- (id) initWithDictionary:(NSDictionary *)dct
{
    if((self=[super init]))
    {
        NSString * animName=[dct valueForKey:@"Animation"];
       animation =[[SvSharedSpriteCache SharedCache] getAnimatedSpriteWithName:animName];
        [animation setFrame:0];
        restitution=[[dct valueForKey:@"Restitution"] floatValue];
        density=[[dct valueForKey:@"Density"]floatValue];
        friction=[[dct valueForKey:@"Friction"] floatValue];
        angle=[[dct valueForKey:@"Angle"] floatValue];
        NSArray *ofa=[dct valueForKey:@"Offset"];
        offset=CGPointMake([[ofa objectAtIndex:0]floatValue],[[ofa objectAtIndex:1] floatValue]);
        NSString * shName=[dct valueForKey:@"Shape"];
        vertices=[[NSMutableArray alloc]init ];
        if([shName isEqualToString:@"Box"])
        {
            shape=0;
            float width=[[dct valueForKey:@"Width"] floatValue];
            float he=[[dct valueForKey:@"Height"] floatValue];
            [vertices addObject:[NSValue valueWithCGPoint:CGPointMake(width, he)]];
        }
        else
            if([shName isEqualToString:@"Circle"])
            {
                shape=2;
                 float rad=[[dct valueForKey:@"Radius"] floatValue];
                [vertices addObject:[NSNumber numberWithFloat:rad]];
            }
        else 
            if([shName isEqualToString:@"Polygon"])
            {
                shape=1;
                NSArray *va=[dct valueForKey:@"Vertices"];
                for(NSArray * ofa in va)
                {
           
               CGPoint ta=CGPointMake([[ofa objectAtIndex:0]floatValue],[[ofa objectAtIndex:1] floatValue]);
                    [vertices addObject:[NSValue valueWithCGPoint:ta]];
                }

            }
        NSArray* preTime=[dct valueForKey:@"Timeline"];
        if(preTime==nil) timeline=nil;
        else
        {
            timeline=[[NSMutableArray alloc]initWithCapacity:[preTime count]];
            for(NSDictionary * tm in preTime)
            {
                SVATimeline* tl=[[SVATimeline alloc]initWithDictionary:tm];
                [timeline addObject:tl];
                [tl release];
            }
        }
    }
    return self;
}
- (b2FixtureDef) getFixtureDefWithOwner
{
    b2FixtureDef ret=b2FixtureDef();
    ret.restitution=restitution;
    ret.density=density;
    ret.friction=friction;
   ret.userData=(void *) self;
    ret.shape=NULL;
    return ret;
}
@synthesize localFixture;
- (void) addToBody:(b2Body *)body asOwner:(SVTetrisBody *)bdy andSensor:(BOOL)sen
{
  
    b2FixtureDef fix=[self getFixtureDefWithOwner];
    body->SetUserData((void *)bdy);
    switch (shape) {
        case 0://box
        {
            b2PolygonShape ret;
            float width=[[vertices objectAtIndex:0] CGPointValue].x;
            float height=[[vertices objectAtIndex:0] CGPointValue].y;
            b2Vec2 center;
            center.x=(offset.x+width/2)/PTM_RATIO;
            center.y=(offset.y+height/2)/PTM_RATIO;
            float hx=width/(2*PTM_RATIO);
            float hy=height/(2*PTM_RATIO);
            ret.SetAsBox(hx,hy , center, angle);
            fix.shape=&ret;
        }
            break;
        case 1:
        {
            b2PolygonShape ret;
            int count =[vertices count];
            b2Vec2 *vertix=(b2Vec2 *)malloc(sizeof(b2Vec2)*count);
            for(int i=0;i<count;i++)
            {
                vertix[i].x=(offset.x+[[vertices objectAtIndex:i] CGPointValue].x)/PTM_RATIO;
                vertix[i].y=(offset.y+[[vertices objectAtIndex:i] CGPointValue].y)/PTM_RATIO;
                
            }
            ret.Set(vertix, count);
            free(vertix);
            fix.shape=&ret;
        };break;
        case 2:
        {
            b2CircleShape ret;
            ret.m_p.Set(offset.x, offset.y);
            ret.m_radius=[[vertices objectAtIndex:0] floatValue];
            fix.shape=&ret;
        };break;
        default:
            break;
    }
    if(sen)
        fix.isSensor=true;
    else
        fix.isSensor=false;
    localFixture= body->CreateFixture(&fix);
    if(localFixture) localFixture->SetUserData((void *) self);
}
-(void) dealloc
{
    [vertices release];
    [super dealloc];
}
@end

@implementation SVPhysicalAspect
@synthesize isSensor;
@synthesize interactWithPassthrough;
@synthesize collisionMask;
- (id) initWithDictionary: (NSDictionary * )dict
{
    if((self=[super init]))
    {
        collisionMask=[[dict valueForKey:@"Collision Mask"] intValue];
        isSensor=[[dict valueForKey:@"Sensor"]boolValue];
        interactWithPassthrough=[[dict valueForKey:@"Interact with Passthough"] boolValue];
        fixRotation=![[dict valueForKey:@"Rotate"]boolValue];
        fixtures=[[NSMutableArray alloc]init];
        NSArray *fa=[dict valueForKey:@"Fixtures"];
        NSArray* preTime=[dict valueForKey:@"Timeline"];
        loop=[[dict valueForKey:@"Loop"] boolValue];
        if(preTime==nil) timeline=nil;
        else
        {
            timeline=[[NSMutableArray alloc]initWithCapacity:[preTime count]];
            for(NSDictionary * tm in preTime)
            {
                SVATimeline* tl=[[SVATimeline alloc]initWithDictionary:tm];
                [timeline addObject:tl];
                [tl release];
            }
        }
        for(NSDictionary * dct in fa)
        {
            SVFixtureDef * def=[[SVFixtureDef alloc] initWithDictionary:dct];
            [fixtures addObject:def];
            [def release];
        }
        addedFixtures=[[NSMutableArray alloc]initWithCapacity:1];
        if([timeline count]==0)
        [addedFixtures addObject:[fixtures objectAtIndex:0]];
        else
        {
            SVATimeline* tl=[timeline objectAtIndex:0];
            [addedFixtures addObject:[fixtures objectAtIndex:tl.change]];
        }
    }
    return self;
}
- (void) dealloc
{
    [addedFixtures release];
    [fixtures release];
    [super dealloc];
}
- (b2Body *) createBodyInWorld:(b2World *)world forOwner:(SVTetrisBody *)own atPos:(CGPoint)pos
{
    owner=own;
    b2BodyDef def;
    def.type=b2_dynamicBody;
    def.position.x=pos.x/PTM_RATIO;
    def.position.y=pos.y/PTM_RATIO;
    def.angle=0;
    def.allowSleep=true;
    def.awake=true;
    def.bullet=true;
    body=world->CreateBody(&def);
    for(SVFixtureDef * fix in addedFixtures)
    {
        [fix addToBody:body asOwner:own andSensor:isSensor];
    }
    return body;
}
- (void) addFixtureToBody:(SVFixtureDef *)fixture
{ 
    [fixture addToBody:body asOwner:owner andSensor:isSensor];
}
- (void) Update:(NSTimeInterval)time
{
    for( SVFixtureDef * fix in addedFixtures)
    {
        [fix updateTime:time];
    }
    if(timeline==nil) return;
    if([timeline count]==0) return;
    if(!loop&&ctml>=[timeline count]-1) return;
    ctime+=time;
    SVATimeline* cdur=[timeline objectAtIndex:ctml];
    double dur=cdur.duration;

    while(ctime>=dur)
    {
        ctime-=dur; 
        ctml++;
        if(ctml>=[timeline count]) 
        {
            if(loop) ctml=0;
            else break;
        }
        
        cdur=[timeline objectAtIndex:ctml];
        if(cdur.type==1)
        {
            [self addFixtureToBody:[fixtures objectAtIndex:cdur.change]];
            [addedFixtures addObject:[fixtures objectAtIndex:cdur.change]];
            [[fixtures objectAtIndex:cdur.change] updateTime:ctime];
        }
        if(cdur.type==-1)
        {
            SVFixtureDef * fx= [fixtures objectAtIndex:cdur.change];
            if(fx!=nil)
            {
                [addedFixtures removeObject:fx];
                body->DestroyFixture(fx.localFixture);
                fx.localFixture=NULL;
                
            }
        }
        dur=cdur.duration;
    } 
}
- (void) Draw
{
    for(SVFixtureDef *an in addedFixtures)
    {
        b2Body *bd= an.localFixture->GetBody();
        b2Vec2 pos=bd->GetPosition();
        an.animation.ul_position=CGPointMake(pos.x*PTM_RATIO, pos.y*PTM_RATIO);
        CC3GLMatrix * tr=an.animation.transform;
        [tr populateIdentity];
         [tr rotateBy:CC3VectorMake(180, 0, 0)];
        [tr rotateBy:CC3VectorMake(0, 0, bd->GetAngle()*180/M_PI)];
        [an.animation Draw];
        
    }
}
@end

@implementation SVMovementAspect
@synthesize useTarget;
@synthesize initialPosition;
- (CGPoint) getPointFromArray: (NSArray *) arr
{
    return CGPointMake([[arr objectAtIndex:0] floatValue], [[arr objectAtIndex:1]floatValue]);
}
- (void) setInitPos:(CGPoint)pos
{
    iniPos=pos;
}

- (id) initWithDictionary: (NSDictionary *) dct
{
    if((self=[super init]))
    {
        NSString *  ipName=[dct valueForKey:@"Initial position"];
        if([ipName isEqualToString:@"Parent"])
            initialPosition=0;
        if([ipName isEqualToString:@"Enemy"])
            initialPosition=1;
        if([ipName isEqualToString:@"Position"])
            initialPosition=2;
        useCenter=[[dct valueForKey:@"Use Center"] boolValue];
        useTargetBody=[[dct valueForKey:@"Use Target Body"] boolValue];
useTarget=[[dct valueForKey:@"Use Target"] boolValue];
        shift=[self getPointFromArray:[dct valueForKey:@"Shift"]];
        orientationInverse=[[dct valueForKey:@"Use Orientation"] boolValue];
        if([[dct valueForKey:@"Attach To Body"] boolValue]==YES)
        {
            moveType=0;
        }
        else
        {
            moveType=1;
        }
        targetForce=[[dct valueForKey:@"Target Force"] floatValue];
        ctf=targetForce;
        targetForceIncrease=[[dct valueForKey:@"Target Force Increase"] floatValue];
        ttangentForce=[[dct valueForKey:@"Tangent Force"] floatValue];
        targetVelocity=[[dct valueForKey:@"Target Velocity"] floatValue];
        if ([dct valueForKey:@"Target Velocity"]==nil)
            useTargetVelocity=NO;
        else useTargetVelocity=YES;
        
        appliedAccel=[self getPointFromArray:[dct valueForKey:@"Acceleration"]];
        appliedVelocity=[self getPointFromArray:[dct valueForKey:@"Velocity"]];
        if([dct valueForKey:@"Velocity"]==nil)
            fixedVelocity=NO;
        else
            fixedVelocity=YES;
        minRandomForce=[self getPointFromArray:[dct valueForKey:@"Minimum Random Force"]];
        maxRandomForce=[self getPointFromArray:[dct valueForKey:@"Maximum Random Force"]];
        minRandomVelOnce=[self getPointFromArray:[dct valueForKey:@"Minimum Random Vel"]];
        maxRandomVelOnce=[self getPointFromArray:[dct valueForKey:@"Maximum Random Vel"]];
        useGravity=[[dct valueForKey:@"Use Gravity"] boolValue];
        initDone=NO;
    }
    return self;
}
- (void) setTargetBody: (SVTetrisBody *) bdy
{
    targetBody=bdy;
}
- (void) setTargetPos: (CGPoint) pos
{
    targetPos=pos;
}
- (void) setSpawner: (SVTetrisBody *) bdy
{
    spawner=bdy;
}
- (CGPoint) getInitialPosition: (int) orientation
{
    CGPoint init;
    switch (initialPosition) {
        case 0:
        {
            if(!useCenter)
            {
            init=[spawner getPosition];
            }else
            {
                CGRect inir=[spawner getBoundingBox];
                init=CGPointMake(inir.origin.x+inir.size.width/2, inir.origin.y+inir.size.height/2);
            }
            
        };  break;
        case 1:
        {
            if(!useCenter)
            {
                init=[targetBody getPosition];
            }else
            {
                CGRect inir=[targetBody getBoundingBox];
                init=CGPointMake(inir.origin.x+inir.size.width/2, inir.origin.y+inir.size.height/2);
            }
            
        };  break;    
        case 2:
        {
            init=iniPos;
        }
        default:
            break;
    }
    return init;
}
- (void) applyToBody: (b2Body *) body inTime: (double) time
{
    if(moveType==0)
    {
        CGPoint position;
        if(initialPosition==0)
        {//spawner attach
            position=[spawner getPosition];  
        }
        if(initialPosition==1)
        {
            position=[targetBody getPosition];
            
        }
        if(initialPosition==2)
        {
            position=iniPos;
        }
        b2Vec2 pos=b2Vec2(position.x/PTM_RATIO, position.y/PTM_RATIO);
        body->SetTransform(pos, body->GetAngle());
        return;
        
    }
    if(!initDone)
    {
       
        b2Vec2 vel=b2Vec2( RandomFloatBetween(minRandomVelOnce.x/PTM_RATIO, maxRandomVelOnce.x/PTM_RATIO), RandomFloatBetween(minRandomVelOnce.y/PTM_RATIO, maxRandomVelOnce.y/PTM_RATIO));
        body->SetLinearVelocity(vel);
        initDone=YES;
        return;
    }
    if(fixedVelocity)
    {
        b2Vec2 vel=b2Vec2(appliedVelocity.x/PTM_RATIO,appliedVelocity.y/PTM_RATIO);
        body->SetLinearVelocity(vel);
    }
    else
    {
        if(useTargetVelocity)
        {
            CGPoint tp=targetPos;
            if(useTargetBody)
                tp=[targetBody getPosition];
            b2Vec2 tpos=b2Vec2(tp.x/PTM_RATIO, tp.y/PTM_RATIO);
            b2Vec2 pos=body->GetPosition();
            tpos=b2Vec2(tpos.x-pos.x, tpos.y-pos.y);
            tpos.Normalize();
            tpos.x*=targetVelocity;
            tpos.y*=targetVelocity;
            body->SetLinearVelocity(tpos);
        }
        else
        {
            CGPoint tp=targetPos;
            if(useTargetBody)
                tp=[targetBody getPosition];
            b2Vec2 tpos=b2Vec2(tp.x/PTM_RATIO, tp.y/PTM_RATIO);
            b2Vec2 pos=body->GetPosition();
            tpos=b2Vec2(tpos.x-pos.x, tpos.y-pos.y);
            tpos.Normalize();
            ctf=ctf+time*targetForceIncrease;
           b2Vec2 force= b2Vec2(tpos.x*ctf+ttangentForce*tpos.y, tpos.y*ctf-ttangentForce*tpos.x);
            
        }
        float32 bm=body->GetMass();
        b2Vec2 force=b2Vec2(bm*appliedAccel.x, bm*appliedAccel.y);
        body->ApplyForce(force, body->GetPosition());
        b2Vec2 rf=b2Vec2( RandomFloatBetween(minRandomForce.x/PTM_RATIO, maxRandomForce.x/PTM_RATIO), RandomFloatBetween(minRandomForce.y/PTM_RATIO, maxRandomForce.y/PTM_RATIO));
        body->ApplyForce(rf, body->GetPosition());
    }
    
}

@end

@implementation SVLifeAspect

- (id) initWithDictionary:(NSDictionary *)dct
{
    if((self=[super init]))
    {
        fHPMax=[[dct valueForKey:@"HPMax"]doubleValue];
        fHP=fHPMax;
        armor=[[SvManaPool alloc]initWithArray:[dct valueForKey:@"Armor"]];
        onDeathSpawner=[[SvStatusEffect alloc]initWithDictionary:[dct valueForKey:@"OnDeath"]];
        timeStep=[[dct valueForKey:@"Time Step"] doubleValue];
        timeLoss=[[dct valueForKey:@"Time Loss"] doubleValue];
        elapsed=0;
        charges=1;
    }
    return self;
}
- (void) setCharges:(int)ch
{
    charges=ch;
}
- (void) setSpawner:(SVTetrisBody *)bdy
{
    spawner=bdy;
}
- (BOOL) isDead
{
    if(fHP<=0) return YES;
    return NO;
}
- (void) applyDirectDamage:(double)dam
{
    fHP-=dam;
    if(fHP>fHPMax) fHP=fHPMax;
}
- (void) applyManaic:(SvManaPool *)dam
{
    double dm=[armor Dot:dam];
    fHP-=dm;
    if(fHP>fHPMax) fHP=fHPMax;
 
}
-(SvStatusEffect *) getEffect
{
    return onDeathSpawner;
}
- (void) updateTime:(double)time
{
    if(timeStep==0) return;
    elapsed+=time;
    while(elapsed>=timeStep)
    {
        elapsed-=timeStep;
        fHP-=timeLoss;
    }
    if(fHP>fHPMax) fHP=fHPMax;

}
- (void) dealloc
{
    [armor release];
    [onDeathSpawner release];
    [super dealloc];
}
@end

@implementation SVATimeline

@synthesize type;
@synthesize change;
@synthesize duration;
- (id) initWithDictionary:(NSDictionary *)dct
{
    if((self=[super init]))
    {
        change=[[dct valueForKey:@"Change To"] intValue];
        duration=[[dct valueForKey:@"Duration"] doubleValue];
        NSString * name=[dct valueForKey:@"Type"];
        if([name isEqualToString:@"Frame"])
            type=0;
        if([name isEqualToString:@"Fixture"])
            type=1;
        //type 2 not implemented yet
        
    }
    return self;
}
@end

@implementation SVTouchAspect
@synthesize touchParent;
@synthesize touchEnemy;
@synthesize touchBlocks;
- (void) setTouchCharges:(int)cha
{
    ch=cha;
}
- (id) initWithDictionary:(NSDictionary *)dct
{
    if((self = [super init]))
    {
        touchParent=[[dct valueForKey:@"Affects parent"] boolValue];
        touchParent=[[dct valueForKey:@"Affects enemy"] boolValue];
        touchParent=[[dct valueForKey:@"Affects blocks"] boolValue];
        onSelf=[[SvStatusEffect alloc ] initWithDictionary:[dct valueForKey:@"On Self"]];
        onParent=[[SvStatusEffect alloc ] initWithDictionary:[dct valueForKey:@"On Parent"]]; 
        onTouchingBody=[[SvStatusEffect alloc ] initWithDictionary:[dct valueForKey:@"On Touching Body"]]; 
           onPassingBody=[[SvStatusEffect alloc ] initWithDictionary:[dct valueForKey:@"On Passing Body"]];
        application=[[NSMutableDictionary alloc]initWithCapacity:2];
    }
    return self;
}
- (void) dealloc
{
    [onSelf release];
    [onParent release];
    [onTouchingBody release];
    [application release];
    [super dealloc];
}
- (void) applyToParent:(SVTetrisBody *)parent
{
    [application setValue:onParent forKey:@"Effect"];
    double mpl[6];
    memset(mpl, 0, sizeof(double)*6);
    mpl[0]=ch;
    SvManaPool * mp=[[SvManaPool alloc]initWithPool:mpl];
    [application setValue:mp forKey:@"Pool"];
    [mp release];
    [parent Apply:application];  
}
- (void) applyToPassing:(SVTetrisBody *)passing
{
    [application setValue:onPassingBody forKey:@"Effect"];
    double mpl[6];
    memset(mpl, 0, sizeof(double)*6);
    mpl[0]=ch;
    SvManaPool * mp=[[SvManaPool alloc]initWithPool:mpl];
    [application setValue:mp forKey:@"Pool"];
    [mp release];

    [passing Apply:application];  
}
- (void) applyToTouching:(SVTetrisBody *)touching
{
    [application setValue:onTouchingBody forKey:@"Effect"];
    double mpl[6];
    memset(mpl, 0, sizeof(double)*6);
    mpl[0]=ch;
    SvManaPool * mp=[[SvManaPool alloc]initWithPool:mpl];
    [application setValue:mp forKey:@"Pool"];
    [mp release];

    [touching Apply:application];  
}

- (void) applyToSelf:(SVTetrisBody *)body
{
    [application setValue:onSelf forKey:@"Effect"];
    double mpl[6];
    memset(mpl, 0, sizeof(double)*6);
    mpl[0]=ch;
    SvManaPool * mp=[[SvManaPool alloc]initWithPool:mpl];
    [application setValue:mp forKey:@"Pool"];
    [mp release];

        [body Apply:application];  
}
@end

@implementation SVAnimationAspect

- (id) initWithDictionary:(NSDictionary *)dict
{

    if((self=[super init]))
    {
        NSString * animName=[dict valueForKey:@"Animation"];
        sprite =[[SvSharedSpriteCache SharedCache] getAnimatedSpriteWithName:animName];
       if([dict valueForKey:@"Fixtures"]!=nil)
       {
           usesAddedFixtures=YES;
           NSArray * fixes=[dict valueForKey:@"Fixtures"];
           NSMutableArray * fix=[[NSMutableArray alloc] initWithCapacity:[fixes count]];
           for (NSDictionary * fdc in fixes)
           {
               SVFixtureDef * fd=[[SVFixtureDef alloc]initWithDictionary:fdc];
               [fix addObject:fd];
               [fd release];
           }
           fixtures=[[NSArray alloc] initWithArray:fix];
           [fix release];
       }
        else
            usesAddedFixtures=NO;
        NSArray * tml=[dict valueForKey:@"Timeline"];
        if(tml!=nil)
        {
            for (NSDictionary * dc in tml)
            {
                SVATimeline * line=[[SVATimeline alloc] initWithDictionary:dc];
                [timeline addObject:line];
                [line release];
            }
        }
        else
            return nil;
    }
    return self;
}
- (void) dealloc
{
    [fixtures release];
    [timeline release];
    [super dealloc];
}
- (void) Update:(NSTimeInterval)time
{
    elapsed+=time;
    
}
@end
@implementation SVSpawnedBody
@synthesize parent;
-(void) setParent:(SVTetrisBody *)parentn
{
    [parent release];
    parent=[parentn retain];
    [life setSpawner:parent];
    
}
- (id) initWithDictionary:(NSDictionary *)dct
{
    if((self =[super initWithDictionary:dct]))
    {
        physics=[[SVPhysicalAspect alloc]initWithDictionary:[dct valueForKey:@"Physics"]];
        movement=[[SVMovementAspect alloc]initWithDictionary:[dct valueForKey:@"Movement"]];
        life=[[SVLifeAspect alloc]initWithDictionary:[dct valueForKey:@"Life"]];
        onTouch=[[SVTouchAspect alloc]initWithDictionary:[dct valueForKey:@"Touch"]];
        spawned=NO;
    }
    return self;
}
- (id) initAndSpawnOnScene:(SVScene *)scene withID:(NSString *)iID byBody:(SVTetrisBody *)ps
{
 
    if(scene==nil) return nil;
    if(iID==nil) return nil;
    if(scene.sceneDictionary==nil) return nil;
    if(ps==nil) return nil;
    NSDictionary * adct=[scene.sceneDictionary valueForKey:@"Spawned Bodies"];
    if(adct==nil) return nil;
    NSDictionary *bdct=[adct valueForKey:iID];
    if(bdct==nil) return nil;
    self =[self initWithDictionary:bdct];
    parent=[ps retain];
    [movement setSpawner:parent];
    [life setSpawner:parent];
    if(movement.useTarget)
      [movement setTargetBody:  [ps getSpawnParameter:@"Target Body" forID:iID]];
    else
        [movement setTargetPos:  [[ps getSpawnParameter:@"Target Position" forID:iID] CGPointValue]];
    if(movement.initialPosition==2)
    {
        [movement setInitPos:[[ps getSpawnParameter:@"Initial Position" forID:iID] CGPointValue]];
    }
    if(movement.initialPosition==1)
    {
        [movement setInitPos:   [[ps getSpawnParameter:@"Target Body" forID:iID] getPosition]];
    }
    if(movement.initialPosition==0)
    {
        [movement setInitPos:[ps getPosition]];
    }
    [life setCharges:[[ps getSpawnParameter:@"Charges" forID:iID] intValue]];
    [onTouch setTouchCharges:[[ps getSpawnParameter:@"Charges" forID:iID] intValue]];
    world=(b2World *)[scene getPointerParameter:@"World"];
    body=[physics createBodyInWorld:world forOwner:ps atPos:[[ps getSpawnParameter:@"Initial Position" forID:iID] CGPointValue]];
    [scene spawnBody:self];
    spawned=YES;
    return self;
}
- (void)ProcessTouches
{
    for(SVTetrisBody * tb in touchingBodies)
        [onTouch applyToTouching:tb];
    for(SVTetrisBody * pb in passingBodies)
    {
        [onTouch applyToPassing:pb];
    }
  if([touchingBodies count]>0)
  {
      [onTouch applyToSelf:self];
      [onTouch applyToParent:parent];
  }
   
}
- (void) Update:(double)time
{
    if(!spawned) return;
    if([life isDead]) return;
    [self ProcessTouches];
    [physics Update:time];
    [movement applyToBody:body inTime:time];
    [life updateTime:time];
    if([life isDead])
    {
        NSMutableDictionary * eff=[NSMutableDictionary new];
        [eff setValue:[life getEffect] forKey:@"Effect"];
        SvManaPool * mp=[[SvManaPool alloc] init];
        [eff setValue:mp forKey:@"Pool"];
        [parent Apply:eff];
        [eff release];
        [mp release];
    }
}
- (void) dealloc
{
    [parent release];
    [physics release];
    [movement release];
    [life release];
    [onTouch release];
    [super dealloc];
}
- (BOOL) canContactMode:(unsigned int)mode
{
    contactMode=physics.collisionMask;
    if(contactMode==0||mode==0) return YES;
    if(contactMode&mode) return YES;
    return NO;
  
}
- (BOOL) canContact:(SVTetrisBody *)kbody
{
    if(!onTouch.touchParent&&kbody==parent) return NO;
    if(!onTouch.touchEnemy&&kbody!=parent&&[kbody isKindOfClass:[SvTetrisMonster class]]) return NO;
    return [self canContactMode:[kbody getContactMode]];
}
-(void) Draw
{
    [physics Draw];
}
-(NSDictionary *) getStatus
{
    return [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithBool:[life isDead]],@"Dead", nil];
}
- (BOOL) SpawnWithParameters:(NSDictionary *)parameters
{
    parent=[[parameters valueForKey:@"Parent"] retain];
    [life setSpawner:parent];
    [movement setSpawner:parent];
    [movement setTargetBody:[parameters valueForKey:@"Target"]];
    [movement setTargetPos:[[parameters valueForKey:@"Target Position"] CGPointValue]];
    [life setCharges:[[parameters valueForKey:@"Charges"] intValue]];
    [onTouch setTouchCharges:[[parameters valueForKey:@"Touch Charges"] intValue]];
    CGPoint initPos;
    if([parameters valueForKey:@"Initial Position"]!=nil)
        initPos=[[parameters valueForKey:@"Initial Position"] CGPointValue];
    else
       initPos=[parent getPosition];
    [movement setInitPos:initPos];
    b2World * w=(b2World *) [[parameters valueForKey:@"World"]pointerValue];
    if(w==NULL) return NO;
    world=w;
    body= [physics createBodyInWorld:w forOwner:parent atPos:initPos];
    
    spawned=YES;
    return YES;
}
- (void) Apply:(NSDictionary *)thing
{
    SvStatusEffect *teff=[thing valueForKey:@"Effect"];
    if(teff==nil) return;
    SvManaPool * cpool=[thing valueForKey:@"Pool"];
    SVStatusEffectInTime * eff=[[SVStatusEffectInTime alloc] initWithEffect:teff andOrientation:1 andChargedPool:cpool andAdditionalParameters:nil];  
   
    if(eff.effect.hasDirectHPEffect)
    {
        [life applyDirectDamage:eff.DHPEPS];
    }
    if(eff.effect.hasSpriteEffect)
    {
      //  SpriteEffect tm=eff.effect.spriteEffect;
       // [physics.animation setSpriteEffect:&tm];
    }
    if(eff.effect.hasForceComponent)
    {
        
        [eff applyForceToBody:body ];
        
    }
      
    if(eff.effect.hasNormalDamage)
    {
        [life applyManaic:eff.damage];
    }
      if(eff.effect.hasFrameChange)
    {
        //currentFrame=eff.toFrame;
    }
    if(eff.effect.canSpawnBody)
    {
        ///TODO -needs body framework;
    }
 
     [eff release];
    
}
- (BOOL) isAlive
{
    return ![life isDead];
}
@end
