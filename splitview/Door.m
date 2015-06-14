//
//  Door.m
//  splitview
//
//  Created by Ali Arslan on 14.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Door.h"

@implementation Door

-(void)calculateCenter{
    
    float avgX = 0;
    float avgY = 0;
    float avgZ = 0;
    
    for (int i=0; i<self.vertice.count; i++) {
        if(i%3 == 0){
            avgX+=[[self.vertice objectAtIndex:i] floatValue];
        }else if(i%2==0){
            avgZ+=[[self.vertice objectAtIndex:i] floatValue];
        }else{
            avgY+=[[self.vertice objectAtIndex:i] floatValue];
        }
    }
    
    

    avgX = avgX/(self.vertice.count/3);
    avgY = avgY/(self.vertice.count/3);
    avgZ = avgZ/(self.vertice.count/3);

    self->center = GLKVector4Make(avgX, avgY, avgZ,1.0);
    
    
    
}

-(float)distanceFromCamera{
    GLKMatrix4 modelView = [self getModelView:Left];
    GLKVector4 res = GLKMatrix4MultiplyVector4(modelView, self->center);
    self->distanceFromCamera = fabsf(res.z);
    return self->distanceFromCamera;
}

-(void)open{
    self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.05f));
}

@end