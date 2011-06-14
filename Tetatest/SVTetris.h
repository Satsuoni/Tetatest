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
@interface SVTetris : SVScene {
    SVAnimatedSprite * _blocks;
}
- (id) initWithParent:(OpenGLView *)par andBackdrop:(NSString *) backdr;
@end
