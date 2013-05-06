//
//  MCViewController.m
//  MagicCubeModel
//
//  Created by Aha on 12-9-28.
//  Copyright (c) 2012年 Aha. All rights reserved.
//

#import "MCViewController.h"
#import "MCPlayHelper.h"
#import <time.h>

@implementation MCViewController{
    NSArray *tmpArr;
    int current;
}


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
    self.axisArray = [NSArray arrayWithObjects:@"x", @"y", @"z", nil];
    self.layerArray = [NSArray arrayWithObjects:@"0", @"1", @"2", nil];
    self.directionArray = [NSArray arrayWithObjects:@"CW", @"CCW", nil];
    
    self.magicCube = [MCMagicCube magicCube];
    self.playHelper = [MCPlayHelper playerHelperWithMagicCube:self.magicCube];
    
    self.currentAxis = X;
    self.currentDirection = CW;
    self.currentLayer = 0;
    
    [self showFaces];
    
    //----------------------------
    tmpArr = nil;
    srand(time(0));
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
    [frontFace release];
    
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
    [backFace release];
    
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
    [upFace release];
    
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
    [downFace release];
    
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
    [leftFace release];
    
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
    [rightFace release];
    
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

- (void)dealloc {
    [backFaceTextView release];
    [upFaceTextView release];
    [leftFaceTextView release];
    [frontFaceTextView release];
    [rightFaceTextView release];
    [downFaceTextView release];
    [axisPicker release];
    [layerPicker release];
    [directionPicker release];
    [axisArray release];
    [layerArray release];
    [directionArray release];
    [magicCube release];
    [playHelper release];
    [super dealloc];
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
            [playHelper checkStateFromInit:YES];
            break;
        case 1:
        {
#ifdef ONLY_TEST
            int count = 0;
            while ([playHelper applyRules] != nil) {
                if ([[playHelper state] compare:END_STATE] == NSOrderedSame) {
                    srand(clock());
                    if (count == 80) {
                        break;
                    }
                    for (int i = 0; i < 40; i++) {
                        SingmasterNotation rotate = (SingmasterNotation)(rand()%27);
                        [self.magicCube rotateWithSingmasterNotation:rotate];
                    }
                    [playHelper checkStateFromInit:YES];
                    NSLog(@"%@%d", @"------------------------------------------------------------------------", count);
                    count++;
                }
            }
#else
            if (tmpArr == nil) {
                [playHelper applyRules];
                tmpArr = playHelper.applyQueue.rotationQueue;
                NSMutableString *strQueue = [NSMutableString string];
                for (NSNumber *rotation in tmpArr) {
                    [strQueue appendFormat:@" %@", [MCTransformUtil getRotationTagFromSingmasterNotation:(SingmasterNotation)[rotation integerValue]]];
                }
                NSLog(@"The new queue :%@", strQueue);
                current = 0;
            } else {
                if (current < [tmpArr count]) {
                    SingmasterNotation rotation = (SingmasterNotation)[[tmpArr objectAtIndex:current] integerValue];
                    if (rand() < RAND_MAX/3) {
                        //incorrect step
                        SingmasterNotation incorrectRotation = (SingmasterNotation)(rand() % (int)(D2+1));
                        incorrectRotation = (SingmasterNotation)(rotation == incorrectRotation ? (incorrectRotation + 1) % (int)(D2+1)
                                    : incorrectRotation);
                        NSLog(@"Incorrect step : %@!!!  Target step : %@",
                              [MCTransformUtil getRotationTagFromSingmasterNotation:incorrectRotation],
                              [MCTransformUtil getRotationTagFromSingmasterNotation:rotation]);
                        rotation = incorrectRotation;
                    }
                    else{
                        NSLog(@"Correct step : %@", [MCTransformUtil getRotationTagFromSingmasterNotation:rotation]);
                    }
                    [playHelper rotateWithSingmasterNotation:rotation];
                    RotationResult result = [playHelper getResultOfTheLastRotation];
                    switch (result) {
                        case Accord:
                        {
                            current++;
                            NSLog(@"Result : Accord");
                        }
                            break;
                        case Disaccord:
                        {
                            NSLog(@"Result : Disaccord");
                            NSMutableString *strQueue = [NSMutableString string];
                            for (NSNumber *rotation in playHelper.applyQueue.extraRotations) {
                                [strQueue appendFormat:@" %@", [MCTransformUtil getRotationTagFromSingmasterNotation:(SingmasterNotation)[rotation integerValue]]];
                            }
                            NSLog(@"Extra queue : %@", strQueue);
                        }
                            break;
                        case StayForATime:
                            NSLog(@"Result : StayForATime");
                            break;
                        case Finished:
                            NSLog(@"Result : Finished");
                            current++;
                            [playHelper clearResidualActions];
                            tmpArr = nil;
                            break;
                        default:
                            break;
                    }
                }
                else{
                    tmpArr = nil;
                }
            }
            NSLog(@"------------------------------------------------------");
#endif
        }
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
    [magicCube init];
    //refresh state and rules
    [playHelper checkStateFromInit:YES];
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
