//
//  Level.m
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"
#import <AVFoundation/AVFoundation.h>

@implementation Level{
    int sequenceNumber;
    NSMutableArray* audioPlayers;
}

-(id) initWithLevelNumber:(int)number{
    audioPlayers =[NSMutableArray array];
    levelNumber = number;
    sequenceNumber = 0;
    return self;
}
-(void) loadLevel{
   AVAudioPlayer *_audioPlayer;
    for(NSString *name in narrations){
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
        [audioPlayers addObject:_audioPlayer];
    }
  /*  for (NSString *name in reminders) {
        [audioPlayer preloadAudioSample:name];
    }*/
}
-(void) setNarrations:(NSMutableArray *)setOfNarrations{
    narrations = setOfNarrations;
}
-(void) setReminders:(NSMutableArray *)setOfReminders{
    reminders = setOfReminders;
}
-(void) setTriggerObject:(TriggerObject *)triggerObj{
    trigger = triggerObj;
}
-(int) getLevelNumber{
    return levelNumber;
}
-(void) playNarration{
    AVAudioPlayer *_audioPlayer;
    NSString* narration = [narrations objectAtIndex:sequenceNumber];
    if(narration != nil){
        _audioPlayer = [audioPlayers objectAtIndex:sequenceNumber];
        [_audioPlayer play];
    //    [audioPlayer playAudioSample:narration];
        sequenceNumber++;
    }
}
-(void) playReminder{
    //////////////////TODO play random
}
-(TriggerObject*) getTriggerObject{
    return trigger;
}

-(void) levelEnds{
   // [audioPlayer shutdownAudioSamplePlayer];
}

@end