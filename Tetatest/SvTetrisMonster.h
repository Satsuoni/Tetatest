//
//  SvTetrisMonster.h
//  Tetatest
//
//  Created by Seva on 6/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SVTetrisBody.h"
#import "OpenGLView.h"
#import "SvManaPool.h"
@interface SvTetrisMonster : SVTetrisBody {
    double HP;
    SvManaPool * pool;
    SVAnimatedSprite * animation;
    BOOL ghostMode;
    BOOL wasCrushed;
    int orientation;
    BOOL canFly;
    NSMutableDictionary * abilities;
    int currentFrame;
    SpriteEffect currentEffect;
}
- (id) initWithDictionary: (NSDictionary *) dict;
- (void) Update: (double) time;
- (void) Apply: (NSDictionary *) thing;
- (NSDictionary *) getStatus;
- (void) Draw;
@end
