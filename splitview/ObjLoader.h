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
#import "Door.h"
#import "Light.h"

@interface ObjLoader : NSObject{

    Object * object;
}

@property( nonatomic, retain)  NSMutableArray *objects;
- (void)initWithPath:(NSString *)path;

@end
