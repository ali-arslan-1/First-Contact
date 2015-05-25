//
//  ObjLoader.h
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import "Object.h"

@interface ObjLoader : NSObject

@property( nonatomic, retain ) Object * object;

- (void)initWithPath:(NSString *)path;

@end
