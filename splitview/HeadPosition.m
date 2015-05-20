//
//  HeadPosition.m
//  splitview-motion
//
//  Created by MCP 2015 on 04/05/15.
//

#import "HeadPosition.h"


@implementation HeadPosition{
    NSMutableArray *objects;
    GLKMatrix4 matrices[2];
    GLKMatrix4 oldMatrices[2];
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
    
    
    oldMatrices[0] = LviewMatrix;
    oldMatrices[1] = RviewMatix;
    
    matrices[0] = GLKMatrix4Translate(LviewMatrix, 0.0, 0.0, 0.5);
    matrices[1] = GLKMatrix4Translate(RviewMatix, 0.0, 0.0, 0.5);
    
    if ([self detectCollision: matrices[0]])
        return oldMatrices;
    else if ([self detectCollision:matrices[1]])
        return oldMatrices;
    return matrices;
}

- (void) addObject :(Object*) object{
    
    [objects addObject:object];
}

- (BOOL) detectCollision: (GLKMatrix4) matrix{
    
    for(Object *obj in objects){
        float* coord = [obj getCoordinates];
        GLKVector4 BboxMin = GLKVector4Make(coord[2], 0.0f, coord[3], 1.0f);
        GLKVector4 BboxMax = GLKVector4Make(coord[0], 0.0f, coord[1], 1.0f);
        
        //Compute the camera coordinates of Bbox
        BboxMin = GLKMatrix4MultiplyVector4(matrix, BboxMin);
        BboxMax = GLKMatrix4MultiplyVector4(matrix, BboxMax);
        
        //check at the camera coordinates if the object hits to camera
        if(BboxMin.z >= 0 || BboxMax.z >= 0)
            return YES;
        
    }
    return NO;
}


//transform object only translate wise. No rotation no scaling!
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
