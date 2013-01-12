//
//  RCRubiksCube.h
//  RubiksCube
//
//  Created by Aha on 12-9-24.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCCubie.h"

@interface MCMagicCube : NSObject

+ (MCMagicCube *)getSharedMagicCube;

//rotate operation
- (void) rotateOnAxis : (AxisType)axis onLayer: (int)layer inDirection: (LayerRotationDirectionType)direction;

//get coordinate of cube having the colors combination
- (struct Point3i)coordinateValueOfCubieWithColorCombination:(ColorCombinationType)combination;

//get the cubie having the colors combination
- (MCCubie *)cubieWithColorCombination:(ColorCombinationType)combination;

//..............
//get the cube in the specified position
- (MCCubie *)cubieAtCoordinateX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z;
- (MCCubie *)cubieAtCoordinatePoint3i:(struct Point3i)point;

@end
