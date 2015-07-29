//
//  Trigger.m
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TriggerObject.h"

@implementation TriggerObject{
    int animationCounter;
}

-(id) init:(NSString *)name levelNumber:(int)number{
    self = [super init: name Type: Trigger];
    levelNumber = number;
    speed = 0.01;
    triggered = NO;
    animationCounter = 0;
    active = NO;
    return self;
}
-(void) responseWhenItIsTriggered{
    triggered = YES;
}

-(int) getLevelNumber{
    return levelNumber;
}
-(void) playAnimation{
    if(triggered && animationCounter<50){
        //TODO Animation
        GLKMatrix4 translationMatrix;
        
        translationMatrix = GLKMatrix4MakeTranslation(0.0f, -speed, 0.0f);
        self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, translationMatrix);
        
        animationCounter++;
    }
}
-(void) activate{
    active = YES;
}
-(void) deactivate{
    active = NO;
}
-(BOOL) isActive{
    return active;
}
@end