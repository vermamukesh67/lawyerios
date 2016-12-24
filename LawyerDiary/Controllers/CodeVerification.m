//
//  CodeVerification.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import "CodeVerification.h"

@interface CodeVerification ()

@end

@implementation CodeVerification

@synthesize confirmationCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:BLACK_COLOR];
    
    [btnContinue setTitle:@"Continue" forState:UIControlStateNormal];
    [btnContinue setTitle:@"" forState:UIControlStateSelected];
    [Global applyPropertiesToButtons:@[btnContinue] likeFont:@"UnDotum" fontSize:20 fontNormalColor:WHITE_COLOR fontHighlightedColor:WHITE_COLOR borderColor:APP_TINT_COLOR borderWidth:0 cornerRadius:5 normalBackgroundColor:APP_TINT_COLOR andHighlightedBackgroundColor:APP_TINT_COLOR];
    
    [imgViewLogo setTintColor:APP_TINT_COLOR];
    [imgViewLogo setImage:IMAGE_WITH_NAME_AND_RENDER_MODE(@"app-icon", kImageRenderModeTemplate)];
    [tfCode setAttributedPlaceholder:[Global getAttributedString:@"Enter Code" withFont:@"HelveticaNeue-Bold" fontSize:36 fontColor:UICOLOR(42, 50, 65, 0.5) strokeColor:CLEARCOLOUR]];
    
    [tfCode setTintColor:APP_TINT_COLOR];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapped:)];
    [self.tableView addGestureRecognizer:tap];
    
    [tfCode setInputAccessoryView:accessoryView];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

#pragma mark - KeyboardNotification
#pragma mark -

-(void)gestureTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)btnContinueTaped:(id)sender
{
    @try {
        if ([tfCode.text isEqualToString:@""]) {
            [Global showNotificationWithTitle:@"Please enter verification code" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
        else if (tfCode.text.length > 0) {
            if ([confirmationCode isEqualToNumber:@(tfCode.text.integerValue)]) {
                
                [self.view endEditing:YES];
                
                Register *detailViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Register"];
                [detailViewController setViewType:SIGN_UP_VIEW];
                [detailViewController setVerificationCode:confirmationCode];
                [detailViewController setUserMobile:_userMobile];
                detailViewController.transitioningDelegate = self;
                detailViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
                detailViewController.view.backgroundColor = [UIColor clearColor];
                
                //            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
                //            [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
                //
                //            UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
                //            UIGraphicsEndImageContext();
                
                //            detailViewController.imageFromPreviousScreen = copied;
                
                [self presentViewController:detailViewController animated:YES completion:^{
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.navigationController popViewControllerAnimated:YES];
                    });
                }];
            }
            else {
                [Global showNotificationWithTitle:@"Please enter valid verification code" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception => %@ %@", [self class], exception);
    }
    @finally {
        
    }
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
