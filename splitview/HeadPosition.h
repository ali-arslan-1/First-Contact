//
//  HeadPosition.h
//  splitview-motion
//
//  Created by MCP 2015 on 04/05/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <GLKit/GLKit.h>
#import "Object.h"

@interface HeadPosition : NSObject

-(id)init;

-(void)moveForward:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatix ;
-(void)moveBackward:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatix ;
-(void)moveLeft:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatix ;
-(void)moveRight:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatix ;
- (void) addObject :(Object*) object ;

@end

