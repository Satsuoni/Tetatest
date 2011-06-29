
//
//  OpenGLView.m
//  Tetatest
//
//  Created by Seva on 6/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OpenGLView.h"
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import "CC3GLMatrix.h"
#import "SVScene.h"
#import "SVTetris.h"
static VertexManager * _sharedVM=nil;
GL_RGBA_Color RGBAColorMake(float r, float g, float b, float a)
{
    GL_RGBA_Color ret={r,g,b,a};
    return ret;
}
@implementation SVSquareWrapper
- (NSComparisonResult) Compare: (SVSquareWrapper *) wrap
{
    if(wrap.vertices[0].pos[2]>_vertices[0].pos[2]) return NSOrderedAscending;
    if(wrap.vertices[0].pos[2]<_vertices[0].pos[2]) return NSOrderedDescending;
    return NSOrderedSame;
}
- (SpriteVertex *) vertices
{
    return _vertices;
}
-(id) copyWithZone:(NSZone *)zone
{
 id newNode = [[[self class] allocWithZone:zone] init];
    SVSquareWrapper * sq=newNode;
    SpriteVertex * vr=sq.vertices;
    memcpy(vr, _vertices, sizeof(_vertices));
    return newNode;
}
@end
@implementation VertexManager
+ (id) getSharedVM
{
    @synchronized([VertexManager class])
    {
        if(_sharedVM==nil)
            [VertexManager alloc];
        return _sharedVM;
    }
    return nil;
}
+ (id) alloc
{
    @synchronized([VertexManager class])
    {
        _sharedVM=[super alloc];
        [_sharedVM init];
        return _sharedVM;
    }
    return nil;
}
- (id) init
{
    if((self=[super init]))
    {
        num_indices=0;
        num_vertices=0;
        cur_max_v=VER_NUM_STEP;
        cur_max_i=VER_NUM_STEP*3;
        cur_index=0;
        ibc=NO;
        vertex_buffer=(char *)malloc(VER_NUM_STEP*sizeof(SpriteVertex));
        index_buffer=(GLushort *)malloc(sizeof(GLushort)*3*VER_NUM_STEP);
    }
    return self;
}
-(void) dealloc
{
    free(vertex_buffer);
    free(index_buffer);
    vertex_buffer=NULL;
    index_buffer=NULL;
    [super dealloc];
}
-(void) clear
{
    num_indices=0;
    num_vertices=0;
    cur_index=0;
}
- (void) processSquare:(SpriteVertex *)vertices //should have 4 vertices
{
    if(num_vertices+4>cur_max_v)
    {
        cur_max_v+=VER_NUM_STEP;
        char * nv_buffer=(char *) malloc(cur_max_v*sizeof(SpriteVertex));
        memcpy(nv_buffer, vertex_buffer, sizeof(SpriteVertex)*num_vertices);
        free(vertex_buffer);
        vertex_buffer=nv_buffer;
    }
    memcpy(&vertex_buffer[num_vertices*sizeof(SpriteVertex)], vertices, sizeof(SpriteVertex)*4);
    
    if(num_indices+6>cur_max_i)
    {
        cur_max_i+=VER_NUM_STEP*2;
        GLushort * nv_buffer=(GLushort *) malloc(cur_max_i*sizeof(GLushort));
        memcpy(nv_buffer, index_buffer, sizeof(GLushort)*num_indices);
        free(index_buffer);
        index_buffer=nv_buffer;    
    }
    index_buffer[num_indices]=num_vertices+2;
    index_buffer[num_indices+1]=num_vertices+1;
    index_buffer[num_indices+2]=num_vertices;
    index_buffer[num_indices+3]=num_vertices;
    index_buffer[num_indices+4]=num_vertices+3;
    index_buffer[num_indices+5]=num_vertices+2;
    num_vertices+=4;
    num_indices+=6;
}
- (void) registerIndexBuffer:(GLuint)attrId
{
        
   if(!ibc)
   {
    glGenBuffers(1, &indexBuffer);
       glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
  
       glGenBuffers(1, &vertexBuffer);
       glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
       ibc=YES;
   }
    
    
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(GLushort)* num_indices, index_buffer, GL_DYNAMIC_DRAW);

     glBufferData(GL_ARRAY_BUFFER, sizeof(SpriteVertex)*num_vertices, vertex_buffer, GL_DYNAMIC_DRAW);

}
-(void) registerVertexBuffer: (GLuint) v_attrId andTexels:(GLuint) t_attrid andVCoords:(GLuint) vc_attrId andFColors: (GLuint*) fc_attrID andParams:(GLuint) tpar andEtype:(GLuint) et_attrID
{
    GLenum gl=glGetError();
    glVertexAttribPointer(v_attrId, 3, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), 0);
    glVertexAttribPointer(t_attrid, 2, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*3));
        glVertexAttribPointer(vc_attrId, 2, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*5));
        glVertexAttribPointer(fc_attrID[0], 4, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*7)); 
            glVertexAttribPointer(fc_attrID[1], 4, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*11)); 
            glVertexAttribPointer(fc_attrID[2], 4, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*15)); 
            glVertexAttribPointer(fc_attrID[3], 4, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*19)); 
        glVertexAttribPointer(tpar, 2, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*23)); 
       glVertexAttribPointer(et_attrID, 1, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (GLvoid*) (sizeof(float)*25));
    gl=glGetError();
}
- (void) Draw
{
 
    glDrawElements(GL_TRIANGLES, num_indices, GL_UNSIGNED_SHORT, 0);
}

@end

@implementation SVTexture
@synthesize texture=_texture;
@synthesize width=_width;
@synthesize height=_height;
@synthesize name;
@synthesize _highestZ=highestZ;
@synthesize _lowestZ=lowestZ;
@synthesize empty;
-(void) ReplaceTextureBlock:(CGRect)block withData:(void *)data
{
      
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexSubImage2D(	GL_TEXTURE_2D, 
                    0, 
                    block.origin.x, 
                 _height-block.origin.y-block.size.height, 
                    block.size.width, 
                    block.size.height, 
                    GL_RGBA, 
                   GL_UNSIGNED_BYTE, 
                   data);
}
- (void) addDrawnSquare:(SVSquareWrapper *)wrap
{
    empty=NO;
    if(wrap.vertices[0].pos[2]>highestZ) highestZ=wrap.vertices[0].pos[2];
    if(wrap.vertices[0].pos[2]<lowestZ) lowestZ=wrap.vertices[0].pos[2];    
    [drawnSquares addObject:[wrap copyAutoreleased]];
}
-(void) clearDrawQueue
{
    [drawnSquares removeAllObjects];
    empty=YES;
}
- (NSComparisonResult) Compare:(SVTexture *)tex
{
    if(tex._lowestZ>lowestZ) return NSOrderedAscending;
      if(tex._lowestZ<lowestZ) return NSOrderedDescending;
    return NSOrderedSame;
}
- (void) Draw: (GLuint) sampler
{
    [self bindAs:GL_TEXTURE0];
     glUniform1i ( sampler, 0 );
    VertexManager *vm= [VertexManager getSharedVM] ;
    [vm clear];
    for(SVSquareWrapper * wrap in drawnSquares)
    {
        [vm processSquare:wrap.vertices];
    }
}
- (void) Sort
{
    [drawnSquares sortUsingSelector:@selector(Compare:)];
}
- (void) Draw: (GLuint) sampler  fromZ:(GLfloat) z_from uptoZ:(GLfloat) z_to andRemove:(BOOL)rem
{
    [self bindAs:GL_TEXTURE0];
    glUniform1i ( sampler, 0 );
    VertexManager *vm= [VertexManager getSharedVM] ;
    [vm clear];
    if(rem)
    {
        highestZ=-100;
        lowestZ=100;
    }
    for(SVSquareWrapper * wrap in drawnSquares)
    {
        if(wrap.vertices[0].pos[2]>=z_from&&wrap.vertices[0].pos[2]<=z_to)
        [vm processSquare:wrap.vertices];
        else
        {
            if(rem)
            {
                if(wrap.vertices[0].pos[2]>highestZ) highestZ=wrap.vertices[0].pos[2];
                if(wrap.vertices[0].pos[2]<lowestZ) lowestZ=wrap.vertices[0].pos[2];      
            }
        }
        if(rem) [removedSquares addObject:wrap];
        if(wrap.vertices[0].pos[2]>z_to) break;
    }
    if(rem)
    {
        
        [drawnSquares removeObjectsInArray:removedSquares];
        [removedSquares removeAllObjects];
        if([drawnSquares count]==0) empty=YES;
        else
            empty=NO;
    }
}

-(id) init
{
    if((self=[super init]))
    {
        isDone=NO;
        _tempdata=NULL;
        drawnSquares=[[NSMutableArray alloc] init] ;
         removedSquares=[[NSMutableArray alloc] init] ;
        highestZ=-100;
        lowestZ=100;
    }
    return self;
}
- (void) startCreatingTexturewithWidth:(int)width andHeight:(int)height
{
    if(isDone)
    {
        glDeleteTextures(1,&_texture);
        if(_tempdata!=NULL)
        {
            free(_tempdata);
            _tempdata=NULL;
        }
        isDone=NO;
    }
    if(!isDone&&_tempdata==NULL)
    {
    _width=width;
    _height=height;
      //  UIImage* image = [UIImage imageNamed:@"tex.png"];
       _tempdata = (unsigned char* ) malloc(_width * _height * 4);
       
      textureContext = CGBitmapContextCreate(_tempdata, _width, _height, 8, _width * 4,
                                             CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
         memset(_tempdata, 0, _width * _height * 4);
        GL_RGBA_Color clr=RGBAColorMake(0, 0, 0, 0);
         CGContextSetFillColor(textureContext, clr.clr);
        CGContextFillRect(textureContext, CGRectMake(0, 0, _width, _height));
    }
}
- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
    //create a context to do our clipping in
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    
    //create a rect with the size we want to crop the image to
    //the X and Y here are zero so we start at the beginning of our
    //newly created context
    CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
    CGContextClipToRect( currentContext, clippedRect);
    
    //create a rect equivalent to the full size of the image
    //offset the rect by the X and Y we want to start the crop
    //from in order to cut off anything before them
    CGRect drawRect = CGRectMake(rect.origin.x * -1,
                                 rect.origin.y * -1,
                                 imageToCrop.size.width,
                                 imageToCrop.size.height);
    
    //draw the image to our clipped context using our offset rect
    CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
    
    //pull the image from our cropped context
    UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
    
    //pop the context to get back to the default
    UIGraphicsEndImageContext();
    
    //Note: this is autoreleased
    return cropped;
}
- (void) drawImageOnTexture:(UIImage *)image fromrect:(CGRect)from withrect:(CGRect)to
{
    if(!isDone&&_tempdata!=NULL)
    {
    UIImage * cimage=[self imageByCropping:image toRect:from];
    CGContextDrawImage(textureContext, to, cimage.CGImage);
    }
}
-(CGPoint) getTexturePoint:(CGPoint)point
{
    if(point.x>_width) point.x=_width;
    if(point.x<0) point.x=0;
    if(point.y>_height) point.y=_height;
    if(point.y<0) point.y=0;
    return CGPointMake(point.x/_width, (_height-point.y)/_height);
}
- (CGRect) getTextureRect:(CGRect)rect
{
    CGRect tex=CGRectMake(0, 0, _width, _height);
    CGRect ret=CGRectIntersection(tex, rect);
    return CGRectMake(ret.origin.x/_width, (_height-ret.origin.y-ret.size.height)/_height, ret.size.width/_width, ret.size.height/_height);
}
- (void) finishTextureCreation
{
    CGContextRelease(textureContext);
       // memset(_tempdata, 0, _width * _height * 4);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _tempdata);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    free(_tempdata); 
    _tempdata=NULL;
    isDone=YES;
}
-(void) bindAs:(GLenum)tex
{
    glActiveTexture(tex);
    glBindTexture(GL_TEXTURE_2D, _texture);
}
- (void) dealloc
{
    [drawnSquares release];
    [removedSquares release];
    glDeleteTextures(1, &_texture);
    if(_tempdata!=NULL)
    {
        free(_tempdata);
        _tempdata=NULL;
         CGContextRelease(textureContext);
    }
    [super dealloc];
}
-  (void)getTextureFromImage:(NSString *)imname width:(int)wd height:(int)hd andFinish:(BOOL)fin
{
    UIImage * im=[UIImage imageNamed:imname];
    if(im==nil) return;
    [self startCreatingTexturewithWidth:wd andHeight:hd];
    [self drawImageOnTexture:im fromrect:CGRectMake(0,0,im.size.width,im.size.height) withrect:CGRectMake(0,0,im.size.width,im.size.height)];
     if(fin)
    [self finishTextureCreation];
}
- (void) deleteTexture
{
    if(isDone)
    {
    glDeleteTextures(1, &_texture);
    }
    if(_tempdata!=NULL)
    {
        free(_tempdata);
        _tempdata=NULL;
        CGContextRelease(textureContext);
    }
    isDone=NO;
}
@end



@implementation SVSprite
@synthesize virt_frame;
@synthesize center_position;
@synthesize transform;
@synthesize layoutPos;
@synthesize effect;
- (void) setSpriteEffect:(SpriteEffect *)effectr
{
    effect=effectr->type;
    [self setEffectParameter:0 toValue:effectr->par1];
     [self setEffectParameter:1 toValue:effectr->par2];
    for(int i=0;i<4;i++)
    {
        [self setEColorR:effectr->colors[i].clr[0] G:effectr->colors[i].clr[1] B:effectr->colors[i].clr[2] A:effectr->colors[i].clr[3] N:i];
    }
}
- (void) setEffectParameter:(int)n toValue:(GLfloat)param
{
    efparams[n]=param;
}
- (void) setEColorR:(GLfloat)r G:(GLfloat)g B:(GLfloat)b A:(GLfloat)a N:(int)n
{
    ecolors[n].clr[0]=r;
  ecolors[n].clr[1]=g;
    ecolors[n].clr[2]=b;
    ecolors[n].clr[3]=a;
}
-(void) renderText:(NSString *)text withFont:(UIFont *) font intoBox:(CGRect)texturebox withColor:(GL_RGBA_Color)color andlineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment
{
    int sizeInBytes = texturebox.size.width*texturebox.size.height*4;
    void* data = malloc(sizeInBytes);
    memset(data, 0, sizeInBytes);
    CGContextRef context = CGBitmapContextCreate(data,  texturebox.size.width, texturebox.size.height, 8, texturebox.size.width * 4,
                                                 CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
  
    CGContextSetFillColor(context, color.clr);
// CGContextTranslateCTM(context, 0.0, texturebox.size.height);
//  CGContextScaleCTM(context, 1.0, -1.0);
    UIGraphicsPushContext(context);
    [text drawInRect:CGRectMake(0, 0, texturebox.size.width, texturebox.size.height) withFont:font
       lineBreakMode:lineBreakMode alignment:alignment];
    UIGraphicsPopContext();
    CGContextRelease(context);
    [texture ReplaceTextureBlock:texturebox withData:data];
    [self setTextureFrame:texturebox];
    free(data);
}
- (void) setFrame: (int) frame
{
    
}
- (id) initWithTexture:(SVTexture *)tex andFrame:(CGRect)texFrame
{
 if((self=[super init]))
 {
     effect=0;
     texture=[tex retain];
     frame=[texture getTextureRect:texFrame];
     wrap=[[[SVSquareWrapper alloc] init] retain];
     transform=[[CC3GLMatrix matrix] retain];
     [transform populateIdentity];
     [transform rotateBy:CC3VectorMake(180, 0, 0)];
 }
    return self;
}
- (void) setTextureFrame:(CGRect)texFrame
{
    frame=[texture getTextureRect:texFrame];  
}
-(void) Draw
{

    
    
    position_v=wrap.vertices;
    for(int i=0;i<4;i++)
    {
        memcpy(position_v[i].fragmentcolors, ecolors, sizeof(ecolors));
        position_v[i].etype=effect;
        position_v[i].params[0]=efparams[0];
         position_v[i].params[1]=efparams[1];
    }
    position_v[0].efpos[0]=0.f;
    position_v[0].efpos[1]=0.f;
    position_v[1].efpos[0]=1.f;
    position_v[1].efpos[1]=0.f;
    position_v[2].efpos[0]=1.f;
    position_v[2].efpos[1]=1.f;
    position_v[3].efpos[0]=0.f;
    position_v[3].efpos[1]=1.f;

    CC3Vector pos;
    pos.x=center_position.x;
    pos.y=center_position.y;
     pos.z=layoutPos;
//ul
    CC3Vector apos;
    apos.x=-virt_frame.width/2;
    apos.y=-virt_frame.height/2;
    apos.z=0;
    CC3Vector p2=CC3VectorAdd(pos, [transform transformLocation:apos]);
    memcpy(&position_v[0].pos[0],&p2, sizeof(float)*3);
    position_v[0].texpos[0]=frame.origin.x;
    position_v[0].texpos[1]=frame.origin.y;
    
//ur
    apos.x=virt_frame.width/2;
    apos.y=-virt_frame.height/2;
    apos.z=0;
     p2=CC3VectorAdd(pos, [transform transformLocation:apos]);
    memcpy(&position_v[1].pos[0],&p2, sizeof(float)*3);
    position_v[1].texpos[0]=frame.origin.x+frame.size.width;
    position_v[1].texpos[1]=frame.origin.y;
//lr
    apos.x=virt_frame.width/2;
    apos.y=virt_frame.height/2;
    apos.z=0;
    p2=CC3VectorAdd(pos, [transform transformLocation:apos]);
    memcpy(&position_v[2].pos[0],&p2, sizeof(float)*3);
    position_v[2].texpos[0]=frame.origin.x+frame.size.width;
    position_v[2].texpos[1]=frame.origin.y+frame.size.height;    
//ll
    apos.x=-virt_frame.width/2;
    apos.y=virt_frame.height/2;
    apos.z=0;
    p2=CC3VectorAdd(pos, [transform transformLocation:apos]);
    memcpy(&position_v[3].pos[0],&p2, sizeof(float)*3);
    position_v[3].texpos[0]=frame.origin.x;
    position_v[3].texpos[1]=frame.origin.y+frame.size.height;  

    [texture addDrawnSquare:wrap];
}
- (CGPoint) ul_position
{
    return CGPointMake(center_position.x-virt_frame.width/2, center_position.y-virt_frame.height/2);
}
- (void) setUl_position:(CGPoint)ul_position
{
    center_position=CGPointMake(ul_position.x+virt_frame.width/2, ul_position.y+virt_frame.height/2);
}
- (void) resetTransform
{
    [transform populateIdentity];
    [transform rotateBy:CC3VectorMake(180, 0, 0)];  
}
- (void) dealloc
{
    [wrap release];
    [transform release];
    [texture release];
    [super dealloc];
}
@end

@implementation SVAnimatedSprite

-(void) setFrame:(int)frameNum
{
    currentFrame=frameNum;
    NSValue *value=[frameset objectAtIndex:currentFrame];
    frame=[texture getTextureRect:[value CGRectValue]];
}
- (id) initWithTexture:(SVTexture *)tex andFrames:(NSArray *)frames
{
    if((self=[super initWithTexture:tex andFrame:[[frames objectAtIndex:0] CGRectValue]]))
    {
        
        frameset=[[[NSArray alloc] initWithArray:frames] retain];
  
    }
    return self;
}
- (void) dealloc
{
 [frameset release];
 [super dealloc];
}
@end


@implementation OpenGLView

typedef struct {
    float Position[3];
    float Color[4];
    float Pos[2];
} Vertex;

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {   
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);        
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
}

- (void)setupDepthBuffer {
    glGenRenderbuffers(1, &_depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height);    
}

- (void)setupFrameBuffer {    
    GLuint framebuffer;
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);   
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer);
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
    
}

- (void)compileShaders {
    
    // 1
    GLuint vertexShader = [self compileShader:@"Svertex" withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:@"Sfragment" withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    glAttachShader(programHandle, vertexShader);
    glAttachShader(programHandle, fragmentShader);
    glLinkProgram(programHandle);
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    glEnable (GL_BLEND);
    glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _texpos =glGetAttribLocation(programHandle, "TexPos");
    _effect_pos =glGetAttribLocation(programHandle, "VirtPos");
    _effect_colors[0] =glGetAttribLocation(programHandle, "ef_color1");
    _effect_colors[1] =glGetAttribLocation(programHandle, "ef_color2");
    _effect_colors[2] =glGetAttribLocation(programHandle, "ef_color3");
    _effect_colors[3] =glGetAttribLocation(programHandle, "ef_color4");
    _effect_type=glGetAttribLocation(programHandle, "effect_type");
    _effect_params=glGetAttribLocation(programHandle, "ef_params");
    //_colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_effect_pos);
    glEnableVertexAttribArray(_effect_type);
      glEnableVertexAttribArray(_effect_params);
    glEnableVertexAttribArray(_effect_colors[0]);
     glEnableVertexAttribArray(_effect_colors[1]);
     glEnableVertexAttribArray(_effect_colors[2]);
     glEnableVertexAttribArray(_effect_colors[3]);
   // glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texpos);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    _sampler =glGetUniformLocation(programHandle, "s_texture");
    ////////////////
   SVTetris * svt=[[SVTetris alloc] initWithParent:self andBackdrop:@"tetr.bmp"];
    currentScene=svt;
}
-(SVTexture *) getTextureNamed:(NSString *)name
{
    return [textures valueForKey:name];
}
- (void) deleteTextureNamed:(NSString *)name
{
    [textures removeObjectForKey:name];
}
- (SVTexture *) createTextureNamed:(NSString *)name 
{
    if([textures valueForKey:name]!=nil)
        return [textures valueForKey:name] ;
    SVTexture *textr=[[SVTexture alloc] init];
    [textures setValue:textr forKey:name];
    [textr release];
    return [textures valueForKey:name] ;
}
- (SVAnimatedSprite *) getAnimatedSpriteWithTexture:(NSString *)texName andFrames:(NSArray *)frames
{
    SVTexture * tx=[self getTextureNamed:texName];
    SVAnimatedSprite * newSprite=[[SVAnimatedSprite alloc]initWithTexture:tx andFrames:frames];
    NSValue * val=[frames objectAtIndex:0];
    newSprite.virt_frame=[val CGRectValue].size;
    return [newSprite autorelease];
}
- (SVSprite *) getSpriteWithTexture:(NSString *)texName andFrame:(CGRect)frame
{
    SVTexture * tx=[self getTextureNamed:texName];
    SVSprite * newSprite=[[SVSprite alloc] initWithTexture:tx andFrame:frame];
  
    newSprite.virt_frame=frame.size;
    return [newSprite autorelease];
}

- (SVSprite *) getSpriteWithTexture:(NSString *)texName andFrame:(CGRect)frame andDrawFrame:(CGSize)dframe
{
    SVTexture * tx=[self getTextureNamed:texName];
    SVSprite * newSprite=[[SVSprite alloc] initWithTexture:tx andFrame:frame];
   
    newSprite.virt_frame=dframe;
    return [newSprite autorelease]; 
}
- (void)setupVBOs {

   /* GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
  glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
   glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
   glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);*/
    
}

- (void)render:(CADisplayLink*)displayLink {
    glClearColor(0, 0.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
   glDepthFunc(GL_ALWAYS);
    //glEnable (GL_BLEND);
    //glBlendFunc (GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    actualResolution=self.frame.size;
    if(actualResolution.width<actualResolution.height)
    {
        float tmp=actualResolution.width;
        actualResolution.width=actualResolution.height;
        actualResolution.height=tmp;
    }
    virtualResolution.width=800;
    virtualResolution.height=600;
    [projection populateOrthoFromFrustumLeft:2 andRight:-2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    //[projection rotateByX:180];
    [projection rotateByZ:270];
    //[projection rotateByX:180];
    // [projection rotateByY:180];
   // [projection multiplyByMatrix:look];
    //[projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateIdentity];
    [modelView populateFromTranslation:CC3VectorMake(0, 0, -7)];
    
    [modelView translateBy:CC3VectorMake(-h/2,-2, 0)];
    //
   [modelView scaleBy:CC3VectorMake(h/virtualResolution.width, 4/virtualResolution.height, 1)];
    //[modelView toloo
    //[modelView populateFromTranslation:CC3VectorMake(0, 0, -7)];
    //_currentRotation += displayLink.duration * 90;
    //[modelView rotateBy:CC3VectorMake(0, 0, _currentRotation)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    [currentScene Render];
    for (SVSprite * spr in drawList)
    {
        [spr Draw]; 
    }
   
   NSMutableArray *sorted=[[NSMutableArray alloc] initWithArray:[[textures allValues] sortedArrayUsingSelector:@selector(Compare:)]];
    /* for(NSString *key in textures)
    {
        SVTexture *texture=[textures valueForKey:key];
     [texture Draw:_sampler];
     [[VertexManager getSharedVM]  registerIndexBuffer:0];
     [[VertexManager getSharedVM] registerVertexBuffer:_positionSlot andTexels:_texpos andVCoords:_effect_pos andFColors:_effect_colors andParams:_effect_params  andEtype:_effect_type];
     [[VertexManager getSharedVM] Draw];
     [texture clearDrawQueue];
    }*/
    for (SVTexture *tex in sorted)
    {
        [tex Sort];
    }
    while([sorted count]>0)
    {
        SVTexture * texture=[sorted objectAtIndex:0];
        if([sorted count]==1)
        {
            [texture Draw:_sampler];
            [[VertexManager getSharedVM]  registerIndexBuffer:0];
            [[VertexManager getSharedVM] registerVertexBuffer:_positionSlot andTexels:_texpos andVCoords:_effect_pos andFColors:_effect_colors andParams:_effect_params  andEtype:_effect_type];
            [[VertexManager getSharedVM] Draw];
            [texture clearDrawQueue];
            [sorted removeObject:texture];
        }
        else
        {
            SVTexture * next=[sorted objectAtIndex:1];
            [texture Draw:_sampler fromZ:texture._lowestZ uptoZ:next._lowestZ andRemove:YES];
            [[VertexManager getSharedVM]  registerIndexBuffer:0];
            [[VertexManager getSharedVM] registerVertexBuffer:_positionSlot andTexels:_texpos andVCoords:_effect_pos andFColors:_effect_colors andParams:_effect_params  andEtype:_effect_type];
            [[VertexManager getSharedVM] Draw];
            if(texture.empty)
                [sorted removeObject:texture];
        }
        [sorted sortUsingSelector:@selector(Compare:)];
    }
    [sorted release];
   
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}

-(void) clearDrawList
{
    [drawList removeAllObjects];
}
- (CGPoint) transformPointToInnerResolution:(CGPoint)point
{
   CGPoint cp= CGPointMake(point.x*virtualResolution.width/actualResolution.width, point.y*virtualResolution.height/actualResolution.height) ;
    return CGPointMake(cp.y, virtualResolution.height-cp.x);
}
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentScene touchesBegan:touches withEvent:event];
}
- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentScene touchesCancelled:touches withEvent:event];
}
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentScene touchesEnded:touches withEvent:event];
}
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [currentScene touchesMoved:touches withEvent:event];
}
- (void) addSpriteToDrawList:(SVSprite *)sprites
{
    if(![drawList containsObject:sprites])
        [drawList addObject:sprites];
}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {   
        self.userInteractionEnabled=YES;
        textures=[[[NSMutableDictionary alloc] init] retain];
        drawList=[[[NSMutableArray alloc]init]retain];
        [self setupLayer];        
        [self setupContext];    
        [self setupDepthBuffer];
        [self setupRenderBuffer];        
        [self setupFrameBuffer];     
        [self compileShaders];
        [self setupVBOs];
        [self setupDisplayLink];        
    }
    return self;
}

- (void)dealloc
{
    [currentScene release];
    [drawList release];
    [textures release];
    [sprite release];
   // [tex release];
    [_context release];
    _context = nil;
    [super dealloc];
}

@end
