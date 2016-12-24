//
//  CaseCell.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 22/07/15.
//  Copyright © 2015 Singularsllp. All rights reserved.
//

#import "CaseCell.h"
#import "Client.h"

@implementation CaseCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];
    
    [Global applyCornerRadiusToViews:@[_imgViewProfile] withRadius:ViewHeight(_imgViewProfile)/2 borderColor:WHITE_COLOR andBorderWidth:1];
    
    UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileGesTapped:)];
    [self.imgViewProfile addGestureRecognizer:tapGes];
    
    [self.imgViewProfile setUserInteractionEnabled:YES];
}

- (void)configureCellWithCaseObj:(Cases *)obj forIndexPath:(NSIndexPath *)indexPath
{
    @try {
        _caseObj = obj;
        _indexPath = indexPath;
        
        if ([_caseObj.clientType isKindOfClass:[NSNumber class]]) {
            
            if ([_caseObj.clientType integerValue]==1) {
                [_lblClientName setText:[NSString stringWithFormat:@"%@ V/S %@", _caseObj.clientFirstName, _caseObj.oppositionFirstName]];
            }
            else if ([_caseObj.clientType integerValue]==2) {
                 [_lblClientName setText:[NSString stringWithFormat:@"%@ V/S %@",_caseObj.oppositionFirstName, _caseObj.clientFirstName]];
            }
            else
            {
                 [_lblClientName setText:[NSString stringWithFormat:@"%@ V/S %@", _caseObj.clientFirstName, _caseObj.oppositionFirstName]];
            }
        }
        else
        {
             [_lblClientName setText:[NSString stringWithFormat:@"%@ V/S %@", _caseObj.clientFirstName, _caseObj.oppositionFirstName]];
        }
        
        
        Client *objClient = [Client fetchClient:_caseObj.clientId];
        
         [_imgViewProfile setImageWithURL:[NSURL URLWithString:kClientId(objClient.taskPlannerId)] placeholderImage:image_placeholder_80];
        
//        if ([objClient.isTaskPlanner isEqualToNumber:@1]) {
//            [_imgViewProfile setImageWithURL:[NSURL URLWithString:GetProPicURLForUser(objClient.clientId)] placeholderImage:image_placeholder_80];
//        }
        [_lblCourt setText:_caseObj.courtName];
        NSString *strDate = [Global dateToFormatedDate:(_caseObj.nextHearingDate==nil)?_caseObj.lastHeardDate:_caseObj.nextHearingDate];
        [_lblDate setText:strDate];
        
        [_lblDate setHidden:YES];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception => %@", [exception debugDescription]);
    }
    @finally {
        
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)profileGesTapped:(id)sender
{
    UIImage *imageToZoom=[self.imgViewProfile image];
    if (imageToZoom) {
        
        imageViewer=[[ImageZoomerScrollView alloc] initWithFrame:SCREENBOUNDS withZoomImage:imageToZoom];
        [imageViewer setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.7]];
        
        UIButton *btnClose=[UIButton buttonWithType:UIButtonTypeCustom];
        [btnClose setFrame:CGRectMake(SCREENWIDTH-40, 25, 28, 28)];
        [btnClose addTarget:self action:@selector(btnCloseImageTapped:) forControlEvents:UIControlEventTouchUpInside];
        [btnClose setImage:[[UIImage imageNamed:@"closePreview"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
        [btnClose setTintColor:[UIColor whiteColor]];
        [btnClose setBackgroundColor:CLEARCOLOUR];
        [[[[UIApplication sharedApplication] delegate] window] addSubview:imageViewer];
        
        imageViewer.transform = CGAffineTransformMakeScale(1.3, 1.3);
        imageViewer.alpha = 0;
        [imageViewer setBackgroundColor:[UIColor colorWithWhite:0 alpha:0.9f]];
        [UIView animateWithDuration:.25 animations:^{
            imageViewer.alpha = 1;
            imageViewer.transform = CGAffineTransformMakeScale(1, 1);
        } completion:^(BOOL finished) {
            
            [[[[UIApplication sharedApplication] delegate] window] addSubview:btnClose];
            
        }];
    }
}

-(void)btnCloseImageTapped:(UIButton *)sender
{
    [sender removeFromSuperview];
    [UIView animateWithDuration:.25 animations:^{
        imageViewer.transform = CGAffineTransformMakeScale(1.3, 1.3);
        imageViewer.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [imageViewer removeFromSuperview];
            
            imageViewer=nil;
        }
    }];
}


@end
