//
//  SVTetris.h
//  Tetatest
//
//  Created by Seva on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVScene.h"
#import "OpenGLView.h"
#import "Box2D.h"
#import "SVTetrisBody.h"
#import "SvManaPool.h"
#define ARC4RANDOM_MAX      4294967296.0f
#define PTM_RATIO 16

#define T_ROW 10
#define T_HEIGHT 19
#define ERASE_INTERVAL 0.2
class ContactListener : public b2ContactListener
{
public:
    
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};
extern float rndup(float);
class QueryCallbackDisplace : public b2QueryCallback
{
public:
    NSInvocation * invokation;
    CGPoint disp;
    b2AABB aabb;
    SVTetrisBody * bdy;
    QueryCallbackDisplace(){invokation=nil;};
    void setInvokation(NSObject * target, SEL selector, CGPoint displacement,b2AABB ab, SVTetrisBody * body)
    {
       invokation=[[NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]] retain];
        [invokation setTarget:target];
        [invokation setSelector:selector];
        disp=displacement;
        aabb=ab;
        bdy=body;
    };
    virtual ~QueryCallbackDisplace() {[invokation release];
        invokation=nil;
                               };
    
	/// Called for each fixture found in the query AABB.
	/// @return false to terminate the query.
	virtual bool ReportFixture(b2Fixture* fixture)
    {
        b2Body *b=fixture->GetBody();
        if(b->GetType()!=b2_dynamicBody) return true;
        SVTetrisBody * ud=(SVTetrisBody *)b->GetUserData();
        if(ud==bdy) return true;
        b2AABB nw=[ud getAABB];
        b2AABB intr=aabb;
        intr.Intersect(nw);
        if(!intr.IsValid()) return true;
        CGPoint ndisp=disp;
        if(disp.x>0)// upperbound nw.x and lowerbound aabb.x 
        {
            if(aabb.upperBound.x>nw.lowerBound.x)
                ndisp.x=(aabb.upperBound.x-nw.lowerBound.x)+0.01;
            else
                ndisp.x=0;
            ndisp.y=0;
        }
        if(disp.x<0)// upperbound nw.x and lowerbound aabb.x 
        {
            if(aabb.lowerBound.x<nw.upperBound.x)
                ndisp.x=(aabb.lowerBound.x-nw.upperBound.x)-0.01;
            else
                ndisp.x=0;
            ndisp.y=0;
        }
        if(disp.y>0)// upperbound nw.x and lowerbound aabb.x 
        {
            if(aabb.upperBound.y>nw.lowerBound.y)
                ndisp.y=(aabb.upperBound.y-nw.lowerBound.y)+0.01;
            else
                ndisp.y=0;
            ndisp.x=0;
        }
        if(disp.y<0)// upperbound nw.x and lowerbound aabb.x 
        {
            if(aabb.lowerBound.y<nw.upperBound.x)
                ndisp.y=(aabb.lowerBound.y-nw.upperBound.y)-0.01;
            else
                ndisp.y=0;
            ndisp.x=0;
        }
        if(ndisp.x==0&&ndisp.y==0)
            return true;
        [invokation setArgument:&ud atIndex:2];
         [invokation setArgument:&ndisp atIndex:3];
        [invokation invoke];
        BOOL retval;
        [invokation getReturnValue:&retval];
        if(retval)
        return true;
        else
            return false;
    };  
};



@interface TGrid : NSObject {
@private
    int Grid[T_ROW][T_HEIGHT];
    BOOL erasing[T_HEIGHT];
    double erasetime[T_HEIGHT];
    double erasectime[T_HEIGHT];
    NSTimeInterval prevtime;
    SVTetrisBody * bodyGrid[T_ROW][T_HEIGHT];
    b2World * world;
    CGRect gridrect;
    double  ERASE_TIME;
    SvManaPool * manaGain;
    SvManaPool * manaPool;
    
}
@property (nonatomic,assign) b2World* world;
@property (nonatomic,assign) CGRect gridrect;
@property (nonatomic,readonly) SvManaPool * manaGain;
@property (nonatomic,readonly) SvManaPool * manaPool;
@property (nonatomic,readwrite) double ERASE_TIME;
- (BOOL) isGridFilledatX: (int) x andY:(int) y;
- (void) fixBlockAtX: (int) x Y: (int) y withType: (int) type;
- (void) Draw: (SVAnimatedSprite *) blocks inRect:(CGRect) inside;
- (void) Reset;
//- (void) fixFigureBlockAt:(int) x Y: (int) y withType: (int) type;
//- (void) unfixFigureBlockAt:(int) x Y: (int) y ;
@end


@interface TFigure : NSObject {
@private
    int max_frame;
    int xs[4];
    int ys[4];
    int types[4];
    int cx;
    int cy;
    b2World *world;
    SVTetrisBody * bodies[4];
    CGRect gridrect;
    BOOL isMissing;
}
@property (nonatomic,assign) b2World *world;
@property (nonatomic,assign) CGRect gridrect;
@property (nonatomic, readwrite) int cx;
@property (nonatomic, readwrite) int cy;
- (void) RotateLeft;
- (void) RotateRight;
- (BOOL) isFigureMissing;
- (BOOL) FitsOnGrid: (TGrid* ) grid;
- (void) Draw: (SVAnimatedSprite *) blocks inRect:(CGRect) inside;
- (id) initWithProbabilityMatrix: (float *) matr andTypeProbability: (float *) types;
- (void) fixOnGrid: (TGrid *) grid;
- (void) reInitWithProbabilityMatrix: (float *) matr andTypeProbability: (float *) types;
- (BOOL) isPresentonX:(int) x Y:(int) y;
- (void) updateBodies;
- (void) createBodies;
- (void) removeBodies;
- (BOOL) isBodyInFigure: (SVTetrisBody *) body;
- (NSArray *) reduceToFallingBlocks;
@end

@interface SVTetris : SVScene {
    SVAnimatedSprite * _blocks;
    TGrid* Grid;
    TFigure * cFigure;
    NSTimeInterval fullTime;
    float step;
    b2World * world;
    CGRect gridrect;
    CGPoint currentTouch;
    CGPoint newTouch;
    BOOL isDragging;
    ContactListener cl;
    NSMutableArray * movingBodies;
    SVTetrisBody * walls[4];
    NSSet * crushableTypes;
    NSMutableArray * sDisp;// successfully displaced objects
    NSMutableArray * sDispVals;// and displacement values
    BOOL dispResult;
    BOOL reduce;
    SvManaPool * manaPool;
    SVSprite *text;
}
- (BOOL) attemptDisplacingBody:(SVTetrisBody *) body byVector: (CGPoint) disp;
- (void) clearDisplacement;
- (BOOL) attemptPlacingFigure;
- (BOOL) attemptMovingFigureLeft;
- (BOOL) attemptMovingFigureRight;
- (BOOL) attemptMovingFigureDown;
- (BOOL) tryMovingBody:(SVTetrisBody *)body ToPosition: (CGPoint) position;
- (BOOL) crushBody: (SVTetrisBody *) body;
- (void) updateFigurePosition;
- (void) step;
- (void) Render;
- (id) initWithParent:(OpenGLView *)par andBackdrop:(NSString *) backdr;
@end
