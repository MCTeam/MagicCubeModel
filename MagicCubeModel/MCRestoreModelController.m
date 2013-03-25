//
//  MCTestPatternController.m
//  MagicCubeModel
//
//  Created by Aha on 13-1-2.
//  Copyright (c) 2013年 Aha. All rights reserved.
//

#import "MCRestoreModelController.h"

@implementation MCRestoreModelController{
    UIButton *clickedButton;
}


- (void)viewDidLoad {
    [super viewDidLoad];
}



- (void)viewDidUnload {
    [super viewDidUnload];
}


- (IBAction)selectOne:(id)sender {
    UIButton *button = (UIButton *)sender;
    [self toggle:CGPointMake(button.frame.origin.x + button.frame.size.width/2,
                             button.frame.origin.y + button.frame.size.height/2)];
    [self.view bringSubviewToFront:button];
    if ([self isClosed]) {
        clickedButton = button;
    }
    else{
        clickedButton = nil;
    }
}

- (NSInteger)runButtonActions:(id)sender {
    if (clickedButton == nil) return -1;
    NSInteger tag = [super runButtonActions:sender];
    NSString *imageName = [NSString stringWithFormat:kKYICircleMenuButtonImageNameFormat, tag];
    [clickedButton setImage:[UIImage imageNamed:imageName]
            forState:UIControlStateNormal];
    
    
    return 1;
}


@end
