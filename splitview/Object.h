//
//  Object.h
//  splitview
//
//  Created by MCP 2015 on 07/05/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_Object_h
#define splitview_Object_h

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <GLKit/GLKit.h>


//This is the BBox of the object, which is used for collision detection

//Only X and Z coordinates, because the actor does not move at Y axis.

@interface Object : NSObject{
    
    float *coordinates;
    NSString *name;
}
-(id) init;
-(void) dealloc;


- (NSMutableArray *)vertice;

- (void)setVertice:(NSMutableArray *)newValue;
- (void) moveObject : (NSString*) name matrix: (GLKMatrix4) matrix;
- (GLfloat *)getVertexData;
- (uint)getNumVertices;

@property( nonatomic, retain ) NSMutableArray *vertice;
@property( nonatomic, retain ) NSMutableArray *texCoord;
@property( nonatomic, retain ) NSMutableArray *normal;
@property( nonatomic, retain ) NSMutableArray *vIndices;
@property( nonatomic, retain ) NSMutableArray *tcIndices;
@property( nonatomic, retain ) NSMutableArray *nIndices;
@property( nonatomic ) GLfloat *vertexData;
@property( nonatomic ) int numVertexPerFace;
@property( nonatomic ) float numFaces;
@property( nonatomic ) bool hasNormal;
@property( nonatomic ) bool hasTexcoord;
@property( nonatomic ) uint positionDim;
@property( nonatomic ) uint normalDim;
@property( nonatomic ) uint texcoordDim;
@property( nonatomic ) uint faceindiceDim;
@property( nonatomic ) uint bytesize_vertexdata;
@property( nonatomic ) int minX;
@property( nonatomic ) int maxX;
@property( nonatomic ) int minZ;
@property( nonatomic ) int maxZ;

@end

#endif
