//
//  Trigger.m
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TriggerObject.h"

@implementation TriggerObject

-(id) init:(NSString *)name levelNumber:(int)number{
    self = [super init: name Type: Trigger];
    self -> levelNumber = number;
    return self;
}
-(void) responseWhenItIsTriggered{
    //TODO Animation
}
-(int) getLevelNumber{
    return levelNumber;
}
@end