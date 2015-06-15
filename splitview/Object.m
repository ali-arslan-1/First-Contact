//
//  Object.m
//  splitview
//
//  Created by MCP 2015 on 07/05/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "Object.h"
#include "HeadPosition.h"

@implementation Object

@synthesize vertice;
@synthesize texCoord;
@synthesize normal;
@synthesize vIndices;
@synthesize tcIndices;
@synthesize nIndices;
@synthesize numVertexPerFace;
@synthesize numFaces;
@synthesize hasNormal;
@synthesize hasTexcoord;
@synthesize positionDim;
@synthesize normalDim;
@synthesize texcoordDim;
@synthesize vertexData;
@synthesize bytesize_vertexdata;
@synthesize minX;
@synthesize maxX;
@synthesize minZ;
@synthesize maxZ;
@synthesize vertexArray;
@synthesize vertexBuffer;
@synthesize modelMatrix;
@synthesize initialModelMatrix;

-(id) init : (NSString*) name Type :(enum ObjectType) type{

    self.type  = type;
    self.name  = name;
    
    self.minX = 0.0f;
    self.maxX = 0.0f;
    self.minZ = 0.0f;
    self.maxZ = 0.0f;
    
    self.texCoord = [[NSMutableArray alloc] init];
    self.normal = [[NSMutableArray alloc] init];
    self.vIndices = [[NSMutableArray alloc] init];
    self.tcIndices = [[NSMutableArray alloc] init];
    self.nIndices = [[NSMutableArray alloc] init];
    self.numVertexPerFace = 0;
    self.numFaces = 0;
    self.hasNormal = false;
    self.hasTexcoord = false;
    self.positionDim = 0;
    self.normalDim = 0;
    self.texcoordDim = 0;
    self.vertexArray = &_vertexArray;
    self.vertexBuffer = &_vertexBuffer;
    self.initialModelMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 0.0f);
    self.modelMatrix = initialModelMatrix;
    
    return self;
}


-(void) dealloc{
    free(coordinates);
    
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
    
    glDeleteBuffers(1, &(_vertexBuffer));
    glDeleteBuffers(1, &(_vertexArray));
}

- (uint)getNumVertices
{
    return numFaces * numVertexPerFace;
}

-(void)calculateCenter{

    float avgX = 0;
    float avgY = 0;
    float avgZ = 0;
    
    
    for (int i=0; i<self.vertice.count; i++) {
        if(i%3 == 0){
            avgX+=[[self.vertice objectAtIndex:i] floatValue];
        }else if(i%3==1){
            avgY+=[[self.vertice objectAtIndex:i] floatValue];
        }else{
            avgZ+=[[self.vertice objectAtIndex:i] floatValue];
        }
    }
    
    
    
    avgX = avgX/(self.vertice.count/3);
    avgY = avgY/(self.vertice.count/3);
    avgZ = avgZ/(self.vertice.count/3);
    
    self->center = GLKVector4Make(avgX, avgY, avgZ,1.0);
}

//transform object only translate wise. No rotation no scaling!
- (void) moveObject:(NSString *)name matrix:(GLKMatrix4) matrix{
 
    float changeX = matrix.m30;
    float changeZ = matrix.m32;
    minX+=changeX;
    maxX+=changeX;
    minZ+=changeZ;
    maxZ+=changeZ;
    
    //float* coord = [obj getCoordinates];
    //[obj setCoordinates:coord[0]+changeX minZ:coord[1]+changeZ maxX:coord[2]+changeX maxZ:coord[3]+changeZ];
            
    
    
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

-(GLKMatrix4)getModelView:(enum Eye) eye{
    GLKMatrix4 matrix;
    
    if(eye == Left){
        matrix = GLKMatrix4Multiply([HeadPosition lView], modelMatrix);
    }else{
        matrix = GLKMatrix4Multiply([HeadPosition rView], modelMatrix);
    }

    return matrix;
}



-(GLKMatrix4)getModelViewProjection:(enum Eye) eye{
    GLKMatrix4 matrix;

    matrix = GLKMatrix4Multiply([HeadPosition projection], [self getModelView:eye]);
    
    
    return matrix;
}
-(GLKMatrix4) getModelViewInverseTranspose:(enum Eye)eye{
    
    GLKMatrix4 matrix;
    BOOL invertible = YES;
    
    matrix = GLKMatrix4InvertAndTranspose([self getModelView:eye], &invertible);
    
    return matrix;

}




@end