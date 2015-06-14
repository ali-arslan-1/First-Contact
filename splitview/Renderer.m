//
//  Renderer.m
//  splitview
//
//  Created by Ali Arslan on 13.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Renderer.h"



@implementation Renderer

-(id)init:(Object*) _object ShaderProgram : (GLuint) program Texture :(uint) _texture{

    self->object = _object;
    self->shaderProgram = program;
    self->texture = _texture;
    uniforms = [NSMutableArray array];
    return self;
}

-(void)addUniform:(enum Uniform)location Matrix4fv :(const GLfloat*)value{
    UniformContainer * container = [[UniformContainer alloc] init:location _matrix4fv:value];
    [uniforms addObject:container];
}

-(void)addUniform:(enum Uniform)location _1i :(GLint)value{
    UniformContainer * container = [[UniformContainer alloc] init:location _1i:value];
    [uniforms addObject:container];
}
-(void)addUniform:(enum Uniform)location _3f :(GLKVector3)value{
    UniformContainer * container = [[UniformContainer alloc] init:location _3f:value];
    [uniforms addObject:container];
}
-(void)addUniform:(enum Uniform)location _4f :(GLKVector4)value{
    UniformContainer * container = [[UniformContainer alloc] init:location _4f:value];
    [uniforms addObject:container];
}
-(void)drawLines:(enum Uniform)count{}
-(void)drawTriangles:(GLuint)fbo Width :(GLfloat)width Height: (GLfloat)height {

    glBindFramebuffer ( GL_FRAMEBUFFER, fbo );
    glViewport(0, 0, width / 2.0, height);
    
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glClear(GL_DEPTH_BUFFER_BIT);
    
    glBindVertexArrayOES(*(self->object.vertexArray));
    // bind a texture
    glEnable(GL_TEXTURE_2D);
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self->texture);
    // Render the object with ES2
    glUseProgram(self->shaderProgram);
    
    for (UniformContainer* container in uniforms) {
        switch (container.type) {
            case Uniform_Matrix4fv:
                glUniformMatrix4fv([ShaderLoader uniforms: container.uniform], 1, 0, container._matrix4fv);
                break;
            case Uniform_1i:
                glUniform1i([ShaderLoader uniforms:container.uniform], container._1i);
                break;
            case Uniform_3f:
                glUniform3f([ShaderLoader uniforms:container.uniform], container._3f.x,container._3f.y,container._3f.z);
                break;
            case Uniform_4f:
                glUniform4f([ShaderLoader uniforms:container.uniform], container._4f.x,container._4f.y,container._4f.z,container._4f.w);
                break;
            default:
                break;
        }
    }
    
    glDrawArrays(GL_TRIANGLES, 0, [self->object getNumVertices]);
    
}

@end