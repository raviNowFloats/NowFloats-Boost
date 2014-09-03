//
//  ChangePasswordController.m
//  NowFloats Biz Management
//
//  Created by jitu keshri on 5/1/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "ChangePasswordController.h"
#import "UIColor+HexaString.h"
#import "DBValidator.h"
#import "SBJson.h"
#import "SBJsonWriter.h"
#import "AlertViewController.h"
@interface ChangePasswordController ()
{
    float viewHeight;
    UINavigationBar *navBar;
    UILabel *headerLabel, *passwordLabel;
    int loginSuccessCode;
    NSMutableData *receivedData;
    NSUserDefaults *userdetails;
    UITextField *currentPasswd,*newPasswd, *confirmPasswd, *userName;
    UIButton *leftCustomButton, *rightCustomButton;
}

@end

@implementation ChangePasswordController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    version = [[UIDevice currentDevice] systemVersion];
    
    userdetails=[NSUserDefaults standardUserDefaults];
    
    passwordTableView.backgroundColor = [UIColor colorFromHexCode:@"#dedede"];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            viewHeight=480;
        }
        
        else
        {
            viewHeight=568;
        }
    }
    
    if(viewHeight == 480)
    {
        if(version.floatValue < 7.0)
        {
        passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,88, 300, 50)];
        }
        else
        {
         passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10,150, 300, 50)];
        }
    }
    else
    {
         passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 150, 300, 50)];
    }
    

    
    passwordLabel.numberOfLines = 2;
    
    passwordLabel.text = @"Check the very first email we've sent to know your Current Password";
    
    passwordLabel.textAlignment=NSTextAlignmentLeft;
    
    passwordLabel.font=[UIFont fontWithName:@"Helvetica-Light" size:12.0];
    
    passwordLabel.textColor=[UIColor  colorWithHexString:@"464646"];
   
    passwordTableView.bounces = NO;
    
    if(version.floatValue < 7.0)
    {
        
        [passwordLabel setBackgroundColor:[UIColor clearColor]];
        
        [passwordTableView setFrame:CGRectMake(0, 44, 320, 480)];
        
        self.navigationController.navigationBarHidden=YES;
        
        CGFloat width = self.view.frame.size.width;
        
        navBar = [[UINavigationBar alloc] initWithFrame:
                  CGRectMake(0,0,width,44)];
        
        [self.view addSubview:navBar];
        
        
        headerLabel=[[UILabel alloc]initWithFrame:CGRectMake(55, 13, 200, 20)];
        
        headerLabel.text=@"Change Password";
        
        headerLabel.backgroundColor=[UIColor clearColor];
        
        headerLabel.textAlignment=NSTextAlignmentCenter;
        
        headerLabel.font=[UIFont fontWithName:@"Helvetica" size:18.0];
        
        headerLabel.textColor=[UIColor  colorWithHexString:@"464646"];
        
        [navBar addSubview:headerLabel];
        
        leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [leftCustomButton setFrame:CGRectMake(5,9,50,26)];
        
        [leftCustomButton setImage:[UIImage imageNamed:@"back-btn.png"] forState:UIControlStateNormal];
        
        [leftCustomButton addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        
        [navBar addSubview:leftCustomButton];
        
        
        rightCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [rightCustomButton setFrame:CGRectMake(265,0,45,44)];
        
        [rightCustomButton setTitle:@"Save" forState:UIControlStateNormal];
        
        [rightCustomButton addTarget:self action:@selector(savePasswd:) forControlEvents:UIControlEventTouchUpInside];
        
        [navBar addSubview:rightCustomButton];
        
        [rightCustomButton setHidden:YES];
        
        
        
    }
    else{
        
        self.navigationController.navigationBarHidden=NO;
        
        self.navigationItem.title=@"Change Password";
        
        self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexCode:@"ffb900"];
        
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        
        rightCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [rightCustomButton setFrame:CGRectMake(280,0,50,44)];
        
        [rightCustomButton setTitle:@"Save" forState:UIControlStateNormal];
        
        [rightCustomButton addTarget:self action:@selector(savePasswd:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    
    [self.view addSubview:passwordLabel];

}





-(void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)savePasswd:(id)sender
{
    [self.view endEditing:YES];
    NSError *error;
    
    NSRegularExpression *regexSpace = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    
     currentPasswd.text = [regexSpace stringByReplacingMatchesInString:currentPasswd.text options:0 range:NSMakeRange(0, [currentPasswd.text length]) withTemplate:@" "];
    
    newPasswd.text = [regexSpace stringByReplacingMatchesInString:newPasswd.text options:0 range:NSMakeRange(0, [newPasswd.text length]) withTemplate:@" "];
    
    confirmPasswd.text = [regexSpace stringByReplacingMatchesInString:confirmPasswd.text options:0 range:NSMakeRange(0, [confirmPasswd.text length]) withTemplate:@" "];
    
    
    if(currentPasswd.text.length == 0 || newPasswd.text.length == 0 || confirmPasswd.text.length == 0)
    {
        if(currentPasswd.text.length == 0)
        {
           
            
            [AlertViewController CurrentView:self.view errorString:@"Current Password cannot be empty" size:60 success:NO];
        }
        else if(newPasswd.text.length == 0)
        {
            
            
            [AlertViewController CurrentView:self.view errorString:@"New Password cannot be empty" size:60 success:NO];
        }
        else if(confirmPasswd.text.length == 0)
        {
            
            
             [AlertViewController CurrentView:self.view errorString:@"Confirm Password cannot be empty" size:60 success:NO];
        }
    }
    else
    {
        if(![newPasswd.text isEqualToString:confirmPasswd.text])
        {
            
             [AlertViewController CurrentView:self.view errorString:@"Passwords mismatch. Please try again" size:60 success:NO];
        }
        else
        {
            if([newPasswd.text isEqualToString:currentPasswd.text])
            {
                
                
                [AlertViewController CurrentView:self.view errorString:@"New password cannot be same as current password" size:60 success:NO];
            }
            else
            {
               
                NSString *fpTag = [appDelegate.storeDetailDictionary objectForKey:@"Tag"];
                
                fpTag = [fpTag lowercaseString];
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:appDelegate.clientId,@"clientId",currentPasswd.text,@"currentPassword",newPasswd.text,@"newPassword",fpTag,@"username", nil];
                
                SBJsonWriter *jsonWriter=[[SBJsonWriter alloc]init];
                
                NSString *uploadString=[jsonWriter stringWithObject:dic];
                
                NSData *postData = [uploadString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
                
                NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
                
                NSString *urlString=[NSString stringWithFormat:
                                     @"%@/changePassword",appDelegate.apiWithFloatsUri];
                
                NSURL *loginUrl=[NSURL URLWithString:urlString];
                
                NSMutableURLRequest *changePasswordRequest = [NSMutableURLRequest requestWithURL:loginUrl];
                
                [changePasswordRequest setHTTPMethod:@"POST"];
                
                [changePasswordRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                
                [changePasswordRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
                
                [changePasswordRequest setValue:postLength forHTTPHeaderField:@"Content-Length"];
                
                [changePasswordRequest setHTTPBody:postData];
                
                NSURLConnection *theConnection;
                
                theConnection =[[NSURLConnection alloc] initWithRequest:changePasswordRequest delegate:self];
            }
            
            
        }
    }
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data1
{
    [receivedData appendData:data1];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    
    if (loginSuccessCode==200)
    {
        
        
        
           [AlertViewController CurrentView:self.view errorString:@"Password changed successfully" size:60 success:NO];
        
        
        
    }
    else
    {
      
        
         [AlertViewController CurrentView:self.view errorString:@"Invalid password" size:60 success:NO];
        
    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = [httpResponse statusCode];
    
    
        if (code==200)
        {
            loginSuccessCode=200;
        }
        else
        {
            loginSuccessCode=code;
        }
   
    
}


-(void) connection:(NSURLConnection *)connection   didFailWithError: (NSError *)error
{
    
    UIAlertView *errorAlert= [[UIAlertView alloc] initWithTitle: [error localizedDescription] message: [error localizedFailureReason] delegate:nil                  cancelButtonTitle:@"Done" otherButtonTitles:nil];
    
    [errorAlert show];

}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 101)
    {
        if(buttonIndex == 0)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 1;
    }
    else if(section == 1)
    {
        return 2;
    }
    else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
   
        if (section==0)
        {
            return 50;
        }
        else
        {
            return 60;//35
        }
   
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier=@"String Identifier";
    
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:identifier];
    
    if (cell==nil)
    {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
        [cell setBackgroundColor:[UIColor whiteColor]];
        
    }
    
    if(indexPath.section == 0)
    {
        if(indexPath.row == 0)
        {
            currentPasswd = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 320, 40)];
            currentPasswd.tag = 101;
            currentPasswd.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0];
            [currentPasswd setPlaceholder:@"Current password"];
            currentPasswd.delegate = self;
            currentPasswd.secureTextEntry = YES;
            currentPasswd.autocorrectionType = UITextAutocorrectionTypeNo;
            [cell.contentView addSubview:currentPasswd];
        }
    }
    else if (indexPath.section == 1)
    {
        if(indexPath.row == 0)
        {
            newPasswd = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 320, 40)];
            newPasswd.tag = 102;
            newPasswd.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0];
            newPasswd.delegate = self;
            [newPasswd setPlaceholder:@"New password"];
            newPasswd.secureTextEntry = YES;
            newPasswd.autocorrectionType = UITextAutocorrectionTypeNo;
            [cell.contentView addSubview:newPasswd];
        }
        else if (indexPath.row == 1)
        {
            confirmPasswd = [[UITextField alloc] initWithFrame:CGRectMake(10, 5, 320, 40)];
            confirmPasswd.tag = 103;
            confirmPasswd.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0];
            confirmPasswd.delegate = self;
            confirmPasswd.secureTextEntry = YES;
            [confirmPasswd setPlaceholder:@"Confirm new password"];
            confirmPasswd.autocorrectionType = UITextAutocorrectionTypeNo;
            [cell.contentView addSubview:confirmPasswd];
        }
    }
    
    [cell setSelected:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


-(CGFloat)tableView:(UITableView*)tableView heightForFooterInSection:(NSInteger)section
{
    return 1.0;
}

-(UIView*)tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero] ;
}

-(UIView*)tableView:(UITableView*)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero] ;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(version.floatValue < 7.0)
    {
        if(rightCustomButton.hidden == YES)
        {
            [rightCustomButton setHidden:NO];
        }
    }
    else
    {
        
        if(self.navigationItem.rightBarButtonItem == nil)
        {
            UIBarButtonItem *rightBtnItem=[[UIBarButtonItem alloc]initWithCustomView:rightCustomButton];
            
            self.navigationItem.rightBarButtonItem = rightBtnItem;
        }
    }
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            
            if(textField==confirmPasswd || textField==newPasswd)
            {
                if(version.floatValue < 7.0)
                {
                    passwordTableView.frame = CGRectMake(0, -60, 320, passwordTableView.frame.size.height);
                    passwordLabel.frame= CGRectMake(10,50, 300, 50);
                }
                else
                {
                    passwordTableView.frame = CGRectMake(0, -60, 320, passwordTableView.frame.size.height);
                    passwordLabel.frame= CGRectMake(10,90, 300, 50);
                }
                
            }
        }
        
        else
        {
           
        }
    }

    
    
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if(textField==confirmPasswd || textField==newPasswd)
    {
        if(version.floatValue < 7.0)
        {
            passwordTableView.frame = CGRectMake(0, 0, 320, passwordTableView.frame.size.height);
            passwordLabel.frame= CGRectMake(10,88, 300, 50);
        }
        else
        {
            passwordTableView.frame = CGRectMake(0, 0, 320, passwordTableView.frame.size.height);
            passwordLabel.frame= CGRectMake(10,150, 300, 50);
        }
        
    }

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
