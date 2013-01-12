//
//  MCTreeNode.h
//  MagicCubeModel
//
//  Created by Aha on 13-1-2.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Global.h"


@interface MCTreeNode : NSObject

@property (retain, nonatomic)NSMutableArray *children;
@property (nonatomic)NodeType type;
@property (nonatomic)NSInteger value;

-(id)initExpNodeWithType:(NodeType)expType;

-(id)initElementNodeWithValue:(NSInteger)elementValue;

-(void)addChild:(MCTreeNode *)node;

@end
