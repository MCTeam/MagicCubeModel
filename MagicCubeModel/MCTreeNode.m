//
//  MCTreeNode.m
//  MagicCubeModel
//
//  Created by Aha on 13-1-2.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCTreeNode.h"

@implementation MCTreeNode

@synthesize children;
@synthesize type;
@synthesize value;

-(id)init{
    if (self = [super init]) {
        children = [[NSMutableArray alloc] init];
    }
    return self;
}

-(id)initExpNodeWithType:(NodeType)expType{
    if (self = [self init]) {
        type = expType;
    }
    return self;
}

-(id)initElementNodeWithValue:(NSInteger)elementValue{
    if (self = [self init]) {
        type = Element;
        value = elementValue;
    }
    return self;
}


-(void)dealloc{
    [children release];
    [super dealloc];
}

-(void)addChild:(MCTreeNode *)node{
    [children addObject:node];
}

@end
