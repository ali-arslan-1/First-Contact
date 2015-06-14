//
//  Renderer.h
//  splitview
//
//  Created by Ali Arslan on 13.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_Renderer_h
#define splitview_Renderer_h
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES3/glext.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "Object.h"
#import "ShaderLoader.h"
#import "HeadPosition.h"
#import "UniformContainer.h"

@interface Renderer : NSObject{
    Object* object;
    GLuint shaderProgram;
    uint texture;
    NSMutableArray *uniforms;
    
}

-(id)init:(Object*) object ShaderProgram : (GLuint) program Texture :(uint) texture;
-(void)addUniform:(enum Uniform)location Matrix4fv :(const GLfloat*)value;
-(void)addUniform:(enum Uniform)location _1i :(GLint)value;
-(void)addUniform:(enum Uniform)location _3f :(GLKVector3)value;
-(void)addUniform:(enum Uniform)location _4f :(GLKVector4)value;
-(void)drawLines:(enum Uniform)count;
-(void)drawTriangles:(GLuint)fbo Width :(GLfloat)width Height: (GLfloat)height  ;

//@property( nonatomic, retain ) NSMutableArray *vertice;

@end


#endif
