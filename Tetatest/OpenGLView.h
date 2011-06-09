//
//  OpenGLView.h
//  Tetatest
//
//  Created by Seva on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include "CC3GLMatrix.h"
@interface SVTexture :NSObject
{
    GLuint _texture;
    unsigned char * _tempdata;
    CGContextRef textureContext; //temporary
    int _width,_height;
    BOOL isDone;
}
@property (nonatomic, readonly) GLuint texture;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
- (void) startCreatingTexturewithWidth: (int) width andHeight:(int) height;
- (void) drawImageOnTexture: (UIImage *)image fromrect: (CGRect) from withrect:(CGRect) to;
- (void) finishTextureCreation;
- (void) deleteTexture;
- (void) getTextureFromImage :(NSString *) imname width: (int) wd height: (int) hd andFinish: (BOOL) fin;
@end
@interface OpenGLView : UIView {
    CAEAGLLayer* _eaglLayer;
    EAGLContext* _context;
    GLuint _colorRenderBuffer;
    GLuint _positionSlot;
    GLuint _colorSlot;
    GLuint _projectionUniform;
    GLuint _modelViewUniform;
    float _currentRotation;
    GLuint _depthRenderBuffer;
    GLuint _texpos;
    GLuint _sampler;
    GLuint _texture;
    SVTexture * tex;
}

@end
