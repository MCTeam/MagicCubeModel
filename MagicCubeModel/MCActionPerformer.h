//
//  MCActionPerformer.h
//  MagicCubeModel
//
//  Created by Aha on 13-6-1.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCMagicCubeDelegate.h"
#import "MCCubieLockerDelegate.h"
#import "MCBasicElement.h"
#import "MCTransformUtil.h"

@interface MCActionPerformer : NSObject

@property (nonatomic, retain) NSObject<MCCubieLockerDelegate> *cubieLocker;
@property (nonatomic, retain) NSObject<MCMagicCubeDelegate> *magicCube;


+ (MCActionPerformer *)actionPerformerWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc
                                     andCubieLocker:(NSObject<MCCubieLockerDelegate> *)locker;

- (id)initActionPerformerWithMagicCube:(NSObject<MCMagicCubeDelegate> *)mc
                        andCubieLocker:(NSObject<MCCubieLockerDelegate> *)locker;


- (NSInteger)treeNodesApply:(MCTreeNode *)root;

@end
