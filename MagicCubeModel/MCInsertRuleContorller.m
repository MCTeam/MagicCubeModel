//
//  MCInsertRuleContorller.m
//  MagicCubeModel
//
//  Created by Aha on 13-1-3.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCInsertRuleContorller.h"

@implementation MCInsertRuleContorller
@synthesize patternName;
@synthesize preStateName;
@synthesize resultActions;
@synthesize transferredResultActions;
@synthesize fnSwitcher;
@synthesize elements;
@synthesize transferredElements;
@synthesize knowledgeBase;
@synthesize actionStr;

- (void)dealloc {
    [patternName release];
    [resultActions release];
    [transferredResultActions release];
    [elements release];
    [transferredElements release];
    [actionStr release];
    [preStateName release];
    [fnSwitcher release];
    [super dealloc];
}

- (void)viewDidUnload {
    [self setPatternName:nil];
    [self setResultActions:nil];
    [self setTransferredResultActions:nil];
    [self setPreStateName:nil];
    [self setFnSwitcher:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad{
    if (elements == nil) {
        elements = [[NSMutableArray alloc] initWithCapacity:100];
    }
    if (transferredElements == nil) {
        transferredElements = [[NSMutableArray alloc] initWithCapacity:100];
    }
    knowledgeBase = [MCKnowledgeBase getSharedKnowledgeBase];
    //reset the switcher
    [self.fnSwitcher setOn:NO];
}

- (IBAction)pressActionBtn:(id)sender {
    NSString *tmp;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"Rotate";
            break;
        case 1:
            tmp = @"FaceToOrientation";
            break;
        case 2:
            tmp = @"LockCubie";
            break;
        case 3:
            tmp = @"UnlockCubie";
            break;
        default:
            break;
    }
    if (tmp != nil) {
        [elements addObject:tmp];
        [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
    }
    [elements addObject:@"("];
    [transferredElements addObject:[NSNumber numberWithInteger:Token_LeftParentheses]];
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressInfoBtn:(id)sender {
    [elements addObject:@"("];
    [transferredElements addObject:[NSNumber numberWithInteger:Token_LeftParentheses]];
    
    NSString *tmp;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"getCombination";
            break;
        case 1:
            tmp = @"getFaceColorFromOrientation";
            break;
        case 2:
            tmp = @"LockedCubie";
            break;
        default:
            break;
    }
    if (tmp != nil) {
        [elements addObject:tmp];
        [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
    }
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressNotationBtn:(id)sender {
    NSString *tmp;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"F";
            break;
        case 1:
            tmp = @"F'";
            break;
        case 2:
            tmp = @"F2";
            break;
        case 3:
            tmp = @"B";
            break;
        case 4:
            tmp = @"B'";
            break;
        case 5:
            tmp = @"B2";
            break;
        case 6:
            tmp = @"R";
            break;
        case 7:
            tmp = @"R'";
            break;
        case 8:
            tmp = @"R2";
            break;
        case 9:
            tmp = @"L";
            break;
        case 10:
            tmp = @"L'";
            break;
        case 11:
            tmp = @"L2";
            break;
        case 12:
            tmp = @"U";
            break;
        case 13:
            tmp = @"U'";
            break;
        case 14:
            tmp = @"U2";
            break;
        case 15:
            tmp = @"D";
            break;
        case 16:
            tmp = @"D'";
            break;
        case 17:
            tmp = @"D2";
            break;
        case 18:
            tmp = @"x";
            break;
        case 19:
            tmp = @"x'";
            break;
        case 20:
            tmp = @"x2";
            break;
        case 21:
            tmp = @"y";
            break;
        case 22:
            tmp = @"y'";
            break;
        case 23:
            tmp = @"y2";
            break;
        case 24:
            tmp = @"z";
            break;
        case 25:
            tmp = @"z'";
            break;
        case 26:
            tmp = @"z2";
            break;
        default:
            break;
    }
    [elements addObject:tmp];
    [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressIdentityBtn:(id)sender {
    NSString *tmp;
    UIButton *pressedBtn = sender;
    if ([self.fnSwitcher isOn]) {
        tmp = [[NSString alloc] initWithFormat:@"%d", pressedBtn.tag];
    } else {
        switch (pressedBtn.tag) {
            case 0:
                tmp = @"BLD";
                break;
            case 1:
                tmp = @"BD";
                break;
            case 2:
                tmp = @"BRD";
                break;
            case 3:
                tmp = @"BL";
                break;
            case 4:
                tmp = @"B";
                break;
            case 5:
                tmp = @"BR";
                break;
            case 6:
                tmp = @"BLU";
                break;
            case 7:
                tmp = @"BU";
                break;
            case 8:
                tmp = @"BRU";
                break;
            case 9:
                tmp = @"LD";
                break;
            case 10:
                tmp = @"D";
                break;
            case 11:
                tmp = @"RD";
                break;
            case 12:
                tmp = @"L";
                break;
            case 14:
                tmp = @"R";
                break;
            case 15:
                tmp = @"LU";
                break;
            case 16:
                tmp = @"U";
                break;
            case 17:
                tmp = @"RU";
                break;
            case 18:
                tmp = @"FLD";
                break;
            case 19:
                tmp = @"FD";
                break;
            case 20:
                tmp = @"FRD";
                break;
            case 21:
                tmp = @"FL";
                break;
            case 22:
                tmp = @"F";
                break;
            case 23:
                tmp = @"FR";
                break;
            case 24:
                tmp = @"FLU";
                break;
            case 25:
                tmp = @"FU";
                break;
            case 26:
                tmp = @"FRU";
                break;
            default:
                break;
        }
    }
    [elements addObject:tmp];
    [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressFuncBtn:(id)sender {
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            [elements removeLastObject];
            [transferredElements removeLastObject];
            [self ouputResult];
            break;
        case 1:
            [self transfer];
            break;
        case 2:
            if ([patternName.text compare:@""] != NSOrderedSame) {
                if (![knowledgeBase insertRullOfMethod:ETFF withState:preStateName.text ifContent:patternName.text thenContent:actionStr]) {
                    NSLog(@"Insert Failded.");
                }
                else{
                    NSLog(@"Insert Successed.");
                }
            }
            else{
                NSLog(@"input pattern name");
            }
            
            break;
        case 3:
            [[MCPlayHelper getSharedPlayHelper] refresh];
            break;
        default:
            break;
    }
}

- (IBAction)pressPartitionBtn:(id)sender {
    NSString *tmp;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 2:
            tmp = @"(";
            [transferredElements addObject:[NSNumber numberWithInteger:Token_LeftParentheses]];
            break;
        case 3:
            tmp = @")";
            [transferredElements addObject:[NSNumber numberWithInteger:Token_RightParentheses]];
            break;
        case 4:
            tmp = @",";
            [transferredElements addObject:[NSNumber numberWithInteger:PLACEHOLDER]];
            break;
        default:
            break;
    }
    [elements addObject:tmp];
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressOrientationBtn:(id)sender {
    NSString *tmp;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"Up";
            break;
        case 1:
            tmp = @"Down";
            break;
        case 2:
            tmp = @"Front";
            break;
        case 3:
            tmp = @"Back";
            break;
        case 4:
            tmp = @"Left";
            break;
        case 5:
            tmp = @"Right";
            break;
        default:
            break;
    }
    
    [elements addObject:tmp];
    [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
    [tmp release];
    [self ouputResult];
}

- (void)transfer {
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    for (NSNumber *obj in transferredElements) {
        [result appendString:[obj stringValue]];
        [result appendString:@","];
    }
    [result replaceOccurrencesOfString:[NSString stringWithFormat:@",%d",PLACEHOLDER] withString:@"" options:NSOrderedSame range:NSMakeRange(0, [result length])];
    [self setActionStr:[result substringToIndex:([result length]-1)]];
    [transferredResultActions setText:actionStr];
    [result release];
}

- (void)ouputResult{
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    for (NSString *obj in elements) {
        [result appendString:obj];
    }
    [resultActions setText:result];
    [result release];
}

@end
