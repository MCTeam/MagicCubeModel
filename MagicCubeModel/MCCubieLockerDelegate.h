//
//  MCCubieLockerDelegate.h
//  MagicCubeModel
//
//  Created by Aha on 13-6-1.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCCubieDelegate.h"

@protocol MCCubieLockerDelegate <NSObject>

// locker max size
#define CubieCouldBeLockMaxNum 26


// This action will unlock all cubies.
// Just when re-check state from init, it should be invoked.
- (void)unlockAllCubies;


- (void)unlockCubieAtIndex:(NSInteger)index;


- (void)unlockCubiesInRange:(NSRange)range;


- (BOOL)emptyAtIndex:(NSInteger)index;

- (void)lockCubie:(NSObject<MCCubieDelegate> *)cubie atIndex:(NSInteger)index;

- (NSObject<MCCubieDelegate> *)cubieLockedInLockerAtIndex:(NSInteger)index;


@end
