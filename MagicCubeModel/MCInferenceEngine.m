//
//  MCInferenceEngine.m
//  MagicCubeModel
//
//  Created by Aha on 13-6-1.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCInferenceEngine.h"

@implementation MCInferenceEngine

@synthesize magicCubeDataSource;
@synthesize actionPerformer;
@synthesize patterns;
@synthesize rules;
@synthesize specialPatterns;
@synthesize specialRules;
@synthesize states;
@synthesize magicCubeState;


+ (MCInferenceEngine *)inferenceEngineWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc{
    return [[[MCInferenceEngine alloc] initWithMagicCube:mc] autorelease];
}

//refresh state and rules
- (id)initWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc{
    if (self = [super init]) {
        // Set the magic cube object
        self.magicCubeDataSource = mc;
        
        // Clear locked cubie list
        [self unlockAllCubies];
        
        // Load the state list.
        self.states = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getStatesOfMethod:ETFF]];
        
        // Create the action performer.
        self.actionPerformer = [MCActionPerformer actionPerformerWithMagicCube:mc andCubieLocker:self];
    }
    return self;
}


- (void)dealloc{
    [super dealloc];
    
    // release all
    self.patterns = nil;
    self.rules = nil;
    self.specialPatterns = nil;
    self.specialRules = nil;
    self.states = nil;
    self.magicCubeState = nil;
    self.magicCubeDataSource = nil;
    self.actionPerformer = nil;
}

// the magic cube setter has been rewritten
// once you set the magic cube object, state and rules will be refreshed
- (void)setMagicCubeDataSource:(NSObject<MCMagicCubeDelegate> *)mc{
    [mc retain];
    [self.magicCubeDataSource release];
    self.magicCubeDataSource = mc;
    
    // While the action performer is created, replace the magic cube object
    if (self.actionPerformer != nil) {
        self.actionPerformer.magicCube = mc;
    }
    
    // To begin with, check the state from 'Init' state
    // and load the rules.
    self.magicCubeState = UNKNOWN_STATE;
    [self checkStateFromInit:YES];
}


- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity{
    if (self.magicCubeDataSource == nil) {
        NSLog(@"set the magic cube object first.");
        return NO;
    }
    else{
        NSObject<MCCubieDelegate> *targetCubie = [self.magicCubeDataSource cubieWithColorCombination:identity];
        BOOL isHome = YES;
        NSDictionary *colorOrientationMapping = [targetCubie getCubieColorInOrientationsWithoutNoColor];
        NSArray *orientations = [colorOrientationMapping allKeys];
        for (NSNumber *orientation in orientations) {
            switch ([self.magicCubeDataSource centerMagicCubeFaceInOrientation:(FaceOrientationType)[orientation integerValue]]) {
                case Up:
                    if ([[colorOrientationMapping objectForKey:orientation] integerValue] != UpColor) {
                        isHome = NO;
                    }
                    break;
                case Down:
                    if ([[colorOrientationMapping objectForKey:orientation] integerValue] != DownColor) {
                        isHome = NO;
                    }
                    break;
                case Left:
                    if ([[colorOrientationMapping objectForKey:orientation] integerValue] != LeftColor) {
                        isHome = NO;
                    }
                    break;
                case Right:
                    if ([[colorOrientationMapping objectForKey:orientation] integerValue] != RightColor) {
                        isHome = NO;
                    }
                    break;
                case Front:
                    if ([[colorOrientationMapping objectForKey:orientation] integerValue] != FrontColor) {
                        isHome = NO;
                    }
                    break;
                case Back:
                    if ([[colorOrientationMapping objectForKey:orientation] integerValue] != BackColor) {
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


- (void)reloadRulesAccordingToCurrentStateOfRubiksCube{
    // Every time apply rule, construct a pool for auto releasing.
    NSAutoreleasePool *loopPool = [[NSAutoreleasePool alloc] init];
    
    self.patterns = [NSDictionary dictionaryWithDictionary:
                     [[MCKnowledgeBase getSharedKnowledgeBase] getPatternsWithPreState:self.magicCubeState
                                                                               inTable:DB_PATTERN_TABLE_NAME]];
    self.rules = [NSDictionary dictionaryWithDictionary:
                  [[MCKnowledgeBase getSharedKnowledgeBase] getRulesOfMethod:ETFF
                                                                   withState:magicCubeState
                                                                     inTable:DB_RULE_TABLE_NAME]];
    self.specialPatterns = [NSDictionary dictionaryWithDictionary:
                            [[MCKnowledgeBase getSharedKnowledgeBase] getPatternsWithPreState:magicCubeState
                                                                                      inTable:DB_SPECIAL_PATTERN_TABLE_NAME]];
    self.specialRules = [NSDictionary dictionaryWithDictionary:
                         [[MCKnowledgeBase getSharedKnowledgeBase] getRulesOfMethod:ETFF
                                                                          withState:magicCubeState
                                                                            inTable:DB_SPECIAL_RULE_TABLE_NAME]];
    [loopPool release];
}

//Apply the pattern and return result
- (BOOL)applyPatternWihtPatternName:(NSString *)name ofType:(AppliedRuleType)type{
    
    // Get the pattern named 'name'
    MCPattern *pattern = nil;
    switch (type) {
        case Special:
            pattern = [self.specialPatterns objectForKey:name];
            break;
        case General:
            pattern = [self.patterns objectForKey:name];
            break;
        default:
            break;
    }
    
    // apply
    if (pattern != nil) {
        return [self treeNodesApply:pattern.root withDeep:0];
    }
    else{
        NSLog(@"Can't find the pattern, the pattern name is wrong");
        return NO;
    }
}

//Apply the action and return result
- (BOOL)applyActionWithPatternName:(NSString *)name ofType:(AppliedRuleType)type{
    // Get the rule name 'name'.
    MCRule *rule = nil;
    switch (type) {
        case Special:
            rule = [self.specialRules objectForKey:name];
            break;
        case General:
            rule = [self.rules objectForKey:name];
            break;
        default:
            break;
    }
    
    // apply
    if (rule != nil) {
        return [self treeNodesApply:rule.root withDeep:0];
    }
    else{
        NSLog(@"Can't find the action, the pattern name is wrong");
        return NO;
    }
}


- (NSInteger)treeNodesApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    switch (root.type) {
        case ExpNode:
        {
            switch (root.value) {
                case And:
                {
                    root.result = [self andNodeApply:root withDeep:deep];
                    return root.result;
                }
                case Or:
                {
                    root.result = [self orNodeApply:root withDeep:deep];
                    return root.result;
                }
                case Not:
                {
                    root.result = [self notNodeApply:root withDeep:deep];
                    return root.result;
                }
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
                            root.result = NO;
                            return root.result;
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
                                    root.result = NO;
                                    return root.result;
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
                                root.result = [cubie isFaceColor:targetColor inOrientation:targetOrientation];
                                return root.result;
                            }
                            case NotAt:
                            {
                                targetCubie = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:0] withDeep:deep+1];
                                ColorCombinationType targetPosition = (ColorCombinationType)[self treeNodesApply:[subPattern.children objectAtIndex:1] withDeep:deep+1];
                                struct Point3i coorValue = [self.magicCubeDataSource coordinateValueOfCubieWithColorCombination:(ColorCombinationType)targetCubie];
                                if (coorValue.x + coorValue.y*3 + coorValue.z * 9 + 13 == targetPosition) {
                                    root.result = NO;
                                    return root.result;
                                }
                            }
                                break;
                            default:
                            {
                                root.result = NO;
                                return root.result;
                            }
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
                    
                    if ([self emptyAtIndex:index]) {
                        root.result = NO;
                        return root.result;
                    }
                }
                    break;
                default:
                {
                    root.result = NO;
                    return root.result;
                }
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
        {
            root.result = NO;
            return root.result;
        }
    }
    
    root.result = YES;
    return root.result;
}


- (BOOL)andNodeApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    for (MCTreeNode *node in root.children) {
        //Being a 'and' node,
        //it will be failed whever one of its child is failed.
        if (![self treeNodesApply:node withDeep: deep+1]) {
            root.result = NO;
            return root.result;
        }
    }
    root.result = YES;
    return root.result;
}


- (BOOL)orNodeApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    for (MCTreeNode *node in root.children) {
        if ([self treeNodesApply:node withDeep:deep+1]) {
            root.result = YES;
            return root.result;
        }
    }
    root.result = NO;
    return root.result;
}


- (BOOL)notNodeApply:(MCTreeNode *)root withDeep:(NSInteger)deep{
    root.result = ![self treeNodesApply:[root.children objectAtIndex:0] withDeep:deep+1];
    return root.result;
}


- (NSString *)checkStateFromInit:(BOOL)isCheckStateFromInit;{
    NSString *goStr;
    //to check from init or not
    if (isCheckStateFromInit) {
        goStr = START_STATE;
        [self unlockAllCubies];
    }
    else{
        goStr = self.magicCubeState;
    }
    //check state
    MCState *tmpState = [states objectForKey:goStr];
    for (; tmpState != nil && [self treeNodesApply:[tmpState root] withDeep:0]; tmpState = [states objectForKey:goStr]) {
        goStr = tmpState.afterState;
    }
    if ([goStr compare:self.magicCubeState] != NSOrderedSame) {
        self.magicCubeState = goStr;
        [self unlockCubieAtIndex:0];
        [self unlockCubiesInRange:NSMakeRange(4, CubieCouldBeLockMaxNum-4)];
        [self reloadRulesAccordingToCurrentStateOfRubiksCube];
    }
    
    return self.magicCubeState;
}


- (void)unlockAllCubies{
    for (int i = 0; i < CubieCouldBeLockMaxNum; i++) {
        lockedCubies[i] = nil;
    }
}


- (void)unlockCubieAtIndex:(NSInteger)index{
    lockedCubies[index] = nil;
}


- (void)unlockCubiesInRange:(NSRange)range{
    int i = 0;
    int position = range.location;
    for (; i < range.length; i++, position++) {
        lockedCubies[position] = nil;
    }
}


- (BOOL)emptyAtIndex:(NSInteger)index{
    return lockedCubies[index] == nil;
}


- (void)lockCubie:(NSObject<MCCubieDelegate> *)cubie atIndex:(NSInteger)index{
    lockedCubies[index] = cubie;
}


- (NSObject<MCCubieDelegate> *)cubieLockedInLockerAtIndex:(NSInteger)index{
    return lockedCubies[index];
}

@end
