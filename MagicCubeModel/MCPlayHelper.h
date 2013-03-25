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

#define CubieCouldBeLockMaxNum 26

@interface MCPlayHelper : NSObject

@property (nonatomic, strong)MCMagicCube *magicCube;
@property (nonatomic, strong)NSDictionary *patterns;
@property (nonatomic, strong)NSDictionary *rules;
@property (nonatomic, strong)NSDictionary *states;
@property (nonatomic, strong)NSString *state;

+ (MCPlayHelper *)playerHelperWithMagicCube:(MCMagicCube *)mc;

- (id)initWithMagicCube:(MCMagicCube *)mc;

//see whether the target cubie is at home
- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity;

//apply the pattern and return result
- (BOOL)applyPatternWihtName:(NSString *)name;

- (void)refreshRules;

- (void)checkState;

- (void)applyRules;

- (void)setCheckStateFromInit:(BOOL)is;

@end
