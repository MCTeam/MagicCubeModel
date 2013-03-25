//
//  MCViewController.h
//  MagicCubeModel
//
//  Created by Aha on 12-9-28.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "MCMagicCube.h"
#import "MCPlayHelper.h"

@interface MCViewController : UIViewController  <UIPickerViewDataSource, UIPickerViewDelegate>

@property (strong, nonatomic) NSArray *axisArray;
@property (strong, nonatomic) NSArray *layerArray;
@property (strong, nonatomic) NSArray *directionArray;

@property (nonatomic) AxisType currentAxis;
@property (nonatomic) LayerRotationDirectionType currentDirection;
@property (nonatomic) int currentLayer;

//helper and magci cube
@property (strong, nonatomic) MCMagicCube *magicCube;
@property (strong, nonatomic) MCPlayHelper *playHelper;

@property (strong, nonatomic) IBOutlet UITextView *backFaceTextView;
@property (strong, nonatomic) IBOutlet UITextView *upFaceTextView;
@property (strong, nonatomic) IBOutlet UITextView *leftFaceTextView;
@property (strong, nonatomic) IBOutlet UITextView *frontFaceTextView;
@property (strong, nonatomic) IBOutlet UITextView *rightFaceTextView;
@property (strong, nonatomic) IBOutlet UITextView *downFaceTextView;

@property (strong, nonatomic) IBOutlet UIPickerView *axisPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *layerPicker;
@property (strong, nonatomic) IBOutlet UIPickerView *directionPicker;


- (IBAction)rotateBtnClicked:(id)sender;

- (IBAction)testBtn:(id)sender;

- (IBAction)newMagicCube:(id)sender;

- (IBAction)saveState:(id)sender;

- (IBAction)loadState:(id)sender;

@end
