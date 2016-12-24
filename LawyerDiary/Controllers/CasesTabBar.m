//
//  CasesTabBar.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 02/08/15.
//  Copyright © 2015 Singularsllp. All rights reserved.
//

#import "CasesTabBar.h"
#import "ClientCases.h"
#import "SubordinateCases.h"
@interface CasesTabBar ()

@end

@implementation CasesTabBar

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tabBar setTranslucent:NO];
//    [self.tabBar setBarTintColor:APP_TINT_COLOR];
    [self.tabBar setTintColor:BLACK_COLOR];
    
    for (UINavigationController *navVC in self.viewControllers) {
        UIViewController *vc = navVC.topViewController;
        if([vc isKindOfClass:[ClientCases class]])
        {
            ((ClientCases*)vc).modeType = self.modeType;
        }
        else
        {
            ((SubordinateCases*)vc).modeType = self.modeType;
        }
        
    }

//    UITabBarItem *item0 = self.tabBar.items[0];
//    [item0 setSelectedImage:IMAGE_WITH_NAME_AND_RENDER_MODE(@"icon-profile", kImageRenderModeTemplate)];
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
