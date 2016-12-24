//
//  TermsCondiWeb.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 12/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import "TermsCondiWeb.h"

@interface TermsCondiWeb ()

@end

@implementation TermsCondiWeb

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"TermsCond" ofType:@"html"]isDirectory:NO]]];
    
    UIBarButtonItem *btnRightBar=[[UIBarButtonItem alloc] initWithTitle:@"Agree" style:UIBarButtonItemStylePlain target:self action:@selector(btnAgreeTapped:)];
    
    [self.navigationItem setRightBarButtonItem:btnRightBar];
    [self.navigationController.navigationBar setTintColor:BLACK_COLOR];
    
     [self.navigationController.navigationBar setTitleTextAttributes:[Global setNavigationBarTitleTextAttributesLikeFont:APP_FONT_BOLD fontColor:BLACK_COLOR andFontSize:18 andStrokeColor:CLEARCOLOUR]];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- UIButton Action Method

-(IBAction)btnAgreeTapped:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"agree"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
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
