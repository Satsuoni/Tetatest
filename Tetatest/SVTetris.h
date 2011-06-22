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
#define T_ROW 10
#define T_HEIGHT 19
class ContactListener : public b2ContactListener
{
public:
    
    void BeginContact(b2Contact* contact);
    void EndContact(b2Contact* contact);
    void PreSolve(b2Contact* contact, const b2Manifold* oldManifold);
    void PostSolve(b2Contact* contact, const b2ContactImpulse* impulse);
};
typedef struct
{
    float restitution;
    float density;
    float friction;
    BOOL isSensor;
    b2BodyType type;
    BOOL isBullet;
    
} b2Template;

#define MREC_POS 7
@interface SVTetrisBody :NSObject {
@public
    unsigned int contactMode;
    NSMutableSet * touchingBodies;
    NSString *name;
    NSString *type;
    b2Body *body;
    b2World * world;
     CGPoint impulse;
    CGPoint recordedPositions[MREC_POS];
    int crec;
    int trec;
}
@property (nonatomic, readonly) NSMutableSet *touchingBodies;
- (id) initWithRect: (CGRect) rect andTemplate:(b2Template) temp inWorld:(b2World *) world withName:(NSString *) name andType:(NSString * )type;
- (BOOL) canContactMode:(unsigned int) mode;
- (BOOL) canContact: (SVTetrisBody *) body;
- (void) setContactMode: (unsigned int) mode;
- (void) applyImpulse:(CGPoint) impulse;
- (void) addTouchingBody:(SVTetrisBody *) body;
- (BOOL) isSensor;
- (void) Reset;
- (NSString *) getName;
- (NSString *) getType;
- (void) setType: (NSString *) str;
- (void) updatePosition:(CGPoint) pos;
- (CGPoint) getPosition;
- (BOOL) isPresentonX:(int) x Y:(int) y withRect: (CGRect) ret;
- (CGRect) getBoundingBox;
- (BOOL) sleeps;
- (void) applyDirectImpulse: (CGPoint) impulse;
- (void) Draw;
- (CGPoint) getVelocity;
- (void) applyLinearDamping:(float) damp;
- (void) recordPosition;
- (BOOL) checkOscillationatLevel:(float) level upToDiff:(float) diff;
- (void) destroyBody;
@end
@interface SVTetrisFreeBlock : SVTetrisBody {
@private
    int btype;
    SVAnimatedSprite * blocks;
}
- (void) Draw;
@end

@interface TGrid : NSObject {
@private
    int Grid[T_ROW][T_HEIGHT];
    BOOL erasing[T_HEIGHT];
    double erasetime[T_HEIGHT];
    NSTimeInterval prevtime;
    SVTetrisBody * bodyGrid[T_ROW][T_HEIGHT];
    b2World * world;
    CGRect gridrect;
    
}
@property (nonatomic,assign) b2World* world;
@property (nonatomic,assign) CGRect gridrect;
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
    BOOL reduce;
}
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
