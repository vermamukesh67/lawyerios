//
//  SubordinateCourts.h
//  LawyerDiary
//
//  Created by Verma Mukesh on 06/08/15.
//  Copyright © 2015 Singularsllp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constant.h"

extern BOOL isForSubordinate;

@interface SubordinateCourts : UIViewController<UITableViewDataSource,UITableViewDelegate>
{
    UIBarButtonItem *barBtnAdd;
    UIBarButtonItem *barBtnReload;
    IBOutlet UILabel *lblErrorMsg;
    
    IBOutlet UIButton *btnReload;
    IBOutlet UITableViewCell *cellNoRecords;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;;

@end
