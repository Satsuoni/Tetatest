//
//  SVTetris.m
//  Tetatest
//
//  Created by Seva on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVTetris.h"
#import "Box2D.h"

#define ARC4RANDOM_MAX      4294967296.0f
#define PTM_RATIO 16
#define ERASE_TIME 1.0
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
@implementation TGrid

- (id) init
{
    if((self=[super init]))
    {
        for(int x=0;x<T_ROW;x++)
            for(int y=0;y<T_HEIGHT;y++)
                Grid[x][y]=-1;
    }
    return self;
}
- (BOOL) isGridFilledatX:(int)x andY:(int)y
{
    if(x<0||x>=T_ROW||y<0||y>=T_HEIGHT) return YES;
    if(Grid[x][y]!=-1) return YES;
    return NO;
}
-(void) Draw:(SVAnimatedSprite *)blocks inRect:(CGRect)inside
{
    blocks.virt_frame=CGSizeMake(30, 30);
    NSTimeInterval now=[NSDate timeIntervalSinceReferenceDate];
        for(int y=0;y<T_HEIGHT;y++)
        {
            if(erasing[y])
            {
                double tm=now-erasetime[y];
                if(tm>ERASE_TIME)//erase complete...
                {
                    for(int yy=y;yy>0;yy--)
                    {
                        for(int xx=0;xx<T_ROW;xx++)
                            Grid[xx][yy]=Grid[xx][yy-1];
                        erasing[yy]=erasing[yy-1];
                        erasetime[yy]=erasetime[yy-1];
                    }
                    for(int xx=0;xx<T_ROW;xx++)
                        Grid[xx][0]=-1;
                    erasing[0]=NO;
                    y--;
                    continue;
                }
                else
                {
                    blocks.effect=2;
                    double cf=tm/ERASE_TIME;
                    [blocks setEffectParameter:1 toValue:5];
                    
                    [blocks  setEColorR:1 G:1 B:cf A:cf+0.2 N:0];
                    [blocks  setEColorR:1 G:0 B:0 A:1 N:1]; 
                }
            }
               for(int x=0;x<T_ROW;x++)
               {
            if(Grid[x][y]!=-1)
                {
            float tx=inside.origin.x+x*30;
            float ty=inside.origin.y+y*30;
            blocks.ul_position=CGPointMake(tx, ty);
              //  blocks.effect=2;
              // [blocks setEffectParameter:1 toValue:2.5];
                
             //   [blocks  setEColorR:1 G:1 B:0.3 A:0.7 N:0];
              //  [blocks  setEColorR:1 G:0 B:0 A:1 N:1];
                [blocks setFrame:Grid[x][y]];
                [blocks Draw];
             //   blocks.effect=0;
                 }
          
              }
              blocks.effect=0;
        }
}
-(void) fixBlockAtX:(int)x Y:(int)y withType:(int)type
{
    Grid[x][y]=type;
    BOOL filled_row=YES;
    for(int xx=0;xx<T_ROW;xx++)
    {
       if(Grid[xx][y]==-1)
       {
           filled_row=NO;
           break;
       }
    }
    if(filled_row)
    {
        erasing[y]=YES;
        erasetime[y]=[NSDate timeIntervalSinceReferenceDate];
    }
}
@end
@implementation TFigure
@synthesize cx;
@synthesize cy;
- (id) init
{
    float cm1[]={1,1,1,1,1,1,1};
    float cm2[]={1,1,1,1,1};
    return [self initWithProbabilityMatrix: cm1 andTypeProbability: cm2];
}
- (void) reInitWithProbabilityMatrix: (float *) matr andTypeProbability: (float *) typef
{
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
        types[i]=generateRandomFromMatrix(typef, 5);
    max_frame=5;  
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
        if(cx+xs[i]==x&&cy+ys[i]==y) return YES;
    }
    return NO;
}
- (void) Draw:(SVAnimatedSprite *)blocks inRect:(CGRect)inside
{
    for(int i=0;i<4;i++)
    {
        float tx=inside.origin.x+30*(cx+xs[i]);
        float ty=inside.origin.y+30*(cy+ys[i]);
        blocks.virt_frame=CGSizeMake(30, 30);
        blocks.ul_position=CGPointMake(tx, ty);
        [blocks setFrame:types[i]];
        [blocks Draw];
    }
}
- (BOOL) FitsOnGrid:(TGrid *)grid
{
    for(int i=0;i<4;i++)
    {
        if([grid isGridFilledatX:cx+xs[i] andY:cy+ys[i]])
            return NO;
    }
    return YES;
}
- (void) fixOnGrid:(TGrid *)grid
{
    if(![self FitsOnGrid:grid]) return;
    for(int i=0;i<4;i++)
    {
        [grid  fixBlockAtX:cx+xs[i] Y:cy+ys[i] withType:types[i]];
    }
}
@end

@implementation SVTetris
-(id) initWithParent:(OpenGLView *)par andBackdrop:(NSString *)backdr
{
    if((self=[super initWithParent:par]))
    {
        SVTexture* tex=[parent createTextureNamed:@"Tetris"];
        [tex startCreatingTexturewithWidth:1024 andHeight:1024];
        UIImage *im=[UIImage imageNamed:backdr];
        [tex drawImageOnTexture:im fromrect:CGRectMake(0,0,im.size.width,im.size.height) withrect:CGRectMake(0,0,im.size.width,im.size.height)];
        UIImage * blocks=[UIImage imageNamed:@"blocks.bmp"];
        [tex drawImageOnTexture:blocks fromrect:CGRectMake(0,0,blocks.size.width,blocks.size.height) withrect:CGRectMake(0,im.size.height,blocks.size.width,blocks.size.height)];
        [tex finishTextureCreation];
        backdrop=[[parent getSpriteWithTexture:@"Tetris" andFrame:CGRectMake(0,0,im.size.width,im.size.height)] retain];
        backdrop.layoutPos=-1;
        backdrop.center_position=CGPointMake(400, 300);
        _blocks=[[parent getAnimatedSpriteWithTexture:@"Tetris" andFrames:[NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(0, im.size.height, 30, 30)], 
            [NSValue valueWithCGRect:CGRectMake(30, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(60, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(90, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(120, im.size.height, 30, 30)],nil]] retain];
        Grid=[[TGrid alloc] init];
        cFigure=[[TFigure alloc] init];
        cFigure.cx=5;
        cFigure.cy=1;
        step=0.5;
        currentTime=0;
        fullTime=0;
      //  CGSize screenSize = parent.bounds.size;
        
        // Define the gravity vector.
        gridrect=CGRectMake(250, 0,300, 570);
        b2Vec2 gravity;
        gravity.Set(0.0f, -9.81f);
        
        // Do we want to let bodies sleep?
        // This will speed up the physics simulation
        bool doSleep = true;
        
        // Construct a world object, which will hold and simulate the rigid bodies.
        world = new b2World(gravity, doSleep);
        
        world->SetContinuousPhysics(true);
       // [self AddSprite:_blocks];
    }
    
    return self;
}
- (void) step
{
    cFigure.cy=cFigure.cy+1;
    //[cFigure RotateLeft];
    if(![cFigure FitsOnGrid:Grid])
    {
       // [cFigure RotateRight];
        
        cFigure.cy--;
        [cFigure fixOnGrid:Grid];
        
    float cm1[]={1,1,1,1,1,1,1};
    float cm2[]={1,1,1,1,1};
        [cFigure reInitWithProbabilityMatrix:cm1 andTypeProbability:cm2];
    cFigure.cx=5;
    cFigure.cy=1;  
    }
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
        isDragging=YES;
        }
    }
    else
    {
        [cFigure RotateLeft];
        if(![cFigure FitsOnGrid:Grid])
            [cFigure RotateRight];
    }
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    isDragging=NO;
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    isDragging=NO;
}
-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
if(isDragging)
{
    CGPoint pt=[[touches  anyObject]locationInView:parent];
    pt=[parent transformPointToInnerResolution:pt];
 while(pt.x-currentTouch.x>30)
 {
     currentTouch.x+=30;
     cFigure.cx++;
     if(![cFigure FitsOnGrid:Grid])
         cFigure.cx--;
 }
    while(currentTouch.x-pt.x>30)
    {
        currentTouch.x-=30;
        cFigure.cx--;
        if(![cFigure FitsOnGrid:Grid])
            cFigure.cx++;
    }
    while(pt.y-currentTouch.y>30)
    {
        currentTouch.y+=30;
        cFigure.cy++;
        if(![cFigure FitsOnGrid:Grid])
            cFigure.cy--;
    }
}
}
- (void) Render
{
    if(currentTime!=0)
    {
    elapsedTime=[NSDate timeIntervalSinceReferenceDate]-currentTime;
        fullTime+=elapsedTime;
    currentTime=[NSDate timeIntervalSinceReferenceDate];
        while(fullTime>step)
        {
            fullTime-=step;
            [self step];
        }
    }
    else
       currentTime=[NSDate timeIntervalSinceReferenceDate]; 
    [backdrop Draw];
    [Grid Draw:_blocks inRect:gridrect];
    [cFigure Draw:_blocks inRect:gridrect];
}
- (void)dealloc
{
    delete world;
    [cFigure release];
    [Grid release];
    [_blocks release];
    [super dealloc];
}
@end
