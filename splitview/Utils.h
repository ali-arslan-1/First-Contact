//
//  Utils.h
//  splitview
//
//  Created by Ali Arslan on 15.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_Utils_h
#define splitview_Utils_h

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Utils : NSObject

+(BOOL)isMatrix4Empty:(GLKMatrix4)matrix;
+(BOOL)isMatrix3Empty:(GLKMatrix3)matrix;
+(BOOL)isVector3Empty:(GLKVector3)vector;
+(BOOL)isVector4Empty:(GLKVector4)vector;
@end


#endif
