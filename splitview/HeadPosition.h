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

-(void)moveForward:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatrix ;
-(void)moveBackward:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatrix ;
-(void)moveLeft:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatrix ;
-(void)moveRight:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatrix ;
-(void)moveDown:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatrix ;
-(void)moveUp:(GLKMatrix4*)LviewMatrix rightEye: (GLKMatrix4*) RviewMatrix ;
- (void)lookDown:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix;
- (void)lookUp:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix;
- (void)lookLeft:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix;
- (void)lookRight:(GLKMatrix4*)LviewMatrix rightEye:(GLKMatrix4*)RviewMatrix;
- (void)addObjects :(NSMutableArray*) newObjects;

@end

