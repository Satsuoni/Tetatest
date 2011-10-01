//
//  SVTetrisBlock.h
//  Tetatest
//
//  Created by Seva Yugov on 10/1/11.
//  Copyright 2011 Tokodai. All rights reserved.
//

#import "SVTetrisBody.h"
#import "Box2D.h"
@class TGrid;
@interface SVTetrisBlock : SVTetrisBody
{
    int blocktype; 
    SVAnimatedSprite * blocks;
    BOOL freeFall;
    TGrid * grid;
    double HP;
    BOOL isErasing;
    double startTime;
    double elapsed;
    double eraseTime;
    double eraseStep;
    BOOL isErased;
    BOOL pulldown;// after erasing, pull down blocks in grid above it
    BOOL isinGrid;//fixed in grid;
    BOOL isInFigure;//part of the figure;
}
@property (nonatomic,readonly) BOOL isinFigure;
@property (nonatomic,readonly) BOOL isinGrid;
@property (nonatomic,readonly) BOOL freeFall;
- (id) initWithType: (int) itype free: (BOOL) free inWorld:(b2World *) world withBlocks:(SVAnimatedSprite *) blocks onGrid:(TGrid *) grid atPos: (CGPoint)pos;
- (unsigned int) getContactMode;
- (void) setParentScene: (SVScene *) scn;
- (id) initWithDictionary: (NSDictionary *) dct;
- (void) Reset;
- (NSString *) getName;
- (NSString *) getType;
- (void) setType: (NSString *) str;
- (void) updatePosition:(CGPoint) pos;
- (CGPoint) getPosition;
- (BOOL) sleeps;
- (void) Draw;
- (BOOL) isAlive;
///////For derivative classes;
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (void) startErasing;
- (void) startErasingWithPulldown;
@end
