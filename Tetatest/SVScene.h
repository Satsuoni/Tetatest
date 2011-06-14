//
//  SVScene.h
//  Tetatest
//
//  Created by Seva on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLView.h"

@interface SVScene : NSObject {
    SVSprite * backdrop;
    OpenGLView* parent;
    NSMutableArray * sprites;
    NSMutableArray *fixedText;
    NSTimeInterval elapsedTime;
    NSTimeInterval currentTime;
}
- (id) initWithParent :(OpenGLView *) par;
- (void) Update;
- (void) Render;
- (void) AddSprite :(SVSprite *) sprite;
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event;
- (void) setBackdrop:(SVSprite *) back;
//- (void) setBackdropwithFile:(NSString *)file;
@end
