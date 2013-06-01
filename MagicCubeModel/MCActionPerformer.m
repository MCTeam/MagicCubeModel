//
//  MCActionPerformer.m
//  MagicCubeModel
//
//  Created by Aha on 13-6-1.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCActionPerformer.h"

@implementation MCActionPerformer

@synthesize magicCube;
@synthesize cubieLocker;

+ (MCActionPerformer *)actionPerformerWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc
                                     andCubieLocker:(NSObject<MCCubieLockerDelegate> *)locker{
    return [[[MCActionPerformer alloc] initActionPerformerWithMagicCube:mc andCubieLocker:locker] autorelease];
}


- (id)initActionPerformerWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc
                        andCubieLocker:(NSObject<MCCubieLockerDelegate> *)locker{
    if (self = [super init]) {
        self.magicCube = mc;
        self.cubieLocker = locker;
    }
    return self;
}


- (void)dealloc{
    [super dealloc];
    self.cubieLocker = nil;
    self.magicCube = nil;
}


- (NSInteger)treeNodesApply:(MCTreeNode *)root{
    switch (root.type) {
        case ExpNode:
        {
            if (root.value == Sequence) {
                return [self sequenceNodeApply:root];
            }
        }
            break;
        case ActionNode:
        {
            switch (root.value) {
                case Rotate:
                    for (MCTreeNode *child in root.children) {
                        [self.magicCube rotateWithSingmasterNotation:(SingmasterNotation)child.value];
                    }
                    break;
                case FaceToOrientation:
                {
                    MCTreeNode *elementNode;
                    elementNode = [root.children objectAtIndex:0];
                    ColorCombinationType targetCombination = (ColorCombinationType)elementNode.value;
                    struct Point3i targetCoor = [self.magicCube coordinateValueOfCubieWithColorCombination:targetCombination];
                    elementNode = [root.children objectAtIndex:1];
                    FaceOrientationType targetOrientation = (FaceOrientationType)elementNode.value;
                    [self.magicCube rotateWithSingmasterNotation:[MCTransformUtil getPathToMakeCenterCubieAtPosition:targetCoor inOrientation:targetOrientation]];
                }
                    break;
                case LockCubie:
                {
                    MCTreeNode *elementNode = [root.children objectAtIndex:0];
                    int index = 0;
                    if ([root.children count] != 1) {
                        index = [(MCTreeNode *)[root.children objectAtIndex:1] value];
                    }
                    int identity = [self treeNodesApply:elementNode];
                    if (identity == -1) {
                        [self.cubieLocker unlockCubieAtIndex:index];
                    }
                    else{
                        [self.cubieLocker lockCubie:[self.magicCube cubieWithColorCombination:(ColorCombinationType)identity]
                                atIndex:index];
                    }
                }
                    break;
                case UnlockCubie:
                {
                    int index = 0;
                    if ([root.children count] != 0) {
                        index = [(MCTreeNode *)[root.children objectAtIndex:0] value];
                    }
                    [self.cubieLocker unlockCubieAtIndex:index];
                }
                    break;
                default:
                    return NO;
            }
        }
            break;
        case InformationNode:
            switch (root.value) {
                case getCombinationFromOrientation:
                {
                    int x=1, y=1, z=1;
                    for (MCTreeNode *child in root.children) {
                        switch ([self.magicCube centerMagicCubeFaceInOrientation:(FaceOrientationType)child.value]) {
                            case Up:
                                y = 2;
                                break;
                            case Down:
                                y = 0;
                                break;
                            case Left:
                                x = 0;
                                break;
                            case Right:
                                x = 2;
                                break;
                            case Front:
                                z = 2;
                                break;
                            case Back:
                                z = 0;
                                break;
                            default:
                                break;
                        }
                    }
                    
                    //Store the result at the node
                    root.result = x+y*3+z*9;
                    return root.result;
                }
                case getCombinationFromColor:
                {
                    int x=1, y=1, z=1;
                    for (MCTreeNode *child in root.children) {
                        switch ((FaceColorType)[self treeNodesApply:child]) {
                            case UpColor:
                                y = 2;
                                break;
                            case DownColor:
                                y = 0;
                                break;
                            case LeftColor:
                                x = 0;
                                break;
                            case RightColor:
                                x = 2;
                                break;
                            case FrontColor:
                                z = 2;
                                break;
                            case BackColor:
                                z = 0;
                                break;
                            default:
                                break;
                        }
                    }
                    
                    //Store the result at the node
                    root.result = x+y*3+z*9;
                    return root.result;
                }
                case getFaceColorFromOrientation:
                {
                    FaceColorType color;
                    FaceOrientationType orientation = (FaceOrientationType)[(MCTreeNode *)[root.children objectAtIndex:0] value];
                    if ([root.children count] == 1) {
                        switch ([self.magicCube centerMagicCubeFaceInOrientation:orientation]) {
                            case Up:
                                color = UpColor;
                                break;
                            case Down:
                                color = DownColor;
                                break;
                            case Left:
                                color = LeftColor;
                                break;
                            case Right:
                                color = RightColor;
                                break;
                            case Front:
                                color = FrontColor;
                                break;
                            case Back:
                                color = BackColor;
                                break;
                            default:
                                color = NoColor;
                                break;
                        }
                    }
                    else{
                        int value = [(MCTreeNode *)[root.children objectAtIndex:1] value];
                        struct Point3i coordinate = {value%3-1, value%9/3-1, value/9-1};
                        color = [[self.magicCube cubieAtCoordinatePoint3i:coordinate] faceColorInOrientation:orientation];
                    }
                    
                    //Store the result at the node
                    root.result = color;
                    return root.result;
                }
                case lockedCubie:
                {
                    int index = 0;
                    if ([root.children count] != 0) {
                        index = [(MCTreeNode *)[root.children objectAtIndex:0] value];
                    }
                    
                    if ([self.cubieLocker emptyAtIndex:index]) {
                        root.result = -1;
                    }
                    else{
                        root.result = [[self.cubieLocker cubieLockedInLockerAtIndex:index] identity];
                    }
                    
                    return root.result;
                }
                default:
                    break;
            }
            break;
        case ElementNode:
            return root.value;
        default:
            return NO;
    }
    return YES;
}

- (BOOL)sequenceNodeApply:(MCTreeNode *)root{
    for (MCTreeNode *node in root.children) {
        [self treeNodesApply:node];
    }
    return YES;
}


@end
