//
//  MCInsertPatternController.h
//  MagicCubeModel
//
//  Created by Aha on 12-12-30.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MCKnowledgeBase.h"
#import "MCPlayHelper.h"


@interface MCInsertPatternController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *patternName;
@property (strong, nonatomic) IBOutlet UITextField *preState;
@property (strong, nonatomic) IBOutlet UITextView *transferredResult;
@property (strong, nonatomic) IBOutlet UISwitch *fnSwitcher;
@property (strong, nonatomic) IBOutlet UITextView *nontransferredResult;
@property (strong, nonatomic) NSMutableArray *elements;
@property (strong, nonatomic) NSMutableArray *transferredElements;
@property (strong, nonatomic) MCKnowledgeBase *knowledgeBase;
@property (strong, nonatomic) NSString *patternStr;
@property (strong, nonatomic) MCPattern *testPattern;



- (IBAction)pressIdentityBtn:(id)sender;

- (IBAction)pressDirectionBtn:(id)sender;

- (IBAction)pressColorBtn:(id)sender;

- (IBAction)pressTypeBtn:(id)sender;

- (IBAction)pressInforBtn:(id)sender;

- (IBAction)pressFuncBtn:(id)sender;

- (IBAction)pressPartitionBtn:(id)sender;


@end
