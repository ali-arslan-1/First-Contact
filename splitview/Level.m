//
//  Level.m
//  splitview
//
//  Created by MCP 2015 on 10/07/15.
//  Copyright (c) 2015 AR/VR Group E. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"
#include <stdlib.h>



@implementation Level{
    int sequenceNumber;
    NSMutableDictionary* audioPlayers;
    NSTimer *repeatingTimer;
}


-(id) initWithLevelNumber:(int)number{
    audioPlayers =[[NSMutableDictionary alloc] init];
    levelNumber = number; 
    sequenceNumber = 0;
    return self;
}
-(void) loadLevel{
   
    for(NSString *name in narrations){
        [self preloadAudio:name];
    }
    for (NSString *name in reminders) {
        [self preloadAudio:name];
    }
    [self doNextSequence];
}
-(void) preloadAudio:(NSString*) name{
    AVAudioPlayer *_audioPlayer;
    NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"mp3"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    _audioPlayer = [[AVAudioPlayer alloc] initWithData:data error:nil];
    [audioPlayers setObject:_audioPlayer forKey:name];

}
-(void) setNarrations:(NSMutableArray *)setOfNarrations{
    narrations = setOfNarrations;
}
-(void) setReminders:(NSMutableArray *)setOfReminders{
    reminders = setOfReminders;
}
-(void) setSequence:(NSMutableArray *)setOfSequence{
    sequence = setOfSequence;
}
-(void) setTriggerObject:(TriggerObject *)triggerObj{
    trigger = triggerObj;
}
-(int) getLevelNumber{
    return levelNumber;
}
-(void) playNarration:(NSString*) name{
    AVAudioPlayer *_audioPlayer;
    if(name != nil){
        _audioPlayer = [audioPlayers objectForKey:name];
        _audioPlayer.delegate = self;
        [_audioPlayer play];
    }
}
-(void) playReminder{
    AVAudioPlayer *_audioPlayer;
    int numberOfReminders = (int)[reminders count];
    int randomNumber = arc4random_uniform(numberOfReminders);
    NSString* reminder = [reminders objectAtIndex:randomNumber];
    if(reminder != nil){
        _audioPlayer = [audioPlayers objectForKey:reminder];
        [_audioPlayer play];
    }
}
-(TriggerObject*) getTriggerObject{
    return trigger;
}

-(void) doNextSequence{
    if(sequenceNumber < [sequence count]){
        NSString* currentSequence = [sequence objectAtIndex:sequenceNumber];
        
        NSArray* tokens = [currentSequence componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"_"]];
        NSString* sequenceType = [tokens objectAtIndex:0];
        NSString* sequenceValue = [tokens objectAtIndex:1];
        
        if([sequenceType isEqualToString:@"Narration"]){
            [self playNarration:sequenceValue];
        } else if ([sequenceType isEqualToString:@"Wait"]){
            [self startOneOffTimer:self timeToWait:[sequenceValue doubleValue]];
            
        } else if ([sequenceType isEqualToString:@"TriggerActive"]){
            if([sequenceValue isEqualToString:@"true"]){
                [trigger activate];
                [self startRepeatingTimer:self];
            }else{
                [trigger deactivate];
            }
            sequenceNumber++;
            [self doNextSequence];
        }
        sequenceNumber++;
    }
}
-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    [self doNextSequence];
}
-(void) levelEnds{
    [repeatingTimer invalidate];
    repeatingTimer = nil;
    audioPlayers = nil;
}
- (IBAction)startOneOffTimer:sender timeToWait:(NSTimeInterval) time{
    [NSTimer scheduledTimerWithTimeInterval:time
                                     target:self
                                   selector:@selector(doNextSequence)
                                   userInfo:[self userInfo]
                                    repeats:NO];
}
- (IBAction)startRepeatingTimer:sender {
    
    // Cancel a preexisting timer.
    [repeatingTimer invalidate];
    
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:60
                                                      target:self selector:@selector(playReminder)
                                                    userInfo:[self userInfo] repeats:YES];
    repeatingTimer = timer;
}
- (NSDictionary *)userInfo {
    return @{ @"StartDate" : [NSDate date] };
}

@end