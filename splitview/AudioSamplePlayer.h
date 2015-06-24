//
//  AudioSamplePlayer.h
//  sound_test
//
//  Created by MCP 2015 on 23/06/15.
//  Copyright (c) 2015 test. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <OpenAl/al.h>
#import <OpenAl/alc.h>
#include <AudioToolbox/AudioToolbox.h>

@interface AudioSamplePlayer : NSObject
- (void) preloadAudioSample:(NSString *)sampleName;
- (void) playAudioSample:(NSString *)sampleName;
- (void) stopAudioSample:(NSString *)sampleName;
@end