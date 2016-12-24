//
//  ImageZoomerScrollView.h
//  TwoTwit
//
//  Created by nayan mistry on 22/01/15.
//  Copyright (c) 2015 nayan mistry. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProgessView.h"

@interface ImageZoomerScrollView : UIScrollView<UIScrollViewDelegate>
{
    ProgessView *progressLayerView;
}

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic) float  progress;

-(id)initWithFrame:(CGRect)frame withZoomImage:(UIImage *)image;
-(id)initWithFrameWithOutProgress:(CGRect)frame withZoomImage:(UIImage *)image;
-(void)prepareScollviewForZooming:(UIImage *)image;
- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)centerScrollViewContents;
@end
