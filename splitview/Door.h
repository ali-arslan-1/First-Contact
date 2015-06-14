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
    float distanceFromCamera;
    GLKVector4 center;
}

-(void)calculateCenter;
-(float)distanceFromCamera;
-(void)open;

@end

#endif
