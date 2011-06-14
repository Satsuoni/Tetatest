//
//  SVTetris.m
//  Tetatest
//
//  Created by Seva on 6/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SVTetris.h"


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
        [tex drawImageOnTexture:blocks fromrect:CGRectMake(0,im.size.height,blocks.size.width,blocks.size.height) withrect:CGRectMake(0,0,blocks.size.width,blocks.size.height)];
        [tex finishTextureCreation];
        backdrop=[[parent getSpriteWithTexture:@"Tetris" andFrame:CGRectMake(0,0,im.size.width,im.size.height)] retain];
        backdrop.layoutPos=1;
        backdrop.center_position=CGPointMake(400, 300);
        _blocks=[[parent getAnimatedSpriteWithTexture:@"Tetris" andFrames:[NSArray arrayWithObjects:[NSValue valueWithCGRect:CGRectMake(0, im.size.height, 30, 30)], 
            [NSValue valueWithCGRect:CGRectMake(30, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(60, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(90, im.size.height, 30, 30)],
            [NSValue valueWithCGRect:CGRectMake(120, im.size.height, 30, 30)],nil]] retain];
        [self AddSprite:_blocks];
    }
    
    return self;
}
- (void)dealloc
{
    [_blocks release];
    [super dealloc];
}
@end
