//
//  LoginController.h
//  NowFloats Biz Management
//
//  Created by Ravindra Naik on 28/07/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

@interface LoginController : UIViewController
{
    AppDelegate *appDelegate;
    
    __weak IBOutlet UILabel *titleView;
    
    __weak IBOutlet UIView *navigationBarView;
    
    __weak IBOutlet UITableView *signInTableView;
    
     NSMutableData *receivedData;
    
    BOOL isLoginForAnotherUser;
    
}

- (IBAction)signInClicked:(id)sender;

- (IBAction)forgotPasswordClicked:(id)sender;

@property (strong, nonatomic) IBOutlet UIView *errorView;

@property (strong, nonatomic) IBOutlet UIButton *goBack;

@property (strong, nonatomic) IBOutlet UIImageView *goBackImage;

@property (strong, nonatomic) IBOutlet UILabel *backLabel;

@property (strong,nonatomic)  UIActivityIndicatorView *activity;

- (IBAction)goBack:(id)sender;

@end
