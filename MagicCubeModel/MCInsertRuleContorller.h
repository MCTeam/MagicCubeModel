//
//  MCInsertRuleContorller.h
//  MagicCubeModel
//
//  Created by Aha on 13-1-3.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCKnowledgeBase.h"
#import "MCPlayHelper.h"
#import "Global.h"

@interface MCInsertRuleContorller : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *patternName;
@property (retain, nonatomic) IBOutlet UITextField *preStateName;
@property (retain, nonatomic) IBOutlet UILabel *resultActions;
@property (retain, nonatomic) IBOutlet UILabel *transferredResultActions;
@property (retain, nonatomic) NSMutableArray *elements;
@property (retain, nonatomic) NSMutableArray *transferredElements;
@property (retain, nonatomic) MCKnowledgeBase *knowledgeBase;
@property (retain, nonatomic) NSString *actionStr;

- (IBAction)pressActionBtn:(id)sender;

- (IBAction)pressInfoBtn:(id)sender;

- (IBAction)pressNotationBtn:(id)sender;

- (IBAction)pressIdentityBtn:(id)sender;

- (IBAction)pressFuncBtn:(id)sender;

- (IBAction)pressPartitionBtn:(id)sender;

- (IBAction)pressOrientationBtn:(id)sender;


@end
