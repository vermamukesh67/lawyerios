//
//  Cases.h
//  LawyerDiary
//
//  Created by Naresh Kharecha on 4/26/15.
//  Copyright (c) 2015 Singularsllp. All rights reserved.
//

#import <UIKit/UIKit.h>

extern BOOL isForSubordinate;

@interface ClientCases : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *lblErrorMsg;
    IBOutlet UIBarButtonItem *barBtnAdd;
    
    IBOutlet UIView *viewAddClient;
    
    IBOutlet UIButton *btnReload;
    UIBarButtonItem *barBtnReload;

}

@property (nonatomic, strong) LLARingSpinnerView *spinnerView;

@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property MODE_TYPE modeType;

@end
