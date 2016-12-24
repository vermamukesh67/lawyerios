//
//  ClientCell.m
//  
//
//  Created by Verma Mukesh on 10/06/15.
//
//

#import "ClientCell.h"
#import "Client.h"

@implementation ClientCell

- (void)awakeFromNib {
    // Initialization code
    [Global applyCornerRadiusToViews:@[_imgViewProfile] withRadius:ViewHeight(_imgViewProfile)/2 borderColor:WHITE_COLOR andBorderWidth:1];
    
    UITapGestureRecognizer *tapGes=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileGesTapped:)];
    [self.imgViewProfile addGestureRecognizer:tapGes];
    
    [self.imgViewProfile setUserInteractionEnabled:YES];
}

- (void)configureCellWithClientObj:(Client *)obj forIndexPath:(NSIndexPath *)indexPath
{
    _clientObj = obj;
    _indexPath = indexPath;
    
    [_lblClientName setText:[NSString stringWithFormat:@"%@ %@", _clientObj.clientFirstName, _clientObj.clientLastName]];
    [_lblMobile setText:_clientObj.mobile];
    
     [_imgViewProfile setImageWithURL:[NSURL URLWithString:kClientId(_clientObj.taskPlannerId)] placeholderImage:image_placeholder_80];
//    if ([_clientObj.isTaskPlanner isEqualToNumber:@1]) {
//       
//    }
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
