//
//  HeadPosition.m
//  splitview-motion
//
//  Created by MCP 2015 on 04/05/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "HeadPosition.h"


@implementation HeadPosition{
    NSMutableArray *objects;

}

- (id) init{
    self = [super init];
    objects = [NSMutableArray array];
    return self;
}

- (void) dealloc{
    //TO DO deallocate the array somehow || is the array allocated?
}

- (GLKMatrix4*) move:(GLKMatrix4)LviewMatrix rightEye:(GLKMatrix4)RviewMatix{
    GLKMatrix4 matrices[2];
    GLKMatrix4 oldMatrices[2] = {LviewMatrix, RviewMatix};
    matrices[0] = GLKMatrix4Translate(LviewMatrix, 0.0, 0.0, 0.05);
    matrices[1] = GLKMatrix4Translate(RviewMatix, 0.0, 0.0, 0.05);
  /*  if ([self detectCollision: matrices[0]])
        return oldMatrices;
    else if ([self detectCollision:matrices[1]])
         return oldMatrices;*/
    return matrices;
    
}

- (void) addObject :(Object*) object{

    [objects addObject:object];
}

- (BOOL) detectCollision: (GLKMatrix4) position{
    
    //GLKMatrix4 position.mYX
    float x = position.m30;
    float z = position.m32;
  
    for(Object *obj in objects){
        float* coord = [obj getCoordinates];
        //  NSLog(@"minX: %f, minZ: %f, maxX: %f, maxZ: %f",coord[0], coord[1], coord[2], coord[3]);
        // x < minX or x > maxX or z < minZ or z > maxZ
        if(x < coord[0] || x > coord[2] || z < coord[1] || z > coord[3])
            return YES;
    }
    return NO;
}
@end
