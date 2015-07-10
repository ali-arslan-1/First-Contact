//
//  Level.m
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"

@implementation Level

-(id) initWithLevelNumber:(int)number Trigger:(TriggerObject *)_trigger{
    
    audioPlayer = [[AudioSamplePlayer alloc] init];
    
    self -> trigger = _trigger;
    [self loadLevel:number];
    
    return self;
}
-(void) loadLevel:(int)number{
    //Temprorary loader until xml
    if (number == 0) {
        narration = @"1-GoodMorningInitiator";
        
    } else if ( number == 1){
        narration = @"2-IncreaseThePower";
    }
    [audioPlayer preloadAudioSample: narration];
}

-(void) playNarration{
    [audioPlayer playAudioSample:narration];
}

-(TriggerObject*) getTriggerObject{
    return trigger;
}

-(void) levelEnds{
    [audioPlayer shutdownAudioSamplePlayer];
}

@end