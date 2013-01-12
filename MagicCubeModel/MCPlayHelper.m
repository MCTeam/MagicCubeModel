//
//  MCPlayHelper.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-29.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCPlayHelper.h"


@implementation MCPlayHelper

@synthesize magicCube;
@synthesize patterns;
@synthesize lockedCubies;

+ (MCPlayHelper *)getSharedPlayHelper{
    static MCPlayHelper *playHelper;
    @synchronized(self)
    {
        if (!playHelper)
            playHelper = [[MCPlayHelper alloc] init];
        return playHelper;
    }
}

- (id)init{
    if (self = [super init]) {
        patterns = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getPatterns]];
        [patterns retain];
        magicCube = [MCMagicCube getSharedMagicCube];
        lockedCubies = [[NSDictionary alloc] init];
    }
    return self;
}

- (void)dealloc{
    [lockedCubies release];
    [patterns release];
    [self setMagicCube:nil];
    [super dealloc];
}

- (BOOL)isCubieAtHomeWithIdentity:(ColorCombinationType)identity{
    if (magicCube == nil) {
        NSLog(@"set the magic cube object first.");
        return NO;
    }
    else{
        MCCubie *targetCubie = [magicCube cubieWithColorCombination:identity];
        BOOL isHome = YES;
        for (int i = 0; i < targetCubie.skinNum; i++) {
            switch (targetCubie.orientations[i]) {
                case Up:
                    if (targetCubie.faceColors[i] != UpColor) {
                        isHome = NO;
                    }
                    break;
                case Down:
                    if (targetCubie.faceColors[i] != DownColor) {
                        isHome = NO;
                    }
                    break;
                case Left:
                    if (targetCubie.faceColors[i] != LeftColor) {
                        isHome = NO;
                    }
                    break;
                case Right:
                    if (targetCubie.faceColors[i] != RightColor) {
                        isHome = NO;
                    }
                    break;
                case Front:
                    if (targetCubie.faceColors[i] != FrontColor) {
                        isHome = NO;
                    }
                    break;
                case Back:
                    if (targetCubie.faceColors[i] != BackColor) {
                        isHome = NO;
                    }
                    break;
            }
            if (!isHome) {
                break;
            }
        }
        return isHome;
    }
}

- (BOOL)applyPatternWihtName:(NSString *)name{
    MCPattern *pattern = [patterns objectForKey:name];
    if (pattern != nil) {
        return [self patternApply:pattern.root];
    }
    else{
        NSLog(@"the pattern name is wrong");
        return NO;
    }
}

-(BOOL)patternApply:(MCTreeNode *)root{
    switch (root.type) {
        case Home:
            for (MCTreeNode *child in root.children) {
                if (![self isCubieAtHomeWithIdentity:(ColorCombinationType)child.value]) {
                    return NO;
                }
            }
            break;
        case Check:
            {
                NSInteger targetCubie;
                for (MCTreeNode *subPattern in root.children) {
                    switch (subPattern.type) {
                            case At:
                            {
                                MCTreeNode *elementNode;
                                elementNode = [subPattern.children objectAtIndex:0];
                                targetCubie = elementNode.value;
                                elementNode = [subPattern.children objectAtIndex:1];
                                NSInteger targetPosition = elementNode.value;
                                struct Point3i coorValue = [magicCube cubieWithColorCombination:targetCubie].coordinateValue;
                                if (coorValue.x + coorValue.y*3 + coorValue.z * 9 + 13 != targetPosition) {
                                    return NO;
                                }
                            }
                            break;
                        case ColorBindOrientation:
                            {
                                MCTreeNode *elementNode;
                                elementNode = [subPattern.children objectAtIndex:0];
                                NSInteger targetOrientation = elementNode.value;
                                elementNode = [subPattern.children objectAtIndex:1];
                                NSInteger targetColor = elementNode.value;
                                MCCubie *cubie = [magicCube cubieWithColorCombination:targetCubie];
                                if ([cubie faceColorOnDirection:targetOrientation] != targetColor) {
                                    return NO;
                                }
                            }
                            break;
                        default:
                            break;
                    }
                }
            }
            break;
        case And:
            return [self andPatternApply:root];
        case Or:
            return [self orPatternApply:root];
        default:
            break;
    }
    return YES;
}


-(BOOL)andPatternApply:(MCTreeNode *)root{
    for (MCTreeNode *node in root.children) {
        if (![self patternApply:node]) {
            return NO;
        }
    }
    return YES;
}


-(BOOL)orPatternApply:(MCTreeNode *)root{
    for (MCTreeNode *node in root.children) {
        if ([self patternApply:node]) {
            return YES;
        }
    }
    return NO;
}


- (void)refreshPatterns{
    [patterns release];
    patterns = [NSDictionary dictionaryWithDictionary:[[MCKnowledgeBase getSharedKnowledgeBase] getPatterns]];
    [patterns retain];
}

@end

