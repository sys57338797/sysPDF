//
//  OrientationNavViewController.m
//  SysPDF
//
//  Created by mutouren on 4/8/16.
//  Copyright © 2016 suyushen. All rights reserved.
//

#import "OrientationNavViewController.h"

@interface OrientationNavViewController ()

@end

@implementation OrientationNavViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.orientation = UIInterfaceOrientationMaskPortrait;
    self.autorotate = YES;
}

-(BOOL)shouldAutorotate
{
    return self.autorotate;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return self.orientation;
    //    return self.orietation;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
