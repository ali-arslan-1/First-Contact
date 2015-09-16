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
#import "UniformContainer.h"
#import "Door.h"
#import "Level.h"
#import "TriggerObject.h"
#import "LevelController.h"
#define BUFFER_OFFSET(i) ((char *)NULL + (i))




@interface GameViewController () {
    
    
    float _rotation;
    GLKMatrix4 _gridModelViewProjectionMatrix[2];
    GLKMatrix4 _gridModelViewMatrix[2];
    NSMutableArray * lights;
    
    GLuint _quadVertexArray;
    GLuint _quadVertexBuffer;
    
    GLuint _gridVertexArray;
    GLuint _gridVertexBuffer;
    
    Level *currentLevel;
    TriggerObject *triggeredObject;
    LevelController *levelController;

    BOOL init;
    
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;


@end

@implementation GameViewController

@synthesize inputTextField;




- (void)viewDidLoad
{
    [super viewDidLoad];
    init = true;
    
    
    startTime = [[NSDate date] timeIntervalSince1970];
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    objloader = [[ObjLoader alloc]init];

    
    // load Geometry
    NSLog(@"loading obj file...");

    [objloader initWithPath:@"Craft"];

    mFrameWidth = self.view.frame.size.width;
    mFrameHeight = self.view.frame.size.height;
  
    GLKVector3 initialPos = GLKVector3Make(-4, 1.45, 0.0);
    GLKVector3 initialViewDir = GLKVector3Make(4, 1.45, 0);
    
    headPosition = [[HeadPosition alloc] initWithPos:initialPos];
    [headPosition addObjects:objloader.getCategorizedObjects];
    

    
    GLKMatrix4 _leftViewMatrix = GLKMatrix4MakeLookAt(initialPos.x, initialPos.y, initialPos.z, initialViewDir.x, initialViewDir.y, initialViewDir.z, 0, 1, 0);
    
    GLKMatrix4 _rightViewMatrix = GLKMatrix4MakeLookAt(initialPos.x, initialPos.y, initialPos.z, initialViewDir.x, initialViewDir.y, initialViewDir.z, 0, 1, 0);
    
    [HeadPosition setLView:_leftViewMatrix];
    [HeadPosition setRView:_rightViewMatrix];
    
    float aspect = fabs(mFrameWidth / 2.0 / mFrameHeight);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 10000.0f);
    
    [HeadPosition setProjection:projectionMatrix];
    
    //==================
    
    // Create and start a CMMotionManager, so that e.g. attitude later can be used:
    // https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CMMotionManager_Class/index.html#//apple_ref/occ/instm/CMMotionManager/startDeviceMotionUpdates
    motionMgr = [[CMMotionManager alloc] init];
    [motionMgr startDeviceMotionUpdates];
    
    // create and init the headRotation-instance from that rotation-matrices then later can be received:
    headRotation = [[HeadRotation alloc] initWithMotionManager:(motionMgr)];
    
    //==================
    
    // _leftViewMatrix = GLKMatrix4MakeTranslation(0.5, -1.0, 0.0);
    //_rightViewMatrix = GLKMatrix4MakeTranslation(-0.5, -1.0, 0.0);
    
   [self setupGL];
    
    [inputTextField addTarget:self
                  action:@selector(textFieldDidChange:)
        forControlEvents:UIControlEventEditingChanged];
 
    //[inputTextField setHidden:YES];
    [inputTextField becomeFirstResponder];
    
    
    levelController = [[LevelController alloc] initwithLevelXML:@"NarrativeSequence"];
    [levelController assignTriggersToLevels:objloader];
    currentLevel = [levelController getNextLevel];
    [currentLevel loadLevel];
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
    int fboCount = 8;
    glGenFramebuffers ( fboCount, mFBO );
    glGenTextures ( fboCount, mColorTextureID );
    glGenRenderbuffers ( fboCount, mDepthRenderBuffer );
    
    for (int i = 0; i < fboCount; i++) {
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
    
    shaderLoader = [[ShaderLoader alloc] init:objloader.objects];
    
    [shaderLoader loadShaders];
    [shaderLoader loadMyShaders];
    [shaderLoader loadBlurShaders];
    [shaderLoader loadBlendShaders];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glGenTextures(1, &mTextureID);
    // square texture
    [self loadTextureFromImage:@"T_E_PodRoom" Type:@"png" TexID:mTextureID];
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
    //Object * object0 = objloader.objects[0];
    
    //Object * object1 = objloader.objects[1];
    
   // [objloader.objects removeObject: object0];
    lights = [NSMutableArray array];
    int i=0;
    for(Object* geometry in objloader.objects){
        mVertexData = [geometry getVertexData];
        mByteSizeOfVertexData = geometry.bytesize_vertexdata;
       // mNumTriangles = [geometry getNumVertices];
        glGenVertexArraysOES(1, geometry.vertexArray);
        glBindVertexArrayOES(*(geometry.vertexArray));
        
        glGenBuffers(1, geometry.vertexBuffer);
        glBindBuffer(GL_ARRAY_BUFFER, *geometry.vertexBuffer);
        glBufferData(GL_ARRAY_BUFFER, mByteSizeOfVertexData, mVertexData, GL_STATIC_DRAW);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal , 3, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(12));
        glEnableVertexAttribArray(GLKVertexAttribTexCoord0 );
        glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, 32, BUFFER_OFFSET(24));
        
        glBindVertexArrayOES(0);
        
        if([geometry isKindOfClass:[Light class]]){
            [lights addObject:geometry];
        }
        
        i++;
    }
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
    [headPosition movePlayer];
    
    for (Object *object in objloader.objects) {
        if([object isKindOfClass:[Door class]]){
            [(Door*)object changeStateIfRequired];
        }
    }
    
    if(triggeredObject){
        [triggeredObject playAnimation];
    }
    
    GLKMatrix4 rotatedLeftViewMatrix;
    GLKMatrix4 rotatedRightViewMatrix;
    
    //==========================================================================================================
    
    // Get the rotation-matrix for the current device-attitude and apply it to the view-matrices:
    
    GLKMatrix4 rotation = [headRotation getRotationMatrix];
    rotatedLeftViewMatrix = GLKMatrix4Multiply(rotation, [HeadPosition lView]);
    rotatedRightViewMatrix = GLKMatrix4Multiply(rotation, [HeadPosition rView]);
    
    //==========================================================================================================
    
    
    GLKMatrix4 gridModelMat = GLKMatrix4MakeTranslation(0.0, 0.0, -15.0);
    gridModelMat = GLKMatrix4Scale(gridModelMat, 2.0, 2.0, 2.0);
    
    GLKMatrix4 leftMVMat = GLKMatrix4Multiply(rotatedLeftViewMatrix, gridModelMat);
    GLKMatrix4 rightMVMat = GLKMatrix4Multiply(rotatedRightViewMatrix, gridModelMat);
    
    // mvp matrices for left and right view
    _gridModelViewProjectionMatrix[0] = GLKMatrix4Multiply([HeadPosition projection], leftMVMat);
    _gridModelViewProjectionMatrix[1] = GLKMatrix4Multiply([HeadPosition projection], rightMVMat);
    
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
    
    glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _gridModelViewProjectionMatrix[0].m);
    glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 1);
    glDrawArrays(GL_LINES, 0, 44);
    
    glClear(GL_DEPTH_BUFFER_BIT);
    
    // render loaded geometries
    for(int i = 0; i< objloader.objects.count; i++){
        Object *loaded = [objloader.objects objectAtIndex:i];
        
        glBindVertexArrayOES(*(loaded.vertexArray));
        // bind a texture
        glEnable(GL_TEXTURE_2D);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, mTextureID);
        // Render the object with ES2
        glUseProgram(shaderLoader._program);
        
        glUniformMatrix4fv([ShaderLoader uniforms: UNIFORM_MODELVIEW_MATRIX], 1, 0, [loaded getModelView:Left].m);
        glUniformMatrix4fv([ShaderLoader uniforms: UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, [loaded getModelViewProjection:Left].m);
        glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEW_INV_TRANS], 1, 0, [loaded getModelViewInverseTranspose:Left].m);
        glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D], 0);
        glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 0);
        //1.071f, 3.264f, -1.882f
        for (Light* light in lights) {
            glUniform3f(light.uniformLocation, light.position.x, light.position.y, light.position.z);
            
        }
        
        
        
        mNumTriangles = [loaded getNumVertices];
        glDrawArrays(GL_TRIANGLES, 0, mNumTriangles);
    }
    
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
    glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 1);
    glDrawArrays(GL_LINES, 0, 44);
    
    
    
    glClear(GL_DEPTH_BUFFER_BIT);
    // render loaded geometries
    for(int i = 0; i< objloader.objects.count; i++){
        Object *loaded = [objloader.objects objectAtIndex:i];
        glBindVertexArrayOES(*(loaded.vertexArray));
        // bind a texture
        glEnable(GL_TEXTURE_2D);
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, mTextureID);
        // Render the object with ES2
        glUseProgram(shaderLoader._program);
        
        glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEW_MATRIX], 1, 0, [loaded getModelView:Right].m);
        glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, [loaded getModelViewProjection:Right].m);
        glUniformMatrix4fv([ShaderLoader uniforms:UNIFORM_MODELVIEW_INV_TRANS], 1, 0, [loaded getModelViewInverseTranspose:Right].m);
        glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D], 0);
        glUniform1i([ShaderLoader uniforms:UNIFORM_ISGRID], 0);
        //glUniform3f([ShaderLoader uniforms:UNIFORM_LIGHT_POS], 1.071f, 3.264f, -1.882f);
        
        for (Light* light in lights) {
            glUniform3f(light.uniformLocation, light.position.x, light.position.y, light.position.z);
            
        }
        
        mNumTriangles = [loaded getNumVertices];
        glDrawArrays(GL_TRIANGLES, 0, mNumTriangles);
    }
    
    
    
    //left eye
    
    [self blur:mFBO[2] otherFbo:mFBO[3] colorTexture: mColorTextureID[2] inputTexture: mColorTextureID[0]];
    
    [self blend: mFBO[4]  inputTexture: mColorTextureID[3] otherInput:mColorTextureID[0]];
    
    //right eye
    [self blur:mFBO[5] otherFbo:mFBO[6] colorTexture: mColorTextureID[5] inputTexture: mColorTextureID[1]];
    
    [self blend: mFBO[7]  inputTexture: mColorTextureID[6] otherInput:mColorTextureID[1]];
    

    /*****************************
     * 6th render pass, use default FBO
     *****************************/
    
    //glBindFramebuffer ( GL_FRAMEBUFFER, mFBO[2] );
    
    [view bindDrawable];
    glViewport(0, 0, mFrameWidth * 2, mFrameHeight * 2);
    
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
    // draw full screen quad
    glBindVertexArrayOES(_quadVertexArray);
    // Render the object with ES2
    glUseProgram(shaderLoader._ppProgram);
    
    
    //glEnable(GL_BLEND);
    //glBlendFunc(GL_SRC_ALPHA, GL_ONE);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, mColorTextureID[4]);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, mColorTextureID[7]);
    
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D_L], 0);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D_R], 1);
    
    glUniform2f([ShaderLoader uniforms:UNIFORM_RESOLUTION],mFrameWidth, mFrameHeight );
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    

    //glDisable(GL_BLEND);
}

-(void)textFieldDidChange:(UITextField *)sender{
    
    int asciiCode = [sender.text characterAtIndex:[sender.text length]-1];
    NSString *input = [NSString stringWithFormat:@"%c", asciiCode];
    //NSLog( @"text changed: %@", input);
    
    if([input  isEqual: @"a"]){
        [headPosition moveLeft];
    }else if([input  isEqual: @"d"]){
        [headPosition moveRight];
    }else if([input  isEqual: @"w"]){
        [headPosition moveForward];
    }else if([input  isEqual: @"x"]){
        [headPosition moveBackward];
    }else if([input  isEqual: @"e"]){
        [headPosition stopMoving];
    }else if([input  isEqual: @"q"]){
        [headPosition stopMoving];
    }else if([input  isEqual: @"c"]){
        [headPosition stopMoving];
    }else if([input  isEqual: @"z"]){
        [headPosition stopMoving];
    }else if([input  isEqual: @"f"]){
        [headPosition lookLeft];
    }else if([input  isEqual: @"h"]){
        [headPosition lookRight];
    }else if ([input isEqual:@"c"]){
        TriggerObject *trigger = [currentLevel getTriggerObject];
        if([trigger isActive]&&[headPosition isTriggered:trigger]){
            [trigger responseWhenItIsTriggered];
            triggeredObject = trigger;
            [currentLevel levelEnds];
            currentLevel = [levelController getNextLevel];
            [currentLevel loadLevel];
        }
    }

   //NSLog(@"left eye camera position: %f, %f, %f",_leftViewMatrix.m30,_leftViewMatrix.m31,_leftViewMatrix.m32);
    
}


-(void) blur: (GLuint) fbo1 otherFbo: (GLuint)fbo2
colorTexture: (GLuint) colorTextureFbo1 inputTexture:(GLuint)input {
    
    
    // verticle
    
    glBindFramebuffer ( GL_FRAMEBUFFER, fbo1 );
    glViewport(0, 0, mFrameWidth / 2.0, mFrameHeight);
    
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, input);
    
    
    // draw full screen quad
    glBindVertexArrayOES(_quadVertexArray);
    
    // Render the object with ES2
    glUseProgram(shaderLoader._blurProgram);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D_FINAL], 0);
    glUniform1f([ShaderLoader uniforms:UNIFORM_ATTENUATION], 1.0f);
    glUniform2f([ShaderLoader uniforms:UNIFORM_SAMPLE_OFFSET], 1.5f / 512.0f, 0.0f);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    
    // horizontal
    glBindFramebuffer ( GL_FRAMEBUFFER, fbo2 );
    glViewport(0, 0, mFrameWidth / 2.0, mFrameHeight);
    
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, colorTextureFbo1);
    
    // draw full screen quad
    glBindVertexArrayOES(_quadVertexArray);
    // Render the object with ES2
    glUseProgram(shaderLoader._blurProgram);
    glUniform1i([ShaderLoader uniforms:UNIFORM_SAMPLER2D_FINAL], 0);
    glUniform1f([ShaderLoader uniforms:UNIFORM_ATTENUATION], 1.0f);
    glUniform2f([ShaderLoader uniforms:UNIFORM_SAMPLE_OFFSET], 0.0f, 1.5f / 512.0f);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

}


-(void) blend: (GLuint) fbo
inputTexture: (GLuint) texture1 otherInput:(GLuint)texture2 {
    
    glBindFramebuffer ( GL_FRAMEBUFFER, fbo );
    glViewport(0, 0, mFrameWidth / 2.0, mFrameHeight);
    
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    //glEnable(GL_TEXTURE_2D);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture1);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, texture2);
    
    // draw full screen quad
    glBindVertexArrayOES(_quadVertexArray);
    // Render the object with ES2
    glUseProgram(shaderLoader._blendProgram);
    glUniform1i([ShaderLoader uniforms:UNIFORM_BLEND_SAMPLER2D_1], 0);
    glUniform1i([ShaderLoader uniforms:UNIFORM_BLEND_SAMPLER2D_2], 1);
    
    
    float runtime = [[NSDate date] timeIntervalSince1970] - startTime;
    
    glUniform1f([ShaderLoader uniforms:UNIFORM_TIME], runtime);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
}
@end

