//
//  CaseCell.h
//  LawyerDiary
//
//  Created by Verma Mukesh on 22/07/15.
//  Copyright © 2015 Singularsllp. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"
#import "ImageZoomerScrollView.h"

@class Cases;

@interface CaseCell : SWTableViewCell
{
    ImageZoomerScrollView *imageViewer;
}

@property (nonatomic, strong) IBOutlet UILabel *lblClientName;
@property (nonatomic, strong) IBOutlet UILabel *lblOppositionName;
@property (nonatomic, strong) IBOutlet UILabel *lblCourt;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewProfile;

@property (nonatomic, strong) Cases *caseObj;
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (weak, nonatomic) IBOutlet UILabel *lblDate;

- (void)configureCellWithCaseObj:(Cases *)obj forIndexPath:(NSIndexPath *)indexPath;

@end
