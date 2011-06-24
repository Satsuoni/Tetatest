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
@implementation SvTetrisMonster

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
   };
    return self;
    
}
- (void) dealloc
{
    [animation release];
    [super dealloc];  
}
- (void) Update:(double)time
{
    body->SetLinearDamping(0.1);
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
            b2Vec2 point=b2Vec2(0,0);
           body->ApplyLinearImpulse(force, point);
            currentEffect=ghostEffect;
        }
    }
    else
    {
        
    }
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
}
- (NSDictionary *) getStatus
{
    NSMutableDictionary *ret=[[NSMutableDictionary alloc] initWithCapacity:1];
    [ret setValue:[NSNumber numberWithBool:wasCrushed] forKey:@"Crushed"];
    wasCrushed=NO;
    return [ret autorelease];
}
@end
