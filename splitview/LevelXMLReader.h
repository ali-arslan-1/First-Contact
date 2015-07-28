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
    // add any data members that you need here
}

-(BOOL)parseDocumentWithData:(NSData *)data;
-(NSMutableArray*) getLevels;
@end