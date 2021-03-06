//
//  MCViewController.m
//  MagicCubeModel
//
//  Created by Aha on 12-9-28.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCViewController.h"
#import "MCPlayHelper.h"

@implementation MCViewController


@synthesize axisArray;
@synthesize layerArray;
@synthesize directionArray;

@synthesize currentAxis, currentDirection, currentLayer;
@synthesize magicCube;
@synthesize playHelper;

@synthesize backFaceTextView;
@synthesize upFaceTextView;
@synthesize leftFaceTextView;
@synthesize frontFaceTextView;
@synthesize rightFaceTextView;
@synthesize downFaceTextView;
@synthesize axisPicker;
@synthesize layerPicker;
@synthesize directionPicker;

- (void)viewDidLoad{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.axisArray = [[NSArray alloc] initWithObjects:@"x", @"y", @"z", nil];
    self.layerArray = [[NSArray alloc] initWithObjects:@"0", @"1", @"2", nil];
    self.directionArray = [[NSArray alloc] initWithObjects:@"CW", @"CCW", nil];
    
    self.magicCube = [MCMagicCube magicCube];
    self.playHelper = [MCPlayHelper playerHelperWithMagicCube:self.magicCube];
    
    self.currentAxis = X;
    self.currentDirection = CW;
    self.currentLayer = 0;
    
    [self showFaces];
}

- (void)showFaces{
    //show the rubik cube face
    //front face
    NSMutableString *frontFace = [[NSMutableString alloc] init];
    for (int y = 1; y >= -1; y--) {
        for (int x = -1; x < 2; x++) {
            [frontFace appendString:[self getStringByFaceColor:[[magicCube cubieAtCoordinateX:x Y:y Z:1]
                                                                faceColorInOrientation:Front]]];
        }
        [frontFace appendString:@"\n"];
    }
    
    [frontFaceTextView setText:frontFace];
    
    //back face
    NSMutableString *backFace = [[NSMutableString alloc] init];
    for (int y = -1; y < 2; y++) {
        for (int x = -1; x < 2; x++) {
            [backFace appendString:[self getStringByFaceColor:[[magicCube cubieAtCoordinateX:x Y:y Z:-1]
                                                             faceColorInOrientation:Back]]];
        }
        [backFace appendString:@"\n"];
    }
    
    [backFaceTextView setText:backFace];
    
    //up face
    NSMutableString *upFace = [[NSMutableString alloc] init];
    for (int z = -1; z < 2; z++) {
        for (int x = -1; x < 2; x++) {
            [upFace appendString:[self getStringByFaceColor:[[magicCube cubieAtCoordinateX:x Y:1 Z:z]
                                                                faceColorInOrientation:Up]]];
        }
        [upFace appendString:@"\n"];
    }
    
    [upFaceTextView setText:upFace];
    
    //down face
    NSMutableString *downFace = [[NSMutableString alloc] init];
    for (int z = 1; z >= -1; z--) {
        for (int x = -1; x < 2; x++) {
            [downFace appendString:[self getStringByFaceColor:[[magicCube cubieAtCoordinateX:x Y:-1 Z:z]
                                                             faceColorInOrientation:Down]]];
        }
        [downFace appendString:@"\n"];
    }
    
    [downFaceTextView setText:downFace];
    
    //left face
    NSMutableString *leftFace = [[NSMutableString alloc] init];
    for (int y = 1; y >= -1; y--) {
        for (int z = -1; z < 2; z++) {
            [leftFace appendString:[self getStringByFaceColor:[[magicCube cubieAtCoordinateX:-1 Y:y Z:z]
                                                               faceColorInOrientation:Left]]];
        }
        [leftFace appendString:@"\n"];
    }
    
    [leftFaceTextView setText:leftFace];
    
    //right face
    NSMutableString *rightFace = [[NSMutableString alloc] init];
    for (int y = 1; y >= -1; y--) {
        for (int z = 1; z >= -1; z--) {
            [rightFace appendString:[self getStringByFaceColor:[[magicCube cubieAtCoordinateX:1 Y:y Z:z]
                                                               faceColorInOrientation:Right]]];
        }
        [rightFace appendString:@"\n"];
    }
    
    [rightFaceTextView setText:rightFace];
    
}

- (NSString *)getStringByFaceColor:(FaceColorType)faceColor{
    switch (faceColor) {
        case UpColor:
            return @"U ";
        case DownColor:
            return @"D ";
        case FrontColor:
            return @"F ";
        case BackColor:
            return @"B ";
        case LeftColor:
            return @"L ";
        case RightColor:
            return @"R ";
        default:
            break;
    }
    return @"nil";
}

- (void)viewDidUnload{
    [self setBackFaceTextView:nil];
    [self setUpFaceTextView:nil];
    [self setLeftFaceTextView:nil];
    [self setFrontFaceTextView:nil];
    [self setRightFaceTextView:nil];
    [self setDownFaceTextView:nil];
    [self setAxisPicker:nil];
    [self setLayerPicker:nil];
    [self setDirectionPicker:nil];
    [self setPlayHelper:nil];
    [self setMagicCube:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}


- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    switch ([pickerView tag]) {
        case 0:
            return 3;
        case 1:
            return 3;
        case 2:
            return 2;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    switch ([pickerView tag]) {
        case 0:
            return [axisArray objectAtIndex:row];
        case 1:
            return [layerArray objectAtIndex:row];
        case 2:
            return [directionArray objectAtIndex:row];
    }
    return nil;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    switch ([pickerView tag]) {
        case 0:
            currentAxis = (AxisType)row;
            break;
        case 1:
            currentLayer = row;
            break;
        case 2:
            currentDirection = (LayerRotationDirectionType)row;
            break;
    }
}

//rotate the model and how to rotate is decided by three picker
- (IBAction)rotateBtnClicked:(id)sender {
    [magicCube rotateOnAxis:currentAxis onLayer:currentLayer inDirection:currentDirection];
    [self showFaces];
}

//each time it's clicked, apply rules once
- (IBAction)testBtn:(id)sender {
    switch ([sender tag]) {
        case 0:
            srand(clock());
            for (int i = 0; i < 40; i++) {
                SingmasterNotation rotate = (SingmasterNotation)(rand()%27);
                [self.magicCube rotateWithSingmasterNotation:rotate];
            }
            [playHelper checkState:YES];
            break;
        case 1:
            [playHelper applyRules];
            break;
        case 2:
        {
            NSString *document  = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *newFile = [document stringByAppendingPathComponent:KNOWLEDGE_DB_FILE_NAME];
            NSString *oldFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:KNOWLEDGE_DB_FILE_NAME];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            if ([fileManager fileExistsAtPath:newFile]) {
                [fileManager removeItemAtPath:newFile error:nil];
            }
            [fileManager copyItemAtPath:oldFile toPath:newFile error:nil];
        }
            break;
        default:
            break;
    }
    
    [self showFaces];
}

- (IBAction)newMagicCube:(id)sender {
    self.magicCube = [magicCube init];
    //refresh state and rules
    [playHelper checkState:YES];
    [self showFaces];
}

//
- (IBAction)saveState:(id)sender {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *fileName = [path stringByAppendingPathComponent:TmpMagicCubeData];
    [NSKeyedArchiver archiveRootObject:magicCube toFile:fileName];
}

- (IBAction)loadState:(id)sender {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [path stringByAppendingPathComponent:TmpMagicCubeData];
    //get the archhived magic cube
    self.magicCube = [MCMagicCube unarchiveMagicCubeWithFile:filePath];
    //associate magic cube with playhelper
    [self.playHelper setMagicCube:magicCube];
    [self showFaces];
}


@end
