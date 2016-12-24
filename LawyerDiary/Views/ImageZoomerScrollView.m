//
//  ImageZoomerScrollView.m
//  TwoTwit
//
//  Created by nayan mistry on 22/01/15.
//  Copyright (c) 2015 nayan mistry. All rights reserved.
//

#import "ImageZoomerScrollView.h"

@implementation ImageZoomerScrollView

@synthesize imageView = _imageView;

-(id)initWithFrame:(CGRect)frame withZoomImage:(UIImage *)image
{
    self=[super initWithFrame:frame];
    if (self) {
    
        self.imageView=[[UIImageView alloc] init];
        [self.imageView setBackgroundColor:CLEARCOLOUR];
        [self addSubview:self.imageView];
        [self setDelegate:self];
        [self addProgressView];
        [self initialize];
        [self prepareScollviewForZooming:image];
       
    }
    return self;
}

-(id)initWithFrameWithOutProgress:(CGRect)frame withZoomImage:(UIImage *)image
{
    self=[super initWithFrame:frame];
    if (self) {
        
        self.imageView=[[UIImageView alloc] init];
        [self.imageView setBackgroundColor:CLEARCOLOUR];
        [self addSubview:self.imageView];
        [self setDelegate:self];
        [self prepareScollviewForZooming:image];
        
    }
    return self;
}

-(void)addProgressView
{
    if (progressLayerView==nil) {
        progressLayerView=[[ProgessView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-30, self.frame.size.height/2-30, 60, 60)];
        [progressLayerView setBackgroundColor:[UIColor clearColor]];
        [progressLayerView setCircleColor:[UIColor colorWithWhite:1 alpha:0.5]];
        [self addSubview:progressLayerView];
    }
}

#pragma mark-
#pragma mark- Download progrss

- (void)initialize {
    
    progressLayerView.contentMode = UIViewContentModeRedraw;
    _progressLayer = [[CAShapeLayer alloc] init];
    _progressLayer.strokeColor = kWhiteColor.CGColor;
    _progressLayer.strokeEnd = 0;
    _progressLayer.fillColor = nil;
    _progressLayer.lineWidth = 4;
    [progressLayerView.layer addSublayer:_progressLayer];
}


- (void)layoutSubviews {
    
    [super layoutSubviews];
    self.progressLayer.frame = CGRectMake(0, 0, 56, 56);
    [self updatePath];
}

#pragma mark - Accessors

- (void)setProgress:(float)progress {
    [self setProgress:progress animated:NO];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    
    if (progress > 0) {
        
        if (animated) {
            CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            animation.fromValue = self.progress == 0 ? @0 : nil;
            animation.toValue = [NSNumber numberWithFloat:progress];
            animation.duration = 1;
            self.progressLayer.strokeEnd = progress;
            [self.progressLayer addAnimation:animation forKey:@"animation"];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressLayer.strokeEnd = progress;
            [CATransaction commit];
        }
    } else {
        self.progressLayer.strokeEnd = 0.0f;
        [self.progressLayer removeAnimationForKey:@"animation"];
    }
    _progress = progress;
}

- (void)updatePath {
    CGPoint center = CGPointMake(CGRectGetMidX(progressLayerView.bounds), CGRectGetMidY(progressLayerView.bounds));
    self.progressLayer.path = [UIBezierPath bezierPathWithArcCenter:center radius:progressLayerView.bounds.size.width / 2 - 2 startAngle:-M_PI_2 endAngle:-M_PI_2 + 2 * M_PI clockwise:YES].CGPath;
}



-(void)prepareScollviewForZooming:(UIImage *)image
{
    if (image!=nil) {
        
        [self setProgress:0 animated:YES];
        [progressLayerView removeFromSuperview];
        progressLayerView=nil;
        
        UITapGestureRecognizer *twoFingerTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewTwoFingerTapped:)];
        twoFingerTapRecognizer.numberOfTapsRequired = 1;
        twoFingerTapRecognizer.numberOfTouchesRequired = 2;
        [self addGestureRecognizer:twoFingerTapRecognizer];
        
//        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewDoubleTapped:)];
//        doubleTapRecognizer.numberOfTapsRequired = 2;
//        [self addGestureRecognizer:doubleTapRecognizer];
        
        
        self.imageView.image=image;
        self.imageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size};
        [self.imageView setContentMode:UIViewContentModeScaleAspectFit];
        
        
        self.contentSize = image.size;
        CGRect scrollViewFrame = self.frame;
        CGFloat scaleWidth = scrollViewFrame.size.width / self.contentSize.width;
        CGFloat scaleHeight = scrollViewFrame.size.height / self.contentSize.height;
        CGFloat minScale = MIN(scaleWidth, scaleHeight);
        
        [self setBounces:NO];
        self.minimumZoomScale = minScale;
        self.maximumZoomScale = 1.5f;
        [self setClipsToBounds:YES];
        self.zoomScale = minScale;
        [self setShowsVerticalScrollIndicator:NO];
        [self setShowsHorizontalScrollIndicator:NO];
       
    }
    
     [self centerScrollViewContents];
}

#pragma mark-
#pragma mark- UseFul Methods

-(void)performWholeAnimation
{
    self.imageView.alpha = 0.0f;
    self.imageView.transform = CGAffineTransformMakeScale(0.1,0.1);
    [UIView beginAnimations:@"fadeInNewView" context:NULL];
    [UIView setAnimationDuration:0.4];
    self.imageView.transform = CGAffineTransformMakeScale(1,1);
    self.imageView.alpha = 1.0f;
    [UIView commitAnimations];
}

#pragma mark
#pragma mark- LayOut Scrollview contents

- (void)centerScrollViewContents {
    
    CGSize boundsSize = self.bounds.size;
    CGRect contentsFrame = self.imageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageView.frame = contentsFrame;
}

#pragma mark
#pragma mark- Gesture Tapped Method

- (void)scrollViewDoubleTapped:(UITapGestureRecognizer*)recognizer {
    
    
    CGPoint PointLocation =[recognizer locationInView:self];
    if(self.zoomScale > self.minimumZoomScale)
        [self setZoomScale:self.minimumZoomScale animated:YES];
    else
        [self zoomToRect:CGRectMake(PointLocation.x, PointLocation.y, 10.0, 10.0) animated:YES];
    
}

- (void)scrollViewTwoFingerTapped:(UITapGestureRecognizer*)recognizer {
    CGFloat newZoomScale = self.zoomScale / 1.5f;
    newZoomScale = MAX(newZoomScale, self.minimumZoomScale);
    
    [self setZoomScale:newZoomScale animated:YES];
}

#pragma mark
#pragma mark- UIScrollview Delegate


- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
    
}


- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self centerScrollViewContents];
    
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
