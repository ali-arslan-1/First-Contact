//
//  Level.h
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#ifndef splitview_Level_h
#define splitview_Level_h

#import <Foundation/Foundation.h>
#import "AudioSamplePlayer.h"
#import "TriggerObject.h"

@interface Level : NSObject{
    AudioSamplePlayer *audioPlayer;
    
    NSString* narration;
    NSString* triggerSound;
    NSMutableArray* reminders;
    
    TriggerObject *trigger;
    float timeToWait;
}
-(id) initWithLevelNumber:(int) number Trigger:(TriggerObject*) _trigger;

-(void) playNarration;
-(TriggerObject*) getTriggerObject;
-(void) levelEnds;
@end

#endif
