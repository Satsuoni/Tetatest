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
    double tt;
    double eraseTime;
    double eraseStep;
    BOOL isErased;
    BOOL pulldown;// after erasing, pull down blocks in grid above it
    BOOL isinGrid;//fixed in grid;
    BOOL isinFigure;//part of the figure;
}
@property (nonatomic,readonly) BOOL isinFigure;
@property (nonatomic,readonly) BOOL isinGrid;
@property (nonatomic,readonly) BOOL freeFall;
@property (nonatomic,readonly) BOOL isErased;
@property (nonatomic,readonly) int blocktype; 
- (id) initWithType: (int) itype free: (BOOL) free inWorld:(b2World *) world withBlocks:(SVAnimatedSprite *) blocks onGrid:(TGrid *) grid atPos: (CGPoint)pos;
- (id) initWithDictionary: (NSDictionary *) dct;

- (void) fixAtX:(int) x andY:(int)y;

- (void) Draw;
- (BOOL) isAlive;
///////For derivative classes;
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (void) startErasing;
- (void) startErasingWithPulldown;
- (void) unfix;
- (void) moveToGridatX:(int) x andY: (int) y;
@end
