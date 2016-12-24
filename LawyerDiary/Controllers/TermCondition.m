//
//  TermCondition.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import "TermCondition.h"
#import "AgreeCell.h"

@interface TermCondition ()

@end

@implementation TermCondition

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[tblRedeenInfo layer] setCornerRadius:13.0f];
    [tblRedeenInfo setClipsToBounds:YES];
    
    [tblRedeenInfo setTableFooterView:footerView];
    [tblRedeenInfo setTableHeaderView:headerView];
    
    if (IS_IPHONE4 || IS_IPHONE5) {
        [tblRedeenInfo setFrame:CGRectMake(10, 20, SCREENWIDTH-20, 460)];
    }
    
    [tblRedeenInfo setCenter:self.view.center];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark-
#pragma mark- UITableView Delegate and DataSouce

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 341;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:@"DescCell"];
    return cell;
}

#pragma mark-
#pragma mark- UIButton Action Method

-(IBAction)btnAgreeTapped:(UIButton *)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:@"YES" forKey:@"agree"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self dismissViewControllerAnimated:YES completion:nil];
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
