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

- (BOOL)loadShaders
{

    return YES;

}

+(GLint)uniforms:(int) position{
    @synchronized(self) {
        return uniforms[position];
    }
}

+(void)setUniforms:(int) position value: (GLint) val{
    @synchronized(self) {
        uniforms[position] = val;
    }
    
}

@end