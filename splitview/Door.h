//
//  Door.h
//  splitview
//
//  Created by Ali Arslan on 14.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_Door_h
#define splitview_Door_h
#import <GLKit/GLKit.h>
#import "Object.h"



@interface Door : Object{
    BOOL closed;
    BOOL partialOpen;
    float distanceFromCamera;
    float openDoorDistLimit;
    float speed;
    float width;
    BOOL zAligned;
    GLKVector4 initialWorldCenter;
}

-(void)calculateAttributes;
-(float)distanceFromCamera;
-(void)changeStateIfRequired;
-(id)init:(NSString *)name Alignment :(BOOL)_zAligned;

@end

#endif
