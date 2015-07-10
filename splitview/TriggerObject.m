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
    self -> levelNumber = number;
    self -> speed = 0.01;
    triggered = NO;
    animationCounter = 0;
    return self;
}
-(void) responseWhenItIsTriggered{
    triggered = YES;
}

-(int) getLevelNumber{
    return levelNumber;
}
-(void) playAnimation{
    if(triggered && animationCounter<10){
        //TODO Animation
        GLKMatrix4 translationMatrix;
        
        translationMatrix = GLKMatrix4MakeTranslation(0.0f, -speed, 0.0f);
        self.modelMatrix = GLKMatrix4Multiply(self.modelMatrix, translationMatrix);
        
        animationCounter++;
    }
}
@end