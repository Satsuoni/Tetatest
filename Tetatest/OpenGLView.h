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
#define VER_NUM_STEP 400
typedef struct
{
    GLfloat pos[3];
    GLfloat texpos[2];
} SpriteVertex;

@interface VertexManager:NSObject
{
    int num_vertices;
    int num_indices;
    int cur_max_v;
    int cur_max_i;
    int cur_index;
     GLuint vertexBuffer;
    GLuint indexBuffer;
    BOOL ibc;
    GLfloat *vertex_buffer;
    GLushort * index_buffer;
}
-(id) init;
+ (id)getSharedVM;
-(void) clear;
-(void) processSquare: (SpriteVertex *) vertices;
-(void) registerVertexBuffer: (GLuint) v_attrId andTexels:(GLuint) t_attrid;
-(void) registerIndexBuffer :(GLuint) attrId;
-(void) Draw;
@end
@interface SVSquareWrapper :NSObject <NSCopying>
{
    SpriteVertex _vertices[4];
}
@property (nonatomic,readonly) SpriteVertex * vertices;
- (id) copyWithZone:(NSZone *)zone;
@end
@interface SVTexture :NSObject
{
    GLuint _texture;
    unsigned char * _tempdata;
    CGContextRef textureContext; //temporary
    int _width,_height;
    BOOL isDone;
    NSString *name;
    NSMutableArray * drawnSquares; 
}
@property (nonatomic,retain) NSString * name;
@property (nonatomic, readonly) GLuint texture;
@property (nonatomic, readonly) int width;
@property (nonatomic, readonly) int height;
- (void) startCreatingTexturewithWidth: (int) width andHeight:(int) height;
- (void) drawImageOnTexture: (UIImage *)image fromrect: (CGRect) from withrect:(CGRect) to;
- (void) finishTextureCreation;
- (void) deleteTexture;
- (void) getTextureFromImage :(NSString *) imname width: (int) wd height: (int) hd andFinish: (BOOL) fin;
- (void) bindAs: (GLenum) tex;
- (CGPoint) getTexturePoint:(CGPoint) point;
- (CGRect) getTextureRect:(CGRect) rect;
- (void) addDrawnSquare: (SVSquareWrapper *) wrap;
- (void) clearDrawQueue;
- (void) Draw:(GLuint) sampler;
- (void) ReplaceTextureBlock: (CGRect) block withData: (void *) data;
@end
typedef struct
{
    GLfloat clr[4];
    // GL_RGBA_Color(GLfloat r,GLfloat g,GLfloat b,GLfloat a);
} GL_RGBA_Color;

@interface SVSprite :NSObject
{
    SVTexture * texture;
    CGRect frame;// in texture coords
    CGSize virt_frame;// virtual size , in vp
    CC3GLMatrix *transform;
    CGPoint center_position;//in virtual pixels
    float layoutPos;// z position...
    int currentFrame;
    SVSquareWrapper *wrap;
    SpriteVertex *position_v;// vertex position ul, ur lr ll
    BOOL isDrawn;
}
@property (nonatomic,assign) CC3GLMatrix * transform;
@property (nonatomic,assign) CGSize virt_frame;
@property (nonatomic,assign) CGPoint center_position;
@property (nonatomic,assign) float layoutPos;
@property (nonatomic,readwrite) CGPoint ul_position;
-(id) initWithTexture: (SVTexture *) tex andFrame: (CGRect) texFrame;
-(void) setTextureFrame: (CGRect) frame;
-(void) Draw;
- (void) resetTransform;
-(void) setFrame : (int) frame;
- (void) renderText:(NSString *) text withFont:(UIFont *) font intoBox:(CGRect) textureBox withColor: (GL_RGBA_Color) color andlineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment;
@end

@interface SVAnimatedSprite : SVSprite {
@private
    NSArray * frameset;
}
-(void) setFrame : (int) frame;
- (id) initWithTexture: (SVTexture *)tex andFrames: (NSArray *) frames;
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
    CGSize actualResolution;
    CGSize virtualResolution;
    NSMutableDictionary * textures;
    NSMutableArray * drawList;
   // SVTexture * tex;
   SVSprite *sprite;
}
- (SVTexture *) createTextureNamed:(NSString*)name; 
- (SVTexture *) getTextureNamed: (NSString *) name;
- (void) deleteTextureNamed: (NSString * )name;
- (SVSprite *) getSpriteWithTexture: (NSString *) texName andFrame: (CGRect) frame;
- (SVSprite *) getSpriteWithTexture: (NSString *) texName andFrame: (CGRect) frame andDrawFrame :(CGSize) dframe;
- (void) addSpriteToDrawList: (SVSprite *) sprite;
- (void) clearDrawList;
@end