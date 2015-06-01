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
    float rotationFactor;
}

- (id) init{
    self = [super init];
    objects = [NSMutableArray array];
    displacementFactor = 0.1f;
    rotationFactor = 0.1f;
    return self;
}

- (void) dealloc{
    //TO DO deallocate the array somehow || is the array allocated?
}

- (void) move:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix displacement: (GLKVector3) disp{
    
    
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Translate(*LviewMatrix, disp.x,disp.y,disp.z);
    GLKMatrix4 _newRightviewMatix = GLKMatrix4Translate(*RviewMatrix, disp.x,disp.y,disp.z);
    
 
 //   if (![self detectCollision: _newLeftViewMatrix] && ![self detectCollision:_newRightviewMatix] ){
        *LviewMatrix = _newLeftViewMatrix;
        *RviewMatrix = _newRightviewMatix;
  // }
    
}


- (void) rotate:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix axis: (GLKVector3) axis factor : (float)factor{
    
    /*GLKVector3 lTranslationVec = GLKVector3Make(LviewMatrix->m30, LviewMatrix->m31, LviewMatrix->m32);
    GLKVector3 rTranslationVec = GLKVector3Make(RviewMatrix->m30, RviewMatrix->m31, RviewMatrix->m32);

    *LviewMatrix = GLKMatrix4TranslateWithVector3(*LviewMatrix , lTranslationVec);
    *RviewMatrix = GLKMatrix4TranslateWithVector3(*RviewMatrix , rTranslationVec);
    */


    
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(factor, axis.x, axis.y, axis.z);
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Multiply(rotation, *LviewMatrix);
    GLKMatrix4 _newRightviewMatix = GLKMatrix4Multiply(rotation, *RviewMatrix);

    //GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Rotate(*LviewMatrix, factor, axis.x, axis.y, axis.z);
    //GLKMatrix4 _newRightviewMatix = GLKMatrix4Rotate(*RviewMatrix, factor, axis.x, axis.y, axis.z);
    

    
    
    /*
    _newLeftViewMatrix = GLKMatrix4Translate(_newLeftViewMatrix , -lTranslationVec.x, -lTranslationVec.y, -lTranslationVec.z);
    _newRightviewMatix = GLKMatrix4Translate(_newRightviewMatix , -rTranslationVec.x, -rTranslationVec.y, -rTranslationVec.z);

    */
    //GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Multiply(*LviewMatrix,GLKMatrix4MakeYRotation(rotationFactor));
    
    //GLKMatrix4 _newRightviewMatix = GLKMatrix4Multiply(*RviewMatrix,GLKMatrix4MakeYRotation(rotationFactor));
    
//  if (![self detectCollision: _newLeftViewMatrix] && ![self detectCollision:_newRightviewMatix] ){
    *LviewMatrix = _newLeftViewMatrix;
    *RviewMatrix = _newRightviewMatix;
//   }

    
}


- (void) moveForward:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, displacementFactor);
    
    [self move:LviewMatrix rightEye:RviewMatrix displacement:displacement];

}


- (void) moveBackward:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, -displacementFactor);
    
    [self move:LviewMatrix rightEye:RviewMatrix displacement:displacement];
    
}

- (void) moveLeft:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(displacementFactor, 0.0f, 0.0f);
    
    [self move:LviewMatrix rightEye:RviewMatrix displacement:displacement];
    
}


- (void) moveRight:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(-displacementFactor, 0.0f, 0.0f);
    
    [self move:LviewMatrix rightEye:RviewMatrix displacement:displacement];
    
}

- (void) moveDown:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, displacementFactor, 0.0f);
    
    [self move:LviewMatrix rightEye:RviewMatrix displacement:displacement];
    
}


- (void) moveUp:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, -displacementFactor, 0.0f);
    
    [self move:LviewMatrix rightEye:RviewMatrix displacement:displacement];
    
}

- (void) lookUp:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.1f, 0.0f, 0.0f);
    
    [self rotate:LviewMatrix rightEye:RviewMatrix axis:axis factor:-rotationFactor];
    
}

- (void) lookDown:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.1f, 0.0f, 0.0f);
    
    [self rotate:LviewMatrix rightEye:RviewMatrix axis:axis factor:rotationFactor];
    
}

- (void) lookLeft:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.0f, 0.1f, 0.0f);
    
    [self rotate:LviewMatrix rightEye:RviewMatrix axis:axis factor:-rotationFactor];
    
}

- (void) lookRight:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.0f, 0.1f, 0.0f);
    
    [self rotate:LviewMatrix rightEye:RviewMatrix axis:axis factor:rotationFactor];
    
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
