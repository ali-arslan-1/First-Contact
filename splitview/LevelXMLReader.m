
//
//  MyData.m
//  XMLDeneme
//
//  Created by MCP 2014 on 27/07/15.
//  Copyright (c) 2015 MCP 2014. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LevelXMLReader.h"

@implementation LevelXMLReader{
  
}

-(BOOL)parseDocumentWithData:(NSData *)data {
    if (data == nil)
        return NO;
    levels = [NSMutableArray array];
    
    narration = NO;
    reminder = NO;
    
    // this is the parsing machine
    NSXMLParser *xmlparser = [[NSXMLParser alloc] initWithData:data];

    // this class will handle the events
    [xmlparser setDelegate:self];
    [xmlparser setShouldResolveExternalEntities:NO];
    
    // now parse the document
    BOOL ok = [xmlparser parse];
    if (ok == NO)
        NSLog(@"XML File could not be parsed");
    else
        NSLog(@"XML File is parsed successfully");
    
   // [xmlparser release];
    return ok;
}
-(NSMutableArray*) getLevels{
    return levels;
}

/*
-(void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"didStartDocument");
}

-(void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"didEndDocument");
}
*/
-(void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
 /*   NSLog(@"didStartElement: %@", elementName);
    
    if (namespaceURI != nil)
        NSLog(@"namespace: %@", namespaceURI);
    
    if (qName != nil)
        NSLog(@"qualifiedName: %@", qName);
 */
    // print all attributes for this element
    if([elementName isEqualToString:@"Level"]){
        NSEnumerator *attribs = [attributeDict keyEnumerator];
        NSString *key, *value;
        int levelNumber;
        while((key = [attribs nextObject]) != nil) {
            value = [attributeDict objectForKey:key];
     //       NSLog(@"  attribute: %@ = %@", key, value);
            if([key isEqualToString:@"ID"]){
                levelNumber = (int)[value integerValue];
                currentLevel = [[Level alloc] initWithLevelNumber:levelNumber];
                narrations = [NSMutableArray array];
                reminders = [NSMutableArray array];
                sequence = [NSMutableArray array];
                break;
            }
        }
    } else if ([elementName isEqualToString:@"narration"]){
        narration = YES;
    } else if ([elementName isEqualToString:@"reminder"]){
        reminder = YES;
    } else if ([elementName isEqualToString:@"Wait"]){
        Wait = YES;
    } else if ([elementName isEqualToString:@"TriggerActive"]){
        TriggerActive = YES;
    }
    
    // add code here to load any data members
    // that your custom class might have
    
}
-(void) parser:(NSXMLParser *) parser foundCharacters:(NSString *)string{
    string = [string stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    string = [string stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    if(string != nil && ![string isEqualToString:@""]){
      //  NSLog(@"Processing Value:%@", string);
        NSString* SequenceElement;
        if(narration){
            [narrations addObject:string];
            narration = NO;
            SequenceElement = [NSString stringWithFormat:@"Narration_%@",string];
        } else if (Wait){
            SequenceElement = [NSString stringWithFormat:@"Wait_%@",string];
            Wait = NO;
        } else if (TriggerActive){
            SequenceElement = [NSString stringWithFormat:@"TriggerActive_%@",string];
            TriggerActive = NO;
        }
        if(SequenceElement != nil)
            [sequence addObject:SequenceElement];
        if (reminder){
            [reminders addObject:string];
            reminder = NO;
        }
    }
}

-(void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
  //  NSLog(@"didEndElement: %@", elementName);
    if([elementName isEqualToString:@"Level"]){
        [currentLevel setNarrations:narrations];
        [currentLevel setReminders:reminders];
        [currentLevel setSequence:sequence];
        [levels addObject:currentLevel];
    }
    
}

// error handling
-(void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError {
    NSLog(@"XMLParser error: %@", [parseError localizedDescription]);
}

-(void)parser:(NSXMLParser *)parser validationErrorOccurred:(NSError *)validationError {
    NSLog(@"XMLParser error: %@", [validationError localizedDescription]);
}

@end