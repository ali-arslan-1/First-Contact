//
//  AudioSamplePlayer.m
//  sound_test
//
//  Created by MCP 2015 on 23/06/15.
//  Copyright (c) 2015 test. All rights reserved.
//

//Code Summary
//1) get the device
//2) make a context with the device
//3) put some data into a buffer
//4) attach the buffer to a source
//5) play the source


#import "AudioSamplePlayer.h"
#define kMaxConcurrentSources 32
#define kMaxBuffers 256
#define kSampleRate 44100

@implementation AudioSamplePlayer

static ALCdevice *openALDevice;
static ALCcontext *openALContext;

// TODO sources should be divided for non interrupted audio and sound effects, otherwise sound effects overload the sources and interrupts all audio
static NSMutableArray *audioSampleSources;
static NSMutableDictionary *audioSampleBuffers;
static NSMutableDictionary *audioSourcesBinded;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Open AVAudioSession somehow... Suitable reaction when app is interrupted by a phone call
        
        
        //1) get the device
        openALDevice = alcOpenDevice(NULL);
        //2) make a context with the device (Air)
        openALContext = alcCreateContext(openALDevice, NULL);
        alcMakeContextCurrent(openALContext);
        
        audioSampleSources = [[NSMutableArray alloc] init];
        audioSampleBuffers = [[NSMutableDictionary alloc] init];
        audioSourcesBinded = [[NSMutableDictionary alloc] init];
        
        ALuint sourceID;
        for (int i = 0; i < kMaxConcurrentSources; i++) {
            /* Create a single OpenAL source */
            alGenSources(1, &sourceID);
            /* Add the source to the audioSampleSources array */
            [audioSampleSources addObject:[NSNumber numberWithUnsignedInt:sourceID]];
        }
    }
    return self;
}

- (void) preloadAudioSample:(NSString *)sampleName
{
    if ([audioSampleBuffers objectForKey:sampleName])
    {
        return;
    }
    
    if ([audioSampleBuffers count] > kMaxBuffers) {
        NSLog(@"Warning: You are trying to create more than 256 buffers! This is not allowed.");
        return;
    }
    
    NSString *audioFilePath = [[NSBundle mainBundle] pathForResource:sampleName ofType:@"caf"];
    
    AudioFileID afid = [self openAudioFile:audioFilePath];
    
    UInt32 audioFileSizeInBytes = [self getSizeOfAudioComponent:afid];
    
    void *audioData = malloc(audioFileSizeInBytes);
    
    OSStatus readBytesResult = AudioFileReadBytes(afid, false, 0, &audioFileSizeInBytes, audioData);
    
    if (0 != readBytesResult)
    {
        NSLog(@"An error occurred when attempting to read data from audio file %@: %d", audioFilePath, (int)readBytesResult);
    }
    
    AudioFileClose(afid);
    
    ALuint outputBuffer;
    alGenBuffers(1, &outputBuffer);
    
    alBufferData(outputBuffer, AL_FORMAT_STEREO16, audioData, audioFileSizeInBytes, kSampleRate);

    
    [audioSampleBuffers setObject:[NSNumber numberWithUnsignedInteger:outputBuffer] forKey:sampleName];
    
    if (audioData)
    {
        free(audioData);
        audioData = NULL;
    }
}

- (AudioFileID) openAudioFile:(NSString *)audioFilePathAsString
{
    NSURL *audioFileURL = [NSURL fileURLWithPath:audioFilePathAsString];
    
    AudioFileID afid;
    OSStatus openAudioFileResult = AudioFileOpenURL((__bridge CFURLRef)audioFileURL, kAudioFileReadPermission, 0, &afid);
    
    if (0 != openAudioFileResult)
    {
        NSLog(@"An error occurred when attempting to open the audio file %@: %d", audioFilePathAsString, (int)openAudioFileResult);
        
    }
    
    return afid;
}

- (UInt32) getSizeOfAudioComponent:(AudioFileID)afid
{
    UInt64 audioDataSize = 0;
    UInt32 propertySize = sizeof(UInt64);
    
    OSStatus getSizeResult = AudioFileGetProperty(afid, kAudioFilePropertyAudioDataByteCount, &propertySize, &audioDataSize);
    
    if (0 != getSizeResult)
    {
        NSLog(@"An error occurred when attempting to determine the size of audio file.");
    }
    
    return (UInt32)audioDataSize;
}

- (void) playAudioSample:(NSString *)sampleName
{
    ALuint source = [self getNextAvailableSource];
    
    alSourcef(source, AL_PITCH, 1.0f);
    alSourcef(source, AL_GAIN, 1.0f);
    
    ALuint outputBuffer = (ALuint)[[audioSampleBuffers objectForKey:sampleName] unsignedIntegerValue];
    
    alSourcei(source, AL_BUFFER, outputBuffer);
  
    alSourcePlay(source);
    
    [audioSourcesBinded setObject:[NSNumber numberWithUnsignedInteger:source] forKey: sampleName];
}

- (void) stopAudioSample:(NSString *)sampleName
{
    NSNumber *sourceID = [audioSourcesBinded objectForKey:sampleName];
    if(sourceID == NULL)
        return;
    ALuint source = (ALuint)[sourceID unsignedIntegerValue];
    alSourceStop(source);
    [audioSourcesBinded removeObjectForKey:sampleName];
}

- (ALuint) getNextAvailableSource
{
    ALint sourceState;
    for (NSNumber *sourceID in audioSampleSources) {
        alGetSourcei([sourceID unsignedIntValue], AL_SOURCE_STATE, &sourceState);
        if (sourceState != AL_PLAYING)
        {
            return [sourceID unsignedIntValue];
        }
    }
    
    ALuint sourceID = [[audioSampleSources objectAtIndex:0] unsignedIntegerValue];
    alSourceStop(sourceID);
    return sourceID;
}
- (void) shutdownAudioSamplePlayer
{
    ALint source;
    for (NSNumber *sourceValue in audioSampleSources)
    {
        NSUInteger sourceID = [sourceValue unsignedIntValue];
        alGetSourcei(sourceID, AL_SOURCE_STATE, &source);
        alSourceStop(sourceID);
        alDeleteSources(1, &sourceID);
    }
    [audioSampleSources removeAllObjects];
    
    NSArray *bufferIDs = [audioSampleBuffers allValues];
    for (NSNumber *bufferValue in bufferIDs)
    {
        NSUInteger bufferID = [bufferValue unsignedIntValue];
        alDeleteBuffers(1, &bufferID);
    }
    [audioSampleBuffers removeAllObjects];
    
    alcDestroyContext(openALContext);
    
    alcCloseDevice(openALDevice);
}


@end
