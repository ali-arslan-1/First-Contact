//
//  GameViewController.h
//  splitview
//
//  Created by Ming Li on 16/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>
#import "ObjLoader.h"
#import "ShaderLoader.h"
#import "HeadPosition.h"
#import "Object.h"

// Uniform index.

GLfloat gGridVertexData[] =
{   //v(x,y,z)
    -5.0f, -5.0f, 0.0f,
    5.0f, -5.0f, 0.0f,
    -5.0f, -4.0f, 0.0f,
    5.0f, -4.0f, 0.0f,
    -5.0f, -3.0f, 0.0f,
    5.0f, -3.0f, 0.0f,
    -5.0f, -2.0f, 0.0f,
    5.0f, -2.0f, 0.0f,
    -5.0f, -1.0f, 0.0f,
    5.0f, -1.0f, 0.0f,
    -5.0f,  0.0f, 0.0f,
    5.0f,  0.0f, 0.0f,
    -5.0f,  1.0f, 0.0f,
    5.0f,  1.0f, 0.0f,
    -5.0f,  2.0f, 0.0f,
    5.0f,  2.0f, 0.0f,
    -5.0f,  3.0f, 0.0f,
    5.0f,  3.0f, 0.0f,
    -5.0f,  4.0f, 0.0f,
    5.0f,  4.0f, 0.0f,
    -5.0f,  5.0f, 0.0f,
    5.0f,  5.0f, 0.0f,
    
    -5.0f, -5.0f, 0.0f,
    -5.0f,  5.0f, 0.0f,
    -4.0f, -5.0f, 0.0f,
    -4.0f,  5.0f, 0.0f,
    -3.0f, -5.0f, 0.0f,
    -3.0f,  5.0f, 0.0f,
    -2.0f, -5.0f, 0.0f,
    -2.0f,  5.0f, 0.0f,
    -1.0f, -5.0f, 0.0f,
    -1.0f,  5.0f, 0.0f,
    0.0f, -5.0f, 0.0f,
    0.0f,  5.0f, 0.0f,
    1.0f, -5.0f, 0.0f,
    1.0f,  5.0f, 0.0f,
    2.0f, -5.0f, 0.0f,
    2.0f,  5.0f, 0.0f,
    3.0f, -5.0f, 0.0f,
    3.0f,  5.0f, 0.0f,
    4.0f, -5.0f, 0.0f,
    4.0f,  5.0f, 0.0f,
    5.0f, -5.0f, 0.0f,
    5.0f,  5.0f, 0.0f,
    
    
};


GLfloat gQuadVertexData[] =
{   //v(x,y,z),vn(x,y,z),vt(u,v)
    1.0f, 1.0f, 0.0f,    0.0f, 0.0f, 1.0f,   1.0f, 1.0f,
    -1.0f, 1.0f, 0.0f,    0.0f, 0.0f, 1.0f,   0.0f, 1.0f,
    1.0f, -1.0f, 0.0f,   0.0f, 0.0f, 1.0f,   1.0f, 0.0f,
    -1.0f, -1.0f, 0.0f,   0.0f, 0.0f, 1.0f,   0.0f, 0.0f
};

@interface GameViewController : GLKViewController <UIAccelerometerDelegate>
{
    ObjLoader   *objloader;
    ShaderLoader *shaderLoader;
    GLfloat     *mVertexData;
    uint         mByteSizeOfVertexData;
    uint         mNumTriangles;
    uint         mTextureID;
    
    GLint        mDefaultFBO;
    GLuint       mFBO[2];
    GLuint       mColorTextureID[2];
    GLuint       mDepthRenderBuffer[2];
    
    GLfloat      mFrameWidth;
    GLfloat      mFrameHeight;
    
    HeadPosition *headPosition;
    
}
- (IBAction)textFieldDidChange:(UITextField *)sender;

@property (weak, nonatomic) IBOutlet UITextField *inputTextField;

@end
