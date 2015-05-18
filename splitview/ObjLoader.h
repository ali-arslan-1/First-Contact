//
//  ObjLoader.h
//  vbo
//
//  Created by Ming Li on 05/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import "Object.h"

@interface ObjLoader : NSObject
{
    NSMutableArray *vertice;
    NSMutableArray *texCoord;
    NSMutableArray *normal;
    NSMutableArray *vIndices;
    NSMutableArray *tcIndices;
    NSMutableArray *nIndices;
    GLfloat        *vertexData;
    
    int             numVertexPerFace;
    float           numFaces;
    bool            hasNormal;
    bool            hasTexcoord;
    uint            positionDim;
    uint            normalDim;
    uint            texcoordDim;
    uint            faceindiceDim;
    uint            bytesize_vertexdata;
    
    int             minX, maxX, minZ, maxZ;
}

- (void)initWithPath:(NSString *)path;
- (int)getNumOfFaces;
- (NSMutableArray *)getVertice;
- (NSMutableArray *)getNormals;
- (NSMutableArray *)getTexCoords;
- (NSMutableArray *)getVIndices;
- (NSMutableArray *)getNIndices;

- (GLfloat *)getVertexData;
- (int)getNumVertexPerFace;
- (uint)getByteSizeOfVertexData;
- (uint)getNumVertices;

-(Object*)getObject:(NSString*) name;
@end
