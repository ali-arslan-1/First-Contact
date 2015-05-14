//
//  ObjLoader.m
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "ObjLoader.h"

@implementation ObjLoader

- (void)initWithPath:(NSString *)path {
    
    NSLog(@"path name : %@", path);
    
    // init Arrays for saving Data
    vertice = [[NSMutableArray alloc] init];
    texCoord = [[NSMutableArray alloc] init];
    normal = [[NSMutableArray alloc] init];
    vIndices = [[NSMutableArray alloc] init];
    tcIndices = [[NSMutableArray alloc] init];
    nIndices = [[NSMutableArray alloc] init];
    numVertexPerFace = 0;
    numFaces = 0;
    hasNormal = false;
    hasTexcoord = false;
    positionDim = 0;
    normalDim = 0;
    texcoordDim = 0;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:path ofType:@"obj"];
    NSLog(@"%@", filePath);
    if (filePath) {
        NSString* content = [NSString stringWithContentsOfFile:filePath
                                                      encoding:NSUTF8StringEncoding
                                                         error:NULL];
        if (content)
        {
            
            minX = 0;
            maxX = 0;
            minZ = 0;
            maxZ = 0;
            
            // separate by new line
            NSArray* allLines = [content componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]];
            
            for (int i = 0; i < [allLines count]; i++) {
                // line string handling
                NSString* strInEachLine = [allLines objectAtIndex:i];
                // separated by space
                NSArray* singleLineStrs = [strInEachLine componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@" "]];
                NSString *firstSymbol = [singleLineStrs objectAtIndex:0];
                
                if ([firstSymbol isEqualToString:@"v"]){
                    positionDim = (uint)[singleLineStrs count] - 1;
                    // NSLog(@"posDim : %d", positionDim);
                    [self addVertexFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"vn"]){
                    hasNormal = true;
                    normalDim = (uint)[singleLineStrs count] - 1;
                    //NSLog(@"normalDim : %d", normalDim);
                    [self addNormalFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"vt"]){
                    hasTexcoord = true;
                    texcoordDim = (uint)[singleLineStrs count] - 1;
                    //NSLog(@"TexcoordDim : %d", texcoordDim);
                    [self addTexCoordFromString:singleLineStrs];
                }
                else if ([firstSymbol isEqualToString:@"f"]){
                    faceindiceDim = (uint)[singleLineStrs count];
                    //      NSLog(@"faceindiceDim : %d", faceindiceDim - 1);
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
            if ([vIndices count] != [tcIndices count] || [vIndices count] != [nIndices count] || [nIndices count] != [tcIndices count])
                NSLog(@"Error: face indices unequal!");
            numFaces = (float)[vIndices count] / numVertexPerFace;
            NSLog(@"face counting : %.2f", (float)[vIndices count] / numVertexPerFace);
            NSLog(@"vertices counting : %.2f", (float)[vertice count] / 3);
            NSLog(@"normal counting : %.2f", (float)[normal count] / 3);
            NSLog(@"texcoord counting : %.2f", (float)[texCoord count] / 2);
            
        }
        
    }
    
}

- (void)dealloc {
    if (vertice)
        [vertice removeAllObjects];
    if (texCoord)
        [texCoord removeAllObjects];
    if (normal)
        [normal removeAllObjects];
    if (vIndices)
        [vIndices removeAllObjects];
    if (tcIndices)
        [tcIndices removeAllObjects];
    if (nIndices)
        [nIndices removeAllObjects];
    if (vertexData)
        free(vertexData);
}

-(void)addVertexFromString:(NSArray *)stringArray
{
    if(vertice == nil)
        vertice = [[NSMutableArray alloc]init];
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        float value = [[stringArray objectAtIndex:i] floatValue];
        if(i == 1){
            if (value < minX)
                minX = value;
            else if (value > maxX)
                maxX = value;
        } else if(i == 3){
            if (value < minZ)
                minZ = value;
            else if (value > maxZ)
                maxZ = value;
        }
        
        //NSLog(@"v %d : %.2f", i, value);
        [vertice addObject:[NSNumber numberWithFloat:value]];
    }
    
}

-(void)addNormalFromString:(NSArray *)stringArray
{
    if(normal == nil)
        normal = [[NSMutableArray alloc]init];
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        float value = [[stringArray objectAtIndex:i] floatValue];
        //NSLog(@"n %d : %.2f", i, value);
        [normal addObject:[NSNumber numberWithFloat:value]];
    }
}

-(void)addTexCoordFromString:(NSArray *)stringArray
{
    if(texCoord == nil)
        texCoord = [[NSMutableArray alloc]init];
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        float value = [[stringArray objectAtIndex:i] floatValue];
        //NSLog(@"tc %d : %.2f", i, value);
        [texCoord addObject:[NSNumber numberWithFloat:value]];
    }
}

-(void)addFaceIndicesFromString:(NSArray *)stringArray
{
    if(vIndices == nil)
        vIndices = [[NSMutableArray alloc]init];
    if(tcIndices == nil)
        tcIndices = [[NSMutableArray alloc]init];
    if(nIndices == nil)
        nIndices = [[NSMutableArray alloc]init];
    
    numVertexPerFace = (int)[stringArray count] - 1;
    
    for (int i = 0; i < [stringArray count]; i++) {
        if (i == 0)
            continue;
        
        NSString *substring = [stringArray objectAtIndex:i];
        /* int vi = [[stringArray objectAtIndex:1] intValue];
         int tci = [[stringArray objectAtIndex:2] intValue];
         int ni = [[stringArray objectAtIndex:3] intValue];
         NSLog(@"%@ : %d %d %d", stringArray, vi, tci, ni);
         
         [vIndices addObject:[NSNumber numberWithInt:vi]];
         [tcIndices addObject:[NSNumber numberWithInt:tci]];
         [nIndices addObject:[NSNumber numberWithInt:ni]];
         
         */
        
        // separated by /
        NSArray* singleIndexs = [substring componentsSeparatedByCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"/"]];
        
        
        int vi = [[singleIndexs objectAtIndex:0] intValue];
        int tci = [[singleIndexs objectAtIndex:1] intValue];
        int ni = [[singleIndexs objectAtIndex:2] intValue];
        //   NSLog(@"%@ : %d %d %d", substring, vi, tci, ni);
        
        [vIndices addObject:[NSNumber numberWithInt:vi]];
        [tcIndices addObject:[NSNumber numberWithInt:tci]];
        [nIndices addObject:[NSNumber numberWithInt:ni]];
        
    }
}

- (int)getNumOfFaces
{
    return numFaces;
}

- (int)getNumVertexPerFace
{
    return numVertexPerFace;
}

- (NSMutableArray *)getVertice
{
    return vertice;
}

- (NSMutableArray *)getNormals
{
    return normal;
}

- (NSMutableArray *)getTexCoords
{
    return texCoord;
}

- (NSMutableArray *)getVIndices
{
    return vIndices;
}

- (NSMutableArray *)getNIndices
{
    return nIndices;
}

- (GLfloat *)getVertexData
{
    uint size_vertexdata = (positionDim + hasNormal * normalDim + hasTexcoord * texcoordDim) * numFaces * numVertexPerFace;
    bytesize_vertexdata = sizeof(GLfloat) * size_vertexdata;
    NSLog(@"size of vertexdata : %d   24*#Faces = %d", size_vertexdata, 24 * (int)numFaces);
    vertexData = malloc(bytesize_vertexdata);
    int offsetPerFace = (positionDim + hasNormal * normalDim + hasTexcoord * texcoordDim) * numVertexPerFace;
    int offsetPerVert = positionDim + hasNormal * normalDim + hasTexcoord * texcoordDim;
    
    for (int i = 0; i < numFaces; i++) {
        //NSLog(@"f %d", i);
        for (int j = 0; j < numVertexPerFace; j++)
        {
            // in obj file index counting starts from 1 not 0
            int v = [[vIndices  objectAtIndex:i * numVertexPerFace + j] intValue] - 1;
            int n = [[nIndices  objectAtIndex:i * numVertexPerFace + j] intValue] - 1;
            int t = [[tcIndices objectAtIndex:i * numVertexPerFace + j] intValue] - 1;
            
            //NSLog(@"v %d n %d", v + 1, n + 1);
            int pos = i * offsetPerFace + offsetPerVert * j;
            // check for overflow
            if (v * positionDim + positionDim - 1 > [vertice count])
            {
                NSLog(@"v index overflow : %d / %lu", v * positionDim + positionDim - 1, (unsigned long)[vertice count]);
                return vertexData;
            }
            
            vertexData[pos++] = [[vertice objectAtIndex:v * positionDim + 0] floatValue]; // x
            vertexData[pos++] = [[vertice objectAtIndex:v * positionDim + 1] floatValue]; // y
            vertexData[pos++] = [[vertice objectAtIndex:v * positionDim + 2] floatValue]; // z
            
            if (hasNormal) {
                vertexData[pos++] = [[normal  objectAtIndex:n * normalDim + 0] floatValue]; // nx
                vertexData[pos++] = [[normal  objectAtIndex:n * normalDim + 1] floatValue]; // ny
                vertexData[pos++] = [[normal  objectAtIndex:n * normalDim + 2] floatValue]; // nz
            }
            if (hasTexcoord) {
                vertexData[pos++] = [[texCoord  objectAtIndex:t * texcoordDim + 0] floatValue]; // u
                vertexData[pos++] = 1-[[texCoord  objectAtIndex:t * texcoordDim + 1] floatValue]; // v
                
            }
        }
        
    }
    return vertexData;
}

- (uint)getByteSizeOfVertexData
{
    return bytesize_vertexdata;
}

- (uint)getNumVertices
{
    return numFaces * numVertexPerFace;
}

- (Object*) getObject
{
    Object* temp = [[Object alloc] init:minX minZ:minZ maxX:maxX maxZ:maxZ];
    return temp;
}
@end
