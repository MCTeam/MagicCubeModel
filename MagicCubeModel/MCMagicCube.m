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

@end
