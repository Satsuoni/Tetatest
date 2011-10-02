//
//  SVScene.m
//  Tetatest
//
//  Created by Seva on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVScene.h"
#import "OpenGLView.h"
#import "SVTetrisBody.h"
NSMutableArray * movingBodies;
@implementation SVScene
@synthesize sceneDictionary;
- (void) spawnBody:(SVTetrisBody *)body
{
    [body setParentScene:self];
}
- (id) initWithParent: (OpenGLView *) par
{
    if((self=[super init]))
    {
        parent=par;
        sprites=[[NSMutableArray alloc] init];
        fixedText=[[NSMutableArray alloc] init];
    }
    return self;
}
- (double) getDoubleParameter:(NSString *)pname
{
    return 0;
}
- (void *) getPointerParameter:(NSString *)pname
{
    return NULL;
}
- (void) Update
{
    
}
-(void) dealloc
{
    [backdrop release];
    [sprites release];
    [fixedText release];
    [super dealloc];
}
-(void) setBackdrop:(SVSprite *)back
{
    backdrop=[back retain];
}
- (void) Render
{
    [backdrop Draw];
    for(SVSprite * spr in sprites)
        [spr Draw];
    for(SVSprite * spr in fixedText)
        [spr Draw];
    
}
- (void) AddSprite :(SVSprite *) sprite
{
    [sprites addObject:sprite];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}
@end

