//
//  SVTetrisBody.m
//  Tetatest
//
//  Created by Seva on 6/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVTetris.h"
#import "Box2D.h"
#import "SVTetrisBody.h"
@implementation SVTetrisBody
@synthesize touchingBodies;
@synthesize passingBodies;
- (id) initWithDictionary:(NSDictionary *)dct
{
   self=[super init];
    if(self)
    {
        passingBodies=[[NSMutableSet alloc]init];
        touchingBodies=[NSMutableSet new];
    }
    return self;
}
- (void) setParentScene:(SVScene *)scn
{
    if(parentScene!=nil) [parentScene release];
    parentScene=[scn retain];
}
- (b2AABB) getAABB
{
    b2AABB ret;
    int fi=0;
    for(b2Fixture * f=body->GetFixtureList();f;f=f->GetNext())
    {
        if(fi==0)
        {ret=f->GetAABB();}
        else
            ret.Combine(f->GetAABB(), ret);
        fi++;
    }
    return ret;
}
- (id) getSpawnParameter:(NSString *)par forID:(NSString *)ID
{
    return nil;
}
- (void) destroyBody
{
    if(body!=NULL)
    {
        world->DestroyBody(body);
        body=NULL;
    }
}
- (void) Update:(double)time
{
    
}
- (void) Apply:(NSDictionary *)thing
{
    
}
- (unsigned int) getContactMode
{
    return contactMode;
}
- (NSDictionary *) getStatus
{
    return nil;
}
- (void) recordPosition
{
    recordedPositions[crec]=[self getPosition];
    crec=(crec+1)%MREC_POS;
    trec++;
    if(trec>MREC_POS)trec=MREC_POS;
    
}
- (BOOL) checkOscillationatLevel:(float)level upToDiff:(float) diff
{
    if(trec<MREC_POS) return NO;
    float tvx=0;
    float tvy=0;
    int crm=crec-1;
    if(crm<0) crm+=MREC_POS;
    float maxx=recordedPositions[crm].x;
    float maxy=recordedPositions[crm].y;
    float minx=recordedPositions[crm].x;
    float miny=recordedPositions[crm].y;
    for(int i=crec;i<crec+MREC_POS-1;i++)
    {
        int ci=i%MREC_POS;
        int pi=(ci+1)%MREC_POS;
        if(recordedPositions[ci].x<minx)minx=recordedPositions[ci].x;
        if(recordedPositions[ci].x>maxx)maxx=recordedPositions[ci].x;
        if(recordedPositions[ci].y<miny)miny=recordedPositions[ci].y;
        if(recordedPositions[ci].y>maxy)maxy=recordedPositions[ci].y;
        tvx+=fabs(recordedPositions[ci].x-recordedPositions[pi].x);
        tvy+=fabs(recordedPositions[ci].y-recordedPositions[pi].y);
    }
    if(tvx<1&&tvy<1) return YES;
    if(tvx<diff*tvy)
    {
        if ((maxy-miny)/tvy<level) return YES;
        else
            return NO;
    }
    if(tvy<diff*tvx)
    {
        if ((maxx-minx)/tvx<level) return YES;
        else
            return NO;
    }
    
    if ((maxy-miny)/tvy>=level) return NO;
    else
        if ((maxx-minx)/tvx>=level) return NO;
        else return YES;
    
    return NO;
}
- (void) applyLinearDamping:(float)damp
{
    if(body!=NULL)
        body->SetLinearDamping(damp);
}
- (void) Draw
{
    
}
- (CGPoint) getVelocity
{
    if(body!=NULL)
    {
        b2Vec2 vel=body->GetLinearVelocity();
        return CGPointMake(vel.x*PTM_RATIO, vel.y*PTM_RATIO);
    }
    return CGPointMake(0, 0);
}
- (BOOL) sleeps
{
    if(body==NULL) return YES; 
    if(body->IsAwake())
        return NO;
    else
        return YES;
}
- (CGRect) getBoundingBox
{
    if(body==NULL) return CGRectZero;
    b2Fixture* f = body->GetFixtureList();
    b2Shape* sh=f->GetShape();
    b2AABB box;
    sh->ComputeAABB(&box, body->GetTransform());
   // bool tr=box.IsValid();
    return CGRectMake(box.lowerBound.x*PTM_RATIO, box.lowerBound.y*PTM_RATIO, PTM_RATIO*fabs(box.lowerBound.x-box.upperBound.x), PTM_RATIO*fabs(box.lowerBound.y-box.upperBound.y));
}
- (BOOL) isPresentonX:(int)x Y:(int)y withRect:(CGRect) gridrect
{
    if(body==NULL) return NO;
    CGRect gridpoint=CGRectMake(gridrect.origin.x+x*30, gridrect.origin.y+y*30, 30, 30);
    for (b2Fixture* f = body->GetFixtureList(); f; f = f->GetNext())
    {
        b2Shape* sh=f->GetShape();
        b2AABB box;
        sh->ComputeAABB(&box, body->GetTransform());
        CGRect newRect=CGRectMake(box.lowerBound.x*PTM_RATIO+1, box.lowerBound.y*PTM_RATIO+1, PTM_RATIO*fabs(box.lowerBound.x-box.upperBound.x)-2, PTM_RATIO*fabs(box.lowerBound.y-box.upperBound.y)-2);
        if( CGRectIntersectsRect(gridpoint, newRect))
            return YES;
        
    }
    return NO;
}
-(void) updatePosition:(CGPoint)pos
{
    if(body==NULL)  return;
    b2Vec2 posb=b2Vec2(pos.x/PTM_RATIO, pos.y/PTM_RATIO);
    body->SetTransform(posb, 0);
}
- (CGPoint) getPosition
{
    if(body==NULL) return CGPointZero;
    b2Vec2 pos=body->GetPosition();
    return CGPointMake(pos.x*PTM_RATIO, pos.y*PTM_RATIO);
}
-(id) initWithRect:(CGRect)rect andTemplate:(b2Template)temp inWorld:(b2World *)worldi withName:(NSString *)namei andType:(NSString *)typei
{
    if((self=[super init]))
    {
        passingBodies=[[NSMutableSet alloc] init];
        world=worldi;
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
        name=[namei retain];
        type=[typei retain];
        touchingBodies=[[NSMutableSet alloc] init];
        
    }
    return self;
}
- (BOOL) canContactMode:(unsigned int)mode
{
    if(contactMode==0||mode==0) return YES;
    if(contactMode&mode) return YES;
    return NO;
}
- (void) setType:(NSString *)str
{
    [type release];
    type=[str retain];
}
- (BOOL) canContact:(SVTetrisBody *)svbody
{
    return [svbody canContactMode:contactMode];
}
- (NSString *) getName
{
    return name;
}
- (NSString *) getType
{
    return type;
}
- (void) addTouchingBody:(SVTetrisBody *)svbody
{
    if(touchingBodies==nil) touchingBodies=[NSMutableSet new];
    if(![touchingBodies containsObject:svbody])
        [touchingBodies addObject:svbody];
}
- (void) applyImpulse:(CGPoint)nimpulse
{
    impulse.x+=nimpulse.x;
    impulse.y+=nimpulse.y;
}
- (void) Reset
{
    impulse=CGPointMake(0, 0);
    [touchingBodies removeAllObjects];
}
-(void) dealloc
{
    [parentScene release];
    [name release];
    [type release];
    [passingBodies release];
    [touchingBodies removeAllObjects];
    [touchingBodies release];
    if(body!=NULL) 
        world->DestroyBody(body);
    [super dealloc];
}
- (void) setContactMode:(unsigned int)mode
{
    contactMode=mode;
}
- (BOOL) isSensor
{
    if(body==NULL) return YES;
    b2Fixture * fix=body->GetFixtureList();
    if(fix->IsSensor())
        return YES;
    return NO;
}
- (void) applyDirectImpulse:(CGPoint)impulseq
{
    if(body==NULL)  return;
    b2Vec2 b=b2Vec2(impulseq.x/PTM_RATIO, impulseq.y/PTM_RATIO);
    b2Vec2 p=b2Vec2(0, 0);
    body->ApplyLinearImpulse(b, p);
}
- (void) applyDirectVelocity:(CGPoint)vel
{
    if(body==NULL)  return;
    b2Vec2 b=b2Vec2(vel.x/PTM_RATIO, vel.y/PTM_RATIO);
    body->SetLinearVelocity(b);
}
- (BOOL) isAlive
{
    return YES;
}
@end
