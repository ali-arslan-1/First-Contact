//
//  ObjLoader.m
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "ObjLoader.h"

@implementation ObjLoader

@synthesize object;
@synthesize objects;

- (void)initWithPath:(NSString *)path {
    
    NSLog(@"path name : %@", path);
    
    // init Arrays for saving Data
    objects = [NSMutableArray array];
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
                    if(object == NULL)
                        object = [[Object alloc] init];
                    else{
                        [objects addObject:object];
                        
                        if ([object.vIndices count] != [object.tcIndices count] || [object.vIndices count] != [object.nIndices count] || [object.nIndices count] != [object.tcIndices count])
                            NSLog(@"Error: face indices unequal!");
                        object.numFaces = (float)[object.vIndices count] / object.numVertexPerFace;
                        NSLog(@"face counting : %.2f", (float)[object.vIndices count] / object.numVertexPerFace);
                        NSLog(@"vertices counting : %.2f", (float)[object.vertice count] / 3);
                        NSLog(@"object.normal counting : %.2f", (float)[object.normal count] / 3);
                        NSLog(@"texcoord counting : %.2f", (float)[object.texCoord count] / 2);
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
            [objects addObject:object];
            if ([object.vIndices count] != [object.tcIndices count] || [object.vIndices count] != [object.nIndices count] || [object.nIndices count] != [object.tcIndices count])
                NSLog(@"Error: face indices unequal!");
            object.numFaces = (float)[object.vIndices count] / object.numVertexPerFace;
            NSLog(@"face counting : %.2f", (float)[object.vIndices count] / object.numVertexPerFace);
            NSLog(@"vertices counting : %.2f", (float)[object.vertice count] / 3);
            NSLog(@"object.normal counting : %.2f", (float)[object.normal count] / 3);
            NSLog(@"texcoord counting : %.2f", (float)[object.texCoord count] / 2);
        }
        
    }
}

- (void)dealloc {
    
}

-(void)addVertexFromString:(NSArray *)stringArray
{
    if(object.vertice == nil)
        object.vertice = [[NSMutableArray alloc]init];
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



@end
