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
#define T_ROW 10
#define T_HEIGHT 19
@interface TGrid : NSObject {
@private
    int Grid[T_ROW][T_HEIGHT];
}
- (BOOL) isGridFilledatX: (int) x andY:(int) y;
- (void) fixBlockAtX: (int) x Y: (int) y withType: (int) type;
- (void) Draw: (SVAnimatedSprite *) blocks inRect:(CGRect) inside;
@end
@interface TFigure : NSObject {
@private
    int max_frame;
    int xs[4];
    int ys[4];
    int types[4];
    int cx;
    int cy;
}
@property (nonatomic, readwrite) int cx;
@property (nonatomic, readwrite) int cy;
- (void) RotateLeft;
- (void) RotateRight;
- (BOOL) FitsOnGrid: (TGrid* ) grid;
- (void) Draw: (SVAnimatedSprite *) blocks inRect:(CGRect) inside;
- (id) initWithProbabilityMatrix: (float *) matr andTypeProbability: (float *) types;
- (void) fixOnGrid: (TGrid *) grid;
- (void) reInitWithProbabilityMatrix: (float *) matr andTypeProbability: (float *) types;
@end

@interface SVTetris : SVScene {
    SVAnimatedSprite * _blocks;
    TGrid* Grid;
    TFigure * cFigure;
    NSTimeInterval fullTime;
    float step;
}
- (void) step;
- (void) Render;
- (id) initWithParent:(OpenGLView *)par andBackdrop:(NSString *) backdr;
@end
