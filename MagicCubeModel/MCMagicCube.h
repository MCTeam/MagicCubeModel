//
//  RCRubiksCube.h
//  RubiksCube
//
//  Created by Aha on 12-9-24.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCCubie.h"

@interface MCMagicCube : NSObject <NSCoding>

@property (strong, nonatomic) NSDictionary *tagsMappingToColors;

//get a new magic cube
+ (MCMagicCube *)magicCube;

//get a saved magic cube from an archived file
+ (MCMagicCube *)unarchiveMagicCubeWithFile:(NSString *)path;

//rotate operation with axis, layer, direction
- (void)rotateOnAxis:(AxisType)axis onLayer:(int)layer inDirection:(LayerRotationDirectionType)direction;

//rotate with Singmaster Notation
- (void)rotateWithSingmasterNotation:(SingmasterNotation)notation;

//get coordinate of cube having the colors combination
- (struct Point3i)coordinateValueOfCubieWithColorCombination:(ColorCombinationType)combination;

//get the cubie having the colors combination
- (MCCubie *)cubieWithColorCombination:(ColorCombinationType)combination;

//get the cube in the specified position
- (MCCubie *)cubieAtCoordinateX:(NSInteger)x Y:(NSInteger)y Z:(NSInteger)z;
- (MCCubie *)cubieAtCoordinatePoint3i:(struct Point3i)point;


- (FaceOrientationType)magicCubeFaceInOrientation:(FaceOrientationType)orientation;

//get the state of cubies
//every state in the "format" axis-orientation
- (NSArray *)getAxisStatesOfAllCubie;

//get the state of cubies
//every state in the "format" orientation-face color
- (NSArray *)getColorInOrientationsOfAllCubie;

@end
