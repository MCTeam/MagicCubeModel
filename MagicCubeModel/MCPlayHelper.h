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
#import "MCPattern.h"

@interface MCPlayHelper : NSObject

@property (nonatomic, retain)MCMagicCube *magicCube;
@property (nonatomic, retain)NSDictionary *patterns;
@property (nonatomic, retain)NSDictionary *lockedCubies;

+ (MCPlayHelper *)getSharedPlayHelper;

//see whether the target cubie is at home
- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity;

//apply the pattern and return result
- (BOOL)applyPatternWihtName:(NSString *)name;

- (void)refreshPatterns;

@end
