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
- (id)initWithPos:(GLKVector3)pos;

-(void)moveForward ;
-(void)moveBackward;
-(void)moveLeft;
-(void)moveRight;
-(void)moveDown;
-(void)moveUp;

-(void)movePlayer;
-(void)stopMoving;
/*
- (void)lookDown;
- (void)lookUp;
 */
- (void)lookLeft;
- (void)lookRight;

-(void) rotateHead:(GLKMatrix4) rotation;

- (void)addObjects :(NSMutableArray*) newObjects;
-(BOOL) isTriggered:(Object*) obj;
+(BOOL) isHeadInside:(GLKVector3)min BBoxMax :(GLKVector3) max;
+(BOOL) isHeadOutside: (GLKVector3)min BBoxMax :(GLKVector3) max;
-(GLKVector3) getHeadPosition;

+ (GLKMatrix4)lView;

+ (GLKMatrix4)rView;

+ (void)setLView:(GLKMatrix4) val;

+ (void)setRView:(GLKMatrix4) val;

+ (GLKMatrix4) projection;
+ (GLKMatrix4) lightProjection;
+ (enum RoomType) currentRoom;
+ (void)setProjection:(GLKMatrix4) val;
+ (void)setLightProjection:(GLKMatrix4) val;
@end

