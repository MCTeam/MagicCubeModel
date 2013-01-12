//
//  MCTestPatternController.h
//  MagicCubeModel
//
//  Created by Aha on 13-1-2.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCKnowledgeBase.h"
#import "MCPlayHelper.h"

@interface MCTestPatternController : UIViewController


@property (retain, nonatomic) MCPlayHelper *playHelper;
@property (retain, nonatomic) IBOutlet UITextField *patternName;
@property (retain, nonatomic) IBOutlet UITextView *resultTextArea;

- (IBAction)testBtn:(id)sender;

@end