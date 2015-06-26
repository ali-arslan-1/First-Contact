//
//  Light.m
//  splitview
//
//  Created by Ali Arslan on 15.06.15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Light.h"

@implementation Light

@synthesize color;
@synthesize uniformLocation;

-(id)init:(NSString*)name{
    
    if(self = [super init:name Type:Light_]){
        
        self->color = GLKVector3Make(1.0, 1.0, 1.0);
        //self->_position = GLKVector4Make(1.071f, 1.264f, -1.882f,1.0f); //TODO
    }
    return self;
}

-(GLKVector4)position{

    if([Utils isVector4Empty:self->_position]){
        [self calculateCenter];
        self->_position = self->center;
    }
    
    return self->_position;
}

@end