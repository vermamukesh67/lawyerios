//
//  SubordinateCaseCell.m
//  LawyerDiary
//
//  Created by Verma Mukesh on 11/12/16.
//  Copyright © 2016 Singularsllp. All rights reserved.
//

#import "SubordinateCaseCell.h"

@implementation SubordinateCaseCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        self.lblTitle=[[UILabel alloc] initWithFrame:CGRectMake(ViewX(self)+15, 0, ViewWidth(self)-30, 22)];
        [self addSubview:self.lblTitle];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
