//
//  LoginScreen.h
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginScreen : UITableViewController
{
    IBOutlet UIImageView *imgViewLogo;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIButton *btnSignUp;
    IBOutlet UIButton *btnLogin;
    IBOutlet FFTextField *tfMobile;
    
    IBOutlet UIView *accessoryView;
    
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *barBtnDone;
    
    IBOutlet UIActivityIndicatorView *indicator;
    
    BOOL viewAppeared;
    BOOL keyboardShown;
    
    BOOL isAccessoryToolBarVisible;

}

- (IBAction)barBtnDoneTaped:(id)sender;

@end
