//
//  ShaderLoader.m
//  splitview
//
//  Created by Ali Arslan on 25.05.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "ShaderLoader.h"

@implementation ShaderLoader

@synthesize _program;
@synthesize _ppProgram;

static GLint uniforms[NUM_UNIFORMS];

+ (GLint)uniforms:(int) position{
    @synchronized(self) {
        return uniforms[position];
    }
}

+ (void)setUniforms:(int) position value: (GLint) val{
    @synchronized(self) {
        uniforms[position] = val;
    }
    
}

-(id)init:(NSMutableArray *)_objects{
    self->objects = _objects;
    return self;
}

-(void)dealloc{

    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    if (_ppProgram) {
        glDeleteProgram(_ppProgram);
        _ppProgram = 0;
    }
}

- (BOOL)loadShaders
{
    
    
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_program, GLKVertexAttribTexCoord0, "texCoord");
    glBindAttribLocation(_program, GLKVertexAttribNormal, "normal");
    
    
    // Link program.
    if (![self linkProgram:_program]) {
        NSLog(@"Failed to link program: %d", _program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_program) {
            glDeleteProgram(_program);
            _program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_MODELVIEW_MATRIX] = glGetUniformLocation(_program, "modelViewMatrix");
    uniforms[UNIFORM_MODELVIEW_INV_TRANS] = glGetUniformLocation(_program, "modelViewInvTransMatrix");
    uniforms[UNIFORM_SAMPLER2D] = glGetUniformLocation(_program, "uSampler");
    uniforms[UNIFORM_ISGRID] = glGetUniformLocation(_program, "isGrid");
    //uniforms[UNIFORM_LIGHT_POS] = glGetUniformLocation(_program, "uLightPosition");
    
    for (Object *object in objects) {
        if([object isKindOfClass:[Light class]]){
            Light* light = (Light*)object;
            light.uniformLocation = glGetUniformLocation(_program,[light.name UTF8String]);
            NSLog(@"light name %s",[light.name UTF8String]);
        }
    }
    
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;

}

- (BOOL)loadMyShaders
{
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    _ppProgram = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"post" ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    //fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"DistortTwoTexture" ofType:@"fsh"];
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"post" ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(_ppProgram, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(_ppProgram, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(_ppProgram, GLKVertexAttribPosition, "position");
    glBindAttribLocation(_ppProgram, GLKVertexAttribTexCoord0, "texCoord");
    
    // Link program.
    if (![self linkProgram:_ppProgram]) {
        NSLog(@"Failed to link program: %d", _ppProgram);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_ppProgram) {
            glDeleteProgram(_ppProgram);
            _ppProgram = 0;
        }
        
        return NO;
    }
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(_ppProgram, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_ppProgram, fragShader);
        glDeleteShader(fragShader);
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_SAMPLER2D_L] = glGetUniformLocation(_ppProgram, "uSamplerL");
    uniforms[UNIFORM_SAMPLER2D_R] = glGetUniformLocation(_ppProgram, "uSamplerR");
    uniforms[UNIFORM_RESOLUTION] = glGetUniformLocation(_ppProgram, "resolution");
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}



@end