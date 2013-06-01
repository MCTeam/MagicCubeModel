//
//  MCInferenceEngine.h
//  MagicCubeModel
//
//  Created by Aha on 13-6-1.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"
#import "MCMagicCubeDelegate.h"
#import "MCKnowledgeBase.h"
#import "MCTransformUtil.h"
#import "MCCubieLockerDelegate.h"
#import "MCActionPerformer.h"

@interface MCInferenceEngine : NSObject<MCCubieLockerDelegate>{
    NSObject<MCCubieDelegate>* lockedCubies[CubieCouldBeLockMaxNum];
}

@property (nonatomic, retain) NSObject<MCMagicCubeDelegate> *magicCubeDataSource;
@property (nonatomic, retain) MCActionPerformer *actionPerformer;
@property (nonatomic, retain) NSDictionary *patterns;
@property (nonatomic, retain) NSDictionary *rules;
@property (nonatomic, retain) NSDictionary *specialPatterns;
@property (nonatomic, retain) NSDictionary *specialRules;
@property (nonatomic, retain) NSDictionary *states;
@property (nonatomic, retain) NSString *magicCubeState;


+ (MCInferenceEngine *)inferenceEngineWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc;


- (id)initWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc;

// Check whether the target cubie is at home
- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity;

// Avoiding to loading all rules into memory,
// Every time we just load rules that can be applied at current state.
// Thereby we should reload rules whenever the state of rubik's cube changes.
- (void)reloadRulesAccordingToCurrentStateOfRubiksCube;

// Apply the pattern and return result
- (BOOL)applyPatternWihtPatternName:(NSString *)name ofType:(AppliedRuleType)type;

// Apply the action and return result
- (BOOL)applyActionWithPatternName:(NSString *)name ofType:(AppliedRuleType)type;

- (NSInteger)treeNodesApply:(MCTreeNode *)root withDeep:(NSInteger)deep;

// Check the current state and return it
- (NSString *)checkStateFromInit:(BOOL)isCheckStateFromInit;

//
- (void)prepareForInference;

- (void)

@end
