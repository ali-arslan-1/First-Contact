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

-(GLKMatrix4*)move:(GLKMatrix4)LviewMatrix rightEye: (GLKMatrix4) RviewMatix ;
- (void) addObject :(Object*) object ;
- (void) moveObject : (NSString*) name matrix: (GLKMatrix4) matrix;
@end

