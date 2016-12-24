//
//  ClientCell.h
//  
//
//  Created by Verma Mukesh on 10/06/15.
//
//

#import <UIKit/UIKit.h>
#import "SWTableViewCell.h"

@class Client;

@interface ClientCell : SWTableViewCell
{
    ImageZoomerScrollView *imageViewer;
}

@property (nonatomic, strong) IBOutlet UILabel *lblClientName;
@property (nonatomic, strong) IBOutlet UILabel *lblMobile;
@property (nonatomic, strong) IBOutlet UIImageView *imgViewProfile;

@property (nonatomic, strong) Client *clientObj;
@property (nonatomic, strong) NSIndexPath *indexPath;

- (void)configureCellWithClientObj:(Client *)obj forIndexPath:(NSIndexPath *)indexPath;

@end
