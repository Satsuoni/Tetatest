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
@implementation SVTexture
@synthesize texture=_texture;
@synthesize width=_width;
@synthesize height=_height;
-(id) init
{
    if((self=[super init]))
    {
        isDone=NO;
        _tempdata=NULL;
    }
    return self;
}
- (void) startCreatingTexturewithWidth:(int)width andHeight:(int)height
{
    if(!isDone&&_tempdata==NULL)
    {
    _width=width;
    _height=height;
      //  UIImage* image = [UIImage imageNamed:@"tex.png"];
       _tempdata = (unsigned char* ) malloc(_width * _height * 4);
      textureContext = CGBitmapContextCreate(_tempdata, _width, _height, 8, _width * 4,
                                             CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
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
- (void) finishTextureCreation
{
    CGContextRelease(textureContext);
    glGenTextures(1, &_texture);
    glBindTexture(GL_TEXTURE_2D, _texture);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, _width, _height, 0, GL_RGBA, GL_UNSIGNED_BYTE, _tempdata);
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST );
    glTexParameteri ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST );
    free(_tempdata); 
    _tempdata=NULL;
    isDone=YES;
}
- (void) dealloc
{
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
@implementation OpenGLView

typedef struct {
    float Position[3];
    float Color[4];
    float Pos[2];
} Vertex;

const Vertex Vertices[] = {
    {{1, -1, 0}, {0.5, 0.5, 0.5, 1},{0,0}},
    {{1, 1, 0}, {0, 0, 0, 1},{0,1}},
    {{-1, 1, 0}, {0, 0, 0, 1},{1,1}},
    {{-1, -1, 0}, {0.5, 0.5, 0.5, 1},{1,0}}
};

const GLubyte Indices[] = {
    0, 1, 2,
    2, 3, 0
};
/*const Vertex Vertices[] = {
 {{1, -1, 0}, {1, 0, 0, 1}},
 {{1, 1, 0}, {1, 0, 0, 1}},
 {{-1, 1, 0}, {0, 1, 0, 1}},
 {{-1, -1, 0}, {0, 1, 0, 1}},
 {{1, -1, -1}, {1, 0, 0, 1}},
 {{1, 1, -1}, {1, 0, 0, 1}},
 {{-1, 1, -1}, {0, 1, 0, 1}},
 {{-1, -1, -1}, {0, 1, 0, 1}}
 };
 
 const GLubyte Indices[] = {
 // Front
 0, 1, 2,
 2, 3, 0,
 // Back
 4, 6, 5,
 4, 7, 6,
 // Left
 2, 7, 3,
 7, 6, 2,
 // Right
 0, 4, 1,
 4, 1, 5,
 // Top
 6, 2, 1, 
 1, 6, 5,
 // Bottom
 0, 3, 7,
 0, 7, 4    
 };*/

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
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "Position");
    _texpos =glGetAttribLocation(programHandle, "TexPos");
    _colorSlot = glGetAttribLocation(programHandle, "SourceColor");
    glEnableVertexAttribArray(_positionSlot);
    glEnableVertexAttribArray(_colorSlot);
    glEnableVertexAttribArray(_texpos);
    
    _projectionUniform = glGetUniformLocation(programHandle, "Projection");
    _modelViewUniform = glGetUniformLocation(programHandle, "Modelview");
    _sampler =glGetUniformLocation(programHandle, "s_texture");
    ////////////////
    tex=[[[SVTexture alloc] init] retain];
    [tex getTextureFromImage:@"tex.png" width:256 height:256 andFinish:YES];
    _texture=tex.texture;
}

- (void)setupVBOs {
    
    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW);
    
    GLuint indexBuffer;
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW);
    
}

- (void)render:(CADisplayLink*)displayLink {
    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glEnable(GL_DEPTH_TEST);
    
    CC3GLMatrix *projection = [CC3GLMatrix matrix];
    float h = 4.0f * self.frame.size.height / self.frame.size.width;
    [projection populateFromFrustumLeft:-2 andRight:2 andBottom:-h/2 andTop:h/2 andNear:4 andFar:10];
    glUniformMatrix4fv(_projectionUniform, 1, 0, projection.glMatrix);
    
    CC3GLMatrix *modelView = [CC3GLMatrix matrix];
    [modelView populateFromTranslation:CC3VectorMake(sin(CACurrentMediaTime()), 0, -7)];
    _currentRotation += displayLink.duration * 90;
    [modelView rotateBy:CC3VectorMake(0, 0, _currentRotation)];
    glUniformMatrix4fv(_modelViewUniform, 1, 0, modelView.glMatrix);
    
    // 1
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glActiveTexture ( GL_TEXTURE0 );
    glBindTexture ( GL_TEXTURE_2D, _texture );
    
    // Set the sampler texture unit to 0
    glUniform1i ( _sampler, 0 );
    // 2
    glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glVertexAttribPointer(_colorSlot, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3));
     glVertexAttribPointer(_texpos,2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 7));
    // 3
    glDrawElements(GL_TRIANGLES, sizeof(Indices)/sizeof(Indices[0]), GL_UNSIGNED_BYTE, 0);
    
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)setupDisplayLink {
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(render:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];    
}


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {        
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
    [tex release];
    [_context release];
    _context = nil;
    [super dealloc];
}

@end
