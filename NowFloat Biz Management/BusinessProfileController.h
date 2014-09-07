//
//  BusinessProfileController.h
//  NowFloats Biz Management
//
//  Created by jitu keshri on 7/26/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import "SA_OAuthTwitterController.h"
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/Social.h>
#import "NFInstaPurchase.h"


@interface BusinessProfileController : UIViewController<SWRevealViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,MFMessageComposeViewControllerDelegate,NFInstaPurchaseDelegate>
{
    UINavigationBar *navBar;
    
    UIButton *customButton;
    NSString *version ;
    
    SWRevealViewController *revealController;
    
    UINavigationController *frontNavigationController;
    
    AppDelegate *appDelegate;
}
@property (strong, nonatomic) IBOutlet UITableView *businessProTable;

- (IBAction)updateDescription:(id)sender;

@property (strong, nonatomic) IBOutlet UILabel *businessNameLabel;

@property (strong, nonatomic) IBOutlet UILabel *categoryLabel;

@property (strong, nonatomic) IBOutlet UIImageView *primaryImageView;

@property (strong, nonatomic) IBOutlet UIView *businessDescView;

@property (strong, nonatomic) IBOutlet UITextView *businessDescText;

@property (strong, nonatomic) IBOutlet UIButton *editButton;

@property (strong, nonatomic) IBOutlet UIImageView *editImage;

-(void)editBizAddress;

-(void)editProfile;

-(void)editContactInfo;

-(void)showBizHours;

-(void)showBizLogo;

-(void)showSocialSharing;

@end
