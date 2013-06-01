//
//  MCPlayHelper.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCPlayHelper.h"
#import "MCTransformUtil.h"


@implementation MCPlayHelper

@synthesize magicCube;
@synthesize helperState;
@synthesize applyQueue;
@synthesize rotationResult;
@synthesize inferenceEngine;
@synthesize explanationSystem;
@synthesize residualActions;


+ (MCPlayHelper *)playerHelperWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc{
    return [[[MCPlayHelper alloc] initWithMagicCube:mc] autorelease];
}

- (id)initWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc{
    if (self = [super init]) {
        // Here allocate the array which store residual actions.
        // The residual actions contains all actions of the applied rule except rotation actions.
        self.residualActions = [NSMutableArray arrayWithCapacity:DEFAULT_RESIDUAL_ACTION_NUM];
        
        // normal helper state
        self.helperState = Normal;
        
        // set magic cube object
        self.magicCube = mc;
        
        // Init the inference engine.
        self.inferenceEngine = [MCInferenceEngine inferenceEngineWithMagicCube:mc];
        
        // Init the explanation system.
        self.explanationSystem = [MCExplanationSystem explanationSystemWithMagicCube:mc
                                                                      andCubieLocker:self.inferenceEngine];
    }
    return self;
}

// The magic cube setter has been rewritten
// once you set the magic cube object, the inference engine's magic cube object
// will be replaced.
- (void)setMagicCube:(NSObject<MCMagicCubeDelegate> *)mc{
    [mc retain];
    [self.magicCube release];
    self.magicCube = mc;
    
    // While the inference engine is created, replace the magic cube object
    if (self.inferenceEngine != nil) {
        self.inferenceEngine.magicCubeDataSource = mc;
    }
    
    // While the explanation system is created, replace the magic cube object
    if (self.explanationSystem != nil) {
        self.explanationSystem.magicCubeDataSource = mc;
    }
}


- (void)dealloc{
    self.magicCube = nil;
    self.applyQueue = nil;
    self.inferenceEngine = nil;
    self.explanationSystem = nil;
    self.residualActions = nil;
    [super dealloc];
}


- (void)rotateOnAxis:(AxisType)axis onLayer:(int)layer inDirection:(LayerRotationDirectionType)direction{
    if (self.magicCube != nil) {
        [self.magicCube rotateOnAxis:axis onLayer:layer inDirection:direction];
        SingmasterNotation currentRotation = [MCTransformUtil getSingmasterNotationFromAxis:axis layer:layer direction:direction];
        //apply rotation and get result
        if (self.applyQueue != nil && self.helperState == ApplyingRotationQueue) {
            self.rotationResult = [self.applyQueue applyRotation:currentRotation];
        }
    }
}


- (void)rotateWithSingmasterNotation:(SingmasterNotation)notation{
    if (self.magicCube != nil) {
        [self.magicCube rotateWithSingmasterNotation:notation];
        //apply rotation and get result
        if (self.applyQueue != nil && self.helperState == ApplyingRotationQueue) {
            self.rotationResult = [self.applyQueue applyRotation:notation];
        }
    }
}


- (RotationResult)getResultOfTheLastRotation{
    return self.rotationResult;
}


- (void)setHelperState:(HelperStateMachine)hs{
    helperState = hs;
    switch (hs) {
        case Normal:
            self.applyQueue = nil;
            self.rotationResult = NoneResult;
            break;
        case ApplyingRotationQueue:
            break;
        default:
            break;
    }
}

- (NSDictionary *)applyRules{
    if (self.magicCube == nil){
        NSLog(@"Set the magic cube before apply rules.");
        return nil;
    }
    
    AppliedRuleType appliedType = Special;
    
    // Check special rules firstly.
    NSString *targetKey = nil;
    for (NSString *key in [self.specialRules allKeys])
    {
        if ([self applyPatternWihtPatternName:key ofType:Special]) {
            targetKey = key;
            appliedType = Special;
            break;
        }
    }
    
    // If no special rules match the state, check general rules.
    if (targetKey == nil) {
        for (NSString *key in [self.rules allKeys])
        {
            if ([self applyPatternWihtPatternName:key ofType:General]) {
                targetKey = key;
                appliedType = General;
                break;
            }
        }
    }
    
#ifdef ONLY_TEST
    NSLog(@"%@", targetKey);
    //error occurs, we can not find the rules to apply and there isn't the finished state.
    if ([self.inferenceEngine.magicCubeState compare:END_STATE] != NSOrderedSame && targetKey == nil) {
        NSLog(@"%@", @"There must be something wrong, I don't apply any rules.");
        //save state for debug
        NSString *savedPath = [NSString stringWithFormat:@"ErrorStateForDebug_%f", [[NSDate date] timeInterval]];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [path stringByAppendingPathComponent:savedPath];
        [NSKeyedArchiver archiveRootObject:magicCube toFile:fileName];
        return nil;
    }
    [self applyActionWithPatternName:targetKey ofType:appliedType];
    [self checkStateFromInit:NO];
#else
    //error occurs, we can not find the rules to apply and there isn't the finished state.
    if ([self.inferenceEngine.magicCubeState compare:END_STATE] != NSOrderedSame && targetKey == nil) {
        NSLog(@"%@", @"There must be something wrong, I don't apply any rules.");
        //save state for debug
        NSString *savedPath = [NSString stringWithFormat:@"ErrorStateForDebug_%f", [[NSDate date] timeInterval]];
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [path stringByAppendingPathComponent:savedPath];
        [NSKeyedArchiver archiveRootObject:magicCube toFile:fileName];
        return nil;
    }
#endif
    
    NSLog(@"State:%@", self.inferenceEngine.magicCubeState);
    NSLog(@"Rules:%@", targetKey);
    
#ifndef ONLY_TEST
    //get the tree of the action according to the pattern name
    MCTreeNode *actionTree = nil;
    switch (appliedType) {
        case Special:
            actionTree = [[self.specialRules objectForKey:targetKey] root];
            break;
        case General:
            actionTree = [[self.rules objectForKey:targetKey] root];
        default:
            break;
    }
    
    //analyse the action and return the result
    switch (actionTree.type) {
        case ExpNode:
        {
            BOOL flag = YES;
            for (MCTreeNode *node in actionTree.children) {
                if (flag) {
                    if (node.type == ActionNode && (node.value == Rotate|| node.value == FaceToOrientation)) {
                        self.applyQueue = [MCApplyQueue applyQueueWithRotationAction:node withMagicCube:self.magicCube];
                        flag = NO;
                    }
                    else{
                        [self treeNodesApply:node withDeep:1];
                    }
                } else {
                    [self.residualActions addObject:node];
                }
            }
        }
            break;
        case ActionNode:
            switch (actionTree.value) {
                case Rotate:
                case FaceToOrientation:
                    self.applyQueue = [MCApplyQueue applyQueueWithRotationAction:actionTree withMagicCube:self.magicCube];
                    break;
                default:
                    [self treeNodesApply:actionTree withDeep:0];
                    break;
            }
            break;
        default:
            break;
    }
    
    NSMutableDictionary *resultDirectory = [NSMutableDictionary dictionaryWithCapacity:DEFAULT_ACTION_INFOMATION_NUM];
    
    //While the apply queue isn't nil, attach it to the result directory.
    if (self.applyQueue != nil) {
        [resultDirectory setObject:[self.applyQueue getQueueWithStringFormat] forKey:KEY_ROTATION_QUEUE];
        self.helperState = ApplyingRotationQueue;
    }
    
    //While the apply queue isn't nil, attach it to the result directory.
    if ([self.accordanceMsgs count] != 0) {
        [resultDirectory setObject:[NSArray arrayWithArray:self.accordanceMsgs] forKey:KEY_TIPS];
        //------------------------------------
        NSLog(@"Tips---");
        for (NSString *msg in self.accordanceMsgs) {
            NSLog(@"%@", msg);
        }
    }
    
    //While there is a cubie is locked at 0 position, add locked cubie info
    if (lockedCubies[0] != nil) {
        [resultDirectory setObject:[NSArray arrayWithObject:[NSNumber numberWithInteger:[lockedCubies[0] identity]]] forKey:KEY_LOCKED_CUBIES];
    }
    
#else
    NSDictionary *resultDirectory = [NSDictionary dictionary];
#endif
    
    return resultDirectory;
}

- (void)clearResidualActions{
    for (MCTreeNode *node in self.residualActions) {
        [self.inferenceEngine treeNodesApply:node withDeep:0];
    }
    [self.residualActions removeAllObjects];
    [self.inferenceEngine checkStateFromInit:NO];
} 

@end

