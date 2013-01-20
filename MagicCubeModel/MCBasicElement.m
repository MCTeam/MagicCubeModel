//
//  MCBasicElement.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCBasicElement.h"

#define END_TOKEN -999
#define LOCKED_CUBIE_TOKEN 999

//tree node
@implementation MCTreeNode

@synthesize children;
@synthesize type;
@synthesize value;

-(id)init{
    if (self = [super init]) {
        self.children = [NSMutableArray array];
    }
    return self;
}

-(id)initNodeWithType:(NodeType)typ{
    if (self = [self init]) {
        self.type = typ;
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
        self.root = [self parsePattern];
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

-(MCTreeNode *)parsePattern{
	[self getToken];
	return [self parseBoolExp];
}

-(MCTreeNode *)parseBoolExp{
	MCTreeNode * node = [self parseBterm];
	if (token==Token_Or)
	{
		MCTreeNode * orNode = [[MCTreeNode alloc] initNodeWithType:ExpNode];
        orNode.value = Or;
		if (orNode != nil) {
			[orNode addChild:node];
			[self getToken];
			[orNode addChild:[self parseBterm]];
            node = orNode;
            [node autorelease];
		}
    }
    while (token == Token_Or) {
        [self getToken];
        [node addChild:[self parseBterm]];
    }
	return node;
}

-(MCTreeNode *)parseBterm{
    MCTreeNode * node = [self parseBfactor];
    if (token == Token_And) {
        MCTreeNode * andNode = [[MCTreeNode alloc] initNodeWithType:ExpNode];
        andNode.value = And;
		if (andNode!=NULL) {
			[andNode addChild:node];
			[self getToken];
			[andNode addChild:[self parseBfactor]];
            node = andNode;
            [node autorelease];
		}
    }
	while (token==Token_And)
	{
        [self getToken];
        [node addChild:[self parseBfactor]];
	}
	return node;
}

-(MCTreeNode *)parseBfactor{
    MCTreeNode * node;
	switch (token) {
        case Home:
            node = [[MCTreeNode alloc] initNodeWithType:PatternNode];
            node.value = Home;
            [self getToken];
            for ([self getToken]; token != Token_RightParentheses;) {
                MCTreeNode *tmp;
                if (token == Token_LeftParentheses) {
                    [self getToken];
                    tmp = [self parseInformationItem];
                    [self getToken];
                } else {
                    tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
                    tmp.value = token;
                    [self getToken];
                    [tmp autorelease];
                }
                [node addChild:tmp];
                
            }
            [self getToken];
            break;
        case Check:
            node = [[MCTreeNode alloc] initNodeWithType:PatternNode];
            node.value = Check;
            [self getToken];
            for ([self getToken]; token >= 0;) {
                MCTreeNode *child;
                MCTreeNode *childElement;
                switch (token) {
                    case At:
                    case ColorBindOrientation:
                    case NotAt:
                        child = [[MCTreeNode alloc] initNodeWithType:PatternNode];
                        child.value = token;
                        [self getToken];
                        int i = 0;
                        for ([self getToken]; i < 2; i++) {
                            if (token == Token_LeftParentheses) {
                                [self getToken];
                                childElement = [self parseInformationItem];
                                [self getToken];
                            } else {
                                childElement = [[MCTreeNode alloc] initNodeWithType:ElementNode];
                                childElement.value = token;
                                [self getToken];
                                [childElement autorelease];
                            }
                            [child addChild:childElement];
                        }
                        [self getToken];
                        break;
                    default:
                        break;
                }
                [node addChild:child];
                [child release];
            }
            [self getToken];
            break;
        case CubiedBeLocked:
            node = [[MCTreeNode alloc] initNodeWithType:PatternNode];
            node.value = CubiedBeLocked;
            [self getToken];
            [self getToken];
            [self getToken];
            break;
        case NoCubieBeLocked:
            node = [[MCTreeNode alloc] initNodeWithType:PatternNode];
            node.value = NoCubieBeLocked;
            [self getToken];
            [self getToken];
            [self getToken];
            break;
        case Token_LeftParentheses :
            [self getToken];
            node = [self parseBoolExp];
            [self getToken];
            return node;
            break;
        default:
            NSLog(@"unexpected token.");
            [self getToken];
            return nil;
            break;
	}
	return [node autorelease];
}

- (MCTreeNode *)parseInformationItem{
    MCTreeNode * node;
	switch (token) {
        case getCombination:
            node = [[MCTreeNode alloc] initNodeWithType:InformationNode];
            node.value = getCombination;
            [self getToken];
            for ([self getToken]; token >= 0; [self getToken]) {
                MCTreeNode *tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
                tmp.value = token;
                [node addChild:tmp];
                [tmp release];
            }
            [self getToken];
            break;
        case getFaceColorFromOrientation:
            node = [[MCTreeNode alloc] initNodeWithType:InformationNode];
            node.value = getFaceColorFromOrientation;
            [self getToken];
            [self getToken];
            MCTreeNode *tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
            tmp.value = token;
            [node addChild:tmp];
            [tmp release];
            [self getToken];
            [self getToken];
            break;
        case LockedCubie:
            node = [[MCTreeNode alloc] initNodeWithType:InformationNode];
            node.value = LockedCubie;
            [self getToken];
            break;
        default:
            NSLog(@"unexpected token.");
            [self getToken];
            return nil;
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


//rule
@implementation MCRule{
    NSInteger token;
    NSEnumerator *enumerator;
    NSArray *elements;
}

@synthesize root;

- (id)initWithString:(NSString *)patternStr{
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
        self.root = [self parseRule];
        [self tokenRelease];
        //release tmp object
        [mutableElements release];
    }
    return self;
}

- (void)dealloc{
    [root release];
    [super dealloc];
}

- (void)tokenInit:(NSMutableArray *)array{
    elements = [NSArray arrayWithArray:array];
    [elements retain];
    enumerator = [elements objectEnumerator];
}

- (void)tokenRelease{
    [elements release];
    elements = nil;
    enumerator = nil;
}

- (void)getToken{
    NSNumber *t;
    if (t = [enumerator nextObject]) {
        token = [t integerValue];
    }
    else{
        token = END_TOKEN;
    }
}

- (MCTreeNode *)parseRule{
	[self getToken];
	return [self parseSequenceExp];
}

- (MCTreeNode *)parseSequenceExp{
	MCTreeNode * node = [[MCTreeNode alloc] initNodeWithType:ExpNode];
    node.value = Sequence;
    MCTreeNode * childNode;
    while ((childNode = [self parseItem]) != nil) {
        [node addChild:childNode];
    }
    
    return [node autorelease];
}

- (MCTreeNode *)parseItem{
    MCTreeNode * node;
	switch (token) {
        case Rotate:
            node = [[MCTreeNode alloc] initNodeWithType:ActionNode];
            node.value = Rotate;
            [self getToken];
            for ([self getToken]; token >= 0; [self getToken]) {
                MCTreeNode *tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
                tmp.value = token;
                [node addChild:tmp];
                [tmp release];
            }
            [self getToken];
            break;
        case FaceToOrientation:
            node = [[MCTreeNode alloc] initNodeWithType:ActionNode];
            node.value = token;
            [self getToken];        //delete "FaceTo"|"MoveTo"
            [self getToken];        //delete "("
            //add two elements
            MCTreeNode *childElement;
            childElement = [[MCTreeNode alloc] initNodeWithType:ElementNode];
            childElement.value = token;
            [node addChild:childElement];
            [childElement release];
            [self getToken];        //delete first element
            childElement = [[MCTreeNode alloc] initNodeWithType:ElementNode];
            childElement.value = token;
            [node addChild:childElement];
            [childElement release];
            [self getToken];        //delete second element
            [self getToken];        //delete ")"
            break;
        case LockCubie:
            node = [[MCTreeNode alloc] initNodeWithType:ActionNode];
            node.value = LockCubie;
            [self getToken];
            [self getToken];
            if (token == Token_LeftParentheses) {
                [self getToken];
                MCTreeNode *child = [self parseInformationItem];
                [node addChild:child];
                [self getToken];
            }
            else{
                MCTreeNode *tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
                tmp.value = token;
                [node addChild:tmp];
                [tmp release];
                [self getToken];
            }
            [self getToken];
            break;
        case UnlockCubie:
            node = [[MCTreeNode alloc] initNodeWithType:ActionNode];
            node.value = UnlockCubie;
            [self getToken];
            [self getToken];
            [self getToken];
            break;
        case Token_LeftParentheses :
            [self getToken];
            node = [self parseItem];
            [self getToken];
            return node;
            break;
        case END_TOKEN:
            return nil;
            break;
        default:
            NSLog(@"unexpected token.");
            [self getToken];
            return nil;
            break;
	}
	return [node autorelease];
}

- (MCTreeNode *)parseInformationItem{
    MCTreeNode * node;
	switch (token) {
        case getCombination:
            node = [[MCTreeNode alloc] initNodeWithType:InformationNode];
            node.value = getCombination;
            [self getToken];
            for ([self getToken]; token >= 0; [self getToken]) {
                MCTreeNode *tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
                tmp.value = token;
                [node addChild:tmp];
                [tmp release];
            }
            [self getToken];
            break;
        case getFaceColorFromOrientation:
            node = [[MCTreeNode alloc] initNodeWithType:InformationNode];
            node.value = getFaceColorFromOrientation;
            [self getToken];
            [self getToken];
            MCTreeNode *tmp = [[MCTreeNode alloc] initNodeWithType:ElementNode];
            tmp.value = token;
            [node addChild:tmp];
            [tmp release];
            [self getToken];
            [self getToken];
            break;
        case LockedCubie:
            node = [[MCTreeNode alloc] initNodeWithType:InformationNode];
            node.value = LockedCubie;
            [self getToken];
            break;
        default:
            NSLog(@"unexpected token.");
            [self getToken];
            return nil;
            break;
    }
	return [node autorelease];
}

@end












