//
//  UniformContainer.m
//  splitview
//
//  Created by Ali Arslan on 14.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UniformContainer.h"


@implementation UniformContainer

-(id)init:(enum Uniform) _uniform _matrix4fv :(const GLfloat*) value{
    self->uniform = _uniform;
    self->_matrix4fv = value;
    self->type = Uniform_Matrix4fv;
    return self;
}

-(id)init: (enum Uniform) _uniform _1i :(GLint ) value{
    self->uniform = _uniform;
    self->_1i = value;
    self->type = Uniform_1i;
    return self;

}
-(id)init: (enum Uniform) _uniform _3f :(GLKVector3) value{
    self->uniform = _uniform;
    self->_3f = value;
    self->type = Uniform_3f;
    return self;
}
-(id)init: (enum Uniform) _uniform _4f :(GLKVector4) value{
    self->uniform = _uniform;
    self->_4f = value;
    self->type = Uniform_4f;
    return self;
}

-(enum Uniform) uniform{
    return self->uniform;
}

-(enum UniformType) type{
    return self->type;
}

-(const GLfloat*) _matrix4fv{
    return self->_matrix4fv;
}

-(GLint) _1i{
    return self->_1i;
}

-(GLKVector3) _3f{
    return self->_3f;
}

-(GLKVector4) _4f{
    return self->_4f;
}

@end