//
//  Home.m
//  RED BOOK
//
//  Created by Naresh Kharecha on 2/2/15.
//  Copyright (c) 2015 Founders Found. All rights reserved.
//

#import "Home.h"
#import "HomeTwo.h"
#import "TermCondition.h"

@interface Home () <UIViewControllerTransitioningDelegate, UITextFieldDelegate>
{
    BOOL viewAppeared;
    BOOL keyboardShown;
    
    BOOL isAccessoryToolBarVisible;
}
@end

@implementation Home

#pragma mark - ViewLifeCycle
#pragma mark -
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mobileFieldValueChanged:) name:UITextFieldTextDidChangeNotification object:nil];
    
    [tfMobile setInputAccessoryView:accessoryView];
    [self registerToReciveKeyboardNotification];
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"agree"]) {
        
        TermCondition *objScr=[self.storyboard instantiateViewControllerWithIdentifier:@"TermCondition"];
        UINavigationController *navVC=(UINavigationController *)[[[UIApplication sharedApplication] delegate] window].rootViewController;
        [self setPresentationStyleForSelfController:navVC presentingController:objScr];
        
        [navVC presentViewController:objScr animated:YES completion:^{
            
        }];
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
    
//    if (!viewAppeared) {
//        [imgViewLogo setFrame:CGRectMake((self.view.frame.size.width/2) - (imgViewLogo.frame.size.width/2), (self.view.frame.size.height/2) - (imgViewLogo.frame.size.height/2), imgViewLogo.frame.size.width, imgViewLogo.frame.size.height)];
//        
//        [lblTitle setAlpha:0.0];
//        [btnSignUp setAlpha:0.0];
//        [btnLogin setAlpha:0.0];
//        [tfMobile setAlpha:0.0];
//        [imgViewLine setAlpha:0.0];
//    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    SetStatusBarHidden(NO);
  
    [scrollView setContentSize:CGSizeMake(SCREENWIDTH/2, SCREENHEIGHT/2)];
    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
    
//    if (!viewAppeared) {
//
//        [self setNeedsStatusBarAppearanceUpdate];
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [UIView animateWithDuration:0.5 animations:^{
//                [imgViewLogo setFrame:CGRectMake(imgViewLogo.frame.origin.x, imgViewLogo.frame.origin.y - (IsBiggerThaniPhone ? 48 : 60), imgViewLogo.frame.size.width, imgViewLogo.frame.size.height)];
//            } completion:^(BOOL finished) {
//                [UIView animateWithDuration:0.4 animations:^{
//                    [lblTitle setAlpha:1.0];
//                    [btnSignUp setAlpha:1.0];
//                    [btnLogin setAlpha:1.0];
//                    [tfMobile setAlpha:1.0];
//                    [imgViewLine setAlpha:1.0];
//                    
//                    SetStatusBarHidden(NO);
//                    
//                    [scrollView setContentSize:VIEWSIZE(self.view)];
//                    [scrollView setContentOffset:CGPointMake(0, 0) animated:NO];
//                }];
//            }];
//        });
//        
//        viewAppeared = YES;
//    }
}

#pragma mark - KeyboardNotification
#pragma mark -
- (void)registerToReciveKeyboardNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotificationObserver
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    if (keyboardShown) {
        return;
    }
    
    [toolbar setFrame:CGRectMake(-self.view.bounds.size.width, 0, toolbar.frame.size.width, toolbar.frame.size.height)];
    
    NSDictionary *userInfo = [aNotification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSValue *animationDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
//    [scrollView setContentOffset:CGPointMake(ViewX(scrollView), -keyboardSize.height) animated:NO];
    
    scrollView.contentInset = contentInsets;
    scrollView.scrollIndicatorInsets = contentInsets;
    
    [UIView commitAnimations];
    
    isAccessoryToolBarVisible = NO;
    [self mobileFieldValueChanged:nil];
    
    keyboardShown = YES;
}

- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSDictionary *userInfo = [aNotification userInfo];
    
    NSValue *animationDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [scrollView setContentInset:UIEdgeInsetsZero];
    [UIView commitAnimations];
    
    isAccessoryToolBarVisible = NO;
    keyboardShown = NO;
}

#pragma mark - Action Methods
#pragma mark -
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
                        
                        HomeTwo *homeTwoVC = [self.storyboard instantiateViewControllerWithIdentifier:@"HomeTwo"];
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

- (void)mobileFieldValueChanged:(NSNotification *)aNotification
{
    [UIView animateWithDuration:0.25 animations:^{
        if (tfMobile.text.length > 0) {
            
            if (!isAccessoryToolBarVisible) {
                isAccessoryToolBarVisible = YES;
                [toolbar setFrame:CGRectMake(0, 0, toolbar.frame.size.width, toolbar.frame.size.height)];
            }
        }
        else {
            isAccessoryToolBarVisible = NO;
            [toolbar setFrame:CGRectMake(-toolbar.frame.size.width, 0, toolbar.frame.size.width, toolbar.frame.size.height)];
        }
    }];
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
