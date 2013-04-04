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

@property (retain, nonatomic) IBOutlet UITextField *patternName;
@property (retain, nonatomic) IBOutlet UITextField *preState;
@property (retain, nonatomic) IBOutlet UITextView *transferredResult;
@property (retain, nonatomic) IBOutlet UISwitch *fnSwitcher;
@property (retain, nonatomic) IBOutlet UITextView *nontransferredResult;
@property (retain, nonatomic) NSMutableArray *elements;
@property (retain, nonatomic) NSMutableArray *transferredElements;
@property (retain, nonatomic) MCKnowledgeBase *knowledgeBase;
@property (retain, nonatomic) NSString *patternStr;
@property (retain, nonatomic) MCPattern *testPattern;



- (IBAction)pressIdentityBtn:(id)sender;

- (IBAction)pressDirectionBtn:(id)sender;

- (IBAction)pressColorBtn:(id)sender;

- (IBAction)pressTypeBtn:(id)sender;

- (IBAction)pressInforBtn:(id)sender;

- (IBAction)pressFuncBtn:(id)sender;

- (IBAction)pressPartitionBtn:(id)sender;


@end
