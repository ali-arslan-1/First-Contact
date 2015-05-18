//
//  Object.h
//  splitview
//
//  Created by MCP 2015 on 07/05/15.
//  Copyright (c) 2015 Ming Li. All rights reserved.
//

#ifndef splitview_Object_h
#define splitview_Object_h



//This is the BBox of the object, which is used for collision detection

//Only X and Z coordinates, because the actor does not move at Y axis.

@interface Object : NSObject{

    float *coordinates;
    NSString *name;
}
-(id) init:(float)minX minZ: (float) minZ maxX: (float) maxX maxZ: (float) maxZ name: (NSString*) Nname;
-(void) dealloc;
-(float*) getCoordinates;
-(void) setCoordinates:(float)minX minZ: (float) minZ maxX: (float) maxX maxZ: (float) maxZ;
-(NSString*) getName;

@end

#endif
