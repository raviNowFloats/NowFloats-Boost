
//
//  BookDomainnController.m
//  NowFloats Biz Management
//
//  Created by jitu keshri on 7/31/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "BookDomainnController.h"
#import "VerifyUniqueNameController.h"
#import "Mixpanel.h"
#import "PopUpView.h"
#import "BizMessageViewController.h"
#import "Aarki.h"
#import "AarkiContact.h"
#import "RegisterChannel.h"
#import "FileManagerHelper.h"
#import "RIATipsController.h"
#import "DomainSelectViewController.h"
#import "UserSettingsWebViewController.h"
#import "TutorialViewController.h"
#import "GetFpAddressDetails.h"
#import "NFActivityView.h"
@interface BookDomainnController ()<RegisterChannelDelegate,PopUpDelegate,UIAlertViewDelegate>
{
  
    
}
@end

@implementation BookDomainnController
@synthesize domianChkImage,domianChkLabel,suggestedUrltextView;
@synthesize userName,BusinessName,city,emailID,phono,country,pincode,category,suggestedURL,countryCode;
@synthesize addressValue,fbpageName;
@synthesize viewName;

@synthesize longt,latt;
@synthesize primaryImageURL,pageDescription;
@synthesize activity;
@synthesize errorView;
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
  
     activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    activity.frame = CGRectMake(130, 160, 60, 60);
    activity.layer.cornerRadius = 8.0f;
    activity.layer.masksToBounds = YES;
    activity.tintColor = [UIColor darkGrayColor];
    activity.color = [UIColor whiteColor];
    activity.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:activity];
    [activity startAnimating];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    // Do any additional setup after loading the view from its nib.
    
    suggestedUrltextView.text = suggestedURL;
    
    suggestedUrltextView.text = [suggestedUrltextView.text lowercaseString];
    
    self.suggestDomainView.layer.borderWidth = 0.5f;
    self.suggestDomainView.layer.borderColor = [UIColor colorWithRed:205.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f].CGColor;
    
    UITapGestureRecognizer *removeKey = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeKeyboard)];
    
    removeKey.numberOfTapsRequired = 1;
    removeKey.numberOfTouchesRequired =1;
    [self.view addGestureRecognizer:removeKey];
    self.view.userInteractionEnabled=YES;
    
    self.privacyLabel.userInteractionEnabled = YES;
    self.termsLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *privacy = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openPrivacy)];
    privacy.numberOfTapsRequired = 1;
    privacy.numberOfTouchesRequired = 1;
    [self.privacyLabel addGestureRecognizer:privacy];
    
    
    UITapGestureRecognizer *terms = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(terms)];
    privacy.numberOfTapsRequired = 1;
    privacy.numberOfTouchesRequired = 1;
    [self.termsLabel addGestureRecognizer:terms];
    
    GetFpAddressDetails *_verifyAddress=[[GetFpAddressDetails alloc]init];
    _verifyAddress.delegate=self;
    [_verifyAddress downloadFpAddressDetails:addressValue];
    
    
}



-(void)removeKeyboard
{
    [self.view endEditing:YES];
}

-(void)textViewDidChange:(UITextView *)textView
{
    if([textView.text isEqualToString:@""])
    {
        self.domianChkImage.image = [UIImage imageNamed:@"domain_not_available.png"];
        self.domianChkLabel.text = @"Please enter a valid Sub-Domain";
    }
    else
    {
        
        if(textView==suggestedUrltextView)
        {
            VerifyUniqueNameController *uniqueNameController=[[VerifyUniqueNameController alloc]init];
            
            uniqueNameController.delegate=self;
            
            [uniqueNameController verifyWithFpName:BusinessName andFpTag:suggestedUrltextView.text];
        }
    }
    
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if(textView == suggestedUrltextView)
    {
        NSCharacterSet *invalidCharSet = [[NSCharacterSet characterSetWithCharactersInString:@"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"] invertedSet];
        NSString *filtered = [[text componentsSeparatedByCharactersInSet:invalidCharSet] componentsJoinedByString:@""];
        return [text isEqualToString:filtered];
    }
    else
        return YES;
    
}

-(void)verifyUniqueNameDidComplete:(NSString *)responseString
{
    
    if ([[responseString lowercaseString] isEqualToString:[suggestedUrltextView.text lowercaseString]])
    {
        
        self.domianChkImage.image = [UIImage imageNamed:@"domain_available.png"];
        self.domianChkLabel.text  = @"Chosen Sub-Domain is Available";
        
    }
    
    
    else
    {
        self.domianChkImage.image = [UIImage imageNamed:@"domain_not_available.png"];
        self.domianChkLabel.text  = @"Chosen Sub-Domain is not Available";
        
    }
    
    
}

-(void)verifyuniqueNameDidFail:(NSString *)responseString
{
    
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)createMysite:(id)sender {
    
    [activity startAnimating];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"Create WebsiteWithFacebook"];
    
    [self.view endEditing:YES];
    
    if (suggestedUrltextView.text.length==0)
    {
       
        
        [self word:@"Oops! Store domain cannot be empty " isSuccess:NO];
        
    }
    
    else
    {
        NSMutableDictionary *regiterDetails;
        if([pincode isEqualToString:@""] || pincode==nil)
            
        {
            
            pincode = @"";
            
        }
        
        if([addressValue isEqualToString:@""] || addressValue==nil)
            
        {
            
            addressValue =[NSString stringWithFormat:@"%@,%@",city,country];
            
        }
        
        if([longt isEqualToString:@""] || longt==nil)
            
        {
            
            longt =@"";
            
            latt  =@"";
            
        }
        
        
        
        if([pageDescription isEqualToString:@""] || pageDescription==nil)
            
        {
            
            pageDescription =@"";
            
        }
        
        if([fbpageName isEqualToString:@""] || fbpageName==nil)
            
        {
            
            fbpageName =@"";
            
            
        }
        

        regiterDetails=[[NSMutableDictionary alloc]initWithObjectsAndKeys:
                        appDelegate.clientId,@"clientId",
                        suggestedUrltextView.text,@"tag",
                        userName,@"contactName",
                        BusinessName,@"name",
                        pageDescription,@"desc",
                        [NSString stringWithFormat:@"%@",city],@"city",
                        [NSString stringWithFormat:@"%@",pincode],@"pincode",
                        country,@"country",
                        addressValue,@"address",
                        phono,@"primaryNumber",
                        [NSString stringWithFormat:@"%@",countryCode],@"primaryNumberCountryCode",
                        [NSString stringWithFormat:@"%@",emailID],@"email",
                        [NSString stringWithFormat:@""],@"Uri",
                        fbpageName,@"fbPageName",
                        category,@"primaryCategory",
                        [NSString stringWithFormat:@"%f",storeLatitude],@"lat",
                        [NSString stringWithFormat:@"%f",storeLongitude],@"lng",
                        nil];
        
        NSLog(@"Register details are %@", regiterDetails);
        
        
        SignUpController *signUpController=[[SignUpController alloc]init];
        
        signUpController.delegate=self;
        
        [signUpController withCredentials:regiterDetails];
        
    }
    
    
    
}

-(void)signUpDidSucceedWithFpId:(NSString *)responseString
{
    [self showBizMessageView:responseString];
}

-(void)signUpDidFailWithError
{
    
    [activity stopAnimating];
    
    UIAlertView *downloadAlertView = [[UIAlertView alloc]initWithTitle:@"Number already registered!" message:@"Entered phone number is already registered with us. Please enter a different one." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    downloadAlertView.tag = 21;
    
    [downloadAlertView setAlertViewStyle:UIAlertViewStylePlainTextInput];
    
    [[downloadAlertView textFieldAtIndex:0] setPlaceholder:@"Enter Mobile Number"];
    
    [downloadAlertView show];
    
    downloadAlertView = nil;
    
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 21)
    {
        if(buttonIndex == 1)
        {
            phono = [alertView textFieldAtIndex:0].text ;
            [self createMysite:nil];
        }
    }
}

-(void)showBizMessageView:(NSString *)responseString
{
    
    // createdFpName = responseString;
    
    NSUserDefaults  *userDefaults=[NSUserDefaults standardUserDefaults];
    
    [userDefaults setObject:responseString  forKey:@"userFpId"];
    
    [userDefaults synchronize];
    
    /*Get all the messages and store details*/
    
    GetFpDetails *getDetails=[[GetFpDetails alloc]init];
    
    getDetails.delegate=self;
    
    [getDetails fetchFpDetail];
}

-(void)downloadFinished
{
    
    
    if (BOOST_PLUS)
    {
        PopUpView *buyDomainPopUp = [[PopUpView alloc]init];
        buyDomainPopUp.delegate=self;
        buyDomainPopUp.tag=102;
        buyDomainPopUp.successBtnText=@"Book Now";
        buyDomainPopUp.cancelBtnText=@"May be Later";
        buyDomainPopUp.titleText = @"Book your Domain";
        buyDomainPopUp.descriptionText = @"Your NowFloats website is now ready.You can now dress it up with your own domain name reflecting your business identity. Choose your free .com or .net now.";
        buyDomainPopUp.descriptionLabel.font = [UIFont fontWithName:@"Helvetica" size:12.0];
        buyDomainPopUp.popUpImage=[UIImage imageNamed:@"storeDomain2.png"];
        [buyDomainPopUp showPopUpView];
    }
    
    else
    {
        [self navigateBizMessageView];
    }
}

-(void)navigateBizMessageView
{
    @try
    {
        [self setRegisterChannel];
        
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel identify:appDelegate.storeTag]; //username
        
        NSDate *createdDate = [NSDate date];
        
        NSDictionary *specialProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                           appDelegate.storeEmail, @"$email",
                                           appDelegate.businessName, @"$name",
                                           createdDate,@"$Created On",
                                           nil];
        
        [mixpanel.people set:specialProperties];
        [mixpanel.people addPushDeviceToken:appDelegate.deviceTokenData];
        
        
        
    }
    
    @catch (NSException *e){}
    
    FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
    
    fHelper.userFpTag=appDelegate.storeTag;
    
    [fHelper createUserSettings];
    
    [fHelper updateUserSettingWithValue:[NSDate date] forKey:@"1stSignUpDate"];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSDate *startTime = [NSDate date];
    
    [userDefaults setObject:startTime forKey:@"appStartDate"];
    
    [userDefaults setObject:[NSNumber numberWithBool:YES] forKey:@"showTutorialView"];
    
    [AarkiContact registerEvent:@"26D69ACEA3F720D5OU"];
    
    [activity stopAnimating];
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    
    [mixpanel track:@"SuccesswithFacebooksignup"];

    
    RIATipsController *ria = [[RIATipsController alloc]initWithNibName:@"RIATipsController" bundle:nil];
    [self.navigationController pushViewController:ria animated:YES];
    
    
    
}
-(void)setRegisterChannel
{
    RegisterChannel *regChannel=[[RegisterChannel alloc]init];
    
    regChannel.delegate=self;
    
    [regChannel registerNotificationChannel];
}

#pragma PopUpDelegate

-(void)successBtnClicked:(id)sender
{
    if ([[sender objectForKey:@"tag"] intValue]==101)
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Cancel SignUp"];
        
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    
    else if ([[sender objectForKey:@"tag"] intValue]==102)
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"goto_domainPurchasefromSignUp"];
        
        DomainSelectViewController *selectController=[[DomainSelectViewController alloc]initWithNibName:@"DomainSelectViewController" bundle:Nil];
        
        selectController.isFromOtherViews = YES;
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:selectController];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
}


-(void)cancelBtnClicked:(id)sender
{
    if ([[sender objectForKey:@"tag"] intValue]==102)
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"cancel_domainPurchasefromSignUp"];
        
        NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
        
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag = appDelegate.storeTag;
        
        if ([userSetting objectForKey:@"isDomainPurchaseCancelled"]==nil)
        {
            [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:NO] forKey:@"isDomainPurchaseCancelled"];
        }
        
        [self navigateBizMessageView];
    }
}

-(void)downloadFailedWithError
{

    
    [self word:@"Something went wrong during download. Please kill the application and click Login In" isSuccess:NO];
    
    [activity stopAnimating];
    
}

-(void)channelDidRegisterSuccessfully
{
}

-(void)channelFailedToRegister
{
}

-(void)openPrivacy
{
    UserSettingsWebViewController *webViewController=[[UserSettingsWebViewController alloc]initWithNibName:@"UserSettingsWebViewController" bundle:nil];
    
    UINavigationController *navController=[[UINavigationController   alloc]initWithRootViewController:webViewController];
    
    webViewController.displayParameter=@"Privacy Policy";
    
    [self presentViewController:navController animated:YES completion:nil];
    
    webViewController=nil;
    
}

-(void)terms
{
    UserSettingsWebViewController *webViewController=[[UserSettingsWebViewController alloc]initWithNibName:@"UserSettingsWebViewController" bundle:nil];
    
    UINavigationController *navController=[[UINavigationController   alloc]initWithRootViewController:webViewController];
    
    webViewController.displayParameter=@"Terms & Conditions";
    
    [self presentViewController:navController animated:YES completion:nil];
    
    webViewController=nil;
    
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
                         
                         errorView.frame=CGRectMake(0, 57, 320, 40);
                         
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

- (IBAction)goBack:(id)sender {
    
    if([viewName isEqualToString:@"rem"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        TutorialViewController *tutroial = [[TutorialViewController alloc]initWithNibName:@"TutorialViewController" bundle:Nil];
        
        
        [self.navigationController pushViewController: tutroial animated:YES];
    }
}

-(void)fpAddressDidFetchLocationWithLocationArray:(NSArray *)locationArray
{
    storeLatitude=[[locationArray valueForKey:@"lat"] doubleValue];
    storeLongitude=[[locationArray valueForKey:@"lng"] doubleValue];
    [activity stopAnimating];
}

-(void)fpAddressDidFail
{
    
    [activity startAnimating];
    GetFpAddressDetails *_verifyAddress=[[GetFpAddressDetails alloc]init];
    _verifyAddress.delegate=self;
    [_verifyAddress downloadFpAddressDetails:city];
    
    
}
@end
