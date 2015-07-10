//
//  ObjLoader.m
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "ObjLoader.h"

@implementation ObjLoader{
    NSMutableArray *PodRoom;
    NSMutableArray *AirLock;
    NSMutableArray *Hallway;
    
    //temprorary solution to be quick for the presentation. This will be erased when Object loading implemented for rendering only the current room that we are in.
    NSMutableArray *categorizedObjects;
}

@synthesize objects;

- (void)initWithPath:(NSString *)path {
    
    NSLog(@"path name : %@", path);
    
    // init Arrays for saving Data
    categorizedObjects = [NSMutableArray array];
    
    PodRoom = [NSMutableArray array];
    AirLock = [NSMutableArray array];
    Hallway = [NSMutableArray array];
    
    [categorizedObjects addObject:Hallway];
    [categorizedObjects addObject:PodRoom];
    [categorizedObjects addObject:AirLock];
 
    
    object = NULL;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"obj"];
    NSLog(@"%@", filePath);
    if (filePath) {
        NSString* content = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        if (content)
        {
            // separate by new line
            NSArray* allLines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            for (int i = 0; i < [allLines count]; i++) {
                // line string handling
                NSString* strInEachLine = [allLines objectAtIndex:i];
                // separated by space
                NSArray* singleLineStrs = [strInEachLine componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]];
                NSString *firstSymbol = [singleLineStrs objectAtIndex:0];
                
                if([firstSymbol isEqualToString:@"o"] || [firstSymbol isEqualToString:@"g"]){
                    
                    if(object!=NULL){
                        if ([object isKindOfClass:[Door class]]) {
                            [(Door*)object calculateAttributes];
                        }
                        [self addObject:object];
                    }
                    
                     @try {
                        NSString *typeAndNameStr = [singleLineStrs objectAtIndex:1];
                        NSArray* comps = [typeAndNameStr componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"_"]];
                        
                        NSString * name;
                        enum ObjectType type;
                        if([[comps objectAtIndex:0] isEqualToString:@"Prop"]){
                            type  = Prop;
                            name = [comps objectAtIndex:1];
                            //name = [NSString stringWithFormat:@"%@%@%@", [comps objectAtIndex:2], @"_", [comps objectAtIndex:1]];
                            object = [[Object alloc] init:name Type:type];
                        }else if ([[comps objectAtIndex:0] isEqualToString:@"DoorFrame"]){
                            type = DoorFrame;
                            name = [comps objectAtIndex:1];
                            object = [[Object alloc] init:name Type:type];
                        }else if ([[comps objectAtIndex:0] isEqualToString:@"Door"]){
                            name = [comps objectAtIndex:1];
                            object = [[Door alloc] init:name Alignment:YES];
                        }else if ([[comps objectAtIndex:0] isEqualToString:@"Room"]){
                            type = Room;
                            name = [comps objectAtIndex:1];
                            object = [[Object alloc] init:name Type:type];
                        }else if ([[comps objectAtIndex:0] isEqualToString:@"Light"]){
                            name = [comps objectAtIndex:1];
                            //name = [NSString stringWithFormat:@"%@%@%@", [comps objectAtIndex:1], @"_", [comps objectAtIndex:2]];
                            object = [[Light alloc] init:name];
                        }else{
                            [NSException raise:@"Invalid object Type and Name format or Value" format:@"Object name with header %@ is invalid", strInEachLine];
                        }
                     
                    
                         
                     }@catch (NSException * e) {
                         NSLog(@"Exception while setting name and type of object: %@", e);
                         [NSException raise:@"Invalid object Type and Name format or Value" format:@"Object name with header %@ is invalid", strInEachLine];
                     }
                }
                else if ([firstSymbol isEqualToString:@"v"]){
                    object.positionDim = (uint)[singleLineStrs count] - 1;
                    // NSLog(@"posDim : %d", object.positionDim);
                    [self addVertexFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"vn"]){
                    object.hasNormal = true;
                    object.normalDim = (uint)[singleLineStrs count] - 1;
                    //NSLog(@"object.normalDim : %d", object.normalDim);
                    [self addNormalFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"vt"]){
                    object.hasTexcoord = true;
                    object.texcoordDim = (uint)[singleLineStrs count] - 1;
                    //NSLog(@"TexcoordDim : %d", object.texcoordDim);
                    [self addTexCoordFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"f"]){
                    object.faceindiceDim = (uint)[singleLineStrs count];
                    //      NSLog(@"object.faceindiceDim : %d", object.faceindiceDim - 1);
                    [self addFaceIndicesFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"#"]){
                    NSLog(@"%@", strInEachLine);
                }
                else if ([firstSymbol isEqualToString:@" "]){
                    
                }
                else {
                    NSLog(@"warning: unhandled symbol : %@", firstSymbol);
                }
            }
            
            [self addObject:object];
        }
        
    }
    objects = [NSMutableArray arrayWithArray:Hallway];
    [objects addObjectsFromArray: PodRoom];
    [objects addObjectsFromArray:AirLock];
    
}

-(void) addObject : (Object*) _object{
    
    if ([_object.vIndices count] != [_object.tcIndices count] || [_object.vIndices count] != [_object.nIndices count] || [_object.nIndices count] != [_object.tcIndices count])
        NSLog(@"Error: face indices unequal!");
    _object.numFaces = (float)[_object.vIndices count] / _object.numVertexPerFace;
    NSLog(@"face counting : %.2f", (float)[_object.vIndices count] / _object.numVertexPerFace);
    NSLog(@"vertices counting : %.2f", (float)[_object.vertice count] / 3);
    NSLog(@"object.normal counting : %.2f", (float)[_object.normal count] / 3);
    NSLog(@"texcoord counting : %.2f", (float)[_object.texCoord count] / 2);
    
    if([_object.name isEqualToString:@"PodRoom"]){[PodRoom addObject:_object];}
    else if([_object.name isEqualToString:@"AirLock"]){[AirLock addObject:_object];}
    else if([_object.name isEqualToString:@"Hallway"]){[Hallway addObject:_object];}
    
    if(_object.type == DoorFrame){[Hallway addObject:_object];}
}

- (void)dealloc {
    
}

-(void)addVertexFromString:(NSArray *)stringArray
{
    if(object.vertice == nil){
        object.vertice = [[NSMutableArray alloc]init];
        object.minX = [[stringArray objectAtIndex:1] floatValue];
        object.maxX = [[stringArray objectAtIndex:1] floatValue];
        object.minZ = [[stringArray objectAtIndex:3] floatValue];
        object.maxZ = [[stringArray objectAtIndex:3] floatValue];
    }
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        float value = [[stringArray objectAtIndex:i] floatValue];
        if(i == 1){
            if (value < object.minX)
                object.minX = value;
            else if (value > object.maxX)
                object.maxX = value;
        } else if(i == 3){
            if (value < object.minZ)
                object.minZ = value;
            else if (value > object.maxZ)
                object.maxZ = value;
        }
        
        //NSLog(@"v %d : %.2f", i, value);
        [object.vertice addObject:[NSNumber numberWithFloat:value]];
    }
    
}

-(void)addNormalFromString:(NSArray *)stringArray
{
    if(object.normal == nil)
        object.normal = [[NSMutableArray alloc]init];
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        float value = [[stringArray objectAtIndex:i] floatValue];
        //NSLog(@"n %d : %.2f", i, value);
        [object.normal addObject:[NSNumber numberWithFloat:value]];
    }
}

-(void)addTexCoordFromString:(NSArray *)stringArray
{
    if(object.texCoord == nil)
        object.texCoord = [[NSMutableArray alloc]init];
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        float value = [[stringArray objectAtIndex:i] floatValue];
        //NSLog(@"tc %d : %.2f", i, value);
        [object.texCoord addObject:[NSNumber numberWithFloat:value]];
    }
}

-(void)addFaceIndicesFromString:(NSArray *)stringArray
{
    if(object.vIndices == nil)
        object.vIndices = [[NSMutableArray alloc]init];
    if(object.tcIndices == nil)
        object.tcIndices = [[NSMutableArray alloc]init];
    if(object.nIndices == nil)
        object.nIndices = [[NSMutableArray alloc]init];
    
    object.numVertexPerFace = (int)[stringArray count] - 1;
    
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        
        NSString *substring = [stringArray objectAtIndex:i];
        /* int vi = [[stringArray objectAtIndex:1] intValue];
         int tci = [[stringArray objectAtIndex:2] intValue];
         int ni = [[stringArray objectAtIndex:3] intValue];
         NSLog(@"%@ : %d %d %d", stringArray, vi, tci, ni);
         
         [object.vIndices addObject:[NSNumber numberWithInt:vi]];
         [object.tcIndices addObject:[NSNumber numberWithInt:tci]];
         [object.nIndices addObject:[NSNumber numberWithInt:ni]];
         
         */
        
        // separated by /
        NSArray* singleIndexs = [substring componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        
        int vi = [[singleIndexs objectAtIndex:0] intValue];
        int tci = [[singleIndexs objectAtIndex:1] intValue];
        int ni = [[singleIndexs objectAtIndex:2] intValue];
        //   NSLog(@"%@ : %d %d %d", substring, vi, tci, ni);
        
        [object.vIndices addObject:[NSNumber numberWithInt:vi]];
        [object.tcIndices addObject:[NSNumber numberWithInt:tci]];
        [object.nIndices addObject:[NSNumber numberWithInt:ni]];
        
    }
}
- (NSMutableArray*) getCategorizedObjects{
    return categorizedObjects;
}




@end
