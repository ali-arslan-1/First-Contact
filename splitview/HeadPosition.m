//
//  HeadPosition.m
//  splitview-motion
//
//  Created by MCP 2015 on 04/05/15.
//
//
//  Modified by Ali Arslan on 26/05/15
//  -Parameters changed to pointer type for move method
//  -Other movements added i.e. left, right, forward, backward
//

#import "HeadPosition.h"


@implementation HeadPosition{
    NSMutableArray *objects;
    GLKMatrix4 matrices[2];
    GLKMatrix4 oldMatrices[2];
    float displacementFactor;
}

- (id) init{
    self = [super init];
    objects = [NSMutableArray array];
    displacementFactor = 0.3f;
    return self;
}

- (void) dealloc{
    //TO DO deallocate the array somehow || is the array allocated?
}

- (void) move:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatix displacement: (GLKVector3) disp{
    
    
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Translate(*LviewMatrix, disp.x,disp.y,disp.z);
    GLKMatrix4 _newRigntviewMatix = GLKMatrix4Translate(*RviewMatix, disp.x,disp.y,disp.z);
    
    
    if (![self detectCollision: _newLeftViewMatrix] && ![self detectCollision:_newRigntviewMatix] ){
        *LviewMatrix = _newLeftViewMatrix;
        *RviewMatix = _newRigntviewMatix;
        
    }
    
}


- (void) moveForward:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, displacementFactor);
    
    [self move:LviewMatrix rightEye:RviewMatix displacement:displacement];

}


- (void) moveBackward:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, -displacementFactor);
    
    [self move:LviewMatrix rightEye:RviewMatix displacement:displacement];
    
}

- (void) moveLeft:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(displacementFactor, 0.0f, 0.0f);
    
    [self move:LviewMatrix rightEye:RviewMatix displacement:displacement];
    
}


- (void) moveRight:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(-displacementFactor, 0.0f, 0.0f);
    
    [self move:LviewMatrix rightEye:RviewMatix displacement:displacement];
    
}

- (void) addObject :(Object*) object{
    
    [objects addObject:object];
}

- (BOOL) detectCollision: (GLKMatrix4) matrix{
    
    for(Object *obj in objects){
        //float* coord = [obj getCoordinates];
        GLKVector4 BboxMin = GLKVector4Make(obj.maxX, 0.0f, obj.maxZ, 1.0f);
        GLKVector4 BboxMax = GLKVector4Make(obj.minX, 0.0f, obj.minZ, 1.0f);
        
        //Compute the camera coordinates of Bbox
        BboxMin = GLKMatrix4MultiplyVector4(matrix, BboxMin);
        BboxMax = GLKMatrix4MultiplyVector4(matrix, BboxMax);
        
        //check at the camera coordinates if the object hits to camera
        if((BboxMin.z >= 0 && BboxMin.z < 1) || (BboxMax.z >= 0 && BboxMax.z < 1))
            return YES;
        
    }
    return NO;
}



@end
