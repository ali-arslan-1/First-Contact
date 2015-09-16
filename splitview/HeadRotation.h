//
//  HeadRotation.h
//  splitview
//
//  Created by Kaspar Scharf on 30/03/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <GLKit/GLKit.h>
#import <CoreMotion/CoreMotion.h>

@interface HeadRotation : NSObject

- (id)initWithMotionManager:(CMMotionManager *)motionMgr;

- (GLKMatrix4)getRotationMatrix;

@end
