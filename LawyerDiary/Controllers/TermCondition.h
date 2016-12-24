//
//  TermCondition.h
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TermCondition : UIViewController
{
    __weak IBOutlet UITableView *tblRedeenInfo;
    __weak IBOutlet NSLayoutConstraint *tblTrailC;
    __weak IBOutlet NSLayoutConstraint *tblleadC;
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet UIView *footerView;
    __weak IBOutlet NSLayoutConstraint *tblHConstant;
}

-(IBAction)btnAgreeTapped:(UIButton *)sender;

@end
