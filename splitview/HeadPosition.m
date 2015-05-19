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
    GLKMatrix4 matrices[2];
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

    GLKMatrix4 oldMatrices[2] = {LviewMatrix, RviewMatix};
    matrices[0] = GLKMatrix4Translate(LviewMatrix, 1.0, 0.0, 0.0);
    matrices[1] = GLKMatrix4Translate(RviewMatix, 1.0, 0.0, 0.0);
    GLKVector4 posLeft = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    GLKVector4 posRight = GLKVector4Make(0.0f, 0.0f, 0.0f, 1.0f);
    
    posLeft = GLKMatrix4MultiplyVector4(matrices[0], posLeft);
    posRight = GLKMatrix4MultiplyVector4(matrices[1], posRight);
    
   if ([self detectCollision: posLeft])
        return oldMatrices;
    else if ([self detectCollision:posRight])
         return oldMatrices;
    return matrices;
}

- (void) addObject :(Object*) object{

    [objects addObject:object];
}

- (BOOL) detectCollision: (GLKVector4) pos{
    // GLKVector4 pos = GLKVector4Make(0.5f, 0.0f, 0.0f, 1.0f);
    //  pos = GLKMatrix4MultiplyVector4(position, pos);
    //GLKMatrix4 position.mYX
    float x = pos.x;//position.m30;
    float z = pos.z;//position.m32;
  
    for(Object *obj in objects){
        float* coord = [obj getCoordinates];
        GLKVector4 BboxMin = GLKVector4Make(-coord[2], 0.0f, -coord[3], 1.0f);
        GLKVector4 BboxMax = GLKVector4Make(-coord[0], 0.0f, -coord[1], 1.0f);
        
        BboxMin = GLKMatrix4MultiplyVector4(matrices[0], BboxMin);
        BboxMax = GLKMatrix4MultiplyVector4(matrices[0], BboxMax);
        
      //    NSLog(@"minX: %f, minZ: %f, maxX: %f, maxZ: %f",coord[0], coord[1], coord[2], coord[3]);
        // x > -maxX or x < -minX or z > -maxZ or z < -minZ   --> because camera moves +z direction and object moves -z direction is the same.
        if(x >= BboxMin.x && x < BboxMax.x && z >= BboxMin.z && z < BboxMax.z)
            return YES;
        //if(x >= -coord[2] && x < -coord[0] && z >= -coord[3] && z < -coord[1])
          //  return YES;
    }
    return NO;
}

- (void) moveObject:(NSString *)name matrix:(GLKMatrix4)matrix{
    for(Object *obj in objects){
        if([obj.getName isEqualToString:name]){
            float changeX = matrix.m30;
            float changeZ = matrix.m32;
            float* coord = [obj getCoordinates];
            [obj setCoordinates:coord[0]+changeX minZ:coord[1]+changeZ maxX:coord[2]+changeX maxZ:coord[3]+changeZ];
        }
    }
}
@end
