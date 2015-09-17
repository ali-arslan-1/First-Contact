//
//  HeadPosition.m
//  splitview-motion
//
//  Created by MCP 2015 on 04/05/15.
//
//
//  Modified by Ali Arslan on 26/05/15
//  -Parameters changed to pointer type for move method
//  -Other movements added i.e. left, right, forward, backward
//

#import "HeadPosition.h"
#import <GLKit/GLKit.h>
#import "Door.h"
enum RoomType{
    Hallway,
    PodRoom,
    AirLock,
    DiningHall,
    EngineRoom,
    Cockpit
};

enum Direction{
    noDirection,
    forward,
    right,
    backward,
    left
};

@implementation HeadPosition{
    NSMutableArray *objects;
    NSMutableArray *currentRoomObjects;
    GLKMatrix4 matrices[2];
    GLKMatrix4 oldMatrices[2];
    float displacementFactor;
    float rotationFactor;
    //when room number is changed, change this also
    BOOL inDoorFrame;
    Object* currentDoor;
    Object* rooms[6];
    enum Direction currentDirection; //to understand if a key is held on
}



GLKVector3 headPos;
static GLKMatrix4 lView;
static GLKMatrix4 rView;
static GLKMatrix4 projection;

+ (GLKMatrix4)lView{
    @synchronized(self) {
        return lView;
    }
}

+ (GLKMatrix4)rView{
    @synchronized(self) {
        return rView;
    }
}

+ (GLKMatrix4)projection{
    @synchronized(self) {
        return projection;
    }
}

+ (void)setLView:(GLKMatrix4) val{
    @synchronized(self) {
        lView= val;
    }
    
}

+ (void)setRView:(GLKMatrix4) val{
    @synchronized(self) {
        rView= val;
    }
}

+ (void)setProjection:(GLKMatrix4) val{
    @synchronized(self) {
        projection = val;
    }
}

- (id) init{
    self = [super init];
    objects = [NSMutableArray array];
    displacementFactor = 0.1f;
    rotationFactor = 0.1f;
    return self;
}
- (id)initWithPos:(GLKVector3)pos{
    self = [super init];
    headPos.x = pos.x;
    headPos.y = pos.y;
    headPos.z = -pos.z; //Z coordinates are flipped at the obj file.
    objects = [NSMutableArray array];
    displacementFactor = 0.1f;
    rotationFactor = 0.1f;
    inDoorFrame = NO;
    currentDirection = noDirection;
    return self;
}


- (void) dealloc{
    //TO DO deallocate the array somehow || is the array allocated?
}

-(GLKVector3) getHeadPosition{
    return headPos;
}
- (void) move:(GLKVector3) disp{
    
    
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Translate(lView, disp.x,disp.y,disp.z);
    GLKMatrix4 _newRightviewMatix = GLKMatrix4Translate(rView, disp.x,disp.y,disp.z);
    
    [self detectCollision:disp];
    /*if(![self detectCollision:disp]){
        lView = _newLeftViewMatrix;
        rView = _newRightviewMatix;
    }*/
    
}

-(void) rotateHead:(GLKMatrix4) rotation{

    lView = GLKMatrix4Multiply(rotation, lView);
    rView = GLKMatrix4Multiply(rotation, rView);
}


- (void) rotate:(GLKVector3) axis factor : (float)factor{
    
    GLKMatrix4 rotation = GLKMatrix4MakeRotation(factor, axis.x, axis.y, axis.z);
    GLKMatrix4 _newLeftViewMatrix = GLKMatrix4Multiply(rotation, lView);
    GLKMatrix4 _newRightviewMatix = GLKMatrix4Multiply(rotation, rView);
    lView = _newLeftViewMatrix;
    rView = _newRightviewMatix;
}

-(BOOL) isTriggered:(Object *)obj{
    
    GLKVector3 BboxMax = GLKVector3Make(obj.maxX+1, 0.0f, obj.maxZ+1);
    GLKVector3 BboxMin = GLKVector3Make(obj.minX-1, 0.0f, obj.minZ-1);
    if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax]){
        return YES;
    }
    else 
        return NO;
}

- (BOOL) detectCollision: (GLKVector3) disp{
    GLKVector3 oldHeadPos = headPos;
    headPos.x = headPos.x - disp.x;
    headPos.z = headPos.z - disp.z;
    BOOL inRoom = YES;
    int type = 0;
    if(inDoorFrame){
        GLKVector3 BboxMax = GLKVector3Make(currentDoor.maxX, 0.0f, currentDoor.maxZ);
        GLKVector3 BboxMin = GLKVector3Make(currentDoor.minX, 0.0f, currentDoor.minZ);
        if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax])
            return NO;
        else{
            Object* room = rooms[Hallway];
            GLKVector3 BboxMax = GLKVector3Make(room.maxX, 0.0f, room.maxZ);
            GLKVector3 BboxMin = GLKVector3Make(room.minX, 0.0f, room.minZ);
            if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax]){
                inDoorFrame = NO;
                currentRoomObjects = [objects objectAtIndex:Hallway];
                return NO;
            }
            
            if([currentDoor.name isEqualToString:@"PodRoom"]){
                type = PodRoom;
                room = rooms[PodRoom];
            }
            else if([currentDoor.name isEqualToString:@"AirLock"]){
                type = AirLock;
                room = rooms[AirLock];
            }
            else if ([currentDoor.name isEqualToString:@"DiningHall"]){
                type = DiningHall;
                room = rooms[DiningHall];
            }
            else if ([currentDoor.name isEqualToString:@"EngineRoom"]){
                type = EngineRoom;
                room = rooms[EngineRoom];
            }
            else if ([currentDoor.name isEqualToString:@"Cockpit"]){
                type = Cockpit;
                room = rooms[Cockpit];
            }
            BboxMax = GLKVector3Make(room.maxX, 0.0f, room.maxZ);
            BboxMin = GLKVector3Make(room.minX, 0.0f, room.minZ);
            if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax]){
                inDoorFrame = NO;
                currentRoomObjects = [objects objectAtIndex:type];
                return NO;
            }
            headPos = oldHeadPos;
            return YES;
        }
    }
    else{
        for(Object *obj in currentRoomObjects){
            GLKVector3 BboxMax = GLKVector3Make(obj.maxX, 0.0f, obj.maxZ);
            GLKVector3 BboxMin = GLKVector3Make(obj.minX, 0.0f, obj.minZ);
            
            if(obj.type == DoorFrame){
                int deltaX = fabsf( BboxMax.x - BboxMin.x);
                int deltaZ = fabsf (BboxMax.z - BboxMin.z);
                if(deltaX>deltaZ){
                    BboxMin.z = BboxMin.z - 0.6;
                    BboxMax.z = BboxMax.z + 0.6;
                }
                else{
                    BboxMin.x = BboxMin.x - 0.6;
                    BboxMax.x = BboxMax.x + 0.6;
                }
                if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax]){
                    inDoorFrame = YES;
                    currentDoor = obj;
                }
                
            }else if(obj.type == Room){
                if([HeadPosition isHeadOutside:BboxMin BBoxMax:BboxMax]){
                    inRoom = NO;
                }
            }else if(obj.type == Door_){
                if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax]){
                    headPos =oldHeadPos;
                    return  YES;
                }
            } else if(obj.type == Light_){
                //Do nothing
            }
            else{
                //other props here
                if([HeadPosition isHeadInside:BboxMin BBoxMax:BboxMax]){
                    headPos = oldHeadPos;
                    return YES;
                }
            }
        }
        if(!inRoom && !inDoorFrame){
            headPos = oldHeadPos;
            return YES;
        }
        
    }
   
    
    return NO;
}

+(BOOL) isHeadInside:(GLKVector3)min BBoxMax :(GLKVector3) max{
    if((headPos.x>= min.x && headPos.x <= max.x) && (headPos.z >= min.z && headPos.z <= max.z)){
        return YES;
    } else
        return NO;
}
+(BOOL) isHeadOutside: (GLKVector3)min BBoxMax :(GLKVector3) max{
    if((headPos.x <(min.x+0.5)|| headPos.x > (max.x-0.5)) || (headPos.z <(min.z+0.5)|| headPos.z > (max.z-0.5))){
        return YES;
    }
    else
        return NO;
}

- (void) moveForward{
    
    currentDirection = forward;
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, displacementFactor);
    
    [self move:displacement];

}


- (void) moveBackward{
    
    currentDirection = backward;
    
    GLKVector3 displacement = GLKVector3Make(0.0f, 0.0f, -displacementFactor);
    
    [self move:displacement];
    
}

- (void) moveLeft{
    
    currentDirection = left;
    
    GLKVector3 displacement = GLKVector3Make(displacementFactor, 0.0f, 0.0f);
    
    [self move:displacement];
    
}


- (void) moveRight{
    
    currentDirection = right;
    
    GLKVector3 displacement = GLKVector3Make(-displacementFactor, 0.0f, 0.0f);
    
    [self move:displacement];
    
}

- (void) moveDown{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, displacementFactor, 0.0f);
    
    [self move:displacement];
    
}


- (void) moveUp{
    
    
    
    GLKVector3 displacement = GLKVector3Make(0.0f, -displacementFactor, 0.0f);
    
    [self move:displacement];
    
}

- (void) movePlayer{
    if(currentDirection != noDirection){
        switch (currentDirection) {
            case forward:
                [self moveForward];
                break;
                
            case right:
                [self moveRight];
                break;
                
            case backward:
                [self moveBackward];
                break;
                
            case left:
                [self moveLeft];
                break;
                
            default:
                break;
        }
    }
}

- (void) stopMoving{
    currentDirection = noDirection;
}

/*
- (void) lookUp{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.1f, 0.0f, 0.0f);
    
    [self rotate:axis factor:-rotationFactor];
    
}

- (void) lookDown{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.1f, 0.0f, 0.0f);
    
    [self rotate:axis factor:rotationFactor];
    
}
 */

- (void) lookLeft{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.0f, 0.1f, 0.0f);
    
    [self rotate:axis factor:-rotationFactor];
    
}

- (void) lookRight{
    
    
    
    GLKVector3 axis = GLKVector3Make(0.0f, 0.1f, 0.0f);
    
    [self rotate:axis factor:rotationFactor];
    
}


- (void) addObjects :(NSMutableArray*) newObjects{
    for(Object *obj in newObjects){
        for(Object *element in obj){
            if(element.type == Room){
                if([element.name isEqualToString:@"PodRoom"])
                    rooms[PodRoom] = element;
                else if([element.name isEqualToString:@"AirLock"])
                    rooms[AirLock] = element;
                else if ([element.name isEqualToString:@"Hallway"])
                    rooms[Hallway] = element;
                else if ([element.name isEqualToString:@"DiningHall"])
                    rooms[DiningHall] = element;
                else if ([element.name isEqualToString:@"EngineRoom"])
                    rooms[EngineRoom] = element;
                else if ([element.name isEqualToString:@"Cockpit"])
                    rooms[Cockpit] = element;
            }
        }
        [objects addObject:obj];
    }
    currentRoomObjects = [objects objectAtIndex:PodRoom];
}




@end
