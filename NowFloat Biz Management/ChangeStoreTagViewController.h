//
//  ChangeStoreTagViewController.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 29/08/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ChangeStoreTagDelegate <NSObject>

-(void)changeStoreTagComplete:(NSString *)strTag;

@end


@interface ChangeStoreTagViewController : UIViewController
{

    IBOutlet UINavigationBar *navBar;

    UIButton *customCancelButton;
    
    UIButton *customNextButton;
    
    IBOutlet UIImageView *textFieldBg;

    IBOutlet UITextField *storeTagTextField;
}

@property (nonatomic,strong) NSString *fpName;

@property (nonatomic,strong) id<ChangeStoreTagDelegate> delegate;

- (IBAction)backButtonClicked:(id)sender;

- (IBAction)checkDomainAvailabilityBtnClicked:(id)sender;

- (IBAction)endEditingBtnClicked:(id)sender;


@end
