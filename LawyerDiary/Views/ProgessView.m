//
//  ProgessView.m
//  TwoTwit
//
//  Created by nayan mistry on 22/01/15.
//  Copyright (c) 2015 nayan mistry. All rights reserved.
//

#import "ProgessView.h"

@implementation ProgessView

@synthesize circleColor;

- (void)drawRect:(CGRect)rect {
    
//    UIColor *color=COLOR_WITH_RGBA(12.0f,119.0f,184.0f,0.4);//[UIColor colorWithWhite:1 alpha:0.4];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(ctx, circleColor.CGColor);
    CGContextSetStrokeColorWithColor(ctx, circleColor.CGColor);
    CGContextStrokeEllipseInRect(ctx, CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4));
}

-(void)clearContext
{
     CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextClearRect(ctx, CGRectMake(2, 2, self.frame.size.width-4, self.frame.size.height-4));
}

@end
