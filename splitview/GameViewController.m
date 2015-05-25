//
//  GameViewController.m
//  splitview
//
//  Created by Ming Li on 16/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "GameViewController.h"
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/glext.h>

#define BUFFER_OFFSET(i) ((char *)NULL + (i))




@interface GameViewController () {
    
    
    GLKMatrix4 _modelViewProjectionMatrix[2];
    GLKMatrix4 _modelViewMatrix[2];
    float _rotation;
    GLKMatrix4 _gridModelViewProjectionMatrix[2];
    GLKMatrix4 _gridModelViewMatrix[2];
    
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    
    GLuint _quadVertexArray;
    GLuint _quadVertexBuffer;
    
    GLuint _gridVertexArray;
    GLuint _gridVertexBuffer;
    
    
    GLKMatrix4 _leftViewMatrix;
    GLKMatrix4 _rightViewMatrix;
    
    BOOL init;
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;


@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    init = true;
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    objloader = [[ObjLoader alloc]init];
    shaderLoader = [[ShaderLoader alloc] init];
    
    // load Geometry
    NSLog(@"loading obj file...");
    [objloader initWithPath:@"EmptyRoom_v1"];
    //[objloader initWithPath:@"texturedeneme_triangulate"];
    //[objloader initWithPath:@"ball"];
    mVertexData = [objloader.object getVertexData];
    mByteSizeOfVertexData = objloader.object.bytesize_vertexdata;
    mNumTriangles = [objloader.object getNumVertices];
    Object* empty_room = objloader.object;
    
    mFrameWidth = self.view.frame.size.width;
    mFrameHeight = self.view.frame.size.height;
    
    headPosition = [[HeadPosition alloc] init];
    [headPosition addObject:empty_room];
    
    _leftViewMatrix = GLKMatrix4MakeTranslation(0.5, 0.0, 0.0);
    _rightViewMatrix = GLKMatrix4MakeTranslation(-0.5, 0.0, 0.0);
    
    // _leftViewMatrix = GLKMatrix4RotateY(_leftViewMatrix, -1.57f);
    // _rightViewMatrix = GLKMatrix4RotateY(_rightViewMatrix, -1.57f);
    [self setupGL];
    
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
    
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (bool)initFBO {
    /******************************************************************************************************
     More documentation about FBO please refer to:
     https://developer.apple.com/library/ios/documentation/3DDrawing/Conceptual/OpenGLES_ProgrammingGuide/WorkingwithEAGLContexts/WorkingwithEAGLContexts.html
     *******************************************************************************************************/
    // get default FBO ID
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &mDefaultFBO);
    
    // Setup my FBO
    glGenFramebuffers ( 2, mFBO );
    glGenTextures ( 2, mColorTextureID );
    glGenRenderbuffers ( 2, mDepthRenderBuffer );
    
    for (int i = 0; i < 2; i++) {
        glBindFramebuffer ( GL_FRAMEBUFFER, mFBO[i] );
        
        NSLog(@"defaultFBO: %d, FBO[%d]: %d", mDefaultFBO, i, mFBO[i]);
        
        /*********************************************
         * Setup color buffer and attach to FBO
         *********************************************/
        // texture has same dimension as our screen
        int textureWidth = (int)floor(mFrameWidth / 2.0);
        int textureHeight = mFrameHeight;
        
        glBindTexture ( GL_TEXTURE_2D, mColorTextureID[i] );
        
        // Set the filtering mode
        glTexParameterf ( GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR );
        glTexParameterf ( GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR );
        glTexParameterf ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf ( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        
        glTexImage2D ( GL_TEXTURE_2D, 0, GL_RGBA, textureWidth, textureHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, NULL );
        
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, mColorTextureID[i], 0);
        
        /*********************************************
         * Setup depth buffer and attach to FBO
         *********************************************/
        glBindRenderbuffer(GL_RENDERBUFFER, mDepthRenderBuffer[i]);
        glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, textureWidth, textureHeight);
        glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, mDepthRenderBuffer[i]);
        
        GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(status != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"FBO[%d] : failed to make complete framebuffer object %x", i, status);
            return false;
        }
    }
    
    
    // Restore the original framebuffer
    glBindFramebuffer ( GL_FRAMEBUFFER, mDefaultFBO );
    glBindTexture ( GL_TEXTURE_2D, 0 );
    
    NSLog(@"FBO created successfully.");
    return true;
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    [shaderLoader loadShaders];
    [shaderLoader loadMyShaders];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glGenTextures(1, &mTextureID);
    // square texture
    [self loadTextureFromImage:@"T_E_Metal" Type:@"jpg" TexID:mTextureID];
    // non square texture
    //[self loadTextureFromImage:@"BasketballColor" Type:@"jpg" TexID:mTextureID];
    
    
    glEnable(GL_DEPTH_TEST);
    
    [self initLoadedGeometry];
    [self initQuadGeometry];
    [self initGridGeometry];
    
    [self initFBO];
}

- (void)initLoadedGeometry
{
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);
    
    glGenBuffers(1, &_vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, mByteSizeOfVertexData, mVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
    
}

- (void)initQuadGeometry
{
    glGenVertexArraysOES(1, &_quadVertexArray);
    glBindVertexArrayOES(_quadVertexArray);
    
    glGenBuffers(1, &_quadVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _quadVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gQuadVertexData), gQuadVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
    
    glBindVertexArrayOES(0);
}

- (void)initGridGeometry
{
    glGenVertexArraysOES(1, &_gridVertexArray);
    glBindVertexArrayOES(_gridVertexArray);
    
    glGenBuffers(1, &_gridVertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, _gridVertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(gGridVertexData), gGridVertexData, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 12, BUFFER_OFFSET(0));
    
    glBindVertexArrayOES(0);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexArray);
    
    glDeleteBuffers(1, &_quadVertexBuffer);
    glDeleteVertexArraysOES(1, &_quadVertexArray);
    
    glDeleteBuffers(1, &_gridVertexBuffer);
    glDeleteVertexArraysOES(1, &_gridVertexArray);
    
    self.effect = nil;
    
    
}

#pragma mark - Texture

-(void)loadTextureFromImage:(NSString *)imageName Type:(NSString *)type TexID:(uint)tid
{
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:type];
    NSData *texData = [[NSData alloc] initWithContentsOfFile:path];
    UIImage *image = [[UIImage alloc] initWithData:texData];
    if (image == nil)
        NSLog(@"Do real error checking here");
    
    size_t width = CGImageGetWidth(image.CGImage);
    size_t height = CGImageGetHeight(image.CGImage);
    NSLog(@"texture image w,h: %zu, %zu", width, height);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc( height * width * 4 );
    CGContextRef context0 = CGBitmapContextCreate( imageData, width, height, 8, 4 * width, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big );
    CGColorSpaceRelease( colorSpace );
    CGContextClearRect( context0, CGRectMake( 0, 0, width, height ) );
    CGContextTranslateCTM( context0, 0, height - height );
    CGContextDrawImage( context0, CGRectMake( 0, 0, width, height ), image.CGImage );
    
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mTextureID);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    /* The input frame is not of size power of 2*/
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    /* The input frame is in format BGRA */
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (int)width, (int)height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    CGContextRelease(context0);
    
    free(imageData);
    
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(mFrameWidth / 2.0 / mFrameHeight);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 10000.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4* viewMatrices;
    
    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelMatrix = GLKMatrix4MakeTranslation(0.0f, -1.0f, -12.0f);
    // modelMatrix = GLKMatrix4Rotate(modelMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    modelMatrix = GLKMatrix4Scale(modelMatrix, 1.0, 1.0, 1.0);
    if(init){
        
        [objloader.object moveObject:@"empty_room" matrix:modelMatrix];
        init = false;
    }
    
    // Eyes have to move together for consistency
    viewMatrices = [headPosition move:_leftViewMatrix rightEye:_rightViewMatrix];
    _leftViewMatrix = viewMatrices[0];
    _rightViewMatrix = viewMatrices[1];
    
    
    
    GLKMatrix4 leftMVMat = GLKMatrix4Multiply(_leftViewMatrix, modelMatrix);
    GLKMatrix4 rightMVMat = GLKMatrix4Multiply(_rightViewMatrix, modelMatrix);
    
    
    // mvp matrices for left and right view
    _modelViewProjectionMatrix[0] = GLKMatrix4Multiply(projectionMatrix, leftMVMat);
    _modelViewProjectionMatrix[1] = GLKMatrix4Multiply(projectionMatrix, rightMVMat);
    
    _modelViewMatrix[0] = leftMVMat;
    _modelViewMatrix[1] = rightMVMat;
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
    
    //Compute the model view matrix for the grid
    GLKMatrix4 gridModelMat = GLKMatrix4MakeTranslation(0.0, 0.0, -15.0);
    gridModelMat = GLKMatrix4Scale(gridModelMat, 2.0, 2.0, 2.0);
    
    leftMVMat = GLKMatrix4Multiply(_leftViewMatrix, gridModelMat);
    rightMVMat = GLKMatrix4Multiply(_rightViewMatrix, gridModelMat);
    
    // mvp matrices for left and right view
    _gridModelViewProjectionMatrix[0] = GLKMatrix4Multiply(projectionMatrix, leftMVMat);
    _gridModelViewProjectionMatrix[1] = GLKMatrix4Multiply(projectionMatrix, rightMVMat);
    
    _gridModelViewMatrix[0] = leftMVMat;
    _gridModelViewMatrix[1] = rightMVMat;
        
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    /*****************************
     *1st render pass, use FBO[0], render left view
     *****************************/
    
    glBindFramebuffer ( GL_FRAMEBUFFER, mFBO[0] );
    glViewport(0, 0, mFrameWidth / 2.0, mFrameHeight);
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // render grid
    glBindVertexArrayOES(_gridVertexArray);
    glUseProgram(shaderLoader._program);
    BOOL invertible = YES;
    
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _gridModelViewProjectionMatrix[0].m);
    GLKMatrix4 modelViewInvTrans = GLKMatrix4InvertAndTranspose(_gridModelViewMatrix[0], &invertible);
    glUniformMatrix4fv([ShaderLoader uniforms: UNIFORM_MODELVIEW_INV_TRANS], 1, 0, modelViewInvTrans.m);
    glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 1);
    glDrawArrays(GL_LINES, 0, 44);
    
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // render loaded geometry
    glBindVertexArrayOES(_vertexArray);
    // bind a texture
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mTextureID);
    // Render the object with ES2
    glUseProgram(shaderLoader._program);
    
    glUniformMatrix4fv([ShaderLoader uniforms: UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[0].m);
    modelViewInvTrans = GLKMatrix4InvertAndTranspose(_modelViewMatrix[0], &invertible);
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEW_INV_TRANS], 1, 0, modelViewInvTrans.m);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D], 0);
    glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 0);
    glDrawArrays(GL_TRIANGLES, 0, mNumTriangles);
    
    /*****************************
     *2nd render pass, use FBO[1], render right view
     *****************************/
    
    glBindFramebuffer ( GL_FRAMEBUFFER, mFBO[1] );
    glViewport(0, 0, mFrameWidth / 2.0, mFrameHeight);
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // render grid
    glBindVertexArrayOES(_gridVertexArray);
    glUseProgram(shaderLoader._program);
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _gridModelViewProjectionMatrix[1].m);
    modelViewInvTrans = GLKMatrix4InvertAndTranspose(_gridModelViewMatrix[1], &invertible);
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEW_INV_TRANS], 1, 0, modelViewInvTrans.m);
    glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 1);
    glDrawArrays(GL_LINES, 0, 44);
    
    glClear(GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(_vertexArray);
    // bind a texture
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mTextureID);
    // Render the object with ES2
    glUseProgram(shaderLoader._program);
    
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix[1].m);
    modelViewInvTrans = GLKMatrix4InvertAndTranspose(_modelViewMatrix[1], &invertible);
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEW_INV_TRANS], 1, 0, modelViewInvTrans.m);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D], 0);
    glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 0);
    glDrawArrays(GL_TRIANGLES, 0, mNumTriangles);
    
    /*****************************
     * 3rd render pass, use default FBO
     *****************************/
    
    [view bindDrawable];
    glViewport(0, 0, mFrameWidth * 2, mFrameHeight * 2);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mColorTextureID[0]);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, mColorTextureID[1]);
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // draw full screen quad
    glBindVertexArrayOES(_quadVertexArray);
    // Render the object with ES2
    glUseProgram(shaderLoader._ppProgram);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D_L], 0);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D_R], 1);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}






@end

