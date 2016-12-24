//
//  CodeVerification.h
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CodeVerification : UITableViewController
{
    IBOutlet UIImageView *imgViewLogo;
    IBOutlet FFTextField *tfCode;
    IBOutlet UIToolbar *toolbar;
    IBOutlet UIBarButtonItem *barBtnDone;
    IBOutlet UIActivityIndicatorView *indicator;
    IBOutlet UIView *accessoryView;
    IBOutlet UIButton *btnContinue;
}

@property (nonatomic, strong) NSNumber *confirmationCode;
@property (nonatomic, strong) NSString *userMobile;

- (IBAction)btnContinueTaped:(id)sender;

@end
