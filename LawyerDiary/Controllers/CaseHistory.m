//
//  CaseHistory.m
//  LawyerDiary
//
//  Created by Shukla, Jageen | Jageen | DCSD on 11/9/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import "CaseHistory.h"
#import "CaseHistoryCell.h"
#import "UITabBarController+ShowHideBar.h"

@interface CaseHistory ()
{
    NSArray *history;
    UILabel *lblError;
}
@end

@implementation CaseHistory

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self fetchCaseHistory];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.tabBarController setHidden:true];
    
    self.title = @"Case History";
    [self.navigationController.navigationBar setTintColor:BLACK_COLOR];
    lblError = [[UILabel alloc] initWithFrame:self.view.bounds];
    lblError.text = @"No history found";
    lblError.textAlignment = NSTextAlignmentCenter;
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.tabBarController setHidden:false];
}
- (void)fetchCaseHistory
{
    // Bhavna:
    if (IS_INTERNET_CONNECTED) {
        
        @try {
            
            NSDictionary *params = @{
                                     kAPIMode: kCaseHistory,
                                     kAPIcaseId: self.existingCaseObj.caseId
                                     };
            
            [NetworkManager startPostOperationWithParams:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                if (responseObject == nil) {
                    
                }
                else {
                    if ([responseObject[kAPIstatus] isEqualToString:@"0"]) {
                        
                    }
                    else {
                        history = [responseObject valueForKey:kAPIcaseList];
                        [self.tableView reloadData];
                    }
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
            }];
        }
        @catch (NSException *exception) {
            NSLog(@"Exception => %@", [exception debugDescription]);
        }
        @finally {
            
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(history.count == 0)
    {
        self.tableView.backgroundView = lblError;
    }
    else
    {
        self.tableView.backgroundView = nil;
    }
    return history.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CaseHistoryCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.lblHistory.text = [history[indexPath.row] valueForKey:@"caseStatus"]; //
    cell.lblHearningDate.text = ([[history[indexPath.row] valueForKey:@"lastHeardDate"] isEqualToString:@"0000-00-00"])?@"Not Set":[history[indexPath.row] valueForKey:@"lastHeardDate"]; //
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
