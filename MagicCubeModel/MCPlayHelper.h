//
//  MCPlayHelper.h
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMagicCube.h"
#import "MCKnowledgeBase.h"
#import "Global.h"
#import "MCBasicElement.h"
#import "MCApplyQueue.h"

#define CubieCouldBeLockMaxNum 26


typedef enum _HelperStateMachine {
    Normal,
    ApplyingRotationQueue
} HelperStateMachine;


@interface MCPlayHelper : NSObject

@property (nonatomic, retain)MCMagicCube *magicCube;
@property (nonatomic, retain)NSDictionary *patterns;
@property (nonatomic, retain)NSDictionary *rules;
@property (nonatomic, retain)NSDictionary *states;
@property (nonatomic, retain)NSString *state;
@property (nonatomic)HelperStateMachine helperState;
@property (nonatomic, retain)MCApplyQueue *applyQueue;
@property (nonatomic)RotationResult rotationResult;
@property (nonatomic, retain)NSMutableArray *residualActions;


+ (MCPlayHelper *)playerHelperWithMagicCube:(MCMagicCube *)mc;

- (id)initWithMagicCube:(MCMagicCube *)mc;

//see whether the target cubie is at home
- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity;

//apply the pattern and return result
- (BOOL)applyPatternWihtName:(NSString *)name;

//rotate operation with axis, layer, direction
- (void)rotateOnAxis:(AxisType)axis onLayer:(int)layer inDirection:(LayerRotationDirectionType)direction;

//rotate operation with parameter SingmasterNotation
- (void)rotateWithSingmasterNotation:(SingmasterNotation)notation;

//get the result of the last rotation
- (RotationResult)getResultOfTheLastRotation;

- (void)refreshRules;

//check the current state and return it
- (NSString *)checkStateFromInit:(BOOL)isCheckStateFromInit;

//apply rules and return actions
//the result is directory:
//"RotationQueue"——the rotation queue in array
//"LockingAt"——
//"Tips"——the string showing tips
- (NSDictionary *)applyRules;

//do the clear thing for next rotation queue
- (void)clearResidualActions;

@end
