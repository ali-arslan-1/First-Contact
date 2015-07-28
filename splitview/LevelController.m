//
//  LevelController.m
//  XMLDeneme
//
//  Created by MCP 2014 on 28/07/15.
//  Copyright (c) 2015 MCP 2014. All rights reserved.
//

#import "LevelController.h"
#import "LevelXMLReader.h"


@implementation LevelController

-(id) initwithLevelXML:(NSString *)xmlName{
    currentLevelNumber=-1;
    
    //Read data from XML
    NSString *XMLFilePath = [[NSBundle mainBundle] pathForResource:xmlName ofType:@"xml"];
    NSData *data = [NSData dataWithContentsOfFile:XMLFilePath];
    LevelXMLReader *levelXMLReader = [[LevelXMLReader alloc] init];
    [levelXMLReader parseDocumentWithData:data];
    levels = [levelXMLReader getLevels];
    return  self;
}
-(Level*) getNextLevel{
    currentLevelNumber++;
    return [levels objectAtIndex:currentLevelNumber];
}
-(void) assignTriggersToLevels:(ObjLoader*) objLoader{
    for (Level* level in levels) {
        int levelNumber = [level getLevelNumber];
        [level setTriggerObject:[objLoader getTriggerForLevel:levelNumber]];
    }
}

@end