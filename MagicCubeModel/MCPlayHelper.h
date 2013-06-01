//
//  MCPlayHelper.h
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMagicCubeDelegate.h"
#import "Global.h"
#import "MCBasicElement.h"
#import "MCApplyQueue.h"
#import "MCInferenceEngine.h"
#import "MCExplanationSystem.h"


#define DEFAULT_RESIDUAL_ACTION_NUM 3


//rotation queue, locked cubies, tips
#define DEFAULT_ACTION_INFOMATION_NUM 3

typedef enum _HelperStateMachine {
    Normal,
    ApplyingRotationQueue
} HelperStateMachine;


@interface MCPlayHelper : NSObject

@property (nonatomic, retain) NSObject<MCMagicCubeDelegate> *magicCube;
@property (nonatomic) HelperStateMachine helperState;
@property (nonatomic, retain) MCApplyQueue *applyQueue;
@property (nonatomic) RotationResult rotationResult;
@property (nonatomic, retain) NSMutableArray *residualActions;
@property (nonatomic, retain) MCInferenceEngine *inferenceEngine;
@property (nonatomic, retain) MCExplanationSystem *explanationSystem;


+ (MCPlayHelper *)playerHelperWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc;


- (id)initWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc;


//rotate operation with axis, layer, direction
- (void)rotateOnAxis:(AxisType)axis onLayer:(int)layer inDirection:(LayerRotationDirectionType)direction;

//rotate operation with parameter SingmasterNotation
- (void)rotateWithSingmasterNotation:(SingmasterNotation)notation;

//get the result of the last rotation
- (RotationResult)getResultOfTheLastRotation;


//apply rules and return actions
//the result is directory:
//"RotationQueue"——the rotation queue in array
//"LockingAt"——an array contains identities(ColorCombinationType) of cubies
//"Tips"——the strings showing tips
//      ——the NSArray with several NSString objects
- (NSDictionary *)applyRules;

//do the clear thing for next rotation queue
- (void)clearResidualActions;

@end
