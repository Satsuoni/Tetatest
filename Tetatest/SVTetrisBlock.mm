//
//  SVTetrisBlock.m
//  Tetatest
//
//  Created by Seva Yugov on 10/1/11.
//  Copyright 2011 Tokodai. All rights reserved.
//

#import "SVTetrisBlock.h"
#import "SVTetrisBody.h"
#import "SVTetris.h"
#import "SvStatusEffect.h"
#define BlockLimitForce 100

@implementation SVTetrisBlock
@synthesize isinGrid;
@synthesize isinFigure;
@synthesize freeFall;
@synthesize isErased;
@synthesize  blocktype;
- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}
- (void) unfix
{
    world->DestroyBody(body);
    CGPoint orig=[self getPosition];
    CGRect rect=CGRectMake(orig.x,orig.y,28,28);
    b2Template temp;
    temp.type=b2_dynamicBody;
    temp.density=1.0;
    temp.friction=0.1;
    temp.restitution=0.3;
    temp.isSensor=NO;
    temp.isBullet=YES;
       b2BodyDef def;
    def.type=temp.type;
    def.position.Set(rect.origin.x/PTM_RATIO, rect.origin.y/PTM_RATIO);
    def.fixedRotation=true;
    if(temp.isBullet)
        def.bullet=true;
    else
        def.bullet=false;
    body=world->CreateBody(&def);
    
    b2PolygonShape box;
    b2Vec2 center=b2Vec2((rect.size.width/2)/PTM_RATIO,(rect.size.height/2)/PTM_RATIO);
    box.SetAsBox(rect.size.width/(2*PTM_RATIO), rect.size.height/(2*PTM_RATIO), center, 0);
    //box.SetAsBox(rect.size.width/(2*PTM_RATIO), rect.size.height/(2*PTM_RATIO));
    b2FixtureDef fix;
    fix.shape=&box;
    fix.restitution=temp.restitution;
    fix.density=temp.density;
    fix.friction=temp.friction;
    if(temp.isSensor)
        fix.isSensor=true;
    body->CreateFixture(&fix);
    body->SetUserData(self);
    [self setContactMode:1];
    freeFall=YES;
    isinFigure=NO;
    isinGrid=NO;
}
- (void) fixAtX:(int) x andY:(int)y
{
    world->DestroyBody(body);
    //CGPoint orig=[self getPosition];
    //CGRect rect=CGRectMake(orig.x,orig.y,28,28);
    CGRect rect=CGRectMake(grid.gridrect.origin.x+x*30+1, grid.gridrect.origin.y+y*30+1, 28, 28);
    b2Template temp;
    temp.type=b2_staticBody;
    temp.density=0;
    temp.friction=0.1;
    temp.restitution=0.2;
    temp.isSensor=NO;

    b2BodyDef def;
    def.type=temp.type;
    def.position.Set(rect.origin.x/PTM_RATIO, rect.origin.y/PTM_RATIO);
    def.fixedRotation=true;
    if(temp.isBullet)
        def.bullet=true;
    else
        def.bullet=false;
    body=world->CreateBody(&def);
    
    b2PolygonShape box;
    b2Vec2 center=b2Vec2((rect.size.width/2)/PTM_RATIO,(rect.size.height/2)/PTM_RATIO);
    box.SetAsBox(rect.size.width/(2*PTM_RATIO), rect.size.height/(2*PTM_RATIO), center, 0);
    //box.SetAsBox(rect.size.width/(2*PTM_RATIO), rect.size.height/(2*PTM_RATIO));
    b2FixtureDef fix;
    fix.shape=&box;
    fix.restitution=temp.restitution;
    fix.density=temp.density;
    fix.friction=temp.friction;
    if(temp.isSensor)
        fix.isSensor=true;
    body->CreateFixture(&fix);
    body->SetUserData(self);
    [self setContactMode:1];
    freeFall=NO;
    isinFigure=NO;
    isinGrid=YES;
    
    [grid fixBlock:self AtX:x Y:y];
}
- (void) startErasingWithPulldown
{
    pulldown=YES;
    isErasing=YES;
    startTime=[NSDate timeIntervalSinceReferenceDate];
    elapsed=0;
    tt=0;
    eraseStep=[parentScene getDoubleParameter:@"Block Erase Step"];
    if(eraseStep==0) eraseStep=0.2;
    eraseTime=[parentScene getDoubleParameter:@"Block Erase Time"];
    if(eraseTime==0) eraseTime=1;
}
- (void) startErasing
{
    pulldown=NO;
    isErasing=YES;
    startTime=[NSDate timeIntervalSinceReferenceDate];
    elapsed=0;
    tt=0;
    eraseStep=[parentScene getDoubleParameter:@"Block Erase Step"];
    if(eraseStep==0) eraseStep=0.2;
    eraseTime=[parentScene getDoubleParameter:@"Block Erase Time"];
    if(eraseTime==0) eraseTime=1;
}
- (BOOL) isAlive
{
    if(HP<=0) return NO;
    if(!isinGrid&&!freeFall&&!isinFigure&&!isErasing) return NO;
    if(isErased) return NO;
    return YES;
}
- (id) initWithType:(int)itype free:(BOOL)free inWorld:(b2World *)iworld withBlocks:(SVAnimatedSprite *)iblocks onGrid:(TGrid *)igrid atPos:(CGPoint)pos
{
    b2Template temp;
    freeFall=free;
    blocktype= itype;
    HP=100;
    if(freeFall)
    {
        temp.type=b2_dynamicBody;
        temp.density=1.0;
        temp.friction=0.1;
        temp.restitution=0.3;
        temp.isSensor=NO;
        temp.isBullet=YES; 
    }
    else
    {
        isinFigure=YES;
           temp.type=b2_kinematicBody;
        temp.density=0;
        temp.friction=0.1;
        temp.restitution=0.4;
        temp.isSensor=NO;
    }
   
    CGRect posr=CGRectMake(pos.x,pos.y,28,28);
    
    self=[super initWithRect:posr andTemplate:temp inWorld:iworld withName:@"Block" andType:[NSString stringWithFormat:@"Block%d",itype]];
    if(self)
    {
        blocks=[iblocks retain];
        grid=igrid;
    }
    return self;
}
- (void) dealloc
{
    if(isinFigure) isinFigure=NO;
    if(isinGrid)
    {
        [grid unfixFigureBlock:self];
        isinGrid=NO;
    }
    [blocks release];
    [super dealloc];
}
- (void) Update:(double)time
{
    if(isErasing)
    {
        elapsed+=time;
        tt+=time;
        while(tt>=eraseStep)
        {
            tt-=eraseStep;
            [grid getManaFromBlock:self];
        }
       if(elapsed>=eraseTime)
       {
           isErased=YES;
           isErasing=NO;
           if(pulldown)
           [grid dropDownFromBlock:self];
           isinFigure=NO;
           isinGrid=NO; 
           freeFall=NO;
           return;
       }
    }
    if(freeFall)
    {
        [self applyLinearDamping:0.1];
    
        CGPoint vel=[self getVelocity];
        float v2=vel.x*vel.x+vel.y*vel.y;
        if(v2>50)
            [self applyLinearDamping:0.2];
        [self recordPosition];
        CGRect gridrect=grid.gridrect;
        if([self sleeps]||[self checkOscillationatLevel:0.35 upToDiff:0.1])
        {
            CGPoint pos=[self getPosition];
            int px=pos.x-gridrect.origin.x-1;
            int py=pos.y-gridrect.origin.y-1;
            int dpx=px%30;
            int dpy=py%30;
            int rx=px/30;
            int ry=py/30;
            if(dpx>15)
            {
                rx++;
                dpx=30-dpx;
            }
            if(dpy>15)
            {
                ry++;
                dpy=30-dpy;
            }
            if(dpx>5||dpy>5)
            {
                float ix=px%30;
                float iy=py%30;
                if(ix>=15.0f)
                {
                    ix=ix-30;
                }
                if(iy>=15.0f)
                {
                    iy=iy-30;
                }
                [self applyDirectVelocity:CGPointMake(-ix*2, -iy*2)];
            }
            else
            {
                [self fixAtX:rx andY:ry];
             
            }
        }
    }
}
-(void) Draw
{
    [blocks setFrame:blocktype];
    blocks.virt_frame=[self getBoundingBox].size;
    blocks.ul_position=[self getPosition];
    blocks.effect=0;
    if(isErasing)
    {
        blocks.effect=2;
        double cf=elapsed/eraseTime;
        [blocks setEffectParameter:0 toValue:0.5f];
        [blocks setEffectParameter:1 toValue:5];
        
        [blocks  setEColorR:1 G:1 B:cf A:cf+0.2 N:0];
        [blocks  setEColorR:1 G:0 B:0 A:1 N:1]; 
        
    }
    if(freeFall)
    {
        blocks.effect=1;
        [blocks setEffectParameter:0 toValue:0.5];
    }
    [blocks Draw];
}
- (void) moveToGridatX:(int)x andY:(int)y
{
    [self updatePosition:CGPointMake(grid.gridrect.origin.x+x*30, grid.gridrect.origin.y+y*30)];
}
- (id) initWithDictionary:(NSDictionary *)dct
{
    return [super initWithDictionary:dct];
}
- (NSDictionary *) getStatus
{
    NSMutableDictionary * tmp=[NSMutableDictionary new];
    [tmp setValue:[NSNumber numberWithDouble:HP]forKey:@"HP"];
    return [tmp autorelease];
}
- (void) Apply:(NSDictionary *)thing
{
    if([thing valueForKey:@"Effect"]!=nil)
    {
        SvStatusEffect *teff=[thing valueForKey:@"Effect"];
        SvManaPool * cpool=[thing valueForKey:@"Pool"];
        SVStatusEffectInTime * eff=[[SVStatusEffectInTime alloc] initWithEffect:teff andOrientation:1 andChargedPool:cpool andAdditionalParameters:nil];  
        
        if(eff.effect.hasDirectHPEffect)
        {
            //ignore
        }
        if(eff.effect.hasSpriteEffect)
        {
            //  SpriteEffect tm=eff.effect.spriteEffect;
            // [physics.animation setSpriteEffect:&tm];
        }
        if(eff.effect.hasForceComponent)
        {
            
          if(isinGrid||isinFigure)
          {
              b2Vec2 fr=[eff getForceToBody:body];
              if(fr.Length()>BlockLimitForce)
              {
                  [self unfix];
                  [eff applyForceToBody:body];
              }
          }
            else
                [eff applyForceToBody:body];
        }
        
        if(eff.effect.hasNormalDamage)
        {
            double dm=0;
            for(int i=0;i<MANA_TYPES;i++)
            {
                if(i!=blocktype)
                {
                    dm+=[eff.damage getMana:i]*0.5;
                }
            }
            if(dm>0)
            HP-=dm;
           
        }
      
      
        
        [eff release];   
    }
}
@end
