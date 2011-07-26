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

@implementation SVFixtureDef
- (id) init
{
    return nil;
}
- (id) initWithDictionary:(NSDictionary *)dct
{
    if((self=[super init]))
    {
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
    }
    return self;
}

- (b2FixtureDef) getFixtureDefWithOwner:(SVTetrisBody *)owner
{
    b2FixtureDef ret=b2FixtureDef();
    ret.restitution=restitution;
    ret.density=density;
    ret.friction=friction;
    ret.userData=(void *) owner;
    ret.shape=NULL;
    return ret;
}
- (void) addToBody:(b2Body *)body asOwner:(SVTetrisBody *)bdy andSensor:(BOOL)sen
{
    b2FixtureDef fix=[self getFixtureDefWithOwner:bdy];
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
    body->CreateFixture(&fix);
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
        for(NSDictionary * dct in fa)
        {
            SVFixtureDef * def=[[SVFixtureDef alloc] initWithDictionary:dct];
            [fixtures addObject:def];
            [def release];
        }
    }
    return self;
}
- (void) dealloc
{
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
    for(SVFixtureDef * fix in fixtures)
    {
        [fix addToBody:body asOwner:own andSensor:isSensor];
    }
    return body;
}
- (void) addFixtureToBody:(SVFixtureDef *)fixture
{ 
    [fixture addToBody:body asOwner:owner andSensor:isSensor];
}
@end

@implementation SVMovementAspect
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
        appliedAccel=[self getPointFromArray:[dct valueForKey:@"Acceleration"]];
        appliedVelocity=[self getPointFromArray:[dct valueForKey:@"Velocity"]];
        minRandomForce=[self getPointFromArray:[dct valueForKey:@"Minimum Random Force"]];
        maxRandomForce=[self getPointFromArray:[dct valueForKey:@"Maximum Random Force"]];
        minRandomVelOnce=[self getPointFromArray:[dct valueForKey:@"Minimum Random Vel"]];
        maxRandomVelOnce=[self getPointFromArray:[dct valueForKey:@"Maximum Random Vel"]];
        useGravity=[[dct valueForKey:@"Use Gravity"] boolValue];
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
- (void) applyToBody: (b2Body *) body inTime: (double) time;

@end

@implementation SVSpawnedBody

@end
