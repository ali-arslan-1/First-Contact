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
#import <GLKit/GLKit.h>

@implementation HeadPosition{
    NSMutableArray *objects;
    GLKMatrix4 matrices[2];
    GLKMatrix4 oldMatrices[2];
    float displacementFactor;
    float rotationFactor;
}

static GLKMatrix4 lView;
static GLKMatrix4 rView;
static GLKMatrix4 projection;

+ (GLKMatrix4)lView{
    @synchronized(self) {
        return lView;
    }
}

+ (GLKMatrix4)rView{
    @synchronized(self) {
        return rView;
    }
}

+ (GLKMatrix4)projection{
    @synchronized(self) {
        return projection;
    }
}

+ (void)setLView:(GLKMatrix4) val{
    @synchronized(self) {
        lView= val;
    }
    
}

+ (void)setRView:(GLKMatrix4) val{
    @synchronized(self) {
        rView= val;
    }
}

+ (void)setProjection:(GLKMatrix4) val{
    @synchronized(self) {
        projection = val;
    }
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

- (void) move:(GLKVector3) disp{
    
    
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Translate(lView, disp.x,disp.y,disp.z);
    GLKMatrix4 _newRightviewMatix = GLKMatrix4Translate(rView, disp.x,disp.y,disp.z);
    
 
   // if (![self detectCollision: _newLeftViewMatrix] && ![self detectCollision:_newRightviewMatix] ){
        lView = _newLeftViewMatrix;
        rView = _newRightviewMatix;
  // }
    
}


- (void) rotate:(GLKVector3) axis factor : (float)factor{
    
    /*GLKVector3 lTranslationVec = GLKVector3Make(LviewMatrix->m30, LviewMatrix->m31, LviewMatrix->m32);
    GLKVector3 rTranslationVec = GLKVector3Make(RviewMatrix->m30, RviewMatrix->m31, RviewMatrix->m32);

    lView = GLKMatrix4TranslateWithVector3(lView , lTranslationVec);
    rView = GLKMatrix4TranslateWithVector3(rView , rTranslationVec);
    */


    
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(factor, axis.x, axis.y, axis.z);
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Multiply(rotation, lView);
    GLKMatrix4 _newRightviewMatix = GLKMatrix4Multiply(rotation, rView);

    //GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Rotate(lView, factor, axis.x, axis.y, axis.z);
    //GLKMatrix4 _newRightviewMatix = GLKMatrix4Rotate(rView, factor, axis.x, axis.y, axis.z);
    

    
    
    /*
    _newLeftViewMatrix = GLKMatrix4Translate(_newLeftViewMatrix , -lTranslationVec.x, -lTranslationVec.y, -lTranslationVec.z);
    _newRightviewMatix = GLKMatrix4Translate(_newRightviewMatix , -rTranslationVec.x, -rTranslationVec.y, -rTranslationVec.z);

    */
    //GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Multiply(lView,GLKMatrix4MakeYRotation(rotationFactor));
    
    //GLKMatrix4 _newRightviewMatix = GLKMatrix4Multiply(rView,GLKMatrix4MakeYRotation(rotationFactor));
    
//  if (![self detectCollision: _newLeftViewMatrix] && ![self detectCollision:_newRightviewMatix] ){
    lView = _newLeftViewMatrix;
    rView = _newRightviewMatix;
  // }

    
}

- (BOOL) detectCollision: (GLKMatrix4) matrix{
    
    for(Object *obj in objects){
        //float* coord = [obj getCoordinates];
        GLKVector4 BboxMin = GLKVector4Make(obj.maxX, 0.0f, obj.maxZ, 1.0f);
        GLKVector4 BboxMax = GLKVector4Make(obj.minX, 0.0f, obj.minZ, 1.0f);
        GLKVector4 BboxMin2 = BboxMin;
        GLKVector4 BboxMax2 = BboxMax;
        
        //Compute the camera coordinates of Bbox
        BboxMin = GLKMatrix4MultiplyVector4(matrix, BboxMin);
        BboxMax = GLKMatrix4MultiplyVector4(matrix, BboxMax);
        
        GLKMatrix4 rot = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(90.0f),0.0,1.0,0.0);
        GLKMatrix4 horizontalMatrix = GLKMatrix4Multiply(rot, matrix);
        
        BboxMin2 = GLKMatrix4MultiplyVector4(horizontalMatrix, BboxMin2);
        BboxMax2 = GLKMatrix4MultiplyVector4(horizontalMatrix, BboxMax2);
        
        
        //check at the camera coordinates if the object hits to camera
        if((BboxMin.z >= -0.2 && BboxMin.z < 0.2) || (BboxMax.z >= -0.2 && BboxMax.z < 0.2))
            return YES;
        
      /*  if((BboxMin.x >= -1.0 && BboxMin.x < 1.0) || (BboxMax.x >= -1.0 && BboxMax.x < 1.0))
            return YES;*/
       /* if((BboxMin2.z >= -0.2 && BboxMin2.z < 0.2) || (BboxMax2.z >= -0.2 && BboxMax2.z < 0.2))
            return YES;
       */
        
        
        
    }
    return NO;
}



- (void) moveForward{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, displacementFactor);
    
    [self move:displacement];

}


- (void) moveBackward{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, -displacementFactor);
    
    [self move:displacement];
    
}

- (void) moveLeft{
    
    
    
    GLKVector3 displacement = GLKVector3Make(displacementFactor, 0.0f, 0.0f);
    
    [self move:displacement];
    
}


- (void) moveRight{
    
    
    
    GLKVector3 displacement = GLKVector3Make(-displacementFactor, 0.0f, 0.0f);
    
    [self move:displacement];
    
}

- (void) moveDown{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, displacementFactor, 0.0f);
    
    [self move:displacement];
    
}


- (void) moveUp{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, -displacementFactor, 0.0f);
    
    [self move:displacement];
    
}

- (void) lookUp{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.1f, 0.0f, 0.0f);
    
    [self rotate:axis factor:-rotationFactor];
    
}

- (void) lookDown{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.1f, 0.0f, 0.0f);
    
    [self rotate:axis factor:rotationFactor];
    
}

- (void) lookLeft{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.0f, 0.1f, 0.0f);
    
    [self rotate:axis factor:-rotationFactor];
    
}

- (void) lookRight{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.0f, 0.1f, 0.0f);
    
    [self rotate:axis factor:rotationFactor];
    
}


- (void) addObjects :(NSMutableArray*) newObjects{
    for(Object *obj in newObjects){
        [objects addObject:obj];
    }
}




@end
