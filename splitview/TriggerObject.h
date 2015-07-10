//
//  Trigger.h
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#ifndef splitview_Trigger_h
#define splitview_Trigger_h
#import <GLKit/GLKit.h>
#import "Object.h"



@interface TriggerObject : Object{
    BOOL triggered;
    int levelNumber;
      float speed;
}

-(void)responseWhenItIsTriggered;
-(id)init:(NSString *)name levelNumber:(int)number;
-(int)getLevelNumber;
-(void) playAnimation;
@end

#endif
