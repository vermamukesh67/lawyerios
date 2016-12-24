//
//  SubordinateClients.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 06/08/15.
//  Copyright © 2015 Singularsllp. All rights reserved.
//

#import "SubordinateClients.h"
#import "Client.h"
#import "ClientCell.h"
#import "ChooseAdmin.h"
#import "ClientDetail.h"
#import "SubordinateAdmin.h"

BOOL isForSubordinate;

@interface SubordinateClients () <SWTableViewCellDelegate>

@property (nonatomic, strong) LLARingSpinnerView *spinnerView;
@property (nonatomic, strong) LLARingSpinnerView *spinnerViewBtn;
@property (nonatomic, strong) NSMutableArray *arrClients;
@end

@implementation SubordinateClients
@synthesize spinnerView,spinnerViewBtn,arrClients;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [lblErrorMsg setTextColor:DARK_GRAY_COLOR];
    
    [self.navigationController.navigationBar setTitleTextAttributes:[Global setNavigationBarTitleTextAttributesLikeFont:APP_FONT_BOLD fontColor:BLACK_COLOR andFontSize:18 andStrokeColor:CLEARCOLOUR]];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 60, 0, 0)];
    
    self.spinnerView = [[LLARingSpinnerView alloc] initWithFrame:CGRectZero];
    [self.spinnerView setBounds:CGRectMake(0, 0, 35, 35)];
    [self.spinnerView setHidesWhenStopped:YES];
    [self.spinnerView setTintColor:APP_TINT_COLOR];
    [self.spinnerView setCenter:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds)-NavBarHeight)];
    [self.view addSubview:self.spinnerView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchClientsLocally:) name:kFetchSubordinateClients object:nil];
    
    [self loadSubordinatesClients];
    
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    isForSubordinate = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated: YES];
    //    self.originalFrame = viewAddCourt.frame;
}

- (void)barBtnAddTaped:(id)sender
{
    ChooseAdmin *chooseAdminVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ChooseAdmin"];
    [chooseAdminVC setDetailViewToChooseAdmin:kDetailViewClients];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:chooseAdminVC];
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)btnReloadTaped:(id)sender
{
    [self loadSubordinatesClients];
}

- (void)barBtnReloadTaped:(id)sender
{
    [self loadSubordinatesClients];
}

- (void)fetchClientsLocally:(NSNotification *)aNotification
{
    if (!arrClients) {
        arrClients = [[NSMutableArray alloc] init];
    }
    
    [arrClients removeAllObjects];
    [arrClients addObjectsFromArray:[Client fetchClientsForSubordinate]];
    
    [self.tableView reloadData];
    
    if (arrClients.count > 0) {
        [self showSpinner:NO withError:NO];
    }
}

- (void)loadSubordinatesClients
{
    if (IS_INTERNET_CONNECTED) {
        
        [btnReload setHidden:YES];
        
        [self fetchSubordinatesWithCompletionHandler:^(BOOL finished) {
            [self setBarButton:AddBarButton];
            
            [self fetchClientsLocally:nil];
        }];
    }
    else {
         
        [self fetchClientsLocally:nil];
        
        [self setBarButton:AddBarButton];
        
        if (arrClients.count > 0 || arrClients.count == 0) {
            [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
        else {
            [lblErrorMsg setText:@"No records stored locally!\n Please connect to the internet to get uodated data."];
            [self showSpinner:NO withError:YES];
            
            [btnReload setHidden:NO];
        }
    }
}
- (void)showSpinner:(BOOL)flag withError:(BOOL)errorFlag
{
    if (flag) {
        
        [lblErrorMsg setHidden:YES];
        [self.tableView setHidden:YES];
        [self.spinnerView startAnimating];
    }
    else {
        if (errorFlag) {
            [lblErrorMsg setHidden:NO];
            [self.tableView setHidden:YES];
        }
        else {
            [lblErrorMsg setHidden:YES];
            [self.tableView setHidden:NO];
        }
        
        [self.spinnerView stopAnimating];
    }
}
- (void)setBarButton:(UIBarButton)barBtnType
{
    switch (barBtnType) {
        case AddBarButton: {
            barBtnAdd = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(barBtnAddTaped:)];
            [barBtnAdd setTintColor:APP_TINT_COLOR];
            
            barBtnReload = [[UIBarButtonItem alloc] initWithImage:IMAGE_WITH_NAME_AND_RENDER_MODE(@"bar-btn-sync", kImageRenderModeTemplate) style:UIBarButtonItemStylePlain target:self action:@selector(barBtnReloadTaped:)];
            [barBtnReload setTintColor:APP_TINT_COLOR];
            
            [self.navigationItem setRightBarButtonItems:@[barBtnAdd, barBtnReload]];
            
            [self.spinnerView setBounds:CGRectMake(0, 0, 35, 35)];
        }
            break;
        case IndicatorBarButton: {
            barBtnAdd = [[UIBarButtonItem alloc] initWithCustomView:self.spinnerView];
            [barBtnAdd setTintColor:APP_TINT_COLOR];
            
            [self.spinnerView setBounds:CGRectMake(0, 0, 20, 20)];
            
            [self.navigationItem setRightBarButtonItems:nil];
            [self.navigationItem setRightBarButtonItem:barBtnAdd];
            [self.spinnerView startAnimating];
        }
            break;
        case NilBarButton: {
            [self.navigationItem setRightBarButtonItems:nil];
        }
        default:
            break;
    }
}
#pragma mark
#pragma mark - UITableViewDataSource / UITableViewDelegate

- (CGFloat)tableView:(nonnull UITableView *)tableView estimatedHeightForHeaderInSection:(NSInteger)section
{
    return 22;
}

- (UIView *)tableView:(nonnull UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    SubordinateAdmin *adminObj = [arrClients[section] objectForKey:kAPIadminData];
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ViewWidth(self.tableView), 22)];
    [headerView setBackgroundColor:UICOLOR(50, 50, 50, 1)];
    
    UILabel *lblHeader = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 22)];
    [lblHeader setBackgroundColor:CLEARCOLOUR];
    [lblHeader setFont:[UIFont boldSystemFontOfSize:13]];
    [lblHeader setTextColor:WHITE_COLOR];
    
    UILabel *lblHasAccess = [[UILabel alloc] initWithFrame:CGRectMake(ViewWidth(tableView)-200, 0, 192, 22)];
    [lblHasAccess setBackgroundColor:CLEARCOLOUR];
    [lblHasAccess setTextAlignment:NSTextAlignmentRight];
    [lblHasAccess setFont:[UIFont boldSystemFontOfSize:13]];
    [lblHasAccess setTextColor:WHITE_COLOR];
    [lblHasAccess setText:[NSString stringWithFormat:@"ACCESS GIVEN: %@", [adminObj.hasAccess isEqualToNumber:@0] ? @"NO" : @"YES"]];
    [headerView addSubview:lblHasAccess];
    
    
    [headerView addSubview:lblHeader];
    NSString *headerTitle;
    
    headerTitle = adminObj.adminName;
    
    
    [lblHeader setText:UPPERCASE_STRING(headerTitle)];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger rowHieght = 60;
    NSArray *courtRecords = [arrClients[indexPath.section] objectForKey:kAPIdata];
    
    if (courtRecords.count == 0) {
        rowHieght = 44;
    }
    return rowHieght;
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView
{
    return arrClients.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger noOfRow = [[arrClients[section] objectForKey:kAPIdata] count];
    if (noOfRow == 0) {
        noOfRow = 1;
    }
    return noOfRow;
}

-(nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    NSArray *clientRecords = [arrClients[indexPath.section] objectForKey:kAPIdata];
    
    if (clientRecords.count > 0) {
        static NSString *cellId=@"ClientCell";
        ClientCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId forIndexPath:indexPath];
        if (cell==nil)
        {
            cell=[[ClientCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        }
        
        [cell setDelegate:self];
        [cell setRightUtilityButtons:[self rightButtons] WithButtonWidth:60];
        [cell configureCellWithClientObj:[clientRecords objectAtIndex:indexPath.row] forIndexPath:indexPath];
        
        return cell;
    }
    else {
        static NSString *cellId=@"NoRecordCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell==nil)
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
            
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            UILabel *lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(ViewX(self.tableView)+15, 0, ViewWidth(self.tableView)-30, ViewHeight(cell))];
            [lblTitle setText:@"No Records Found!"];
            [lblTitle setTextAlignment:NSTextAlignmentCenter];
            [lblTitle setFont:[UIFont systemFontOfSize:16]];
            [lblTitle setTextColor:UICOLOR(109, 109, 114, 1)];
            [cell addSubview:lblTitle];
            
            [cell setBackgroundColor:UICOLOR(245, 245, 245, 1)];
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
        return cell;
    }
    return nil;
}

- (NSArray *)rightButtons
{
    NSMutableArray *rightUtilityButtons = [NSMutableArray new];
    
    [rightUtilityButtons sw_addUtilityButtonWithColor:WHITE_COLOR icon:IMAGE_WITH_NAME(IMG_trash_icon)];
    
    return rightUtilityButtons;
}

#pragma mark - SWTableViewDelegate

- (void)swipeableTableViewCell:(SWTableViewCell *)cell scrollingToState:(SWCellState)state
{
    switch (state) {
        case 0:
            NSLog(@"utility buttons closed");
            break;
        case 1:
            NSLog(@"left utility buttons open");
            break;
        case 2:
            NSLog(@"right utility buttons open");
            break;
        default:
            break;
    }
}

- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index
{
    switch (index) {
        case 0:
            NSLog(@"left button 0 was pressed");
            break;
        case 1:
            NSLog(@"left button 1 was pressed");
            break;
        case 2:
            NSLog(@"left button 2 was pressed");
            break;
        case 3:
            NSLog(@"left btton 3 was pressed");
        default:
            break;
    }
}
- (void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerRightUtilityButtonWithIndex:(NSInteger)index
{
    @try {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        
        switch (index) {
            case 0:
            {
                // Delete button was pressed
                
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
                        SubordinateAdmin *adminObj = [arrClients[indexPath.section] objectForKey:kAPIadminData];
                        
                        if ([adminObj.hasAccess isEqualToNumber:@1]) {
                            
                            Client *toBeDeletedClientObj = [[arrClients[indexPath.section] valueForKey:@"data"] objectAtIndex:indexPath.row];
                            
                            if (![Cases isThisClientExist:toBeDeletedClientObj.localClientId]) {
                                
                                [self.tableView beginUpdates];
                                
                                if ([toBeDeletedClientObj.isSynced isEqualToNumber:@0] && [toBeDeletedClientObj.clientId isEqualToNumber:@-1]) {
                                    [Client deleteClient:toBeDeletedClientObj.localClientId];
                                }
                                else {
                                    [Client updatedClientPropertyofClient:toBeDeletedClientObj withProperty:kClientIsDeleted andValue:@1];
                                    [self deleteClient:toBeDeletedClientObj forAdmin:adminObj];
                                }
                                
                                [arrClients removeAllObjects];
                                [arrClients addObjectsFromArray:[Client fetchClientsForSubordinate]];
                                
                                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath, nil] withRowAnimation:UITableViewRowAnimationTop];
                                if ([[arrClients[indexPath.section] objectForKey:kAPIdata] count] == 0) {
                                    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationTop];
                                }
                                
                                [self.tableView endUpdates];
                                
                                if (arrClients.count == 0) {
                                    [lblErrorMsg setText:@"No Clients found."];
                                    [self showSpinner:NO withError:YES];
                                }
                                
                            }
                            else {
                                UI_ALERT(@"", @"This Client is belongs to one of the existing Case. So you can't delete this Client. To delete this Court, you've to delete Case first.", nil);
                            }
                        }
                        else {
                            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                            UI_ALERT(@"Warning", @"You don't have access to perform this operation.", nil);
                        }
                    }
                        break;
                    default:
                        break;
                }
                
                [cell hideUtilityButtonsAnimated:YES];
            }
                break;
            default:
                break;
                
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception => %@", [exception debugDescription]);
    }
    @finally {
        
    }
}

- (BOOL)swipeableTableViewCellShouldHideUtilityButtonsOnSwipe:(SWTableViewCell *)cell
{
    // allow just one cell's utility button to be open at once
    return YES;
}

- (BOOL)swipeableTableViewCell:(SWTableViewCell *)cell canSwipeToState:(SWCellState)state
{
    switch (state) {
        case 1:
            // set to NO to disable all left utility buttons appearing
            return YES;
            break;
        case 2:
            // set to NO to disable all right utility buttons appearing
            return YES;
            break;
        default:
            break;
    }
    
    return YES;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[arrClients[indexPath.section] valueForKey:@"data"] count] > 0) {
        
        ClientDetail *clientDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ClientDetail"];
        
        SubordinateAdmin *adminObj = [arrClients[indexPath.section] objectForKey:kAPIadminData];
        [clientDetailVC setExistingAdminObj:adminObj];
//        [clientDetailVC setIsForSubordinate:YES];
        [clientDetailVC setClientObj:[[arrClients[indexPath.section] valueForKey:@"data"] objectAtIndex:indexPath.row]];
        [self.navigationController pushViewController:clientDetailVC animated:YES];
    }
    else {
        [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    }
}

- (void)deleteClient:(Client *)objClient forAdmin:(SubordinateAdmin *)adminObj
{
    if (IS_INTERNET_CONNECTED) {
        
        @try {
            
            NSDictionary *params = @{
                                     kAPIMode: kdeleteClient,
                                     kAPIuserId: USER_ID,
                                     kAPIclientId: objClient.clientId,
                                     kAPIadminId: adminObj.adminId
                                     };
            
            [NetworkManager startPostOperationWithParams:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (responseObject == nil) {
                    [Global showNotificationWithTitle:@"Client can't be deleted right now" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                }
                else {
                    if ([responseObject[kAPIstatus] isEqualToString:@"0"]) {
                        [Global showNotificationWithTitle:@"Client can't be deleted right now" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                        //                        UI_ALERT(@"ERROR", [responseObject valueForKey:kAPImessage], nil);
                    }
                    else {
                        [Client deleteClient:objClient.clientId];
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [Global showNotificationWithTitle:@"Client can't be deleted right now" titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception => %@", [exception debugDescription]);
        }
        @finally {
            
        }
    }
    else {
        //        [Global showNotificationWithTitle:@"Court will be delted from server, when you get online." titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        //        [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
    }
}

- (void)fetchSubordinatesWithCompletionHandler:(void (^)(BOOL finished))completionHandler
{
    if (IS_INTERNET_CONNECTED) {
        
        @try {
            
            NSDictionary *params = @{
                                     kAPIMode: kloadSubordinateClient,
                                     kAPIsubordinateId: USER_ID
                                     };
            
            if (arrClients.count == 0) {
                [self showSpinner:YES withError:NO];
                [self setBarButton:NilBarButton];
            }
            else {
                [self setBarButton:IndicatorBarButton];
            }
            
            [NetworkManager startPostOperationWithParams:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                [self showSpinner:NO withError:NO];
                
                if (responseObject == nil) {
                    if (arrClients.count > 0) {
                        [Global showNotificationWithTitle:kSOMETHING_WENT_WRONG titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                    }
                    else {
                        [lblErrorMsg setText:kSOMETHING_WENT_WRONG];
                        [self showSpinner:NO withError:YES];
                    }
                }
                else {
                    if ([responseObject[kAPIstatus] isEqualToString:@"0"]) {
                        UI_ALERT(@"ERROR", [responseObject valueForKey:kAPImessage], nil);
                    }
                    else {
                        NSArray *arrSubordinates = [responseObject valueForKey:kAPIclientData];
                        
                        if (arrSubordinates.count > 0) {
                            
                            [SubordinateAdmin deleteSubordinateAdmins];
                            [Client deleteCientsForSubordinate];
                            
                            for (NSDictionary *obj in arrSubordinates) {
                                [SubordinateAdmin saveSubordinateAdmin:obj];
                                [Client saveClientsForSubordinate:obj];
                            }
                            
                            [self showSpinner:NO withError:NO];
                        }
                        else {
                            
                            [Client deleteCientsForSubordinate];
                            
                            [lblErrorMsg setText:@"No Subordiantes Clients Found."];
                            [self showSpinner:NO withError:YES];
                        }
                    }
                }
                completionHandler(YES);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSString *strMsg;
                
                if (error.code == kCFURLErrorTimedOut) {
                    strMsg = kREQUEST_TIME_OUT;
                }
                else if (error.code == kCFURLErrorNetworkConnectionLost) {
                    strMsg = kCHECK_INTERNET;
                }
                else {
                    strMsg = kSOMETHING_WENT_WRONG;
                }
                
                [lblErrorMsg setText:strMsg];
                [self showSpinner:NO withError:YES];
                
                [Global showNotificationWithTitle:strMsg titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
                
                if (arrClients.count > 0) {
                    [self.tableView setHidden:NO];
                    [lblErrorMsg setHidden:YES];
                }
                else {
                    [btnReload setHidden:NO];
                }
                
                completionHandler(YES);
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception => %@", [exception debugDescription]);
        }
        @finally {
            
        }
    }
    else {
        [self fetchClientsLocally:nil];
        
        if (arrClients.count > 0) {
            [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
        else {
            [lblErrorMsg setText:@"No records stored locally!\n Please connect to the internet to get uodated data."];
            [self showSpinner:NO withError:YES];
            
            [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        }
        
//        [self showSpinner:NO withError:YES];
//        [Global showNotificationWithTitle:kCHECK_INTERNET titleColor:WHITE_COLOR backgroundColor:APP_RED_COLOR forDuration:1];
        
        completionHandler(YES);
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

- (IBAction)actionToggleLeftDrawer:(id)sender {
    [[AppDelegate globalDelegate] toggleLeftDrawer:self animated:YES];
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
