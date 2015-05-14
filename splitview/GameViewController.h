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
#import "HeadPosition.h"
#import "Object.h"

@interface GameViewController : GLKViewController <UIAccelerometerDelegate>
{
    ObjLoader   *objloader;
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


@end
