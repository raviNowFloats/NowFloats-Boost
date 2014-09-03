//
//  ForgotPasswordController.m
//  NowFloats Biz Management
//
//  Created by jitu keshri on 5/7/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "ForgotPasswordController.h"
#import "Mixpanel.h"
#import "UIColor+HexaString.h"
#import "SBJsonWriter.h"
#import "DBValidator.h"
#import "SBJson.h"
#import "Helpshift.h"

@interface ForgotPasswordController ()<UIAlertViewDelegate>
{
    float viewHeight;
    UILabel *headerLabel;
    UINavigationBar *navBar;
    int loginSuccessCode;
    NSMutableData *receivedData;
    UIButton *leftCustomButton, *submitButton;
    UITextField *userName;
    UILabel *navigationLabel;
}

@end

@implementation ForgotPasswordController
@synthesize errorView,activity;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    if (version.floatValue<7.0)
    {
        self.navigationController.navigationBarHidden=NO;
        self.navigationItem.title=@"Forgot Password";
        self.navigationController.navigationBar.tintColor = [UIColor colorFromHexCode:@"#f7f7f7"];
    }
    else
    {
        self.navigationController.navigationBarHidden=NO;
        self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexCode:@"#f7f7f7"];
        self.navigationController.navigationBar.tintColor = [UIColor darkGrayColor];
        self.navigationItem.title= @"";
        navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 0, 380, 44)];
        navigationLabel.backgroundColor = [UIColor clearColor];
        navigationLabel.font = [UIFont fontWithName:@"Helvetica Neue-Regular" size:17.0f];
        navigationLabel.textColor =[UIColor colorFromHexCode:@"#8b8b8b"];
        navigationLabel.text=@"Forgot Password";
        [self.navigationController.navigationBar addSubview:navigationLabel];
        self.navigationController.navigationBar.translucent = NO;
    }
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == 102 && buttonIndex == 0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    version = [[UIDevice currentDevice] systemVersion];
    
    appDelegate=(AppDelegate *)[UIApplication  sharedApplication].delegate;
    
    forgotTableView.dataSource = self;
    
    forgotTableView.delegate = self;
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"forgotPassword_clicked"];

    
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
    
   
    
        forgotTableView.backgroundColor = [UIColor clearColor];
        
        forgotTableView.backgroundView = nil;
    
        forgotTableView.scrollEnabled = NO;
    
        forgotTableView.separatorStyle = UITableViewCellSeparatorStyleNone;

      //  self.navigationController.navigationBarHidden=YES;

    
    submitButton = [[UIButton alloc] init];
    
    if(viewHeight == 480)
    {
          submitButton.frame = CGRectMake(10, 145, 300, 40);
    }
    else
    {
         submitButton.frame = CGRectMake(10, 125, 300, 45);
    }
    
    [submitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [submitButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitButton addTarget:self action:@selector(submitPassword:) forControlEvents:UIControlEventTouchUpInside];
    submitButton.backgroundColor = [UIColor colorFromHexCode:@"#ffb900"];
    
    submitButton.layer.cornerRadius = 5.0;
    submitButton.layer.masksToBounds = YES;
    
    [self.view addSubview:submitButton];
  
    
    
        
    activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    
    activity.frame = CGRectMake(130, 160, 60, 60);
    activity.layer.cornerRadius = 8.0f;
    activity.layer.masksToBounds = YES;
    activity.tintColor = [UIColor darkGrayColor];
    activity.color = [UIColor whiteColor];
    activity.backgroundColor = [UIColor darkGrayColor];
    
    


}

#pragma UITableView

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  1;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [navigationLabel removeFromSuperview];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [navigationLabel removeFromSuperview];
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:nil];
    
    if (!cell)
    {
        
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
        [cell setBackgroundColor:[UIColor whiteColor]];
        
    }
    

        if(indexPath.row == 0)
        {
            if(viewHeight == 480)
            {
                userName = [[UITextField alloc] initWithFrame:CGRectMake(10,3, 320, 40)];
            }
            else
            {
                userName = [[UITextField alloc] initWithFrame:CGRectMake(10,3, 320, 40)];
            }
            UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 1)];
            lineView.backgroundColor = [UIColor colorFromHexCode:@"#d4d4d4"];
            
            [cell.contentView addSubview:lineView];
            
            UIView *MiddleLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 43, 320, 1)];
            MiddleLineView.backgroundColor = [UIColor colorFromHexCode:@"#d4d4d4"];
            
            [cell.contentView addSubview:MiddleLineView];
            userName.tag = 101;
            userName.autocapitalizationType = UITextAutocapitalizationTypeNone;
            userName.font = [UIFont fontWithName:@"Helvetica-Light" size:15.0];
            [userName setPlaceholder:@"Username"];
            userName.delegate = self;
            userName.autocorrectionType = UITextAutocorrectionTypeNo;
            [cell.contentView addSubview:userName];
        }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}




#pragma TextField methods
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
  
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(void)back:(id)sender
{
    [self.view endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)submit:(id)sender
{
    [self.view endEditing:YES];
    
    
    if(userName.text.length == 0)
    {
        [activity stopAnimating];
        [activity removeFromSuperview];
        
        [self word:@"Username cannot be empty" isSuccess:NO];
    }
    else
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithObjectsAndKeys:appDelegate.clientId,@"clientId",userName.text,@"fpKey", nil];
        
        SBJsonWriter *jsonWriter=[[SBJsonWriter alloc]init];
        
        NSString *uploadString=[jsonWriter stringWithObject:dic];
        
        NSData *postData = [uploadString dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        
        NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        NSString *urlString=[NSString stringWithFormat:
                             @"%@/forgotPassword",appDelegate.apiWithFloatsUri];
        
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
    
    submitButton.backgroundColor = [UIColor colorFromHexCode:@"#ffb900"];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data1
{
    [receivedData appendData:data1];
}


- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [activity stopAnimating];
    [activity removeFromSuperview];
    if (loginSuccessCode==200)
    {
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"forgotPassword_retrieved"];
        
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Check your email!" message:@"We have sent you an email with password details" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        
        alert.tag = 102;
        
        [alert show];
        
        alert=nil;
        
        
        
    }
    else
    {
       
        
        [self word:@"Uh oh! Something went wrong. Try again." isSuccess:NO];

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

- (void)word:(NSString*)string isSuccess:(BOOL)success
{
    errorView.alpha = 1.0;
    if(success)
    {
        errorView.backgroundColor = [UIColor colorWithRed:93.0f/255.0f green:172.0f/255.0f blue:1.0f/255.0f alpha:1.0];
        
        
    }
    else
    {
        errorView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:34.0f/255.0f blue:0.0f/255.0f alpha:1.0];
    }
    
    UILabel  *errorLabel = [[UILabel alloc]init];
    errorLabel.frame=CGRectMake(20, 0, 280, 40);
    errorLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:14.0];
    errorLabel.textAlignment =NSTextAlignmentCenter;
    errorLabel.text =@"";
    errorLabel.text = string;
    errorLabel.textColor = [UIColor whiteColor];
    errorLabel.backgroundColor =[UIColor clearColor];
    [errorLabel setNumberOfLines:0];
    
    
    
    
    errorView.tag = 55;
    errorView.frame=CGRectMake(0, -200, 320, 40);
    [UIView animateWithDuration:0.8f
                          delay:0.03f
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         
                         errorView.frame=CGRectMake(0, 0, 320, 40);
                         
                         [errorView addSubview:errorLabel];
                         
                         
                         
                     }completion:^(BOOL finished){
                         
                         double delayInSeconds = 1.5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             
                             
                             
                             [UIView animateWithDuration:0.8f
                                                   delay:0.10f
                                                 options:UIViewAnimationOptionTransitionFlipFromBottom
                                              animations:^{
                                                  
                                                  errorView.alpha = 0.0;
                                                  errorView.frame = CGRectMake(0, -55, 320, 50);
                                                  
                                                  
                                              }completion:^(BOOL finished){
                                                  
                                                  for (UIView *errorRemoveView in [self.view subviews]) {
                                                      if (errorRemoveView.tag == 55) {
                                                          errorLabel.frame=CGRectMake(-200, 0, -50, 40);
                                                      }
                                                      
                                                  }
                                                  
                                                  
                                              }];
                             
                         });
                         
                     }];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitPassword:(id)sender
{
    [self.view addSubview:activity];
    [activity startAnimating];
     submitButton.backgroundColor = [UIColor colorFromHexCode:@"#ebaa00"];
    [self submit:nil];
}


- (IBAction)submitClicked:(id)sender
{
    [self submit:nil];
}

@end
