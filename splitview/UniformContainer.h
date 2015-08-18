//
//  UniformContainer.h
//  splitview
//
//  Created by Ali Arslan on 14.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_UniformContainer_h
#define splitview_UniformContainer_h

#import <GLKit/GLKit.h>

enum Uniform
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_MODELVIEW_MATRIX,
    UNIFORM_MODELVIEW_INV_TRANS,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_SAMPLER2D,
    UNIFORM_SAMPLER2D_L,
    UNIFORM_SAMPLER2D_R,
    UNIFORM_SAMPLER2D_FINAL,
    UNIFORM_ISGRID,
    UNIFORM_LIGHT_POS,
    UNIFORM_LIGHT_COLOR,
    UNIFORM_MTL_AMB,
    UNIFORM_MTL_DIFF,
    UNIFORM_MET_SEPC,
    UNIFORM_MET_SEPC_EXP,
    UNIFORM_RESOLUTION,
    UNIFORM_SAMPLE_OFFSET,
    UNIFORM_ATTENUATION,
    UNIFORM_BLEND_SAMPLER2D_1,
    UNIFORM_BLEND_SAMPLER2D_2,
    UNIFORM_TIME,
    NUM_UNIFORMS
};


enum UniformType{
    Uniform_Matrix4fv,
    Uniform_1i,
    Uniform_3f,
    Uniform_4f
};


@interface UniformContainer : NSObject{
    enum UniformType type;
    enum Uniform uniform;
    const GLfloat* _matrix4fv;
    GLint  _1i;
    GLKVector3 _3f;
    GLKVector4 _4f;
}

-(id)init: (enum Uniform) _uniform _matrix4fv :(const GLfloat*) value;
-(id)init: (enum Uniform) _uniform _1i :(GLint ) value;
-(id)init: (enum Uniform) _uniform _3f :(GLKVector3) value;
-(id)init: (enum Uniform) _uniform _4f :(GLKVector4) value;

-(enum Uniform) uniform;

-(enum UniformType) type;

-(const GLfloat*) _matrix4fv;
-(GLint) _1i;
-(GLKVector3) _3f;
-(GLKVector4) _4f;
@end

#endif
