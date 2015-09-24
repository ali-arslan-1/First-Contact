//
//  Light.h
//  splitview
//
//  Created by Ali Arslan on 15.06.15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#ifndef splitview_Light_h
#define splitview_Light_h
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Object.h"
#import "Utils.h"

@interface Light : Object


@property ( nonatomic ) GLKVector4 position;
@property GLKVector3 color;
@property NSString* id;
@property (nonatomic) GLint uniformLocation;

-(id)init:(NSString*)name Id : (NSString*)_id;
-(GLKVector4)position;

@end

#endif
