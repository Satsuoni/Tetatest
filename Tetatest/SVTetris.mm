//
//  SVTetris.m
//  Tetatest
//
//  Created by Seva on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVTetris.h"
#import "Box2D.h"
#import "SVTetrisBody.h"
#import "SVTetrisBlock.h"
#import "SvTetrisMonster.h"
void ContactListener::BeginContact(b2Contact * contact)
{
    const b2Fixture *fixA=contact->GetFixtureA();
    const b2Fixture *fixB=contact->GetFixtureB();
    if(fixA->IsSensor()||fixB->IsSensor())
    {
    const b2Body* bodyA = fixA->GetBody();
    const b2Body* bodyB = fixB->GetBody();
        SVTetrisBody *bA=(SVTetrisBody*) bodyA->GetUserData();
        SVTetrisBody *bB=(SVTetrisBody*) bodyB->GetUserData();
        if([bA canContact:bB])
        {
            [bA.passingBodies addObject:bB];
            [bB.passingBodies addObject:bA];
         
        }
    }
}
void ContactListener::EndContact(b2Contact * contact)
{
    
}
void ContactListener::PreSolve(b2Contact * contact, const b2Manifold *old )
{
    const b2Body* bodyA = contact->GetFixtureA()->GetBody();
    const b2Body* bodyB = contact->GetFixtureB()->GetBody();
    SVTetrisBody *bA=(SVTetrisBody*) bodyA->GetUserData();
    SVTetrisBody *bB=(SVTetrisBody*) bodyB->GetUserData();
   
    if(![bA canContact:bB]||![bB canContact:bA])
    {
        [bA.passingBodies addObject:bB];
        [bB.passingBodies addObject:bA];
        contact->SetEnabled(false); 
    }
    else
    {
        [bA addTouchingBody:bB];
        [bB addTouchingBody:bA];
    }
}
void ContactListener::PostSolve(b2Contact * contact, const b2ContactImpulse *impulse)
{
    const b2Body* bodyA = contact->GetFixtureA()->GetBody();
    const b2Body* bodyB = contact->GetFixtureB()->GetBody();
    SVTetrisBody *bA=(SVTetrisBody*) bodyA->GetUserData();
    SVTetrisBody *bB=(SVTetrisBody*) bodyB->GetUserData();
   // [bA applyImpulse:CGPointMake(impulse->tangentImpulses[0]+impulse->normalImpulses[0], impulse->tangentImpulses[1]+impulse->normalImpulses[1])];
   //    [bB applyImpulse:CGPointMake(-(impulse->tangentImpulses[0]+impulse->normalImpulses[0]),-( impulse->tangentImpulses[1]+impulse->normalImpulses[1]))];
}
float rndup(float up)
{
   return (((float)arc4random())/((float)ARC4RANDOM_MAX))*up; 
}
int generateRandomFromMatrix (float * matr,int n)
{
    float sm1=0;
    for(int i=0;i<n;i++)
        sm1+=matr[i];
    float rnd1=(((float)arc4random())/((float)ARC4RANDOM_MAX))*sm1;
    int mi=0;
    while(rnd1>matr[mi])
    {
        rnd1-=matr[mi];
        mi++;
    }
    return mi;
}
CGPoint dir[4]={{-1,0},{0,-1},{1,0},{0,1}};
NSString * dirNames[4]={@"Right",@"Down",@"Left",@"Up"};
@implementation TGrid
@synthesize world;
@synthesize gridrect;
@synthesize ERASE_TIME;
@synthesize manaGain;
@synthesize manaPool;
- (void) unfixFigureBlock:(SVTetrisBlock *)block
{
    for(int x=0;x<T_ROW;x++)
        for(int y=0;y<T_HEIGHT;y++)
        {
            if(bodyGrid[x][y]==block)
                bodyGrid[x][y]=nil;
        }
}
- (void) cleanGrid
{
    for(int x=0;x<T_ROW;x++)
        for(int y=0;y<T_HEIGHT;y++)
        {
            if(!bodyGrid[x][y].isinGrid)
                bodyGrid[x][y]=nil;
        }
}
- (void) fixBlock:(SVTetrisBlock *)bl AtX:(int)x Y:(int)y
{
    if(bodyGrid[x][y]!=nil)
    {
        NSLog(@"Wrong block position...");
        [bodyGrid[x][y] release];
        bodyGrid[x][y]=nil;
    }
    bodyGrid[x][y]=bl;
    BOOL fill=YES;
    for(int x=0;x<T_ROW;x++)
        if(bodyGrid[x][y]==nil){fill=NO;break;}
    if(fill)
        [self startRemovingLine:y];
}
- (void) startRemovingLine:(int)line
{
    for(int x=0;x<T_ROW;x++)
    {
        [bodyGrid[x][line] startErasingWithPulldown];
    }

        
}
- (void) getManaFromBlock:(SVTetrisBlock *)bl
{
     [manaPool addMana:bl.blocktype amount:[manaGain getMana:bl.blocktype]];
}
- (id) init
{
    if((self=[super init]))
    {
        double manpool[MANA_TYPES]={0.2,0.2,0.2,0.2,0.2,0.2};
        manaGain=[[SvManaPool alloc] initWithPool:manpool];
        manaPool=[[SvManaPool alloc] init];
        for(int x=0;x<T_ROW;x++)
            for(int y=0;y<T_HEIGHT;y++)
               bodyGrid[x][y]=nil;
    }
    return self;
}

-(void) dealloc
{
    [manaGain release];
    for(int x=0;x<T_ROW;x++)
        for(int y=0;y<T_HEIGHT;y++)
        {
            if(bodyGrid[x][y]!=nil)
            {
                [bodyGrid[x][y] destroyBody];
                [bodyGrid[x][y] release];
                bodyGrid[x][y]=nil;
            }
        }
    [super dealloc];
}
- (BOOL) isGridFilledatX:(int)x andY:(int)y
{
    if(x<0||x>=T_ROW||y<0||y>=T_HEIGHT) return YES;
    if(bodyGrid[x][y]!=nil) return YES;
    return NO;
}
- (void) Reset
{
    for(int x=0;x<T_ROW;x++)
        for(int y=0;y<T_HEIGHT;y++)
        {
            if(bodyGrid[x][y]!=nil)
            {
                [bodyGrid[x][y] destroyBody];
                [bodyGrid[x][y] release];
                bodyGrid[x][y]=nil;
            }
        
        }
}
- (void) dropDownFromBlock:(SVTetrisBlock *)bl
{
    if(![bl isErased]) return;
    for(int x=0;x<T_ROW;x++)
        for(int y=0;y<T_HEIGHT;y++)
        {
            if(bodyGrid[x][y]==bl)
            {
                for(int yy=y;yy>0;yy--)
                {
                   
                      
                        bodyGrid[x][yy]=bodyGrid[x][yy-1];
                        [bodyGrid[x][yy] updatePosition:CGPointMake(gridrect.origin.x+x*30, gridrect.origin.y+yy*30)];
                  
                }
            }
        }
}

@end
@implementation TFigure
@synthesize cx;
@synthesize cy;
@synthesize world;
@synthesize gridrect;
- (void) updateBodies
{
  
      for(int i=0;i<4;i++)
      {
          CGPoint pos=CGPointMake((cx+xs[i])*30+gridrect.origin.x+1, (cy+ys[i])*30+gridrect.origin.y+1);
          if(!bodies[i].isinFigure) bodies[i]=nil;
          if(bodies[i]==nil) continue;
          [bodies[i] updatePosition:pos];
      }
 
}
- (void) removeBodies
{
    for(int i=0;i<4;i++)
    {   
        bodies[i]=nil;
    }  
}
-  (void)setBlocks:(SVAnimatedSprite *)ib
{
    blocks=ib;
}
- (void) setGrid:(TGrid *)grd
{
    grid=grd;
}
- (void) createBodies
{
    for(int i=0;i<4;i++)
    {
        CGPoint pos=CGPointMake((cx+xs[i])*30+gridrect.origin.x+1, (cy+ys[i])*30+gridrect.origin.y+1);
     
        SVTetrisBlock * bd=[[SVTetrisBlock alloc] initWithType:types[i] free:NO inWorld:world withBlocks:blocks onGrid:grid atPos:pos];
        [bd setContactMode:1];
        bodies[i]=bd;
        [parent spawnBody:bodies[i]];
    }   
}
- (BOOL) isBodyInFigure:(SVTetrisBody *)body
{
    if(([body getContactMode]&1)==0)
        return NO;
    if([body isSensor])
        return NO;
    for(int i=0;i<4;i++)
    {
        if(!bodies[i].isinFigure) bodies[i]=nil;
        if(bodies[i]==nil) continue;
        if(bodies[i]==body)return NO;
    }
    for(int i=0;i<4;i++)
    {
        if(bodies[i]==nil) continue;
        if(bodies[i]==body)return NO;
        if([body isPresentonX:cx+xs[i] Y:cy+ys[i] withRect:gridrect])
            return YES;
    }
    return NO;
}
- (id) init
{
    float cm1[]={1,1,1,1,1,1,1};
    float cm2[]={1,1,1,1,1};
    return [self initWithProbabilityMatrix: cm1 andTypeProbability: cm2];
}
- (void) reduceToFallingBlocks
{
    
   // NSMutableArray * arr=[[NSMutableArray alloc] initWithCapacity:4];
    for(int i=0;i<4;i++)
    {
        if(!bodies[i].isinFigure) bodies[i]=nil;
        if(bodies[i]==nil) continue;
        
        [bodies[i] unfix];
        [bodies[i] applyDirectImpulse:CGPointMake(arc4random()%2000-1000,arc4random()%2000-1000)];
        bodies[i]=nil;
    } 
   
    isMissing=YES;
   // return [arr autorelease];
}
- (BOOL) isFigureMissing
{
    if(isMissing) return YES;
    for(int i=0;i<4;i++)
        if(bodies[i]!=nil&&bodies[i].isinFigure) return NO;
    return YES;
}
- (void) reInitWithProbabilityMatrix: (float *) matr andTypeProbability: (float *) typef
{
    isMissing=NO;
    int kind=generateRandomFromMatrix(matr,7);
    switch (kind)
    {
        case 0:{ //****
            xs[0]=-2;ys[0]=0;
            xs[1]=-1;ys[1]=0;
            xs[2]=0;ys[2]=0;
            xs[3]=1;ys[3]=0;
        }; break;
        case 1:{ //*
            //***
            xs[0]=-1;ys[0]=-1;
            xs[1]=-1;ys[1]=0;
            xs[2]=0;ys[2]=0;
            xs[3]=1;ys[3]=0;
        }; break;
        case 2:{ //   *
            // ***
            xs[0]=-1;ys[0]=0;
            xs[1]=0;ys[1]=0;
            xs[2]=1;ys[2]=0;
            xs[3]=1;ys[3]=-1;
        }; break;
        case 3:{ //**
            //**
            xs[0]=-1;ys[0]=-1;
            xs[1]=-1;ys[1]=0;
            xs[2]=0;ys[2]=0;
            xs[3]=0;ys[3]=-1;
        }; break;
        case 4:{ // **
            //**
            xs[0]=-1;ys[0]=0;
            xs[1]=0;ys[1]=0;
            xs[2]=0;ys[2]=-1;
            xs[3]=1;ys[3]=-1;
        }; break;
        case 5:{ //**
            // **
            xs[0]=-1;ys[0]=-1;
            xs[1]=0;ys[1]=-1;
            xs[2]=0;ys[2]=0;
            xs[3]=1;ys[3]=0;
        }; break;
        case 6:{ // *
            //***
            xs[0]=-1;ys[0]=0;
            xs[1]=0;ys[1]=0;
            xs[2]=0;ys[2]=-1;
            xs[3]=1;ys[3]=0;
        }; break;
    };
    for(int i=0;i<4;i++)
        types[i]=generateRandomFromMatrix(typef, MANA_TYPES);
    max_frame=MANA_TYPES;  
}
- (id) initWithProbabilityMatrix:(float *)matr andTypeProbability:(float *)typef
{
    if((self=[super init]))
    {
        [self reInitWithProbabilityMatrix:matr andTypeProbability:typef];
    }
    return self;
}
- (void) RotateLeft
{
    int nxs[4]={ys[0],ys[1],ys[2],ys[3]};
    int nys[4]={-xs[0],-xs[1],-xs[2],-xs[3]};
    for(int i=0;i<4;i++)
    {
        xs[i]=nxs[i];
        ys[i]=nys[i];
    }
}
- (void) RotateRight
{
    int nxs[4]={-ys[0],-ys[1],-ys[2],-ys[3]};
    int nys[4]={xs[0],xs[1],xs[2],xs[3]};
    for(int i=0;i<4;i++)
    {
        xs[i]=nxs[i];
        ys[i]=nys[i];
    }
}
- (BOOL) isPresentonX:(int)x Y:(int)y
{
    for(int i=0;i<4;i++)
    {
        if(!bodies[i].isinFigure) bodies[i]=nil;
        if(bodies[i]==nil) continue;
        if(cx+xs[i]==x&&cy+ys[i]==y) return YES;
    }
    return NO;
}
- (void) Draw:(SVAnimatedSprite *)blocks inRect:(CGRect)inside
{
  /*  for(int i=0;i<4;i++)
    {
        float tx=inside.origin.x+30*(cx+xs[i]);
        float ty=inside.origin.y+30*(cy+ys[i]);
        blocks.virt_frame=CGSizeMake(30, 30);
        blocks.ul_position=CGPointMake(tx, ty);
        [blocks setFrame:types[i]];
        [blocks Draw];
    }*/
}
- (BOOL) FitsOnGrid
{
    for(int i=0;i<4;i++)
    {
        if(!bodies[i].isinFigure) bodies[i]=nil;
        if(bodies[i]==nil) continue;
        if([grid isGridFilledatX:cx+xs[i] andY:cy+ys[i]])
            return NO;
    }
    return YES;
}
- (void) fixOnGrid
{
    if(![self FitsOnGrid]) return;
    for(int i=0;i<4;i++)
    {
        if(!bodies[i].isinFigure) bodies[i]=nil;
        if(bodies[i]==nil) continue;
        [bodies[i] moveToGridatX:cx+xs[i] andY:cy+ys[i]];
        [bodies[i] fixAtX:cx+xs[i] andY:cy+ys[i]];
      //  [grid  fixBlockAtX:cx+xs[i] Y:cy+ys[i] withType:types[i]];
    }
}
- (void) setParent:(SVScene *)iparent
{
    parent=iparent;
}
@end

@implementation SVTetris
-(id) initWithParent:(OpenGLView *)par andBackdrop:(NSString *)backdr
{
    if((self=[super initWithParent:par]))
    {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Data" ofType:@"plist"];
        
        NSDictionary *rd=[NSDictionary dictionaryWithContentsOfFile:path];
        self.sceneDictionary=rd;
        NSDictionary * dsprites=[rd valueForKey:@"Sprites"];
        NSArray * sprn=[NSArray arrayWithObjects:@"Backdrop1",@"Monster",@"Blocks",@"Ice", nil];
        [[SvSharedSpriteCache SharedCache] createAndLoadSprites:sprn usingDictionary:dsprites intoView:parent];
        
       /* SVTexture* tex=[parent createTextureNamed:@"Tetris"];
        [tex startCreatingTexturewithWidth:1024 andHeight:1024];
        UIImage *im=[UIImage imageNamed:backdr];
        [tex drawImageOnTexture:im fromrect:CGRectMake(0,0,im.size.width,im.size.height) withrect:CGRectMake(0,0,im.size.width,im.size.height)];
        UIImage * blocks=[UIImage imageNamed:@"blocks.bmp"];
        [tex drawImageOnTexture:blocks fromrect:CGRectMake(0,0,blocks.size.width,blocks.size.height) withrect:CGRectMake(0,im.size.height,blocks.size.width,blocks.size.height)];
        UIImage * mns=[UIImage imageNamed:@"good.png"];
        [tex drawImageOnTexture:mns fromrect:CGRectMake(0,0,mns.size.width,mns.size.height) withrect:CGRectMake(0,im.size.height+blocks.size.height,mns.size.width,mns.size.height)];
        
        [tex finishTextureCreation];*/
        backdrop=[[SvSharedSpriteCache SharedCache]getSpriteWithName:@"Backdrop1"];//[[parent getSpriteWithTexture:@"Tetris" andFrame:CGRectMake(0,0,im.size.width,im.size.height)] retain];
        backdrop.layoutPos=-1;
        backdrop.center_position=CGPointMake(400, 300);
        _blocks=[[SvSharedSpriteCache SharedCache] getAnimatedSpriteWithName:@"Blocks"];
        /*[[parent getAnimatedSpriteWithTexture:@"Tetris" andFrames:[NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(0, im.size.height, 30, 30)], 
            [NSValue valueWithCGRect:CGRectMake(30, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(60, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(90, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(120, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(150, im.size.height, 30, 30)], nil]] retain];*/
 
        Grid=[[TGrid alloc] init];
        cFigure=[[TFigure alloc] init];
        [cFigure setGrid:Grid];
        [cFigure setParent:self];
        [cFigure setBlocks:_blocks];
        cFigure.cx=5;
        cFigure.cy=1;
    
        step=0.8;
        currentTime=0;
        fullTime=0;
        if(movingBodies!=nil){[movingBodies release]; movingBodies=nil;}
        movingBodies=[[NSMutableArray alloc] init];
      //  CGSize screenSize = parent.bounds.size;
        
        // Define the gravity vector.
        gridrect=CGRectMake(250, 0,300, 570);
            cFigure.gridrect=gridrect;
        b2Vec2 gravity;
      gravity.Set(0.0f, 9.81f);
        
       // gravity.Set(0.0f, 0.0f);
        
        // Do we want to let bodies sleep?
        // This will speed up the physics simulation
        bool doSleep = true;
        crushableTypes=[[NSSet alloc]initWithObjects:@"Monster",@"Player",@"Enemy", nil];
        // Construct a world object, which will hold and simulate the rigid bodies.
        world = new b2World(gravity, doSleep);
        
        world->SetContinuousPhysics(true);
        world->SetContactListener(&cl);
        Grid.world=world;
        b2Template def;
        def.type=b2_staticBody;
        def.density=0;
        def.restitution=0.2;
        def.friction=0.1;
        def.isSensor=NO;
        SVTetrisBody * nb=[[SVTetrisBody alloc] initWithRect:CGRectMake(gridrect.origin.x-100, gridrect.origin.y+gridrect.size.height, gridrect.size.width+200.f, 20.f) andTemplate:def inWorld:world withName:@"Lower wall" andType:@"Wall"];
                           walls[0]=nb;
        nb=[[SVTetrisBody alloc] initWithRect:CGRectMake(gridrect.origin.x-100, gridrect.origin.y-30, gridrect.size.width+200.f, 30.f) andTemplate:def inWorld:world withName:@"Upper wall" andType:@"Wall"];
        walls[1]=nb;
        nb=[[SVTetrisBody alloc] initWithRect:CGRectMake(gridrect.origin.x-100, gridrect.origin.y-30, 100.f, gridrect.size.height+60.f) andTemplate:def inWorld:world withName:@"Left wall" andType:@"Wall"];
        walls[2]=nb;
        nb=[[SVTetrisBody alloc] initWithRect:CGRectMake(gridrect.origin.x+gridrect.size.width, gridrect.origin.y-30, 100.f, gridrect.size.height+60.f) andTemplate:def inWorld:world withName:@"Right wall" andType:@"Wall"];
        walls[3]=nb;
        cFigure.world=world;
        Grid.gridrect=gridrect;
        [cFigure createBodies];
        sDisp=[[NSMutableArray alloc] init];
        sDispVals=[[NSMutableArray alloc] init ];
        Grid.ERASE_TIME=1.0;
        manaPool=[[SvManaPool alloc] init];
        [parent createTextureNamed:@"Text"];
        SVTexture *textex=[parent getTextureNamed:@"Text"];
        [textex startCreatingTexturewithWidth:256 andHeight:256];
           [textex finishTextureCreation];
        text=[[parent getSpriteWithTexture:@"Text" andFrame:CGRectMake(0, 0, 256,256)] retain];
        /*
         Sensor"] boolValue];
         Restitution"] floatValue];
         Density"] floatValue];
         Friction"] floatValue];
         Rect"];
         World"] pointerValue] 
         Name"] andType:@"Monster"]))
         Sprite"]
         
         */
       // float gh=im.size.height+blocks.size.height;
        SVAnimatedSprite *msprite=[[SvSharedSpriteCache SharedCache] getAnimatedSpriteWithName:@"Monster"];
        /*[parent getAnimatedSpriteWithTexture:@"Tetris" andFrames:[NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(0, gh, 30, 30)],                                                                                              [NSValue valueWithCGRect:CGRectMake(30,gh, 30, 30)],                                                                                             [NSValue valueWithCGRect:CGRectMake(60, gh, 30, 30)],                                                                                             [NSValue valueWithCGRect:CGRectMake(90, gh, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(120, gh, 30, 30)], 
            [NSValue valueWithCGRect:CGRectMake(150, gh, 30, 30)], 
            [NSValue valueWithCGRect:CGRectMake(180, gh, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(210, gh, 30, 30)], nil]] ;*/
        
        NSMutableDictionary *mdic=[[NSMutableDictionary alloc] initWithCapacity:8];
        [mdic setValue:[NSNumber numberWithBool:NO] forKey:@"Sensor"];
         [mdic setValue:[NSNumber numberWithFloat:0.2] forKey:@"Restitution"];
        [mdic setValue:[NSNumber numberWithFloat:1] forKey:@"Density"];
        [mdic setValue:[NSNumber numberWithFloat:0.5] forKey:@"Friction"];
        NSArray * arrd=[[NSArray alloc] initWithObjects:[NSNumber numberWithFloat:gridrect.origin.x+21],[NSNumber numberWithFloat:500],[NSNumber numberWithFloat:28],[NSNumber numberWithFloat:30], nil];
        [mdic setObject:arrd forKey:@"Rect"];
        [mdic setObject:[NSValue valueWithPointer:world] forKey:@"World"];
        [mdic setValue:@"Test" forKey:@"Name"];
        [mdic setObject:msprite forKey:@"Sprite"];
     
        NSDictionary *adi=[rd valueForKey:@"Abilities"];
        SvAbility * abil=[[SvAbility alloc]initWithDictionary:[adi valueForKey:@"Walk"]];
         SvAbility * abil1=[[SvAbility alloc]initWithDictionary:[adi valueForKey:@"Icebolt"]];
        NSArray * tmpa=[[NSArray alloc ]initWithObjects:abil,abil1, nil];//abil,
        [mdic setObject:tmpa forKey:@"Abilities"];
        [abil release];
        [abil1 release];
        [tmpa release];
       // [rd release];
        SvTetrisMonster * mnst=[[SvTetrisMonster alloc] initWithDictionary:mdic];
        [self spawnBody:mnst];
        
        [mnst release];
      
        [arrd release];
        [mdic release];
       // [self AddSprite:_blocks];
    }
    
    return self;
}
- (void *) getPointerParameter:(NSString *)pname
{
    if([pname isEqualToString:@"World"])
        return world;
    return NULL;
}
- (void) step
{
    if([cFigure isFigureMissing])
    {
        float cm1[]={1,1,1,1,1,1,1};
        float cm2[]={1,1,1,1,1};
        [cFigure reInitWithProbabilityMatrix:cm1 andTypeProbability:cm2];
        cFigure.cx=5;
        cFigure.cy=1;  
        if([self attemptPlacingFigure])
        {
            [cFigure createBodies];
        }
        else
        {
            [Grid Reset];
            [cFigure createBodies];
        }

    }
    
    if(![self attemptMovingFigureDown])
    {
       
        [cFigure fixOnGrid];
         [cFigure removeBodies];
    float cm1[]={1,1,1,1,1,1,1};
    float cm2[]={1,1,1,1,1};
        [cFigure reInitWithProbabilityMatrix:cm1 andTypeProbability:cm2];
    cFigure.cx=5;
    cFigure.cy=1;  
        if([self attemptPlacingFigure])
        {
            [cFigure createBodies];
            isDragging=false;
        }
        else
        {
            [Grid Reset];
            [cFigure createBodies];
        }
    }
}
- (BOOL) attemptPlacingFigure
{
    if(![cFigure FitsOnGrid])//simplest case
    { return NO;}
    for(SVTetrisBody * body in movingBodies)
    {
        if([cFigure isBodyInFigure:body])
        {
            for(int k=1;k<4;k++)
            { 
            CGPoint pos=[body getPosition];
            pos.y=(floorf(pos.y/30)+k)*30;
            if([self tryMovingBody:body ToPosition:pos])
            {
                [sDisp removeAllObjects];
                [sDispVals removeAllObjects];
                return YES;
            }
                
            }
            return NO;
        }
    }   
    [cFigure updateBodies];
    return YES;
 
}
- (BOOL) attemptMovingFigureDown
{
    cFigure.cy++;
    if(![cFigure FitsOnGrid])//simplest case
    {cFigure.cy--; return NO;}
    for(SVTetrisBody * body in movingBodies)
    {
        if([cFigure isBodyInFigure:body])
        {
            CGPoint pos=[body getPosition];
            pos.y=(floorf(pos.y/30)+1)*30+1;
            if(![self tryMovingBody:body ToPosition:pos])
            {
                cFigure.cy--;
                return NO;
            }
            else
            {
                [sDisp removeAllObjects];
                [sDispVals removeAllObjects];
            }
        }
    }   
    [cFigure updateBodies];
    return YES;
}
- (BOOL) attemptMovingFigureRight
{
    cFigure.cx++;
    if(![cFigure FitsOnGrid])//simplest case
    {cFigure.cx--; return NO;}
    for(SVTetrisBody * body in movingBodies)
    {
        if([cFigure isBodyInFigure:body])
        {
            CGPoint pos=[body getPosition];
            pos.x=gridrect.origin.x+ (floorf((pos.x-gridrect.origin.x)/30)+1)*30+1;
            if(![self tryMovingBody:body ToPosition:pos])
            {
                cFigure.cx--;
                return NO;
            }
            else
            {
            [sDisp removeAllObjects];
            [sDispVals removeAllObjects];
            }
        }
    }
       [cFigure updateBodies];
    return YES;
}
- (BOOL) attemptMovingFigureLeft
{
    cFigure.cx--;
    if(![cFigure FitsOnGrid])//simplest case
    {cFigure.cx++; return NO;}
    for(SVTetrisBody * body in movingBodies)
    {
        if([cFigure isBodyInFigure:body])
        {
            CGRect box=[body getBoundingBox];
            CGPoint pos=box.origin;
            pos.x=gridrect.origin.x+(floorf((pos.x+box.size.width-gridrect.origin.x)/30.0)-1)*30-box.size.width+1;
            if(![self tryMovingBody:body ToPosition:pos])
            {
                cFigure.cx++;
                return NO;
            }
            else
            {
                [sDisp removeAllObjects];
                [sDispVals removeAllObjects];
            }
        }
    }
    [cFigure updateBodies];
    return YES;
}
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint pt=[[touches  anyObject]locationInView:parent];
    pt=[parent transformPointToInnerResolution:pt];
    if(CGRectContainsPoint(gridrect, pt))
    {
        int ptx=(pt.x-gridrect.origin.x)/30;
        int pty=(pt.y-gridrect.origin.y)/30;
        if([cFigure isPresentonX:ptx Y:pty])
        {
        currentTouch=pt;
            newTouch=pt;
        isDragging=YES;
        }
    }
    else
    {
        if(pt.x>gridrect.origin.x)
        {
        [cFigure RotateLeft];
        if(![self attemptPlacingFigure])
            [cFigure RotateRight];
        }
        else
            reduce=YES;
    }
}
- (BOOL) crushBody:(SVTetrisBody *)body
{
    NSDictionary * crush=[[NSDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithBool:YES], @"Crush",nil];
    [body Apply:crush];
    [crush release];
    NSDictionary * ret=[body getStatus];
    
    if(ret!=nil)
    {
        NSNumber * val=[ret valueForKey:@"Crushed"];
        if(val!=nil)
            return [val boolValue];
    }
    
    return NO;
}
- (BOOL) tryMovingBody:(SVTetrisBody *)body ToPosition:(CGPoint)position
{
    CGPoint curPos=[body getPosition];
    [body updatePosition:position];
    CGRect bounds=[body getBoundingBox];
    if(bounds.origin.x<gridrect.origin.x||bounds.origin.y<gridrect.origin.y||
       bounds.origin.x+bounds.size.width>gridrect.origin.x+gridrect.size.width||
       bounds.origin.y+bounds.size.height>gridrect.origin.y+gridrect.size.height)
    {
        //out of bounds
        [body updatePosition:curPos];
        if([crushableTypes containsObject:[body getType]])
            return [self crushBody:body];
        else
            return NO;
    }
    int sx=floorf((bounds.origin.x-gridrect.origin.x)/30.0);
    int sy=floorf((bounds.origin.y-gridrect.origin.y)/30.0);
    int lx=ceilf((bounds.origin.x+bounds.size.width-gridrect.origin.x)/30.0);
    int ly=ceilf((bounds.origin.y+bounds.size.height-gridrect.origin.y)/30.0);
    for(int x=sx;x<lx;x++)//grid collision
        for(int y=sy;y<ly;y++)
        {
            if([Grid isGridFilledatX:x andY:y])
            {
                [body updatePosition:curPos];
                if([crushableTypes containsObject:[body getType]])
                    return [self crushBody:body];
                else
                    return NO; 
            }
        }
    // body to body collision...hmmm
    dispResult=YES;
    QueryCallbackDisplace disp;
    CGPoint shift=CGPointMake((position.x-curPos.x)/PTM_RATIO, (position.y-curPos.y)/PTM_RATIO);
    b2AABB aabb=[body getAABB];
    disp.setInvokation(self, @selector(attemptDisplacingBody:byVector:), shift,aabb,body);
    world->QueryAABB(&disp,aabb);
    if(dispResult==NO)
    {
        [body updatePosition:curPos];
        return NO;
    }
    return YES;
}
- (BOOL) attemptDisplacingBody:(SVTetrisBody *)body byVector:(CGPoint)disp
{
    CGPoint pos=[body getPosition];
    CGPoint newpos=CGPointMake(pos.x+disp.x*PTM_RATIO, pos.y+disp.y*PTM_RATIO);
    if(![self tryMovingBody:body ToPosition:newpos])
    {
        dispResult=NO;
        for(int i=0;i<[sDisp count];i++)
        {
            SVTetrisBody* body=[sDisp objectAtIndex:i];
            CGPoint tp=[[sDispVals objectAtIndex:i] CGPointValue];
            [body updatePosition:tp];
        }
        [sDisp removeAllObjects];
        [sDispVals removeAllObjects];
        return NO;
    }
    else
    {
        [sDisp addObject:body];
        [sDispVals addObject:[NSValue valueWithCGPoint:pos]];
        return YES;
    }
    return YES;
    
}
-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isDragging=NO;
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isDragging=NO;
}
- (void) updateFigurePosition
{
    if(isDragging)
    {
    while(newTouch.x-currentTouch.x>30)
    {
        currentTouch.x+=30;
        [self attemptMovingFigureRight];
    }
    while(currentTouch.x-newTouch.x>30)
    {
        currentTouch.x-=30;
        [self attemptMovingFigureLeft];
    }
    while(newTouch.y-currentTouch.y>30)
    {
        currentTouch.y+=30;
        [self attemptMovingFigureDown];
    } 
    }
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
if(isDragging)
{
    CGPoint pt=[[touches  anyObject]locationInView:parent];
    pt=[parent transformPointToInnerResolution:pt];
    newTouch=pt;
 
}
}
- (void) Render
{
    //////
    [Grid.manaPool DrainIntoPool:manaPool];

    /////////////
    [backdrop Draw];
    if(currentTime!=0)
    {
    elapsedTime=[NSDate timeIntervalSinceReferenceDate]-currentTime;
        for(SVTetrisBody * body in movingBodies)
        {
            [body.touchingBodies removeAllObjects];
            [body.passingBodies removeAllObjects];
        }
        world->Step(elapsedTime, 15, 8);
      //  world->ClearForces();
        for(SVTetrisBody * body in movingBodies)
            [body Update:elapsedTime];
        [self updateFigurePosition];
        fullTime+=elapsedTime;
    currentTime=[NSDate timeIntervalSinceReferenceDate];
        while(fullTime>step)
        {
            fullTime-=step;
            [self step];
        }
            [self cleanupBodies];
       // [cFigure updateBodies];
          for(SVTetrisBody * body in movingBodies)
        {
            [body Draw];
         
        }
           
        if(reduce)
        {
            if([self attemptPlacingFigure]&&![cFigure isFigureMissing])
            {
            [cFigure reduceToFallingBlocks];
           
            }
        }
    }
    else
       currentTime=[NSDate timeIntervalSinceReferenceDate]; 
    

    [text renderText:
     [NSString  stringWithFormat:@"SUN: %d\rMNT: %d\rFRS: %d\rSEA: %d\rSWP: %d\rSPR: %d",
      (int)[manaPool getMana:0],
      (int)[manaPool getMana:1],
      (int)[manaPool getMana:2],
      (int)[manaPool getMana:3],
      (int)[manaPool getMana:4],
      (int)[manaPool getMana:5]
      ] withFont:[UIFont fontWithName:@"Arial" size:18] intoBox:CGRectMake(0, 0, 110, 130) withColor:RGBAColorMake(0.9f, 1.0f, 0.9f, 1.0f) andlineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
    text.layoutPos=1;
    text.virt_frame=CGSizeMake(110, 130);
    text.ul_position=CGPointMake(620, 30);
    [text Draw];
    reduce=NO;
   }
- (void) clearDisplacement
{
    [sDisp removeAllObjects];
    [sDispVals removeAllObjects];
}
- (void) spawnBody:(SVTetrisBody *)body
{
    [body setParentScene:self];
    if([movingBodies containsObject:body]) return;
    [movingBodies addObject:body];
}
- (void) cleanupBodies
{
    [Grid cleanGrid];
    NSMutableArray * rem=[NSMutableArray new];
    for(SVTetrisBody * tdb in movingBodies)
    {
        if(![tdb isAlive])
        {
            [rem addObject:tdb];
        }
    }
    [movingBodies removeObjectsInArray:rem];
    for(SVTetrisBody * body in rem)
    {
        [body release];
    }
    [rem release];
}
- (void)dealloc
{
    [text release];
    [manaPool release];
    [sDispVals release];
    [sDisp release];
    [crushableTypes release];
    for(int i=0;i<4;i++)
        [walls[i] release];
    [movingBodies release];
    movingBodies=nil;
    delete world;
    [cFigure release];
    [Grid release];
    [_blocks release];
    [super dealloc];
}
@end
