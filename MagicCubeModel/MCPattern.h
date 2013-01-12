//
//  MCPattern.h
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCTreeNode.h"

@interface MCPattern : NSObject

@property(retain, nonatomic)MCTreeNode *root;


- (id)initWithString:(NSString *)patternStr;

@end
