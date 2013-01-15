//
//  RCRubiksCube.m
//  RubiksCube
//
//  Created by Aha on 12-9-24.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCMagicCube.h"

@implementation MCMagicCube{
    MCCubie *magicCubies3D[3][3][3];
    MCCubie *magicCubiesList[27];
    NSInteger orientationToMagicCubeFace[6];
}

+ (MCMagicCube *)getSharedMagicCube{
    static MCMagicCube *magicCube;
    @synchronized(self)
    {
        if (!magicCube)
            magicCube = [[MCMagicCube alloc] init];
        return magicCube;
    }
}

- (id) init{
    if (self = [super init]) {
        for (int z = 0; z < 3; z++) {
            for (int y = 0; y < 3; y++) {
                for (int x = 0; x < 3; x++) {
                    if (x != 1 || y != 1 || z != 1) {
                        struct Point3i coordinateValue = {.x = x-1, .y = y-1, .z = z-1};
                        magicCubies3D[x][y][z] = [[MCCubie alloc] initWithCoordinateValue:coordinateValue];
                        magicCubiesList[x+y*3+z*9] = magicCubies3D[x][y][z];
                    }
                }
            }
        }
        for (int i  = 0; i < 6; i++) {
            //At the begining, the orientation and the magic cube face orientation is same
            orientationToMagicCubeFace[i] = i;
        }
    }
    return self;
}   //initial the rubik's cube

- (void) dealloc{
    for (int i = 0; i < 27; i++) {
        [magicCubiesList[i] release];
    }
    [super dealloc];
}

- (void) rotateOnAxis : (AxisType)axis onLayer: (int)layer inDirection: (LayerRotationDirectionType)direction{
    MCCubie *layerCubes[9];
    switch (axis) {
        case X:
            //change data
            for(int y = 0; y < 3; ++y)
            {
                for(int z = 0; z < 3; ++z)
                {
                    [magicCubies3D[layer][y][z] shiftOnAxis:axis inDirection:direction];
                    layerCubes[z+y*3] = magicCubies3D[layer][y][z];
                }
            }
            break;
        case Y:
            //change data
            for(int x = 0; x < 3; ++x)
            {
                for(int z = 0; z < 3; ++z)
                {
                    [magicCubies3D[x][layer][z] shiftOnAxis:axis inDirection:direction];
                    layerCubes[z+x*3] = magicCubies3D[x][layer][z];
                }
            }
            break;
        case Z:
            //change data
            for(int x = 0; x < 3; ++x)
            {
                for(int y = 0; y < 3; ++y)
                {
                    [magicCubies3D[x][y][layer] shiftOnAxis:axis inDirection:direction];
                    layerCubes[y+x*3] = magicCubies3D[x][y][layer];
                }
            }
            break;
        default:
            break;
    }
    
    //refresh pointer
    for(int index = 0; index < 9; ++index)
    {
        struct Point3i value = layerCubes[index].coordinateValue;
        magicCubies3D[value.x+1][value.y+1][value.z+1] = layerCubes[index];
    }
    
    //change magic cube face orientation
    if (layer == 1) {
        switch (axis) {
            case X:
                if (direction == CW) {
                    FaceOrientationType tmp = orientationToMagicCubeFace[Front];
                    orientationToMagicCubeFace[Front] = orientationToMagicCubeFace[Down];
                    orientationToMagicCubeFace[Down] = orientationToMagicCubeFace[Back];
                    orientationToMagicCubeFace[Back] = orientationToMagicCubeFace[Up];
                    orientationToMagicCubeFace[Up] = tmp;
                }
                else{
                    FaceOrientationType tmp = orientationToMagicCubeFace[Front];
                    orientationToMagicCubeFace[Front] = orientationToMagicCubeFace[Up];
                    orientationToMagicCubeFace[Up] = orientationToMagicCubeFace[Back];
                    orientationToMagicCubeFace[Back] = orientationToMagicCubeFace[Down];
                    orientationToMagicCubeFace[Down] = tmp;
                }
                break;
            case Y:
                if (direction == CW) {
                    FaceOrientationType tmp = orientationToMagicCubeFace[Front];
                    orientationToMagicCubeFace[Front] = orientationToMagicCubeFace[Right];
                    orientationToMagicCubeFace[Right] = orientationToMagicCubeFace[Back];
                    orientationToMagicCubeFace[Back] = orientationToMagicCubeFace[Left];
                    orientationToMagicCubeFace[Left] = tmp;
                } else {
                    FaceOrientationType tmp = orientationToMagicCubeFace[Front];
                    orientationToMagicCubeFace[Front] = orientationToMagicCubeFace[Left];
                    orientationToMagicCubeFace[Left] = orientationToMagicCubeFace[Back];
                    orientationToMagicCubeFace[Back] = orientationToMagicCubeFace[Right];
                    orientationToMagicCubeFace[Right] = tmp;
                }
                break;
            case Z:
                if (direction == CW) {
                    FaceOrientationType tmp = orientationToMagicCubeFace[Up];
                    orientationToMagicCubeFace[Up] = orientationToMagicCubeFace[Left];
                    orientationToMagicCubeFace[Left] = orientationToMagicCubeFace[Down];
                    orientationToMagicCubeFace[Down] = orientationToMagicCubeFace[Right];
                    orientationToMagicCubeFace[Right] = tmp;
                } else {
                    FaceOrientationType tmp = orientationToMagicCubeFace[Up];
                    orientationToMagicCubeFace[Up] = orientationToMagicCubeFace[Right];
                    orientationToMagicCubeFace[Right] = orientationToMagicCubeFace[Down];
                    orientationToMagicCubeFace[Down] = orientationToMagicCubeFace[Left];
                    orientationToMagicCubeFace[Left] = tmp;
                }
                break;
            default:
                break;
        }
    }
    
}   //rotate operation

- (struct Point3i) coordinateValueOfCubieWithColorCombination : (ColorCombinationType)combination{
    return magicCubiesList[combination].coordinateValue;
}   //get coordinate of cube having the color combination

- (MCCubie *) cubieWithColorCombination : (ColorCombinationType)combination{
    return magicCubiesList[combination];
}

- (MCCubie *)cubieAtCoordinateX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z{
    return magicCubies3D[x][y][z];
}

- (MCCubie *)cubieAtCoordinatePoint3i:(struct Point3i)point{
    return magicCubies3D[point.x][point.y][point.z];
}

- (void)rotateWithSingmasterNotation:(SingmasterNotation)notation{
    switch (notation) {
        case F:
            [self rotateOnAxis:Z onLayer:2 inDirection:CW];
            break;
        case Fi:
            [self rotateOnAxis:Z onLayer:2 inDirection:CCW];
            break;
        case F2:
            [self rotateOnAxis:Z onLayer:2 inDirection:CW];
            [self rotateOnAxis:Z onLayer:2 inDirection:CW];
            break;
        case B:
            [self rotateOnAxis:Z onLayer:0 inDirection:CCW];
            break;
        case Bi:
            [self rotateOnAxis:Z onLayer:0 inDirection:CW];
            break;
        case B2:
            [self rotateOnAxis:Z onLayer:0 inDirection:CCW];
            [self rotateOnAxis:Z onLayer:0 inDirection:CCW];
            break;
        case R:
            [self rotateOnAxis:X onLayer:2 inDirection:CW];
            break;
        case Ri:
            [self rotateOnAxis:X onLayer:2 inDirection:CCW];
            break;
        case R2:
            [self rotateOnAxis:X onLayer:2 inDirection:CW];
            [self rotateOnAxis:X onLayer:2 inDirection:CW];
            break;
        case L:
            [self rotateOnAxis:X onLayer:0 inDirection:CCW];
            break;
        case Li:
            [self rotateOnAxis:X onLayer:0 inDirection:CW];
            break;
        case L2:
            [self rotateOnAxis:X onLayer:0 inDirection:CCW];
            [self rotateOnAxis:X onLayer:0 inDirection:CCW];
            break;
        case U:
            [self rotateOnAxis:Y onLayer:2 inDirection:CW];
            break;
        case Ui:
            [self rotateOnAxis:Y onLayer:2 inDirection:CCW];
            break;
        case U2:
            [self rotateOnAxis:Y onLayer:2 inDirection:CW];
            [self rotateOnAxis:Y onLayer:2 inDirection:CW];
            break;
        case D:
            [self rotateOnAxis:Y onLayer:0 inDirection:CCW];
            break;
        case Di:
            [self rotateOnAxis:Y onLayer:0 inDirection:CW];
            break;
        case D2:
            [self rotateOnAxis:Y onLayer:0 inDirection:CCW];
            [self rotateOnAxis:Y onLayer:0 inDirection:CCW];
            break;
        case x:
            [self rotateOnAxis:X onLayer:0 inDirection:CW];
            [self rotateOnAxis:X onLayer:1 inDirection:CW];
            [self rotateOnAxis:X onLayer:2 inDirection:CW];
            break;
        case xi:
            [self rotateOnAxis:X onLayer:0 inDirection:CCW];
            [self rotateOnAxis:X onLayer:1 inDirection:CCW];
            [self rotateOnAxis:X onLayer:2 inDirection:CCW];
            break;
        case y:
            [self rotateOnAxis:Y onLayer:0 inDirection:CW];
            [self rotateOnAxis:Y onLayer:1 inDirection:CW];
            [self rotateOnAxis:Y onLayer:2 inDirection:CW];
            break;
        case yi:
            [self rotateOnAxis:Y onLayer:0 inDirection:CCW];
            [self rotateOnAxis:Y onLayer:1 inDirection:CCW];
            [self rotateOnAxis:Y onLayer:2 inDirection:CCW];
            break;
        case z:
            [self rotateOnAxis:Z onLayer:0 inDirection:CW];
            [self rotateOnAxis:Z onLayer:1 inDirection:CW];
            [self rotateOnAxis:Z onLayer:2 inDirection:CW];
            break;
        case zi:
            [self rotateOnAxis:Z onLayer:0 inDirection:CCW];
            [self rotateOnAxis:Z onLayer:1 inDirection:CCW];
            [self rotateOnAxis:Z onLayer:2 inDirection:CCW];
            break;
        default:
            break;
    }
}

- (FaceOrientationType)magicCubeFaceInOrientation:(FaceOrientationType)orientation{
    return orientationToMagicCubeFace[orientation];
}

@end
