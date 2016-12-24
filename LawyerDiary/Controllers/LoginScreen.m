//
//  LoginScreen.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import "LoginScreen.h"
#import "CodeVerification.h"
#import "TermsCondiWeb.h"

@interface LoginScreen ()

@end

@implementation LoginScreen

- (void)viewDidLoad {
    [super viewDidLoad];
    
    SetStatusBarHidden(NO);
    
    [self setNeedsStatusBarAppearanceUpdate];
    
    [self.navigationController.navigationBar setTranslucent:NO];
    [Global setBackGroundImageToNavigationBar:self.navigationController.navigationBar withImageColor:CLEAR_COLOR];
    
    [self.navigationItem setBackBarButtonItem:[Global hideBackBarButtonTitle]];
    
    //    [lblTitle setTextColor:APP_TINT_COLOR];
    
    [btnSignUp setTitle:@"Continue" forState:UIControlStateNormal];
    [btnSignUp setTitle:@"" forState:UIControlStateSelected];
    
    //    NSLog(@"font fmily %@", [UIFont fontNamesForFamilyName:@"Milano-regular"]);
    [imgViewLogo setTintColor:APP_TINT_COLOR];
    [imgViewLogo setImage:IMAGE_WITH_NAME_AND_RENDER_MODE(@"app-icon", kImageRenderModeTemplate)];
    
    [Global applyPropertiesToButtons:@[btnSignUp] likeFont:@"UnDotum" fontSize:20 fontNormalColor:WHITE_COLOR fontHighlightedColor:WHITE_COLOR borderColor:APP_TINT_COLOR borderWidth:0 cornerRadius:5 normalBackgroundColor:APP_TINT_COLOR andHighlightedBackgroundColor:APP_TINT_COLOR];
    
    [tfMobile setAttributedPlaceholder:[Global getAttributedString:@"Phone Number" withFont:@"HelveticaNeue-Bold" fontSize:36 fontColor:UICOLOR(42, 50, 65, 0.5) strokeColor:CLEARCOLOUR]];
    
    [tfMobile setTintColor:APP_TINT_COLOR];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureTapped:)];
    [self.tableView addGestureRecognizer:tap];
    [tfMobile setInputAccessoryView:accessoryView];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"agree"]) {
        
        TermsCondiWeb *objScr=[self.storyboard instantiateViewControllerWithIdentifier:@"TermsCondiWeb"];
        UINavigationController *nav=[[UINavigationController alloc] initWithRootViewController:objScr];
        [self presentViewController:nav animated:YES completion:^{
            
        }];
     
//        TermCondition *objScr=[self.storyboard instantiateViewControllerWithIdentifier:@"TermCondition"];
//        UINavigationController *navVC=(UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
//        [self setPresentationStyleForSelfController:navVC presentingController:objScr];
//        
//        [navVC presentViewController:objScr animated:YES completion:^{
//            
//        }];
    }
}

- (void)setPresentationStyleForSelfController:(UINavigationController *)selfController presentingController:(UIViewController *)presentingController
{
    if ([NSProcessInfo instancesRespondToSelector:@selector(isOperatingSystemAtLeastVersion:)])
    {
        //iOS 8.0 and above
        presentingController.providesPresentationContextTransitionStyle = YES;
        presentingController.definesPresentationContext = YES;
        
        [presentingController setModalPresentationStyle:UIModalPresentationOverCurrentContext];
    }
    else
    {
        [selfController setModalPresentationStyle:UIModalPresentationCurrentContext];
        [selfController.navigationController setModalPresentationStyle:UIModalPresentationCurrentContext];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    SetStatusBarHidden(NO);
}

#pragma mark - Action Methods
#pragma mark -

-(void)gestureTapped:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)btnSignUpTaped:(id)sender
{
    if ([tfMobile.text isEqualToString:@""]) {
        [Global showNotificationWithTitle:@"Please enter your mobile number" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
    }
    else {
        [self.view endEditing:YES];
        [self checkUserIsRegistered];
    }
}

- (IBAction)btnLogInTaped:(id)sender
{
    
}

- (IBAction)barBtnDoneTaped:(id)sender
{
    if ([tfMobile.text isEqualToString:@""]) {
        [Global showNotificationWithTitle:@"Please enter your mobile number" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
    }
    else if (tfMobile.text.length < 10) {
        [Global showNotificationWithTitle:@"Please enter valid mobile number" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
    }
    else {
        [self.view endEditing:YES];
        [self checkUserIsRegistered];
    }
}

#pragma mark - Make Login Request
#pragma mark -
- (void)checkUserIsRegistered
{
    if (IS_INTERNET_CONNECTED)
    {
        
        [btnSignUp setSelected:YES];
        [indicator startAnimating];
        
        NSDictionary *params = @{
                                 kAPIMode: kisRegistered,
                                 kAPImobile: tfMobile.text,
                                 kAPIcountryCode: @"",
                                 kAPIdeviceToken: ShareObj.deviceToken,
                                 kAPIdeviceType: @0
                                 };
        
        UserIntrectionEnable(NO);
        [NetworkManager startPostOperationWithParams:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            UserIntrectionEnable(YES);
            [btnSignUp setSelected:NO];
            [indicator stopAnimating];
            
            if (responseObject == nil) {
                [Global showNotificationWithTitle:kSOMETHING_WENT_WRONG titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
            }
            else {
                if ([responseObject[kAPIstatus] isEqualToString:@"0"]) {
                    UI_ALERT(@"ERROR", [responseObject valueForKey:kAPImessage], nil);
                }
                else {
                    if ([responseObject[@"isRegistered"] isEqualToNumber:@1]) {
                        //                        [self showVerificationAlertForUser:responseObject];
                        [self saveUserInfo:[responseObject valueForKey:@"user"]];
                    }
                    else {
                        
                        CodeVerification *homeTwoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CodeVerification"];
                        [homeTwoVC setUserMobile:tfMobile.text];
                        [homeTwoVC setConfirmationCode:[responseObject valueForKey:@"code"]];
                        [self.navigationController pushViewController:homeTwoVC animated:YES];
                    }
                }
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            UserIntrectionEnable(YES);
            [btnSignUp setSelected:NO];
            [indicator stopAnimating];
            
            if (error.code == kCFURLErrorTimedOut) {
                [Global showNotificationWithTitle:kREQUEST_TIME_OUT titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
            }
            else if (error.code == kCFURLErrorNetworkConnectionLost) {
                [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
            }
            else {
                [Global showNotificationWithTitle:kSOMETHING_WENT_WRONG titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
            }
        }];
    }
    else {
        [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
    }
}

#pragma mark - Show Verification Alert
#pragma mark -
- (void)showVerificationAlertForUser:(NSDictionary *)userInfo
{
    NSString *alertTitle = NSLocalizedString(@"Enter Verification Code", @"Text Input Alert");
    NSString *alertMessage = NSLocalizedString(@"Please enter received verification code via text message", @"Plain and secure text input");
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:alertTitle
                                                                             message:alertMessage
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = NSLocalizedString(@"Code", @"Login");
         [textField setKeyboardType:UIKeyboardTypeNumberPad];
         //         [textField addTarget:self
         //                       action:@selector(alertTextFieldDidChange:)
         //             forControlEvents:UIControlEventEditingChanged];
     }];
    
    //    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
    //     {
    //         textField.placeholder = NSLocalizedString(@"PasswordPlaceholder", @"Password");
    //         textField.secureTextEntry = YES;
    //     }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                                           style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Continue", @"OK action")
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction *action)
                               {
                                   UITextField *login = alertController.textFields.firstObject;
                                   //                                   UITextField *password = alertController.textFields.lastObject;
                                   
                                   if (![login.text isEqualToString:@""]) {
                                       
                                       if ([[userInfo valueForKey:@"code"] isEqualToNumber:@(login.text.integerValue)]) {
                                           [self saveUserInfo:[userInfo valueForKey:@"user"]];
                                       }
                                       else {
                                           [Global showNotificationWithTitle:@"Please enter valid verification code" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                                           
                                           [self presentViewController:alertController animated:YES completion:nil];
                                       }
                                   }
                                   else {
                                       [Global showNotificationWithTitle:@"Please enter verification code" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                                       
                                       [self presentViewController:alertController animated:YES completion:nil];
                                   }
                                   
                                   NSLog(@"OK action");
                                   NSLog(@"Login value: %@",login.text);
                                   //                                   NSLog(@"Password value: %@",password.text);
                               }];
    
    //    okAction.enabled = NO;
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - Save User Info
#pragma mark -
- (void)saveUserInfo:(NSDictionary *)userDic
{
    @try {
        NSString *userId = [userDic valueForKey:kAPIuserId];
        SetLoginUserId(userId);
        
        ShareObj.loginuserId = GetLoginUserId;
        
        ShareObj.userObj = [User saveUser:userDic];
        
        [APP_DELEGATE showHome];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception => %@", [exception debugDescription]);
    }
    @finally {
        
    }
}

#pragma mark - Memory Management
#pragma mark -
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation
#pragma mark -
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    Register *detailViewController = segue.destinationViewController;
    
    if ([segue.identifier isEqualToString:@"SignUp"]) {
        [detailViewController setViewType:SIGN_UP_VIEW];
    }
    else if ([segue.identifier isEqualToString:@"LogIn"]) {
        [detailViewController setViewType:LOGIN_VIEW];
    }
    detailViewController.transitioningDelegate = self;
    detailViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    detailViewController.view.backgroundColor = [UIColor clearColor];
    
    UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 0);
    [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
    
    UIImage *copied = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    detailViewController.imageFromPreviousScreen = copied;
}


@end
