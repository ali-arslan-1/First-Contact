//
//  HeadRotation.m
//  splitview
//
//  Created by Kaspar Scharf on 30/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import "HeadRotation.h"

@import UIKit;

@implementation HeadRotation

// A CMMotionManager is needed to access the attitude of the device:
// Class-information: https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CMMotionManager_Class/index.html
CMMotionManager *mgr;

// sign of the corrected roll-angle, set depending on device-orientation:
float rollSign = -1.0f;

// angle (in radians) that is added to the pitch-angle received from the device depending
// on device-orientation to deal with the automatic turn-around of the display:
float pitchCorrection = 0.;


// Custom initializer that needs to be called:
- (id)initWithMotionManager:(CMMotionManager *)motionMgr {
    
    self = [super init];
        
    mgr = motionMgr;
        
    // Needs to be called once, so that we can use the orientation-property of the UIDevice later:
    // See https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIDevice_Class/#//apple_ref/occ/instm/UIDevice/beginGeneratingDeviceOrientationNotifications
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        
    return self;

}


// Returns a matrix to rotate the world in front of the camera depending on the device-orientation,
// so that it feels like the camera is moved through the world with the device:
- (GLKMatrix4)getRotationMatrix {
    
    // Depending on current device-orientation, roll and pitch have to be corrected, so that the rotations are always done towards the correct directions:
    UIDevice *currentDevice = [UIDevice currentDevice];
    
    if ([currentDevice orientation] == UIDeviceOrientationLandscapeRight){
        rollSign = - 1.0f;
        pitchCorrection = 0.;
    } else if ([currentDevice orientation] == UIDeviceOrientationLandscapeLeft) {
        rollSign = 1.0f;
        pitchCorrection = M_PI;
    }

    
    // Receive the current attitude-data and calculate the partial roation-matrices from the corrected angles:
    // https://developer.apple.com/library/ios/documentation/CoreMotion/Reference/CMAttitude_Class/index.html#//apple_ref/occ/cl/CMAttitude
    CMAttitude *a = [[mgr deviceMotion] attitude];
    
    GLKMatrix4 yaw = GLKMatrix4MakeYRotation(- a.yaw);
    GLKMatrix4 pitch = GLKMatrix4MakeZRotation(- a.pitch + pitchCorrection);
    GLKMatrix4 roll = GLKMatrix4MakeXRotation(rollSign * (a.roll - M_PI / 2.0));
    
    // Return product of all rotations:
    return GLKMatrix4Multiply(roll, GLKMatrix4Multiply(pitch, yaw));
}

@end