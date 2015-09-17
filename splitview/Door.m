//
//  Door.m
//  splitview
//
//  Created by Ali Arslan on 14.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Door.h"
#import "HeadPosition.h"

@implementation Door{
    GLKVector4 worldViewCenter;
    float dotViewDir;
    float dotUpDir;
    GLKVector3 BboxMax;
    GLKVector3 BboxMin;
    int animationCounter;
    bool hasAccess;
}

-(id)init:(NSString *)name Alignment :(BOOL)_zAligned{
    
    if(self = [super init:name Type:Door_]){
        self->openDoorDistLimit = 3.0;
        self->closed = true;
        self->partialOpen = false;
        self->zAligned = _zAligned;
        self->speed = 0.05;
    }
    
   
    animationCounter=0;
    return self;
}

-(void)calculateAttributes{
    
    [self calculateCenter];

    
    if (zAligned) {
        width = fabsf(self.maxZ) - fabsf(self.minZ);
    }else{
        width = fabsf(self.maxX) - fabsf(self.minX);
    }
    
    initialWorldCenter = GLKMatrix4MultiplyVector4([self initialModelMatrix], self->center);
    
    
    BboxMax = GLKVector3Make(self.maxX+4, 0.0f, self.maxZ+4);
    BboxMin = GLKVector3Make(self.minX-4, 0.0f, self.minZ-4);
    int deltaX = fabsf( BboxMax.x - BboxMin.x);
    int deltaZ = fabsf (BboxMax.z - BboxMin.z);
    if(deltaX>deltaZ){
        zAligned = NO;
    }
    else{
        zAligned = YES;
    }
    
    if([self.name isEqualToString:@"AirLock"])
        hasAccess = NO;
    else
        hasAccess = YES;
    
}

-(float)distanceFromCamera{
    GLKMatrix4 modelView = [self getModelView:Left];
    worldViewCenter = GLKMatrix4MultiplyVector4(modelView, self->center);
    GLKVector4 cameraForward =GLKMatrix4MultiplyVector4([HeadPosition lView], GLKVector4Make(0, 0, 1, 0));
    GLKVector4 cameraUp =GLKMatrix4MultiplyVector4([HeadPosition lView], GLKVector4Make(0, 1, 0, 0));
    dotViewDir = GLKVector4DotProduct(cameraForward, self->center);
    dotUpDir = GLKVector4DotProduct(cameraUp, self->center);
    self->distanceFromCamera = fabsf(worldViewCenter.z);
    return self->distanceFromCamera;
}

-(void)changeStateIfRequired{
    if(hasAccess){
        
        if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax] && animationCounter < 50){
            //open the door
            animationCounter++;
            if(zAligned){
                self.modelMatrix = GLKMatrix4Translate(self.modelMatrix, 0.0, 0.0, speed);
            }else{
                self.modelMatrix = GLKMatrix4Translate(self.modelMatrix, speed, 0.0, 0.0);
            }
        } else if([HeadPosition isHeadOutside:BboxMin BBoxMax:BboxMax] && animationCounter > 0){
            //close the door
            animationCounter--;
            if(zAligned){
                self.modelMatrix = GLKMatrix4Translate(self.modelMatrix, 0.0, 0.0, -speed);
            }else{
                self.modelMatrix = GLKMatrix4Translate(self.modelMatrix, -speed, 0.0, 0.0);
            }
            
        }
    
    }
   
    
    
    
    /*
    if ((closed || partialOpen) && [self distanceFromCamera] < self->openDoorDistLimit  && fabsf(dotViewDir)>4 && dotUpDir>0.80) { //open
        GLKMatrix4 translationMatrix;
        if(self->zAligned){
            translationMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, self->speed);
        }else{
            translationMatrix = GLKMatrix4MakeTranslation(self->speed, 0.0f, 0.0f);
        }
        
        self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, translationMatrix);
        
        partialOpen = true;

        GLKVector4 worldCenter =  GLKMatrix4MultiplyVector4(self.modelMatrix, self->center);
        
        if (zAligned) {
            if((fabsf(worldCenter.z) - fabsf(initialWorldCenter.z))> width*10){
                closed = false;
                partialOpen = false;
            }
        }else{
            if((fabsf(worldCenter.x) - fabsf(initialWorldCenter.x))> width*10){
                closed = false;
                partialOpen = false;
            }
        
        }
        
        
    }else if ((!closed || partialOpen) && [self distanceFromCamera] > self->openDoorDistLimit){ //close
        GLKMatrix4 translationMatrix;
        if(self->zAligned){
            translationMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -self->speed);
        }else{
            translationMatrix = GLKMatrix4MakeTranslation(-self->speed, 0.0f, 0.0f);
        }
        
        self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, translationMatrix);
        
        partialOpen = true;
        GLKVector4 worldCenter =  GLKMatrix4MultiplyVector4(self.modelMatrix, self->center);

        if(zAligned){
            if((worldCenter.z - fabsf(initialWorldCenter.z))< 0){
                closed = true;
                partialOpen = false;
            }
        }else{
            if((worldCenter.x - fabsf(initialWorldCenter.x))< 0){
                closed = true;
                partialOpen = false;
            }
        
        }
        
        
    }*/
    
}
-(BOOL) isClosed{
    return closed;
}

@end