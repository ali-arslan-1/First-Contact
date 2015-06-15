//
//  Utils.m
//  splitview
//
//  Created by Ali Arslan on 15.06.15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Utils.h"

@implementation Utils

+(BOOL)isMatrix4Empty:(GLKMatrix4)matrix{

    for (int i =0; i<16; i++) {
            if(matrix.m[i] !=0.0f)
                return NO;
    }
    
    return YES;
}

+(BOOL)isMatrix3Empty:(GLKMatrix3)matrix{
    
    for (int i =0; i<9; i++) {
        if(matrix.m[i] !=0.0f)
            return NO;
    }
    
    return YES;
}

+(BOOL)isVector3Empty:(GLKVector3)vector{
    for (int i =0; i<3; i++) {
        if(vector.v[i] !=0.0f)
            return NO;
    }
    
    return YES;
}

+(BOOL)isVector4Empty:(GLKVector4)vector{
    for (int i =0; i<4; i++) {
        if(vector.v[i] !=0.0f)
            return NO;
    }
    
    return YES;
}
@end