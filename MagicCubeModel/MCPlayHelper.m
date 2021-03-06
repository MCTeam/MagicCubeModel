//
//  MCPlayHelper.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCPlayHelper.h"
#import "MCTransformUtil.h"


@implementation MCPlayHelper{
    MCCubie* lockedCubies[CubieCouldBeLockMaxNum];
    SingmasterNotation previousRotation;
    RotationResult previousResult;
    int currentRotationQueuePosition;
}

@synthesize magicCube;
@synthesize patterns;
@synthesize rules;
@synthesize states;
@synthesize state;
@synthesize helperState;
@synthesize rotationQueue;
@synthesize extraOperations;

+ (MCPlayHelper *)playerHelperWithMagicCube:(MCMagicCube *)mc{
    return [[MCPlayHelper alloc] initWithMagicCube:mc];
}

- (id)initWithMagicCube:(MCMagicCube *)mc{
    if (self = [super init]) {
        //normal helper state
        self.helperState = Normal;
        //clearing rotation queue
        self.rotationQueue = nil;
        //locked cubie list
        for (int i = 0; i < CubieCouldBeLockMaxNum; i++) {
            lockedCubies[0] = nil;
        }
        
        self.magicCube = mc;
        //refresh state and rules
        self.state = START_STATE;
        self.patterns = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getPatternsWithPreState:state]];
        self.rules = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getRulesOfMethod:ETFF withState:state]];
        self.states = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getStatesOfMethod:ETFF]];
        [self checkState:YES];
    }
    return self;
}

//the magic cube setter has been rewritten
//once you set the magic cube object, state and rules will be refreshed
- (void)setMagicCube:(MCMagicCube *)mc{
    magicCube = mc;
    //refresh state and rules
    self.state = START_STATE;
    self.patterns = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getPatternsWithPreState:state]];
    self.rules = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getRulesOfMethod:ETFF withState:state]];
    self.states = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getStatesOfMethod:ETFF]];
    [self checkState:YES];
}

- (void)dealloc{
    [self setMagicCube:nil];
}

- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity{
    if (magicCube == nil) {
        NSLog(@"set the magic cube object first.");
        return NO;
    }
    else{
        MCCubie *targetCubie = [magicCube cubieWithColorCombination:identity];
        BOOL isHome = YES;
        for (int i = 0; i < targetCubie.skinNum; i++) {
            switch ([magicCube magicCubeFaceInOrientation:targetCubie.orientations[i]]) {
                case Up:
                    if (targetCubie.faceColors[i] != UpColor) {
                        isHome = NO;
                    }
                    break;
                case Down:
                    if (targetCubie.faceColors[i] != DownColor) {
                        isHome = NO;
                    }
                    break;
                case Left:
                    if (targetCubie.faceColors[i] != LeftColor) {
                        isHome = NO;
                    }
                    break;
                case Right:
                    if (targetCubie.faceColors[i] != RightColor) {
                        isHome = NO;
                    }
                    break;
                case Front:
                    if (targetCubie.faceColors[i] != FrontColor) {
                        isHome = NO;
                    }
                    break;
                case Back:
                    if (targetCubie.faceColors[i] != BackColor) {
                        isHome = NO;
                    }
                    break;
                case WrongOrientation:
                    isHome = NO;
                    break;
            }
            if (!isHome) {
                break;
            }
        }
        return isHome;
    }
}

- (BOOL)applyPatternWihtName:(NSString *)name{
    MCPattern *pattern = [patterns objectForKey:name];
    if (pattern != nil) {
        return [self treeNodesApply:pattern.root];
    }
    else{
        NSLog(@"the pattern name is wrong");
        return NO;
    }
}


#define NO_LOCKED_CUBIE -1
- (NSInteger)treeNodesApply:(MCTreeNode *)root{
    switch (root.type) {
        case ExpNode:
        {
            switch (root.value) {
                case And:
                    return [self andNodeApply:root];
                case Or:
                    return [self orNodeApply:root];
                case Sequence:
                    return [self sequenceNodeApply:root];
                case Not:
                    return [self notNodeApply:root];
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
                        value = (ColorCombinationType)[self treeNodesApply:child];
                        if (value == NO_LOCKED_CUBIE) {
                            return NO;
                        }
                        if (![self isCubieAtHomeWithIdentity:value]) {
                            return NO;
                        }
                    }
                }
                    break;
                case Check:
                {
                    NSInteger targetCubie;
                    for (MCTreeNode *subPattern in root.children) {
                        switch (subPattern.value) {
                            case At:
                            {
                                targetCubie = [self treeNodesApply:[subPattern.children objectAtIndex:0]];
                                ColorCombinationType targetPosition = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:1]];
                                struct Point3i coorValue = [magicCube coordinateValueOfCubieWithColorCombination:(ColorCombinationType)targetCubie];
                                if (coorValue.x + coorValue.y*3 + coorValue.z * 9 + 13 != targetPosition) {
                                    return NO;
                                }
                            }
                                break;
                            case ColorBindOrientation:
                            {
                                MCCubie *cubie = nil;
                                FaceOrientationType targetOrientation = (FaceOrientationType)[self treeNodesApply:[subPattern.children objectAtIndex:0]];
                                FaceColorType targetColor = (FaceColorType)[self treeNodesApply:[subPattern.children objectAtIndex:1]];
                                if ([subPattern.children count] > 2) {
                                    NSInteger position = [(MCTreeNode *)[subPattern.children objectAtIndex:2] value];
                                    cubie = [magicCube cubieAtCoordinateX:(position%3-1) Y:(position%9/3-1) Z:(position/9-1)];
                                } else {
                                    cubie = [magicCube cubieWithColorCombination:(ColorCombinationType)targetCubie];
                                }
                                return [cubie isFaceColor:targetColor inOrientation:targetOrientation];
                            }
                            case NotAt:
                            {
                                targetCubie = [self treeNodesApply:[subPattern.children objectAtIndex:0]];
                                ColorCombinationType targetPosition = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:1]];
                                struct Point3i coorValue = [magicCube coordinateValueOfCubieWithColorCombination:(ColorCombinationType)targetCubie];
                                if (coorValue.x + coorValue.y*3 + coorValue.z * 9 + 13 == targetPosition) {
                                    return NO;
                                }
                            }
                                break;
                            default:
                                return NO;
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
                    return lockedCubies[index] != nil;
                }
                default:
                    return NO;
            }
        }
            break;
        case ActionNode:
        {
            switch (root.value) {
                case Rotate:
                    for (MCTreeNode *child in root.children) {
                        [magicCube rotateWithSingmasterNotation:(SingmasterNotation)child.value];
                    }
                    break;
                case FaceToOrientation:
                {
                    MCTreeNode *elementNode;
                    elementNode = [root.children objectAtIndex:0];
                    ColorCombinationType targetCombination = (ColorCombinationType)elementNode.value;
                    struct Point3i targetCoor = [magicCube coordinateValueOfCubieWithColorCombination:targetCombination];
                    elementNode = [root.children objectAtIndex:1];
                    FaceOrientationType targetOrientation = (FaceOrientationType)elementNode.value;
                    [magicCube rotateWithSingmasterNotation:[self getPathToMakeCenterCubieAtPosition:targetCoor inOrientation:targetOrientation]];
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
                        lockedCubies[index] = nil;
                    }
                    else{
                        lockedCubies[index] = [magicCube cubieWithColorCombination:(ColorCombinationType)identity];
                    }
                }
                    break;
                case UnlockCubie:
                {
                    int index = 0;
                    if ([root.children count] != 0) {
                        index = [(MCTreeNode *)[root.children objectAtIndex:0] value];
                    }
                    lockedCubies[index] = nil;
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
                        switch ([magicCube magicCubeFaceInOrientation:(FaceOrientationType)child.value]) {
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
                    return x+y*3+z*9;
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
                    return x+y*3+z*9;
                }
                case getFaceColorFromOrientation:
                {
                    FaceColorType color;
                    FaceOrientationType orientation = (FaceOrientationType)[(MCTreeNode *)[root.children objectAtIndex:0] value];
                    if ([root.children count] == 1) {
                        switch ([magicCube magicCubeFaceInOrientation:orientation]) {
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
                        color = [[magicCube cubieAtCoordinatePoint3i:coordinate] faceColorInOrientation:orientation];
                    }
                    return color;
                }
                case lockedCubie:
                {
                    int index = 0;
                    if ([root.children count] != 0) {
                        index = [(MCTreeNode *)[root.children objectAtIndex:0] value];
                    }
                    if (lockedCubies[index] == nil) {
                        return -1;
                    }
                    else{
                        return lockedCubies[index].identity;
                    }
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

- (BOOL)andNodeApply:(MCTreeNode *)root{
    for (MCTreeNode *node in root.children) {
        if (![self treeNodesApply:node]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)orNodeApply:(MCTreeNode *)root{
    for (MCTreeNode *node in root.children) {
        if ([self treeNodesApply:node]) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)sequenceNodeApply:(MCTreeNode *)root{
    for (MCTreeNode *node in root.children) {
        [self treeNodesApply:node];
    }
    return YES;
}

- (BOOL)notNodeApply:(MCTreeNode *)root{
    return ![self treeNodesApply:[root.children objectAtIndex:0]];
}

- (NSDictionary *)applyRules{
    if (self.magicCube == nil){
        NSLog(@"Set the magic cube before apply rules.");
        return nil;
    }
    NSString *key;
    NSArray *keys = [rules allKeys];
    int count = [rules count];
    MCTreeNode *action = nil;
    int i;
    for (i = 0; i < count; i++)
    {
        key = [keys objectAtIndex:i];
        if ([self applyPatternWihtName:key]) {
            action = [[rules objectForKey:key] root];
#ifdef ONLY_TEST
            [self treeNodesApply:action];
            NSLog(@"%@", key);
#endif
            break;
        }
    }
    //error occurs, we can not find the rules to apply and there isn't the finished state.
    if ([[self checkState:NO] compare:END_STATE] != NSOrderedSame && action == nil) {
        NSLog(@"%@", @"There must be something wrong, I don't apply any rules.");
        //save state for debug
        NSString *savedPath = [NSString stringWithFormat:@"ErrorStateForDebug_%f", [[NSDate date] timeInterval]];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [path stringByAppendingPathComponent:savedPath];
        [NSKeyedArchiver archiveRootObject:magicCube toFile:fileName];
        return nil;
    }
    NSLog(@"%@", state);
    
#ifndef ONLY_TEST    
    //analyse the action and return the result
    NSMutableArray *returnedRotationQueue = nil;
    currentRotationQueuePosition = 0;
    previousResult = NoneResult;
    previousRotation = NoneNotation;
    for (MCTreeNode *node in action.children) {
        switch (node.value) {
            case Rotate:
            {
                returnedRotationQueue = [NSMutableArray arrayWithCapacity:10];
                self.rotationQueue = [NSMutableArray arrayWithCapacity:10];
                for (MCTreeNode *child in node.children) {
                    if (child.value == Fw2 || child.value == Bw2 || child.value == Rw2 || child.value == Lw2 ||
                        child.value == Uw2 || child.value == Dw2 ) {
                        [returnedRotationQueue addObject:[MCTransformUtil getRotationTagFromSingmasterNotation:(SingmasterNotation)(child.value-2)]];
                        [returnedRotationQueue addObject:[MCTransformUtil getRotationTagFromSingmasterNotation:(SingmasterNotation)(child.value-2)]];
                        [rotationQueue addObject:[NSNumber numberWithInteger:(child.value-2)]];
                        [rotationQueue addObject:[NSNumber numberWithInteger:(child.value-2)]];
                    }
                    else{
                        [returnedRotationQueue addObject:[MCTransformUtil getRotationTagFromSingmasterNotation:(SingmasterNotation)child.value]];
                        [rotationQueue addObject:[NSNumber numberWithInteger:child.value]];
                    }
                }
            }
                break;
            case FaceToOrientation:
            {
                MCTreeNode *elementNode;
                elementNode = [node.children objectAtIndex:0];
                ColorCombinationType targetCombination = (ColorCombinationType)elementNode.value;
                struct Point3i targetCoor = [magicCube coordinateValueOfCubieWithColorCombination:targetCombination];
                elementNode = [node.children objectAtIndex:1];
                FaceOrientationType targetOrientation = (FaceOrientationType)elementNode.value;
                returnedRotationQueue = [NSArray arrayWithObject:
                                 [MCTransformUtil getRotationTagFromSingmasterNotation:
                                  [self getPathToMakeCenterCubieAtPosition:targetCoor inOrientation:targetOrientation]]];
            }
                break;
            case LockCubie:
            {
                MCTreeNode *elementNode = [node.children objectAtIndex:0];
                int index = 0;
                if ([node.children count] != 1) {
                    index = [(MCTreeNode *)[node.children objectAtIndex:1] value];
                }
                int identity = [self treeNodesApply:elementNode];
                if (identity == -1) {
                    lockedCubies[index] = nil;
                }
                else{
                    lockedCubies[index] = [magicCube cubieWithColorCombination:(ColorCombinationType)identity];
                }
            }
                break;
            case UnlockCubie:
            {
                int index = 0;
                if ([node.children count] != 0) {
                    index = [(MCTreeNode *)[node.children objectAtIndex:0] value];
                }
                lockedCubies[index] = nil;
            }
                break;
        }
    }
    NSDictionary *resultDirectory = nil;
    if (returnedRotationQueue != nil) {
        resultDirectory = [NSDictionary dictionaryWithObject:[NSArray arrayWithArray:returnedRotationQueue] forKey:RotationQueueKey];
        self.helperState = ApplyingRotationQueue;
    }
#else
    NSDictionary *resultDirectory = [NSDictionary dictionary];
#endif
    return resultDirectory;
}

- (void)refreshRules{
    self.states = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getStatesOfMethod:ETFF]];
    self.patterns = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getPatternsWithPreState:state]];
    self.rules = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getRulesOfMethod:ETFF withState:state]];
}

- (NSString *)checkState:(BOOL)isCheckStateFromInit;{
    NSString *goStr;
    //to check from init or not
    if (isCheckStateFromInit) {
        goStr = START_STATE;
        for (int i = 0; i < CubieCouldBeLockMaxNum; i++) {
            lockedCubies[i] = nil;
        }
    }
    else{
        goStr = state;
    }
    //check state
    for (MCState *tmpState = [states objectForKey:goStr]; tmpState != nil && [self treeNodesApply:[tmpState root]]; tmpState = [states objectForKey:goStr]) {
        goStr = tmpState.afterState;
    }
    if ([goStr compare:state] != NSOrderedSame) {
        self.state = goStr;
        lockedCubies[0] = nil;
        for (int i = 4; i < CubieCouldBeLockMaxNum; i++) {
            lockedCubies[i] = nil;
        }
        [self refreshRules];
    }
    
    return self.state;
}

- (SingmasterNotation)getPathToMakeCenterCubieAtPosition:(struct Point3i)coordinate inOrientation:(FaceOrientationType)orientation{
    SingmasterNotation result = NoneNotation;
    switch (orientation) {
        case Up:
            switch (coordinate.y) {
                case 1:
                    result = NoneNotation;
                    break;
                case 0:
                    switch (coordinate.x*2+coordinate.z) {
                        case 1:
                            result = x;
                            break;
                        case -1:
                            result = xi;
                            break;
                        case 2:
                            result = zi;
                            break;
                        case -2:
                            result = z;
                            break;
                        default:
                            break;
                    }
                    break;
                case -1:
                    result = x2;
                    break;
                default:
                    break;
            }
            break;
        case Down:
            switch (coordinate.y) {
                case -1:
                    result = NoneNotation;
                    break;
                case 0:
                    switch (coordinate.x*2+coordinate.z) {
                        case 1:
                            result = xi;
                            break;
                        case -1:
                            result = x;
                            break;
                        case 2:
                            result = z;
                            break;
                        case -2:
                            result = zi;
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                    result = x2;
                    break;
                default:
                    break;
            }
            break;
        case Left:
            switch (coordinate.x) {
                case -1:
                    result = NoneNotation;
                    break;
                case 0:
                    switch (coordinate.y*2+coordinate.z) {
                        case 1:
                            result = y;
                            break;
                        case -1:
                            result = yi;
                            break;
                        case 2:
                            result = zi;
                            break;
                        case -2:
                            result = z;
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                    result = y2;
                    break;
                default:
                    break;
            }
            break;
        case Right:
            switch (coordinate.x) {
                case 1:
                    result = NoneNotation;
                    break;
                case 0:
                    switch (coordinate.y*2+coordinate.z) {
                        case 1:
                            result = yi;
                            break;
                        case -1:
                            result = y;
                            break;
                        case 2:
                            result = z;
                            break;
                        case -2:
                            result = zi;
                            break;
                        default:
                            break;
                    }
                    break;
                case -1:
                    result = y2;
                    break;
                default:
                    break;
            }
            break;
        case Front:
            switch (coordinate.z) {
                case 1:
                    result = NoneNotation;
                    break;
                case 0:
                    switch (coordinate.x*2+coordinate.y) {
                        case 1:
                            result = xi;
                            break;
                        case -1:
                            result = x;
                            break;
                        case 2:
                            result = y;
                            break;
                        case -2:
                            result = yi;
                            break;
                        default:
                            break;
                    }
                    break;
                case -1:
                    result = y2;
                    break;
                default:
                    break;
            }
            break;
        case Back:
            switch (coordinate.z) {
                case -1:
                    result = NoneNotation;
                    break;
                case 0:
                    switch (coordinate.x*2+coordinate.y) {
                        case 1:
                            result = x;
                            break;
                        case -1:
                            result = xi;
                            break;
                        case 2:
                            result = yi;
                            break;
                        case -2:
                            result = y;
                            break;
                        default:
                            break;
                    }
                    break;
                case 1:
                    result = y2;
                    break;
                default:
                    break;
            }
            break;
        default:
            result = NoneNotation;
            break;
    }
    return result;
}

- (void)rotateOnAxis:(AxisType)axis onLayer:(int)layer inDirection:(LayerRotationDirectionType)direction{
    if (self.magicCube != nil) {
        [self.magicCube rotateOnAxis:axis onLayer:layer inDirection:direction];
        SingmasterNotation currentRotation = [MCTransformUtil getSingmasterNotationFromAxis:axis layer:layer direction:direction];
        //detect the rotation result
        //if the queue is exist, continue
        //else, return finished
        if (self.rotationQueue == nil) {
            previousResult = Finished;
        }
        else{
            //if they are same, accord
            SingmasterNotation targetRotation = (SingmasterNotation)[[self.rotationQueue objectAtIndex:currentRotationQueuePosition] integerValue];
            if (targetRotation == currentRotation) {
                previousResult = Accord;
                currentRotationQueuePosition++;
            }
            else{
                if (previousResult == StayForATime) {
                    if ([MCTransformUtil isSingmasterNotation:previousRotation andSingmasterNotation:currentRotation equalTo:targetRotation]) {
                        previousResult = Accord;
                        currentRotationQueuePosition++;
                    }
                    else{
                        previousResult = Disaccord;
                        //insert extra operations
                        [self.rotationQueue insertObject:[NSNumber numberWithInteger:
                                                          [MCTransformUtil getContrarySingmasterNotation:previousRotation]]
                                                 atIndex:currentRotationQueuePosition];
                        [self.rotationQueue insertObject:[NSNumber numberWithInteger:
                                                          [MCTransformUtil getContrarySingmasterNotation:currentRotation]]
                                                 atIndex:currentRotationQueuePosition];
                        //save extra operations
                        self.extraOperations = [NSArray arrayWithObjects:
                                                [MCTransformUtil getRotationTagFromSingmasterNotation:[MCTransformUtil getContrarySingmasterNotation:previousRotation]],
                                                [MCTransformUtil getRotationTagFromSingmasterNotation:[MCTransformUtil getContrarySingmasterNotation:currentRotation]],
                                                nil];
                    }
                } else {
                    if ([MCTransformUtil isSingmasterNotation:currentRotation PossiblePartOfSingmasterNotation:targetRotation]) {
                        previousResult = StayForATime;
                    }
                    else{
                        previousResult = Disaccord;
                        //insert extra operations
                        [self.rotationQueue insertObject:[NSNumber numberWithInteger:
                                                          [MCTransformUtil getContrarySingmasterNotation:currentRotation]]
                                                 atIndex:currentRotationQueuePosition];
                        //save extra operations
                        self.extraOperations = [NSArray arrayWithObjects:
                                                [MCTransformUtil getRotationTagFromSingmasterNotation:[MCTransformUtil getContrarySingmasterNotation:currentRotation]],
                                                nil];
                    }
                }
            }
            
            if (currentRotationQueuePosition == [self.rotationQueue count]) {
                self.rotationQueue = nil;
                previousResult = Finished;
            }
        }
        previousRotation = currentRotation;
    }
}

- (RotationResult)getResultOfTheLastRotation{
    return previousResult;
}

@end

