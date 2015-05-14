//
//  Object.m
//  splitview
//
//  Created by MCP 2015 on 07/05/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Object.h"

@implementation Object{}

-(id) init:(float)minX minZ:(float)minZ maxX:(float)maxX maxZ:(float)maxZ{
    coordinates = (float*) malloc(4*sizeof(float));
    coordinates[0] = minX;
    coordinates[1] = minZ;
    coordinates[2] = maxX;
    coordinates[3] = maxZ;
    return self;
}

-(void) dealloc{
    free(coordinates);
}
-(float*) getCoordinates{
    return coordinates;
}

@end