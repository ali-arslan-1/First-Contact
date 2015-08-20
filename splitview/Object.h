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

enum ObjectType{
    Room,
    Prop,
    DoorFrame,
    Door_,
    Light_,
    Trigger
};

enum Eye{
    Left,
    Right
};

@interface Object : NSObject{
    GLuint _vertexArray;
    GLuint _vertexBuffer;
    float *coordinates;

    GLKVector4 center;
}
-(id) init : (NSString*) name Type :(enum ObjectType) type;
-(void) dealloc;


- (NSMutableArray *)vertice;

- (void)setVertice:(NSMutableArray *)newValue;
- (void) moveObject : (NSString*) name matrix: (GLKMatrix4) matrix;
- (GLfloat *)getVertexData;
- (uint)getNumVertices;
-(GLKMatrix4) getModelView:(enum Eye)eye;
-(GLKMatrix4) getModelViewProjection:(enum Eye)eye;
-(GLKMatrix4) getModelViewInverseTranspose:(enum Eye)eye;
-(GLKMatrix4) getLightModelViewProjection:(GLKMatrix4) lightViewMatrix;
-(void) calculateCenter;


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
@property( nonatomic ) float minX;
@property( nonatomic ) float maxX;
@property( nonatomic ) float minZ;
@property( nonatomic ) float maxZ;
@property( nonatomic ) NSString* name ;
@property( nonatomic ) NSString* parent ;
@property (nonatomic) enum ObjectType type;
@property GLuint* vertexArray;
@property GLuint* vertexBuffer;
@property GLKMatrix4 modelMatrix;
@property GLKMatrix4 initialModelMatrix;
@end

#endif
