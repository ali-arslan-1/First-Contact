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
#import <AVFoundation/AVFoundation.h>
#import "TriggerObject.h"

@interface Level : NSObject <AVAudioPlayerDelegate> {    
    NSString* triggerSound;
    NSMutableArray* narrations;
    NSMutableArray* reminders;
    NSMutableArray* sequence;
    int levelNumber;
    
    TriggerObject *trigger;
}
-(id) initWithLevelNumber:(int) number;
-(void) setNarrations:(NSMutableArray*) setOfNarrations;
-(void) setReminders:(NSMutableArray*) setOfReminders;
-(void) setSequence:(NSMutableArray*) setOfSequence;
-(void) setTriggerObject:(TriggerObject*) triggerObj;
-(int) getLevelNumber;
-(void) loadLevel;
-(TriggerObject*) getTriggerObject;
-(void) levelEnds;
@end

#endif
