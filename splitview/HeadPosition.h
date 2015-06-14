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

-(void)moveForward ;
-(void)moveBackward;
-(void)moveLeft;
-(void)moveRight;
-(void)moveDown;
-(void)moveUp;
- (void)lookDown;
- (void)lookUp;
- (void)lookLeft;
- (void)lookRight;
- (void)addObjects :(NSMutableArray*) newObjects;

+ (GLKMatrix4)lView;

+ (GLKMatrix4)rView;

+ (void)setLView:(GLKMatrix4) val;

+ (void)setRView:(GLKMatrix4) val;

+ (GLKMatrix4) projection;

+ (void)setProjection:(GLKMatrix4) val;
@end

