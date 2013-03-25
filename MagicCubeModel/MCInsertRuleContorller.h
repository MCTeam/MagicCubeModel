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

@property (strong, nonatomic) IBOutlet UITextField *patternName;
@property (strong, nonatomic) IBOutlet UITextField *preStateName;
@property (strong, nonatomic) IBOutlet UILabel *resultActions;
@property (strong, nonatomic) IBOutlet UILabel *transferredResultActions;
@property (strong, nonatomic) IBOutlet UISwitch *fnSwitcher;
@property (strong, nonatomic) NSMutableArray *elements;
@property (strong, nonatomic) NSMutableArray *transferredElements;
@property (strong, nonatomic) MCKnowledgeBase *knowledgeBase;
@property (strong, nonatomic) NSString *actionStr;
@property (strong, nonatomic) MCRule *testRule;

- (IBAction)pressActionBtn:(id)sender;

- (IBAction)pressInfoBtn:(id)sender;

- (IBAction)pressNotationBtn:(id)sender;

- (IBAction)pressIdentityBtn:(id)sender;

- (IBAction)pressFuncBtn:(id)sender;

- (IBAction)pressPartitionBtn:(id)sender;

- (IBAction)pressOrientationBtn:(id)sender;


@end
