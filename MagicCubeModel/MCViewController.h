//
//  MCViewController.h
//  MagicCubeModel
//
//  Created by Aha on 12-9-28.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Global.h"
#import "RCRubiksCube.h"

@interface MCViewController : UIViewController  <UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) NSArray *axisArray;
@property (retain, nonatomic) NSArray *layerArray;
@property (retain, nonatomic) NSArray *directionArray;

@property (nonatomic) AxisType currentAxis;
@property (nonatomic) LayerRotationDirectionType currentDirection;
@property (nonatomic) int currentLayer;
@property (retain, nonatomic) RCRubiksCube *rubikCube;

@property (retain, nonatomic) IBOutlet UITextView *backFaceTextView;
@property (retain, nonatomic) IBOutlet UITextView *upFaceTextView;
@property (retain, nonatomic) IBOutlet UITextView *leftFaceTextView;
@property (retain, nonatomic) IBOutlet UITextView *frontFaceTextView;
@property (retain, nonatomic) IBOutlet UITextView *rightFaceTextView;
@property (retain, nonatomic) IBOutlet UITextView *downFaceTextView;

@property (retain, nonatomic) IBOutlet UIPickerView *axisPicker;
@property (retain, nonatomic) IBOutlet UIPickerView *layerPicker;
@property (retain, nonatomic) IBOutlet UIPickerView *directionPicker;

@property (retain, nonatomic) IBOutlet UIButton *rotateButton;

- (IBAction)rotateBtnClicked:(id)sender;

@end
