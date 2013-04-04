//
//  MCInsertPatternController.m
//  MagicCubeModel
//
//  Created by Aha on 12-12-30.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCInsertPatternController.h"

@implementation MCInsertPatternController
@synthesize patternName;
@synthesize preState;
@synthesize transferredResult;
@synthesize fnSwitcher;
@synthesize nontransferredResult;
@synthesize elements;
@synthesize transferredElements;
@synthesize knowledgeBase;
@synthesize patternStr;
@synthesize testPattern;


- (IBAction)pressIdentityBtn:(id)sender {
    NSString *tmp = nil;
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

- (IBAction)pressDirectionBtn:(id)sender {
    NSString *tmp = nil;
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

- (IBAction)pressColorBtn:(id)sender {
    NSString *tmp = nil;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"UpColor";
            break;
        case 1:
            tmp = @"DownColor";
            break;
        case 2:
            tmp = @"FrontColor";
            break;
        case 3:
            tmp = @"BackColor";
            break;
        case 4:
            tmp = @"LeftColor";
            break;
        case 5:
            tmp = @"RightColor";
            break;
        default:
            break;
    }
    
    [elements addObject:tmp];
    [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressTypeBtn:(id)sender {
    NSString *tmp = nil;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"Home";
            break;
        case 1:
            tmp = @"Check";
            break;
        case 2:
            tmp = @"ColorBindOrientation";
            break;
        case 3:
            tmp = @"At";
            break;
        case 4:
            tmp = @"NotAt";
            break;
        case 5:
            tmp = @"CubiedBeLocked";
            break;
        default:
            break;
    }
    if (tmp != nil) {
        [elements addObject:tmp];
        [transferredElements addObject:[NSNumber numberWithInteger:pressedBtn.tag]];
        [elements addObject:@"("];
        [transferredElements addObject:[NSNumber numberWithInteger:Token_LeftParentheses]];
    }
    [tmp release];
    [self ouputResult];
}

- (IBAction)pressInforBtn:(id)sender {
    [elements addObject:@"("];
    [transferredElements addObject:[NSNumber numberWithInteger:Token_LeftParentheses]];
    
    NSString *tmp = nil;
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
        case 3:
            tmp = @"getCombinationFromColor";
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
            if ([patternName.text compare:@""] != NSOrderedSame && [preState.text compare:@""] != NSOrderedSame) {
                if (![knowledgeBase insertPattern:patternStr withKey:patternName.text withPreState:preState.text]) {
                    NSLog(@"Insert Failded.");
                }
                else{
                    NSLog(@"Insert Successed.");
                }
            }
            else{
                NSLog(@"input pattern name/after state and pre state.");
            }
            break;
        case 4:
            if ([patternName.text compare:@""] != NSOrderedSame && [preState.text compare:@""] != NSOrderedSame) {
                if (![knowledgeBase insertStateOfMethod:ETFF withPattern:patternStr preState:preState.text afterState:patternName.text]) {
                    NSLog(@"Insert Failded.");
                }
                else{
                    NSLog(@"Insert Successed.");
                }
            }
            else{
                NSLog(@"input pattern name/after state and pre state.");
            }
            break;
        default:
            break;
    }
}

- (void)ouputResult{
    NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
    if (testPattern != nil && [testPattern errorFlag]) {
        int position = [testPattern errorPosition];
        int i;
        for (i = 0; i < position; i++) {
            if ([(NSNumber *)[transferredElements objectAtIndex:i] integerValue] == PLACEHOLDER) {
                position++;
            }
            [result appendString:[elements objectAtIndex:i]];
        }
        [result appendString:@"[Error occurrs here:"];
        [result appendString:[elements objectAtIndex:i]];
        [result appendString:@"]"];
        for (i++; i < [elements count]; i++) {
            [result appendString:[elements objectAtIndex:i]];
        }
        [self setTestPattern:nil];
        [nontransferredResult setTextColor:[UIColor redColor]];
    } else {
        for (NSString *obj in elements) {
            [result appendString:obj];
        }
        [nontransferredResult setTextColor:[UIColor blackColor]];
    }
    [nontransferredResult setText:result];
    [result release];
}

- (IBAction)pressPartitionBtn:(id)sender {
    NSString *tmp = nil;
    UIButton *pressedBtn = sender;
    switch (pressedBtn.tag) {
        case 0:
            tmp = @"&";
            [transferredElements addObject:[NSNumber numberWithInteger:Token_And]];
            break;
        case 1:
            tmp = @"|";
            [transferredElements addObject:[NSNumber numberWithInteger:Token_Or]];
            break;
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
        case 5:
            tmp = @"!";
            [transferredElements addObject:[NSNumber numberWithInteger:Token_Not]];
            break;
        default:
            break;
    }
    [elements addObject:tmp];
    [tmp release];
    [self ouputResult];
}

- (void)dealloc {
    [patternName release];
    [transferredResult release];
    [nontransferredResult release];
    [elements release];
    [transferredElements release];
    [patternStr release];
    [preState release];
    [fnSwitcher release];
    [super dealloc];
}

- (void)transfer {
    if ([elements count] > 0) {
        NSMutableString *result = [[NSMutableString alloc] initWithString:@""];
        for (NSNumber *obj in transferredElements) {
            [result appendString:[obj stringValue]];
            [result appendString:@","];
        }
        [result replaceOccurrencesOfString:[NSString stringWithFormat:@",%d",PLACEHOLDER] withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [result length])];
        [self setPatternStr:[result substringToIndex:([result length]-1)]];
        //detect error
        testPattern = [[MCPattern alloc] initWithString:patternStr];
        if ([testPattern errorFlag]) {
            [self ouputResult];
        } else {
            [transferredResult setText:patternStr];
            [self setTestPattern:nil];
        }
        [result release];
    } else {
        [transferredResult setText:@""];
    }
    
}

- (void)viewDidUnload {
    [self setPatternName:nil];
    [self setTransferredResult:nil];
    [self setNontransferredResult:nil];
    [self setPreState:nil];
    [self setFnSwitcher:nil];
    [self setTestPattern:nil];
    [super viewDidUnload];
}

- (void)viewDidLoad {
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



@end
