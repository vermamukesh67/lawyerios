//
//  EditCase.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 24/07/15.
//  Copyright © 2015 Singularsllp. All rights reserved.
//

#import "EditCase.h"
#import "ChooseClient.h"
#import "ChooseCourt.h"
#import "ChooseAdmin.h"

#import "SubordinateCases.h"

BOOL isForSubordinate;
SubordinateAdmin *selectedAdminObj;

@interface EditCase () <UITextFieldDelegate, ChooseClientDelegate, ChooseCourtDelegate>
{
    BOOL isNHCellExpanded;
    BOOL isPHCellExpanded;
    
    BOOL enableTableRowSelection;
}

@property (nonatomic, strong) LLARingSpinnerView *spinnerView;

@end

@implementation EditCase

@synthesize existingCaseObj;
@synthesize existingClientObj;
@synthesize existingCourtObj;

//@synthesize isForSubordinate;
@synthesize existingAdminObj;

- (void)viewDidLoad {
    [super viewDidLoad];

    [self.navigationController.navigationBar setTintColor:BLACK_COLOR];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    
    [tfOLastName setPlaceholder:@"Optional"];
    
    if (existingCaseObj != nil) {
        
        [self setTitle:[NSString stringWithFormat:@"%@ v/s %@", CAPITALIZED_STRING(existingCaseObj.clientFirstName), CAPITALIZED_STRING(existingCaseObj.oppositionFirstName)]];
        
        [self setCaseDetail];
        [self setClienDetail];
        [self setCourtDetail];
        
        existingCourtObj = [Court fetchCourtLocally:existingCaseObj.localCourtId];
        existingClientObj = [Client fetchClientLocally:existingCaseObj.localClientId];
    }
    else {
        
        [self setTitle:[NSString stringWithFormat:@"%@ v/s Xyz", CAPITALIZED_STRING(existingClientObj.clientFirstName)]];
        
        if (existingClientObj != nil) {
            [lblClientName setText:[NSString stringWithFormat:@"%@ %@", CAPITALIZED_STRING(existingClientObj.clientFirstName), CAPITALIZED_STRING(existingClientObj.clientLastName)]];
            [lblClientMobile setText:existingClientObj.mobile];
        }
        
        if (existingCourtObj != nil) {
            [lblCourtName setText:existingCourtObj.courtName];
            [lblMegistrateName setText:existingCourtObj.megistrateName];
            [lblCourtCity setText:existingCourtObj.courtCity];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [datePicker setCalendar:calendar];
    [datePicker setTimeZone:calendar.timeZone];
    
    [self setBarButton:SaveBarButton];
    
    self.spinnerView = [[LLARingSpinnerView alloc] initWithFrame:CGRectZero];
    [self.spinnerView setBounds:CGRectMake(0, 0, 20, 20)];
    [self.spinnerView setHidesWhenStopped:YES];
    [self.spinnerView setTintColor:BLACK_COLOR];
    [self.spinnerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)-NavBarHeight)];
    [self.view addSubview:self.spinnerView];
    
    if (selectedAdminObj != nil) {
        existingAdminObj = selectedAdminObj;
    }
    
    if (isForSubordinate) {
        if ([existingAdminObj.hasAccess isEqualToNumber:@1]) {
            [self setBarButton:SaveBarButton];
            enableTableRowSelection = YES;
        }
        else {
            [self setBarButton:NilBarButton];
            enableTableRowSelection = NO;
        }
    }
    else {
        if (ShareObj.hasAdminAccess) {
            [self setBarButton:SaveBarButton];
            enableTableRowSelection = YES;
        }
        else {
            if (ShareObj.fetchSubordinateStatus == kStatusUndetermined) {
                [self setBarButton:SaveBarButton];
                enableTableRowSelection = YES;
            }
            else {
                [self setBarButton:NilBarButton];
                enableTableRowSelection = NO;
            }
        }
    }
    
    [self validateInputFiledsAccessibility];
}

- (void)validateInputFiledsAccessibility
{
    if (isForSubordinate) {
        if ([existingAdminObj.hasAccess isEqualToNumber:@1]) {
            [self enableInputFields:YES];
        }
        else {
            [self enableInputFields:NO];
        }
    }
    else {
        if (ShareObj.hasAdminAccess) {
            [self enableInputFields:YES];
        }
        else {
            if (ShareObj.fetchSubordinateStatus == kStatusUndetermined) {
                [self enableInputFields:YES];
            }
            else {
                [self enableInputFields:NO];
            }
        }
    }
}

- (void)enableInputFields:(BOOL)flag
{
    [tfCaseNo setUserInteractionEnabled:flag];
    [tfCaseStatus setUserInteractionEnabled:flag];
//    [tfNHearingDate setUserInteractionEnabled:flag];
    [tfOFirstName setUserInteractionEnabled:flag];
    [tfOLastName setUserInteractionEnabled:flag];
    [tfOLawyerName setUserInteractionEnabled:flag];
}

#pragma mark - UIKeyboardNOtifications
#pragma mark -
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    NSValue *animationDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, (keyboardSize.height), 0.0);
    self.tableView.contentInset = contentInsets;
    self.tableView.scrollIndicatorInsets = contentInsets;
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
    [UIView commitAnimations];
}

- (void)setCaseDetail
{
    [tfCaseNo setText:existingCaseObj.caseNo];
    [tfPHeardDate setText:existingCaseObj.lastHeardDate];
    [tfNHearingDate setText:[Global getDateStringOfFormat:DefaultBirthdateFormat fromDateString:existingCaseObj.nextHearingDate ofFormat:ServerBirthdateFormat]];
    [tfCaseStatus setText:existingCaseObj.caseStatus];
    
    [tfOFirstName setText:existingCaseObj.oppositionFirstName];
    [tfOLastName setText:existingCaseObj.oppositionLastName];
    [tfOLawyerName setText:existingCaseObj.oppositionLawyerName];
}

- (void)setClienDetail
{
    [lblClientName setText:[NSString stringWithFormat:@"%@ %@", CAPITALIZED_STRING(existingCaseObj.clientFirstName), CAPITALIZED_STRING(existingCaseObj.clientLastName)]];
    [lblClientMobile setText:existingCaseObj.mobile];
}

- (void)setCourtDetail
{
    [lblCourtName setText:existingCaseObj.courtName];
    [lblMegistrateName setText:existingCaseObj.megistrateName];
    [lblCourtCity setText:existingCaseObj.courtCity];
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 48;
}

- (CGFloat) tableView:(nonnull UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section != 3) {
        return 1;
    }
    else {
        return 48;
    }
}

- (UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ViewWidth(self.tableView), 48)];
    [headerView setBackgroundColor:UICOLOR(239, 239, 244, 1)];
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, ViewHeight(headerView)-30, ViewWidth(headerView)-30, 30)];
    [lblHeader setBackgroundColor:CLEARCOLOUR];
    [lblHeader setFont:[UIFont systemFontOfSize:14]];
    [lblHeader setTextColor:UICOLOR(109, 109, 114, 1)];
    
    [headerView addSubview:lblHeader];
    NSString *headerTitle;
    
    switch (section) {
        case 0: {
            headerTitle = @"Case Detail";
        }
            break;
        case 1: {
            headerTitle = @"Court Detail";
        }
            break;
        case 2: {
            headerTitle = @"Client Detail";
        }
            break;
        case 3: {
            headerTitle = @"Oppostition Detail";
        }
            break;
        default:
            break;
    }
    
    [lblHeader setText:UPPERCASE_STRING(headerTitle)];
    
    return headerView;
}

- (CGFloat)tableView:(nonnull UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    CGFloat rowHeight;
    
    switch (indexPath.section) {
        case 0: {
            rowHeight = 44;
            if ((isNHCellExpanded && indexPath.row == 2)) {
                rowHeight = 162;
            }
        }
            break;
        case 1: {
            rowHeight = 60;
        }
            break;
        case 2: {
            rowHeight = 60;
        }
            break;
        case 3: {
            rowHeight = 44;
        }
            break;
        default:
            break;
    }
    return rowHeight;
}

//- (NSString *)tableView:(nonnull UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *headerTitle;
//    
//    switch (section) {
//        case 0: {
//            headerTitle = @"Case Detail";
//        }
//            break;
//        case 1: {
//            headerTitle = @"Court Detail";
//        }
//            break;
//        case 2: {
//            headerTitle = @"Client Detail";
//        }
//            break;
//        case 3: {
//            headerTitle = @"Oppostition Detail";
//        }
//            break;
//        default:
//            break;
//    }
//    return headerTitle;
//}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return 4;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger noOfRow;
    
    switch (section) {
        case 0: {
            if ((isPHCellExpanded || isNHCellExpanded)) {
                noOfRow = 4;
            }
            else {
                noOfRow = 3;
            }
        }
            break;
        case 1: {
            noOfRow = 1;
        }
            break;
        case 2: {
            noOfRow = 1;
        }
            break;
        case 3: {
            noOfRow = 3;
        }
            break;
        default:
            break;
    }
    return noOfRow;
}

- (UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    return cellCaseNo;
                }
                    break;
                case 1: {
                    return cellNHearingDate;
                }
                    break;
//                case 2: {
//                    if (isPHCellExpanded) {
//                        return cellCaseDatePicker;
//                    }
//                    else {
//                        return cellNHearingDate;
//                    }
//                }
//                    break;
                case 2: {
                    if (isNHCellExpanded) {
                        return cellCaseDatePicker;
                    }
                    else {
                        return cellCaseStatus;
                    }
                }
                    break;
                case 3: {
                    return cellCaseStatus;
                }
                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    return cellCourtDetail;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    return cellClientDetail;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 3: {
            switch (indexPath.row) {
                case 0: {
                    return cellOFirstName;
                }
                    break;
                case 1: {
                    return cellOLastName;
                }
                    break;
                case 2: {
                    return cellOLawyerName;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
    
    return nil;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
     [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (enableTableRowSelection) {
        [self.view endEditing:YES];
        if (indexPath.section == 0) {
           
            [self.tableView beginUpdates];
            
            if (indexPath.row == 1) {
                
                if (isNHCellExpanded) {
                    isNHCellExpanded = NO;
                    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
                    [tfNHearingDate setText:[Global getDateStringFromDate:datePicker.date ofFormat:DefaultBirthdateFormat]];
                }
                else {
                    isNHCellExpanded = YES;
                    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
                }
            }
            
            /*
             if (indexPath.row == 1) {
             if (isPHCellExpanded) {
             isPHCellExpanded = NO;
             [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
             [tfPHeardDate setText:[Global getDateStringFromDate:datePicker.date ofFormat:DefaultBirthdateFormat]];
             }
             else if (isNHCellExpanded) {
             isNHCellExpanded = NO;
             [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
             [self.tableView endUpdates];
             isPHCellExpanded = YES;
             [self.tableView beginUpdates];
             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
             }
             else {
             isPHCellExpanded = YES;
             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
             }
             }
             else if (indexPath.row == 2 && !isPHCellExpanded && !isNHCellExpanded) {
             isNHCellExpanded = YES;
             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
             }
             else if (indexPath.row == 2 && isNHCellExpanded) {
             isNHCellExpanded = NO;
             [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationTop];
             [tfNHearingDate setText:[Global getDateStringFromDate:datePicker.date ofFormat:DefaultBirthdateFormat]];
             }
             else if (indexPath.row == 3 && isPHCellExpanded) {
             isPHCellExpanded = NO;
             [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:2 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
             [self.tableView endUpdates];
             isNHCellExpanded = YES;
             [self.tableView beginUpdates];
             [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationBottom];
             }*/
            
            if (isPHCellExpanded) {
                //            [datePicker setMinimumDate:nil];
                //            [datePicker setMaximumDate:[NSDate date]];
                
                if (tfPHeardDate.text.length > 0) {
                    [datePicker setDate:[Global getDatefromDateString:tfPHeardDate.text ofFormat:DefaultBirthdateFormat]];
                }
                else {
                    [datePicker setDate:[NSDate date]];
                }
            }
            else if (isNHCellExpanded) {
                //            [datePicker setMinimumDate:[NSDate date]];
                //            [datePicker setMaximumDate:nil];
                if (tfNHearingDate.text.length > 0) {
                    [datePicker setDate:[Global getDatefromDateString:tfNHearingDate.text ofFormat:DefaultBirthdateFormat]];
                }
                else {
                    [datePicker setDate:[NSDate date]];
                }
            }
            
            [self.tableView endUpdates];
        }
        else if (indexPath.section == 1) {
            ChooseCourt *courtVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseCourt"];
            [courtVC setDelegate:self];
            [courtVC setExistingCourtObj:existingCourtObj];
            
            if (isForSubordinate) {
                [courtVC setExistingAdminObj:existingAdminObj];
            }
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:courtVC];
            [self presentViewController:navController animated:YES completion:nil];
        }
        else if (indexPath.section == 2) {
            ChooseClient *clientVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseClient"];
            [clientVC setDelegate:self];
            [clientVC setExistingClientObj:existingClientObj];
            
            if (isForSubordinate) {
                [clientVC setExistingAdminObj:existingAdminObj];
            }
            
            UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:clientVC];
            [self presentViewController:navController animated:YES completion:nil];
        }
    }
    else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        //        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)clientSelected:(Client *)clientObj
{
    existingClientObj = clientObj;

//    if (existingCaseObj != nil) {
//        [existingCaseObj setClientId:existingClientObj.clientId];
//        [existingCaseObj setLocalClientId:existingClientObj.localClientId];
//        [existingCaseObj setClientFirstName:existingClientObj.clientFirstName];
//        [existingCaseObj setClientLastName:existingClientObj.clientLastName];
//        [existingCaseObj setMobile:existingClientObj.mobile];
//    }
    
    [lblClientName setText:[NSString stringWithFormat:@"%@ %@", CAPITALIZED_STRING(existingClientObj.clientFirstName), CAPITALIZED_STRING(existingClientObj.clientLastName)]];
    [lblClientMobile setText:existingClientObj.mobile];

    [self.tableView reloadData];
}

- (void)courtSelected:(Court *)courtObj
{
    existingCourtObj = courtObj;
    
//    if (existingCaseObj != nil) {
//        [existingCaseObj setCourtId:existingCourtObj.courtId];
//        [existingCaseObj setLocalCourtId:existingCourtObj.localCourtId];
//        [existingCaseObj setCourtName:existingCourtObj.courtName];
//        [existingCaseObj setCourtCity:existingCourtObj.courtCity];
//        [existingCaseObj setMegistrateName:existingCourtObj.megistrateName];
//    }
    
    [lblCourtName setText:existingCourtObj.courtName];
    [lblMegistrateName setText:existingCourtObj.megistrateName];
    [lblCourtCity setText:existingCourtObj.courtCity];
    
    [self.tableView reloadData];
}
- (IBAction)barBtnSaveTaped:(id)sender
{
    NSString *errMsg = [self validateDetails];
    if ([errMsg isEqualToString:@""]) {
        [self saveCase];
    }
    else {
        UI_ALERT(@"", errMsg, nil);
    }
}

- (void)saveCase
{
    [self.view endEditing:YES];
    
    NSLog(@"date - %@", [Global getDateStringOfFormat:ServerBirthdateFormat fromDateString:tfNHearingDate.text ofFormat:DefaultBirthdateFormat]);
    
    NSMutableDictionary *caseParams = [[NSMutableDictionary alloc] init];
   
    
    if (IS_INTERNET_CONNECTED) {
        
        @try {
            
            caseParams[kAPIuserId] = USER_ID;
            caseParams[kAPIcaseNo] = tfCaseNo.text;
            caseParams[kAPIlastHeardDate] = [Global getDateStringOfFormat:ServerBirthdateFormat fromDateString:tfNHearingDate.text ofFormat:DefaultBirthdateFormat];
            caseParams[kAPInextHearingDate] = [Global getDateStringOfFormat:ServerBirthdateFormat fromDateString:tfNHearingDate.text ofFormat:DefaultBirthdateFormat];
            caseParams[kAPIcaseStatus] = tfCaseStatus.text;
            caseParams[kAPIlocalClientId] = existingClientObj.localClientId,
            caseParams[kAPIclientId] = existingClientObj.clientId;
            caseParams[kAPIclientFirstName] = existingClientObj.clientFirstName;
            caseParams[kAPIclientLastName] = existingClientObj.clientLastName;
            caseParams[kAPImobile] = existingClientObj.mobile;
            caseParams[kAPIoppositionFirstName] = tfOFirstName.text;
            caseParams[kAPIoppositionLastName] = tfOLastName.text;
            caseParams[kAPIoppositionLawyerName] = tfOLawyerName.text;
            
            caseParams[kAPIcourtId] = existingCourtObj.courtId;
            caseParams[kAPIcourtName] = existingCourtObj.courtName;
            caseParams[kAPImegistrateName] = existingCourtObj.megistrateName;
            caseParams[kAPIcourtCity] = existingCourtObj.courtCity;
            [caseParams setObject:isForSubordinate ? existingAdminObj.adminId : @0 forKey:kAPIadminId];
            [caseParams setObject:@"" forKey:kAPIaddress];
            [caseParams setObject:@"" forKey:kAPIemail];
            [caseParams setObject:ksaveCase forKey:kAPIMode];
            
            if (existingCaseObj) {
                if ([existingCaseObj.isSynced isEqualToNumber:@1]) {
                    caseParams[kAPIcaseId] = existingCaseObj.caseId;
                    caseParams[kAPIlocalCourtId] = existingCourtObj.courtId;
                    caseParams[kAPIlocalClientId] = existingCaseObj.localClientId,
                    caseParams[kAPIclientId] = existingCaseObj.clientId;
                    caseParams[kAPIclientFirstName] = existingCaseObj.clientFirstName;
                    caseParams[kAPIclientLastName] = existingCaseObj.clientLastName;
                    caseParams[kAPImobile] = existingClientObj.mobile;
                    caseParams[kAPIcourtId] = existingCaseObj.courtId;
                    caseParams[kAPIcourtName] = existingCaseObj.courtName;
                    caseParams[kAPImegistrateName] = existingCaseObj.megistrateName;
                    caseParams[kAPIcourtCity] = existingCaseObj.courtCity;
                }
                
                //caseParams[kAPIlocalCaseId] = existingCaseObj.localCaseId;
            }
            
            NSLog(@"%@", caseParams);
            
            [self setBarButton:IndicatorBarButton];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [NetworkManager startPostOperationWithParams:caseParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                    
                    [self setBarButton:SaveBarButton];
                    
                    if (responseObject == nil) {
                        [Global showNotificationWithTitle:kSOMETHING_WENT_WRONG titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                    }
                    else {
                        if ([responseObject[kAPIstatus] isEqualToString:@"0"]) {
                            [Global showNotificationWithTitle:[responseObject valueForKey:kAPImessage] titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                        }
                        else {
                            caseParams[kAPIcaseId] = [responseObject objectForKey:kAPIcaseId];
                            caseParams[kAPIcourtId] = [responseObject objectForKey:kAPIcourtId];
                            
                            
                      [Cases saveCase:caseParams forSubordiante:isForSubordinate withAdminDetail:isForSubordinate ? @{
                                                                                                                                              kAPIadminId: existingAdminObj.adminId,
                                                                                                                                              kAPIadminName: existingAdminObj.adminName,
                                                                                                                                              kAPIhasAccess: existingAdminObj.hasAccess
                                                                                                                                              } : nil];

                            
                            
                            
                            POST_NOTIFICATION(isForSubordinate ? kFetchSubordinateCases : kFetchCases, nil);
                            
                            if (existingCaseObj) {
                                [self.navigationController popViewControllerAnimated:YES];
                                [Global showNotificationWithTitle:@"Case saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
                            }
                            else {
                                [self dismissViewControllerAnimated:YES completion:^{
                                    [Global showNotificationWithTitle:@"Case saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
                                }];
                            }
                        }
                    }
                    
                } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                    
                    [self setBarButton:SaveBarButton];
                    
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
            });
        }
        @catch (NSException *exception) {
            NSLog(@"Exception => %@", [exception debugDescription]);
        }
        @finally {
            
        }
    }
    else {
        
        [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];

//        caseParams[kIsSynced] = @0;
//        
//        [Cases saveCase:caseParams forSubordiante:isForSubordinate withAdminDetail:isForSubordinate ? @{
//                                                                                                        kAPIadminId: existingAdminObj.adminId,
//                                                                                                        kAPIadminName: existingAdminObj.adminName,
//                                                                                                        kAPIhasAccess: existingAdminObj.hasAccess
//                                                                                                        } : nil];
//       POST_NOTIFICATION(isForSubordinate ? kFetchSubordinateCases : kFetchCases, nil);
//        
//        if (existingCaseObj) {
//            [self.navigationController popViewControllerAnimated:YES];
//            [Global showNotificationWithTitle:@"Case saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
//        }
//        else {
//            [self dismissViewControllerAnimated:YES completion:^{
//                [Global showNotificationWithTitle:@"Case saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
//            }];
//        }
    }
}

- (void)setBarButton:(UIBarButton)barBtnType
{
    switch (barBtnType) {
        case SaveBarButton: {
            barBtnSave = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain target:self action:@selector(barBtnSaveTaped:)];
            [barBtnSave setTintColor:BLACK_COLOR];
            [self.navigationItem setRightBarButtonItem:barBtnSave];
            
//            UserIntrectionEnable(YES);
        }
            break;
        case IndicatorBarButton: {
            barBtnSave = [[UIBarButtonItem alloc] initWithCustomView:self.spinnerView];
            [barBtnSave setTintColor:BLACK_COLOR];
            [self.navigationItem setRightBarButtonItem:barBtnSave];
            [self.spinnerView startAnimating];
            
//            UserIntrectionEnable(NO);
        }
            break;
        case NilBarButton: {
            [self.navigationItem setRightBarButtonItem:nil];
        }
            break;
        default:
            break;
    }
}

- (NSString *)validateDetails
{
    NSString *errMsg = @"";
    if ([Global validateTextField:tfCaseNo]) {
        errMsg = @"Please enter Case No.";
    }
    else if ([Global validateTextField:tfNHearingDate]) {
        errMsg = @"Please enter Next Hearing date for Case.";
    }
    else if ([Global validateTextField:tfOFirstName]) {
        errMsg = @"Please enter Opposition First Name";
    }
//    else if ([Global validateTextField:tfOLastName]) {
//        errMsg = @"Please enter Opposition Last Name";
//    }
    else if ([Global validateTextField:tfOLawyerName]) {
        errMsg = @"Please enter Opposition Lawyer Name";
    }
        
    return errMsg;
}

- (BOOL)textFieldShouldReturn:(nonnull UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)datePickerValueChanged:(id)sender {
    if (isPHCellExpanded) {
        [tfPHeardDate setText:[Global getDateStringFromDate:datePicker.date ofFormat:DefaultBirthdateFormat]];
    }
    else if (isNHCellExpanded) {
        [tfNHearingDate setText:[Global getDateStringFromDate:datePicker.date ofFormat:DefaultBirthdateFormat]];
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
