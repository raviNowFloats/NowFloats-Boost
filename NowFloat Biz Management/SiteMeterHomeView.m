//
//  SiteMeterHomeView.m
//  NowFloats Biz Management
//
//  Created by Ravindra Naik on 27/08/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "SiteMeterHomeView.h"

@implementation SiteMeterHomeView
@synthesize cardOverlayView;
- (void)awakeFromNib
{
    // Initialization code
    
    
    cardOverlayView.layer.cornerRadius = 4.0f;
    cardOverlayView.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
