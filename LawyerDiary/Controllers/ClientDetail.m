//
//  ClientDetail.m
//  
//
//  Created by Verma Mukesh on 10/06/15.
//
//

#import "ClientDetail.h"
#import "Client.h"

BOOL isForSubordinate;
SubordinateAdmin *selectedAdminObj;

@interface ClientDetail () <UITextViewDelegate>
{
    UITextField *activeTextField;
}
@end

@implementation ClientDetail

@synthesize clientObj;
//@synthesize isForSubordinate;
@synthesize existingAdminObj;

#pragma mark - ViewLifeCycle
#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController.navigationBar setTintColor:BLACK_COLOR];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:WHITE_COLOR] forBarMetrics:UIBarMetricsDefault];
    //    [self.navigationController.navigationBar setShadowImage:[UIImage imageWithColor:APP_TINT_COLOR]];
    
    
    [btnPetitioner setImage:[UIImage imageNamed:@"unCheckbox"] forState:UIControlStateNormal];
    [btnPetitioner setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateSelected];
    
    [btnPetitioner setSelected:YES];
    
    [btnDefendant setImage:[UIImage imageNamed:@"unCheckbox"] forState:UIControlStateNormal];
    [btnDefendant setImage:[UIImage imageNamed:@"checkbox"] forState:UIControlStateSelected];
    
    [tfEmail setPlaceholder:@"Optional"];
    [tvAddress setPlaceholder:@"Optional"];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[Global setNavigationBarTitleTextAttributesLikeFont:APP_FONT_BOLD fontColor:BLACK_COLOR andFontSize:18 andStrokeColor:CLEARCOLOUR]];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 0)];
    
//    [tvAddress setPlaceholder:@"Address"];
//    [tvAddress setPlaceholderColor:Placeholder_Text_Color];
    
    [btnSave setBackgroundColor:UICOLOR(50, 50, 50, 1)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self setTitle:@"Client Detail"];
    
    if (clientObj) {
        
        if ([clientObj.clientType integerValue]==1) {
            [btnPetitioner setSelected:YES];
            [btnDefendant setSelected:NO];
        }
        else if ([clientObj.clientType integerValue]==2)
        {
            [btnPetitioner setSelected:NO];
            [btnDefendant setSelected:YES];
        }
        
        [tfFirstName setText:clientObj.clientFirstName];
        [tfLastName setText:clientObj.clientLastName];
        [tfMobile setText:clientObj.mobile];
        [tfEmail setText:clientObj.email];
        [tvAddress setText:clientObj.address];
        
        [self.navigationItem setRightBarButtonItem:nil];
    }
    
//    [btnSave setBackgroundColor:APP_TINT_COLOR];
    
    if (selectedAdminObj != nil) {
        existingAdminObj = selectedAdminObj;
    }
    
    [tfMobile setInputAccessoryView:toolbar];
    [tvAddress setInputAccessoryView:toolbar];
    
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
    [tfFirstName setUserInteractionEnabled:flag];
    [tfLastName setUserInteractionEnabled:flag];
    [tfEmail setUserInteractionEnabled:flag];
    [tfMobile setUserInteractionEnabled:flag];
    [tvAddress setUserInteractionEnabled:flag];
    [btnDefendant setUserInteractionEnabled:flag];
    [btnPetitioner setUserInteractionEnabled:flag];
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

#pragma mark - UITableViewDataSource / UITableViewDelegate
#pragma mark -
- (CGFloat)tableView:(nonnull UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (isForSubordinate) {
        if ([existingAdminObj.hasAccess isEqualToNumber:@1]) {
            return 7;
        }
        else {
            return 6;
        }
    }
    else {
        if (ShareObj.hasAdminAccess) {
            return 7;
        }
        else {
            if (ShareObj.fetchSubordinateStatus == kStatusUndetermined) {
                return 7;
            }
            else return 6;
        }
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowHeight;
    
    if (indexPath.row == 6) {
        rowHeight = 64;
    }
    else if (indexPath.row==5 && isForSubordinate) {
        rowHeight=0;
    }
    else {
        rowHeight = 44;
    }
    return rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0: {
            return cellFirstName;
        }
            break;
        case 1: {
            return cellLatsName;
        }
            break;
        case 2: {
            return cellMobile;
        }
            break;
        case 3: {
            return cellEmail;
        }
            break;
        case 4: {
            return cellAddress;
        }
            break;
        case 6: {
            return cellBtn;
        }
            break;
        case 5: {
            [cellClientType setClipsToBounds:YES];
            return cellClientType;
        }
            break;
        default:
            break;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 6) {
        if (tfFirstName.text.length == 0 ||
            tfLastName.text.length == 0 ||
            tfMobile.text.length == 0)
        {
            [Global showNotificationWithTitle:@"Client detail can't be blanked!" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
//        else if (![Global validateEmail:tfEmail.text]) {
//            [Global showNotificationWithTitle:@"Please enter valid Email" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
//        }
        else {
            [self.view endEditing:YES];
            
            if (isForSubordinate) {
                switch (ShareObj.fetchSubordinateStatus) {
                    case kStatusUndetermined: {
                        UI_ALERT(@"", @"The status of given access to subordinate is undermined yet.\nSo, you can not modify any records.", nil);
                    }
                        break;
                    case kStatusFailed: {
                        UI_ALERT(@"", @"The approach to get status of access failed somehow.\nSo, you can not modify any records.", nil);
                    }
                        break;
                    case kStatusFailedBecauseInternet: {
                        UI_ALERT(@"", @"The approach to get status of access failed because of internert inavailability.\nSo, you can not modify any records.", nil);
                    }
                        break;
                    case kStatusSuccess: {
                        if (ShareObj.hasAdminAccess) {
                            [self saveClient];
                        }
                        else {
                            UI_ALERT(@"", @"You have given access to one of your subordinate.\nSo, you can not modify any records.", nil);
                        }
                    }
                        break;
                    default:
                        break;
                }
            }
            else {
                [self saveClient];
            }
        }
    }
}

#pragma mark - Action Methods
#pragma mark -

- (IBAction)btnpetitionerTapped:(id)sender {
    
    [btnDefendant setSelected:NO];
    
    [btnPetitioner setSelected:YES];
}

- (IBAction)btnDefendantTapped:(id)sender {
    
    [btnDefendant setSelected:YES];
    
    [btnPetitioner setSelected:NO];
    
}

- (IBAction)btnCancelTaped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnSaveTaped:(id)sender
{
    
}

- (IBAction)barBtnDoneTaped:(id)sender
{
    if ([sender tag] == 0) {
        [tfEmail becomeFirstResponder];
    }
    else {
        if (tfFirstName.text.length == 0 ||
            tfLastName.text.length == 0 ||
            tfMobile.text.length == 0)
        {
            [Global showNotificationWithTitle:@"Client detail can't be blanked!" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
        else if (![Global validateEmail:tfEmail.text]) {
            [Global showNotificationWithTitle:@"Please enter valid Email" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
        else {
            [self.view endEditing:YES];
//            [self saveClient];
        }
    }
}

- (void)saveClient
{
    [activeTextField resignFirstResponder];
    
    
    NSMutableDictionary *clientParams = [[NSMutableDictionary alloc] init];
    
    
    if (IS_INTERNET_CONNECTED) {
        
        @try {
            
            [self showIndicator:YES];
            
            clientParams[kAPIuserId] = USER_ID;
            clientParams[kAPIclientFirstName] = tfFirstName.text;
            clientParams[kAPIclientLastName] = tfLastName.text;
            clientParams[kAPIemail] = tfEmail.text;
            clientParams[kAPImobile] = tfMobile.text;
            clientParams[kAPIaddress] = tvAddress.text;
            clientParams[kAPIadminId] = isForSubordinate ? existingAdminObj.adminId : @0;
            clientParams[kAPIMode] = ksaveClient;
            clientParams[kAPIclientType] = (btnPetitioner.isSelected)?@1:@2;
            
            
            if (clientObj) {
                if ([clientObj.isSynced isEqualToNumber:@1]) {
                    clientParams[kAPIclientId] = clientObj.clientId;
                    clientParams[kAPIisTaskPlanner] = clientObj.isTaskPlanner;
                    clientParams[kAPItaskPlannerId] = clientObj.taskPlannerId;
                }
                
                clientParams[kAPIlocalClientId] = clientObj.localClientId;
            }
            
            [NetworkManager startPostOperationWithParams:clientParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [self showIndicator:NO];
                if (responseObject == nil) {
                    [Global showNotificationWithTitle:kSOMETHING_WENT_WRONG titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                }
                else {
                    if ([responseObject[kAPIstatus] isEqualToString:@"0"]) {
                        [Global showNotificationWithTitle:[responseObject valueForKey:kAPImessage] titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                    }
                    else {
                        
                        [clientParams setObject:[responseObject objectForKey:kAPIclientId] forKey:kAPIclientId];
                        Client *tempClientObj = [Client saveClients:clientParams forSubordiante:isForSubordinate withAdminDetail:isForSubordinate ? @{
                                                                                                                                                      kAPIadminId: existingAdminObj.adminId,
                                                                                                                                                      kAPIadminName: existingAdminObj.adminName,
                                                                                                                                                      kAPIhasAccess: existingAdminObj.hasAccess
                                                                                                                                                      } : nil];
                        
                        if (clientObj) {
                            NSArray *caseArr = [Cases fetchCaseWhichBelongsToThisClient:clientObj.localClientId];
                            
                            
                            if (caseArr.count > 0) {
                                
                                for (Cases *caseObj in caseArr) {
                                    [caseObj setLocalClientId:tempClientObj.localClientId];
                                    [caseObj setClientId:tempClientObj.clientId];
                                    [caseObj setClientFirstName:tempClientObj.clientFirstName];
                                    [caseObj setClientLastName:tempClientObj.clientLastName];
                                    [caseObj setMobile:tempClientObj.mobile];
                                    [caseObj setIsSynced:@0];
                                    
                                    [ShareObj saveCaseWhileUpdatingCourtOrClient:caseObj];
                                }
                            }
                        }

                        [Client updatedClientPropertyofClient:tempClientObj withProperty:kClientIsSynced andValue:@1];
                        
                        POST_NOTIFICATION(isForSubordinate ? kFetchSubordinateClients : kFetchClients, nil);
                        
                        if (clientObj) {
                            [self.navigationController popViewControllerAnimated:YES];
                            [Global showNotificationWithTitle:@"Client saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
                        }
                        else {
                            [self dismissViewControllerAnimated:YES completion:^{
                                [Global showNotificationWithTitle:@"Client saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
                            }];
                        }
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                [self showIndicator:NO];
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
        @catch (NSException *exception) {
            NSLog(@"Exception => %@", [exception debugDescription]);
        }
        @finally {
            
        }
    }
    else {
        
        [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        
//        clientParams[kIsSynced] = @0;
//        
//        Client *tempClientObj = [Client saveClients:clientParams forSubordiante:isForSubordinate withAdminDetail:isForSubordinate ? @{
//                                                                                                                                      kAPIadminId: existingAdminObj.adminId,
//                                                                                                                                      kAPIadminName: existingAdminObj.adminName,
//                                                                                                                                      kAPIhasAccess: existingAdminObj.hasAccess
//                                                                                                                                      } : nil];
//        
//        if (clientObj) {
//            NSArray *caseArr = [Cases fetchCaseWhichBelongsToThisClient:clientObj.localClientId];
//            
//            
//            if (caseArr.count > 0) {
//                
//                for (Cases *caseObj in caseArr) {
//                    [caseObj setLocalClientId:tempClientObj.localClientId];
//                    [caseObj setClientId:tempClientObj.clientId];
//                    [caseObj setClientFirstName:tempClientObj.clientFirstName];
//                    [caseObj setClientLastName:tempClientObj.clientLastName];
//                    [caseObj setMobile:tempClientObj.mobile];
//                    [caseObj setIsSynced:@0];
//                    
//                    [ShareObj saveCaseWhileUpdatingCourtOrClient:caseObj];
//                }
//            }
//        }
//
//        POST_NOTIFICATION(isForSubordinate ? kFetchSubordinateClients : kFetchClients, nil);
//        
//        if (clientObj) {
//            [self.navigationController popViewControllerAnimated:YES];
//            [Global showNotificationWithTitle:@"Client saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
//        }
//        else {
//            [self dismissViewControllerAnimated:YES completion:^{
//                [Global showNotificationWithTitle:@"Client saved successfully!" titleColor:WHITE_COLOR backgroundColor:APP_GREEN_COLOR forDuration:1];
//            }];
//        }
    }
}

- (void)showIndicator:(BOOL)flag
{
    [btnSave setTitle:flag ? @"" : @"Save" forState:UIControlStateNormal];
    flag ? [indicator startAnimating] : [indicator stopAnimating];
    UserIntrectionEnable(!flag);
}

#pragma mark - UITextViewDelegate
#pragma mark -
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [barBtnDone setTitle:@"Done"];
    [barBtnDone setTag:1];
}

#pragma mark - UITextFieldDelegate
#pragma mark -
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    activeTextField = textField;
    
    NSInteger cellIndex;
    NSInteger cellSection;
    
    cellIndex = activeTextField.tag;
    cellSection = 0;
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:cellIndex inSection:cellSection]];
    [self.tableView scrollRectToVisible:cell.frame animated:YES];
    
    if (activeTextField.tag == 2) {
        [barBtnDone setTitle:@"Next"];
        [barBtnDone setTag:0];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    switch (activeTextField.tag) {
        case 0: {
            [tfLastName becomeFirstResponder];
        }
            break;
        case 1: {
            [tfMobile becomeFirstResponder];
        }
            break;
        case 2: {
            
            [tfEmail becomeFirstResponder];
        }
            break;
        case 3: {
            [tvAddress becomeFirstResponder];
        }
            break;
        default:
            break;
    }
    return YES;
}

#pragma mark - Memory Management
#pragma mark -
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
