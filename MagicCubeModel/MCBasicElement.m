//
//  MCBasicElement.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCBasicElement.h"

#define END_TOKEN -999

//tree node
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

//pattern
@implementation MCPattern{
    NSInteger token;
    NSEnumerator *enumerator;
    NSArray *elements;
}

@synthesize root;


-(id)initWithString:(NSString *)patternStr{
    if (self = [self init]) {
        NSMutableArray *mutableElements = [[NSMutableArray alloc]init];
        //split the string
        NSArray *components = [patternStr componentsSeparatedByString:@","];
        //transfer into number
        for (NSString *element in components){
            [mutableElements addObject:[NSNumber numberWithInteger:[element intValue]]];
        }
        //transfer into tree
        [self tokenInit:mutableElements];
        root = [self parsePattern];
        [root retain];
        [self tokenRelease];
        //release tmp object
        [mutableElements release];
    }
    return self;
}

-(void)dealloc{
    [root release];
    [super dealloc];
}

-(void)tokenInit:(NSMutableArray *)array{
    elements = [NSArray arrayWithArray:array];
    [elements retain];
    enumerator = [elements objectEnumerator];
}

-(void)tokenRelease{
    [elements release];
    elements = nil;
    enumerator = nil;
}

-(void)getToken{
    NSNumber *t;
    if (t = [enumerator nextObject]) {
        token = [t integerValue];
    }
    else{
        token = END_TOKEN;
    }
}

-(MCTreeNode *)parsePattern
{
	[self getToken];
	MCTreeNode * rootNode = [self parseBoolExp];
	return rootNode;
}

-(MCTreeNode *)parseBoolExp
{
	MCTreeNode * node = [self parseBterm];
	while (token==Token_Or)
	{
		MCTreeNode * orNode = [[MCTreeNode alloc] initExpNodeWithType:Or];
		if (orNode != nil) {
			[orNode addChild:node];
			[self getToken];
			[orNode addChild:[self parseBterm]];
            node = orNode;
		}
        [orNode autorelease];
	}
	return node;
}

-(MCTreeNode *)parseBterm{
    MCTreeNode * node = [self parseBfactor];
	while (token==Token_And)
	{
        MCTreeNode * andNode = [[MCTreeNode alloc] initExpNodeWithType:And];
		if (andNode!=NULL) {
			[andNode addChild:node];
			[self getToken];
			[andNode addChild:[self parseBfactor]];
            node = andNode;
		}
        [andNode autorelease];
	}
	return node;
}

-(MCTreeNode *)parseBfactor{
    MCTreeNode * node;
	switch (token) {
        case Home:
            node = [[MCTreeNode alloc] initExpNodeWithType:Home];
            [self getToken];
            for ([self getToken]; token >= 0; [self getToken]) {
                [node addChild:[[MCTreeNode alloc] initElementNodeWithValue:token]];
            }
            [self getToken];
            break;
        case Check:
            node = [[MCTreeNode alloc] initExpNodeWithType:Check];
            [self getToken];
            for ([self getToken]; token >= 0; [self getToken]) {
                MCTreeNode *child;
                MCTreeNode *childElement;
                switch (token) {
                    case At:
                    case ColorBindOrientation:
                        child = [[MCTreeNode alloc] initExpNodeWithType:token];
                        [self getToken];[self getToken];
                        childElement = [[MCTreeNode alloc] initElementNodeWithValue:token];
                        [child addChild:childElement];
                        [childElement release];
                        [self getToken];
                        childElement = [[MCTreeNode alloc] initElementNodeWithValue:token];
                        [child addChild:childElement];
                        [childElement release];
                        [self getToken];[self getToken];
                        break;
                    default:
                        break;
                }
                [node addChild:child];
                [child release];
            }
            [self getToken];
            break;
        case Token_LeftParentheses :
            [self getToken];
            node = [self parseBoolExp];
            [self getToken];
            break;
        default:
            NSLog(@"unexpected token.");
            [self getToken];
            break;
	}
	return [node autorelease];
}

@end

//state
@implementation MCState

@synthesize afterState;

- (id)initWithPatternStr:(NSString *)patternStr andAfterState:(NSString *)state{
    if (self = [self initWithString:patternStr]) {
        self.afterState = state;
    }
    return self;
}

- (void)dealloc{
    [afterState release];
    [super dealloc];
}

@end
