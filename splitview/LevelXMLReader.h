//
//  MyData.h
//  XMLDeneme
//
//  Created by MCP 2014 on 27/07/15.
//  Copyright (c) 2015 MCP 2014. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "Level.h"

@interface LevelXMLReader : NSObject <NSXMLParserDelegate> {
    Level* currentLevel;
    NSMutableArray* levels;
    NSMutableArray* narrations;
    NSMutableArray* reminders;
    NSMutableArray* sequence;
    BOOL narration;
    BOOL reminder;
    BOOL Wait;
    BOOL TriggerActive;
}

-(BOOL)parseDocumentWithData:(NSData *)data;
-(NSMutableArray*) getLevels;
@end