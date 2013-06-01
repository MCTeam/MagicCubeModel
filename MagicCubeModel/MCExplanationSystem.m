//
//  MCExplanationSystem.m
//  MagicCubeModel
//
//  Created by Aha on 13-6-1.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCExplanationSystem.h"

@implementation MCExplanationSystem

@synthesize accordanceMsgs;
@synthesize magicCubeDataSource;
@synthesize cubieLocker;


- (void)dealloc{
    [super dealloc];
    self.accordanceMsgs = nil;
    self.magicCubeDataSource = nil;
    self.cubieLocker = nil;
}


+ (MCExplanationSystem *)explanationSystemWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc
                                         andCubieLocker:(NSObject<MCCubieLockerDelegate> *)locker{
    return [[[MCExplanationSystem alloc] initExplanationSystemWithMagicCube:mc andCubieLocker:locker] autorelease];
}


- (id)initExplanationSystemWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc
                          andCubieLocker:(NSObject<MCCubieLockerDelegate> *)locker{
    if (self = [super init]) {
        // the data source which gives concrete data of magic cube
        self.magicCubeDataSource = mc;
        
        // the locker which we can get locked cubies info from
        self.cubieLocker = locker;
        
        // Allocate accordance messages of the pattern of the applied rule
        self.accordanceMsgs = [NSMutableArray arrayWithCapacity:DEFAULT_PATTERN_ACCORDANCE_MESSAGE_NUM];
        
    }
    return self;
}


- (NSArray *)translateAppliedPattern:(MCPattern *)pattern{
    //Before apply pattern, clear accrodance messages firstly.
    [self.accordanceMsgs removeAllObjects];
    
    // apply
    if (pattern != nil) {
        [self treeNodesApply:pattern.root withDeep:0];
    }
    else{
        NSLog(@"Error! Explanation system receives nil pattern.");
        return nil;
    }
    
    
    return [NSArray arrayWithArray:self.accordanceMsgs];
}


- (NSInteger)treeNodesApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    switch (root.type) {
        case ExpNode:
        {
            switch (root.value) {
                case And:
                    return [self andNodeApply:root withDeep:deep];
                case Or:
                    return [self orNodeApply:root withDeep:deep];
                case Not:
                    return [self notNodeApply:root withDeep:deep];
                default:
                    break;
            }
        }
            break;
        case PatternNode:
        {
            switch (root.value) {
                case Home:
                {
                    ColorCombinationType value;
                    for (MCTreeNode *child in root.children) {
                        value = (ColorCombinationType)[self treeNodesApply:child withDeep:deep+1];
                        if (![self isCubieAtHomeWithIdentity:value]) {
                            return NO;
                        }
                    }
                    if (deep == 0) {
                        NSString *msg = [MCTransformUtil getContenFromPatternNode:root
                                                             accordingToMagicCube:self.magicCubeDataSource
                                                                  andLockedCubies:lockedCubies];
                        if (msg != nil) {
                            [self.accordanceMsgs addObject:msg];
                        }
                    }
                }
                    break;
                case Check:
                {
                    ColorCombinationType targetCubie = ColorCombinationTypeBound;
                    for (MCTreeNode *subPattern in root.children) {
                        switch (subPattern.value) {
                            case At:
                            {
                                targetCubie = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:0] withDeep:deep+1];
                                ColorCombinationType targetPosition = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:1] withDeep:deep+1];
                                struct Point3i coorValue = [self.magicCubeDataSource coordinateValueOfCubieWithColorCombination:(ColorCombinationType)targetCubie];
                                if (coorValue.x + coorValue.y*3 + coorValue.z * 9 + 13 != targetPosition) {
                                    return NO;
                                }
                            }
                                break;
                            case ColorBindOrientation:
                            {
                                NSObject<MCCubieDelegate> *cubie = nil;
                                FaceOrientationType targetOrientation = (FaceOrientationType)[self treeNodesApply:[subPattern.children objectAtIndex:0] withDeep:deep+1];
                                FaceColorType targetColor = (FaceColorType)[self treeNodesApply:[subPattern.children objectAtIndex:1] withDeep:deep+1];
                                if ([subPattern.children count] > 2) {
                                    NSInteger position = [(MCTreeNode *)[subPattern.children objectAtIndex:2] value];
                                    cubie = [self.magicCubeDataSource cubieAtCoordinateX:(position%3-1) Y:(position%9/3-1) Z:(position/9-1)];
                                } else {
                                    cubie = [self.magicCubeDataSource cubieWithColorCombination:(ColorCombinationType)targetCubie];
                                }
                                return [cubie isFaceColor:targetColor inOrientation:targetOrientation];
                            }
                            case NotAt:
                            {
                                targetCubie = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:0] withDeep:deep+1];
                                ColorCombinationType targetPosition = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:1] withDeep:deep+1];
                                struct Point3i coorValue = [self.magicCubeDataSource coordinateValueOfCubieWithColorCombination:(ColorCombinationType)targetCubie];
                                if (coorValue.x + coorValue.y*3 + coorValue.z * 9 + 13 == targetPosition) {
                                    return NO;
                                }
                            }
                                break;
                            default:
                                return NO;
                        }
                    }
                    if (deep == 0) {
                        NSString *msg = [MCTransformUtil getContenFromPatternNode:root
                                                             accordingToMagicCube:self.magicCubeDataSource
                                                                  andLockedCubies:lockedCubies];
                        if (msg != nil) {
                            [self.accordanceMsgs addObject:msg];
                        }
                    }
                }
                    break;
                case CubiedBeLocked:
                {
                    int index = 0;
                    if ([root.children count] != 0) {
                        index = [(MCTreeNode *)[root.children objectAtIndex:0] value];
                    }
                    
                    if ([self emptyAtIndex:index]) return NO;
                    
                    if (deep == 0) {
                        NSString *msg = [MCTransformUtil getContenFromPatternNode:root
                                                             accordingToMagicCube:self.magicCubeDataSource
                                                                  andLockedCubies:lockedCubies];
                        if (msg != nil) {
                            [self.accordanceMsgs addObject:msg];
                        }
                    }
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
                        switch ([self.magicCubeDataSource centerMagicCubeFaceInOrientation:(FaceOrientationType)child.value]) {
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
                        switch ((FaceColorType)[self treeNodesApply:child withDeep:deep+1]) {
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
                        switch ([self.magicCubeDataSource centerMagicCubeFaceInOrientation:orientation]) {
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
                        color = [[self.magicCubeDataSource cubieAtCoordinatePoint3i:coordinate] faceColorInOrientation:orientation];
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
                    
                    if ([self emptyAtIndex:index]) {
                        root.result = -1;
                    }
                    else{
                        root.result = [[self cubieLockedInLockerAtIndex:index] identity];
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


- (BOOL)andNodeApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    for (MCTreeNode *node in root.children) {
        
        //Being a 'and' node,
        //it will be failed whever one of its child is failed.
        if (![self treeNodesApply:node withDeep: deep+1]) {
            return NO;
        }
        
        //While this node is true, we store some accordance messages
        //for several occasions.
        switch (node.type) {
            case ExpNode:
                if (node.value == Not) {
                    //Notice that the node is 'Not' node.
                    //You should get the negative sentence by invoking
                    //'getNegativeSentenceOfContentFromPatternNode'
                    NSString *msg = [MCTransformUtil getNegativeSentenceOfContentFromPatternNode:[node.children objectAtIndex:0]
                                                                            accordingToMagicCube:self.magicCubeDataSource
                                                                                 andLockedCubies:lockedCubies];
                    if (msg != nil) {
                        [self.accordanceMsgs addObject:msg];
                    }
                }
                break;
            case PatternNode:
            {
                switch (node.value) {
                    case Home | Check:
                    {
                        NSString *msg = [MCTransformUtil getContenFromPatternNode:node
                                                             accordingToMagicCube:self.magicCubeDataSource
                                                                  andLockedCubies:lockedCubies];
                        if (msg != nil) {
                            [self.accordanceMsgs addObject:msg];
                        }
                    }
                        break;
                    case CubiedBeLocked:
                    {
                        if ([node.children count] == 0 ||
                            [(MCTreeNode *)[node.children objectAtIndex:0] value] == 0) {
                            NSString *msg = [MCTransformUtil getContenFromPatternNode:node
                                                                 accordingToMagicCube:self.magicCubeDataSource
                                                                      andLockedCubies:lockedCubies];
                            if (msg != nil) {
                                [self.accordanceMsgs addObject:msg];
                            }
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
                break;
            default:
                break;
        }
    }
    return YES;
}


- (BOOL)orNodeApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    for (MCTreeNode *node in root.children) {
        if ([self treeNodesApply:node withDeep:deep+1]) {
            //While this node is true, we store some accordance messages
            //for several occasions.
            switch (node.type) {
                case ExpNode:
                    if (node.value == Not) {
                        //Notice that the node is 'Not' node.
                        //You should get the negative sentence by invoking
                        //'getNegativeSentenceOfContentFromPatternNode'
                        //The result maybe nil.
                        NSString *msg = [MCTransformUtil getNegativeSentenceOfContentFromPatternNode:[node.children objectAtIndex:0]
                                                                                accordingToMagicCube:self.magicCubeDataSource
                                                                                     andLockedCubies:lockedCubies];
                        if (msg != nil) {
                            [self.accordanceMsgs addObject:msg];
                        }
                        
                    }
                    break;
                case PatternNode:
                {
                    switch (node.value) {
                        case Home | Check:
                        {
                            NSString *msg = [MCTransformUtil getContenFromPatternNode:node
                                                                 accordingToMagicCube:self.magicCubeDataSource
                                                                      andLockedCubies:lockedCubies];
                            if (msg != nil) {
                                [self.accordanceMsgs addObject:msg];
                            }
                        }
                            break;
                        case CubiedBeLocked:
                        {
                            if ([node.children count] == 0 ||
                                [(MCTreeNode *)[node.children objectAtIndex:0] value] == 0) {
                                NSString *msg = [MCTransformUtil getContenFromPatternNode:node
                                                                     accordingToMagicCube:self.magicCubeDataSource
                                                                          andLockedCubies:lockedCubies];
                                if (msg != nil) {
                                    [self.accordanceMsgs addObject:msg];
                                }
                            }
                        }
                            break;
                        default:
                            break;
                    }
                }
                    break;
                default:
                    break;
            }
            
            return YES;
        }
    }
    return NO;
}


- (BOOL)notNodeApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    return ![self treeNodesApply:[root.children objectAtIndex:0] withDeep:deep+1];
}

@end
