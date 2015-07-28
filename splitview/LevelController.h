//
//  LevelController.h
//  XMLDeneme
//
//  Created by MCP 2014 on 28/07/15.
//  Copyright (c) 2015 MCP 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Level.h"
#import "ObjLoader.h"

@interface LevelController : NSObject{
    int currentLevelNumber;
    NSMutableArray* levels;
}
-(id) initwithLevelXML:(NSString*) xmlName;
-(void) assignTriggersToLevels:(ObjLoader*) objLoader;
-(Level*) getNextLevel;
@end

