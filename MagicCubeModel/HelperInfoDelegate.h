//
//  HelperInfoDelegate.h
//  MCGame
//
//  Created by Aha on 13-5-29.
//
//

#import <Foundation/Foundation.h>

@protocol HelperInfoDelegate <NSObject>

- (void)onShowQueue:(NSArray *)queue;

- (void)onShowTips:(NSArray *)tips;

- (void)onShowLockedCubies:(NSArray *)lockedCubies;

- (void)onEndPrepare;

@end
