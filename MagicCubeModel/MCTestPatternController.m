//
//  MCTestPatternController.m
//  MagicCubeModel
//
//  Created by Aha on 13-1-2.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCTestPatternController.h"

@implementation MCTestPatternController
@synthesize playHelper;
@synthesize patternName;
@synthesize resultTextArea;


- (void)viewDidLoad {
    [super viewDidLoad];
    playHelper = [MCPlayHelper getSharedPlayHelper];
}

- (void)dealloc {
    [patternName release];
    [resultTextArea release];
    [super dealloc];
}


- (void)viewDidUnload {
    [self setPatternName:nil];
    [self setResultTextArea:nil];
    [super viewDidUnload];
}


- (IBAction)testBtn:(id)sender {
    UIButton *button = sender;
    switch (button.tag) {
        case 0:
            srand(clock());
            for (int i = 0; i < 40; i++) {
                SingmasterNotation rotate = rand()%27;
                [[MCMagicCube getSharedMagicCube] rotateWithSingmasterNotation:rotate];
            }
            break;
        case 1:
            [playHelper applyRules];
            break;
        default:
            break;
    }
    
//    [playHelper checkState];
//    NSString * result = [NSString stringWithFormat:@"\n%@", playHelper.state];
//    [resultTextArea setText:[resultTextArea.text stringByAppendingString:result]];
    
//    if ([patternName.text compare:@""] != NSOrderedSame) {
//        if ([playHelper applyPatternWihtName:patternName.text]) {
//            NSString * result = [NSString stringWithFormat:@"\n'%@' test sucessful.", patternName.text];
//            [resultTextArea setText:[resultTextArea.text stringByAppendingString:result]];
//        }
//        else{
//            NSString * result = [NSString stringWithFormat:@"\n'%@' test failed.", patternName.text];
//            [resultTextArea setText:[resultTextArea.text stringByAppendingString:result]];
//        }
//    }
//    else{
//        [resultTextArea setText:[resultTextArea.text stringByAppendingString:@"Please input pattern name"]];
//    }
}


@end
