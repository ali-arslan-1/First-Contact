//
//  ShaderLoader.h
//  splitview
//
//  Created by Ali Arslan on 25.05.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_ShaderLoader_h
#define splitview_ShaderLoader_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#include "UniformContainer.h"
#include "Object.h"
#include "Light.h"


@interface ShaderLoader : NSObject{
    NSMutableArray * objects;
}


@property( nonatomic ) GLuint _program;
@property( nonatomic ) GLuint _ppProgram;
@property( nonatomic ) GLuint _blurProgram;

#pragma mark -  OpenGL ES 2 shader compilation
-(id)init:(NSMutableArray*)_objects;

- (BOOL)loadShaders;
- (BOOL)loadMyShaders;
- (BOOL)loadBlurShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;


+(GLint) uniforms:(int) position;
+(void) setUniforms:(int) position value: (GLint) val;



@end

#endif
