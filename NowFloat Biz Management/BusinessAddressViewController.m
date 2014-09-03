//
//  BusinessAddressViewController.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 31/01/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import "BusinessAddressViewController.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexaString.h"
#import "MyAnnotation.h"
#import "UpdateStoreData.h"
#import "Mixpanel.h"
#import "GetFpAddressDetails.h"
#import "BusinessAddress.h"
#import "BusinessAddressCell.h"
#import "businessAddressCell1.h"
#import "AlertViewController.h"

BOOL isMapClicked;
static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
NSMutableArray *countryListArray;


@interface BusinessAddressViewController ()<updateStoreDelegate,FpAddressDelegate,GMSMapViewDelegate>
{
    NSString *version;
    UIImageView *pinImageView;
    GMSMapView *storeMapView;
    CGFloat animatedDistance;
    NSString *addressUpdate;
    float viewHeight;
    UIBarButtonItem *rightBtnItem;
    NSString *fullAddress,*addressLine;
    NSString *country;
    NSString *uploadCity ;
    NSString *uploadPincode;
    NSString *uploadFulladdress;
    NSString *uploadCountry;
    NSString *uploadState;
    
    
    
    
}
@end

@implementation BusinessAddressViewController
@synthesize isFromOtherViews;
@synthesize countryPicker,countryPickerView;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewDidAppear:(BOOL)animated
{
  
    
    [self showAddress];
  
    if([appDelegate.storeDetailDictionary objectForKey:@"changedAddress"] != nil){
        
        [AlertViewController CurrentView:self.view errorString:@"Business Location Updated" size:0 success:YES];
        [self UpdateMapView];
    }
    else{
    
        [self showMapView];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
       appDelegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
  
        isMapClicked = YES;
    
       countryPickerView.frame = CGRectMake(0, 800, 320, 400);
    
    
    NSError *error;
    
    countryListArray=[[NSMutableArray alloc]init];
  
    
    NSString *filePathForCountries = [[NSBundle mainBundle] pathForResource:@"listofcountries" ofType:@"json"];
    
    NSString *myJSONString = [[NSString alloc] initWithContentsOfFile:filePathForCountries encoding:NSUTF8StringEncoding error:&error];
    
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[myJSONString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&error];
    
    NSMutableArray *countryJsonArray=[[NSMutableArray  alloc]initWithArray:[[json objectForKey:@"countries"]objectForKey:@"country"]];
    
    for (int i=0; i<[countryJsonArray count]; i++)
    {
        [countryListArray insertObject:[[countryJsonArray objectAtIndex:i]objectForKey:@"-name"] atIndex:i];
        
    }

    
        addressLine = [appDelegate.storeDetailDictionary objectForKey:@"Address"];
        addressLine = [addressLine stringByReplacingOccurrencesOfString:@"," withString:@""];
        addressLine = [addressLine stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
        if([appDelegate.storeDetailDictionary objectForKey:@"City"] == [NSNull null])
        {
        
        }
        else
        {
            addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[appDelegate.storeDetailDictionary objectForKey:@"City"]] withString:@""];
        }
        
        if([appDelegate.storeDetailDictionary objectForKey:@"PinCode"] == [NSNull null])
        {
        
        }
        else
        {
            addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[appDelegate.storeDetailDictionary objectForKey:@"PinCode"]] withString:@""];
        }
        
    
        if([appDelegate.storeDetailDictionary objectForKey:@"Country"] == [NSNull null])
        {
            
        }
        else
        {
            addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[appDelegate.storeDetailDictionary objectForKey:@"Country"]] withString:@""];
        }
    
    NSString *state = [[NSUserDefaults standardUserDefaults]stringForKey:@"state"];

    if([state isEqualToString:@""])
    {
        
    }
    else
    {
         addressLine = [addressLine stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults]stringForKey:@"state"]] withString:@""];
    }
    
    
    addressTextView.delegate = self;
    addressTextView.frame = CGRectMake(0, 2000, 320, 200);
    
    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    mixPanel.showNotificationOnActive = NO;
    
    version = [[UIDevice currentDevice] systemVersion];
    
    self.businessAddTable1.bounces =NO;
    self.businessAddTable2.bounces =NO;
    
    self.businessAddTable1.scrollEnabled = NO;
    self.businessAddTable1.scrollEnabled = NO;
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            // iPhone Classic
            viewHeight = 480;
            if(version.floatValue < 7.0)
            {
            [mapView setFrame:CGRectMake(0, 220, mapView.frame.size.width, mapView.frame.size.height+140)];
            self.businessAddTable1.frame = CGRectMake(self.businessAddTable1.frame.origin.x, self.businessAddTable1.frame.origin.y-20, self.businessAddTable1.frame.size.width, 180);
                
            self.businessAddTable2.frame = CGRectMake(self.businessAddTable2.frame.origin.x, self.businessAddTable2.frame.origin.y-20, self.businessAddTable2.frame.size.width, 178);
                
            self.locateLabel.frame = CGRectMake(self.locateLabel.frame.origin.x, self.locateLabel.frame.origin.y-24, self.locateLabel.frame.size.width, self.locateLabel.frame.size.height);
            }
            else
            {
            [mapView setFrame:CGRectMake(0,215, mapView.frame.size.width, mapView.frame.size.height+140)];
                
                self.businessAddTable1.frame = CGRectMake(self.businessAddTable1.frame.origin.x, self.businessAddTable1.frame.origin.y-10, self.businessAddTable1.frame.size.width, 180);
                
                self.businessAddTable2.frame = CGRectMake(self.businessAddTable2.frame.origin.x, self.businessAddTable2.frame.origin.y-10, self.businessAddTable2.frame.size.width, 178);
                
                self.locateLabel.frame = CGRectMake(self.locateLabel.frame.origin.x, self.locateLabel.frame.origin.y-24, self.locateLabel.frame.size.width, self.locateLabel.frame.size.height);
            }
            
            addressScrollView.contentSize=CGSizeMake(self.view.frame.size.width,result.height+160);

        }
        if(result.height == 568)
        {
            // iPhone 5
            //[addressScrollView setContentSize:CGSizeMake(320, 568)];
            viewHeight = 568;
            [mapView setFrame:CGRectMake(0,260, mapView.frame.size.width, mapView.frame.size.height+200)];
        }
    }

    
    
    
    if ([version floatValue]==7.0)
    {
        if(viewHeight  == 568)
        {
            [addressTextView  setTextContainerInset:UIEdgeInsetsMake(-5,0 , 0, 0)];
            
            self.automaticallyAdjustsScrollViewInsets=NO;
        }
        else
        {
            [addressTextView setContentInset:UIEdgeInsetsMake(-10,0 , 0, 0)];
        }
        
        

    }
    else
    {
        [addressTextView setContentInset:UIEdgeInsetsMake(-10,0 , 0, 0)];
        
    }

    [self.view setBackgroundColor:[UIColor colorWithHexString:@"dedede"]];
    
 

    version = [[UIDevice currentDevice] systemVersion];

    [addressTextView.layer setCornerRadius:6.0f];
    
    [addressTextView.layer setBorderWidth:1.0];
    
    [addressTextView.layer setBorderColor:[UIColor colorWithHexString:@"dcdcda"].CGColor];
    
    addressTextView.textColor=[UIColor colorWithHexString:@"9c9b9b"];
    
    [toolBar setHidden:YES];
    
    SWRevealViewController *revealController;
    
    if (!isFromOtherViews)
    {
        revealController = [self revealViewController];
        
        revealController.delegate=self;
        
        revealController.rightViewRevealWidth=0;
        
        revealController.rightViewRevealOverdraw=0;
    }

    /*Design the NavigationBar here*/
    
    if (version.floatValue<7.0)
    {
        self.navigationController.navigationBarHidden=NO;
        self.navigationItem.title=@"Business Address";

    
    }
    else
    {
        self.navigationItem.title=@"Business Address";
    }

    
    
    [self setRighttNavBarButton];
}

-(void)setRighttNavBarButton
{
    
    customRighNavButton=[UIButton buttonWithType:UIButtonTypeSystem];
    
    
    [customRighNavButton addTarget:self action:@selector(editAddress) forControlEvents:UIControlEventTouchUpInside];
    
    [customRighNavButton setTitle:@"Save" forState:UIControlStateNormal];
    [customRighNavButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    customRighNavButton.titleLabel.font = [UIFont fontWithName:@"Helvetica Neue-Regular" size:17.0f];
    
    
    if (version.floatValue<7.0) {
        
        [customRighNavButton setFrame:CGRectMake(260,21, 60, 30)];
        [navBar addSubview:customRighNavButton];
        UIBarButtonItem *rightBarBtn=[[UIBarButtonItem alloc]initWithCustomView:customRighNavButton];
        self.navigationItem.rightBarButtonItem=rightBarBtn;
        
    }
    else
    {
        [customRighNavButton setFrame:CGRectMake(260,21, 60, 30)];
        [navBar addSubview:customRighNavButton];
        UIBarButtonItem *rightBarBtn=[[UIBarButtonItem alloc]initWithCustomView:customRighNavButton];
        self.navigationItem.rightBarButtonItem=rightBarBtn;
    }
    
    [customRighNavButton setHidden:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(tableView==self.businessAddTable1)
    {
        return 1;
    }
    else
        
    return 2;
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    BusinessAddressCell *cell = [self.businessAddTable1 dequeueReusableCellWithIdentifier:@"businessAdd"];
    
    
    businessAddressCell1 *cell1 = [self.businessAddTable2 dequeueReusableCellWithIdentifier:@"businessAdd2"];
    
    if(tableView==self.businessAddTable1)
    {
    if(!cell)
    {
        [tableView registerNib:[UINib nibWithNibName:@"BusinessAddressCell" bundle:nil] forCellReuseIdentifier:@"businessAdd"];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"businessAdd"];
        
        cell.addressText.text = addressLine;
    }
    }
    
    if(tableView==self.businessAddTable2)
    {
        if(!cell1)
        {
            [tableView registerNib:[UINib nibWithNibName:@"businessAddressCell1" bundle:nil] forCellReuseIdentifier:@"businessAdd2"];
            
            cell1 = [tableView dequeueReusableCellWithIdentifier:@"businessAdd2"];
        }
        cell1.addressText1.delegate = self;
        cell1.addressText2.delegate = self;
        
        if(indexPath.row==0)
        {
            cell1.countryButton.hidden = YES;
            cell1.addressText2.hidden = NO;
            cell1.countrySelectIcon.hidden =YES;
            
            if([appDelegate.storeDetailDictionary objectForKey:@"City"] == [NSNull null])
            {
                    cell1.addressText1.placeholder = @"Town/City";
            }
            else
            {
                if([[appDelegate.storeDetailDictionary objectForKey:@"City"]isEqualToString:@""])
                {
                    cell1.addressText1.placeholder = @"Town/City";
                }
                else
                {
                    cell1.addressText1.text=[appDelegate.storeDetailDictionary objectForKey:@"City"];
                }
            }
            
            if([appDelegate.storeDetailDictionary objectForKey:@"PinCode"] == [NSNull null])
            {
                cell1.addressText2.placeholder = @"Pincode/Zipcode";
            }
            else
            {
                if([[appDelegate.storeDetailDictionary objectForKey:@"PinCode"]isEqualToString:@""])
                {
                    cell1.addressText2.placeholder = @"Pincode/Zipcode";
                }
                else
                {
                    cell1.addressText2.text=[appDelegate.storeDetailDictionary objectForKey:@"PinCode"];
                }
            }
            
            
        
        
        }
        if(indexPath.row==1)
        {
             cell1.countryButton.hidden = NO;
             cell1.addressText2.hidden = YES;
            cell1.countrySelectIcon.hidden =NO;
            [cell1.countryButton addTarget:self action:@selector(selectCountry) forControlEvents:UIControlEventTouchUpInside];
            if([appDelegate.storeDetailDictionary objectForKey:@"Country"] == [NSNull null])
            {
                [cell1.countryButton setTitle:@"Country" forState:UIControlStateNormal];
                [cell1.countryButton setAlpha:0.5];
            }
            else
            {
                if([[appDelegate.storeDetailDictionary objectForKey:@"Country"]isEqualToString:@""])
                {
                   [cell1.countryButton setAlpha:0.5];
                    [cell1.countryButton setTitle:@"Country" forState:UIControlStateNormal];
                }
                else
                {
                    [cell1.countryButton setAlpha:0.5];
                    [cell1.countryButton setTitle:[appDelegate.storeDetailDictionary objectForKey:@"Country"] forState:UIControlStateNormal];
                }
            }
        
            NSString *state = [[NSUserDefaults standardUserDefaults]stringForKey:@"state"];
            if([state isEqualToString:@""] || state == nil)
            {
               
                cell1.addressText1.placeholder = @"State";
            }
            else
            {
              
                 cell1.addressText1.text =state;
            }
            
       
        }
        
        return cell1;
    }

    return cell;
    
   
    
    
}



-(void)showAddress
{
    if ([appDelegate.storeDetailDictionary objectForKey:@"Address"]!=[NSNull null])
    {
        
        addressTextView.text=[appDelegate.storeDetailDictionary objectForKey:@"Address"];
        
        NSString *spList=addressTextView.text;
        NSArray *list = [spList componentsSeparatedByString:@","];
        
        addressTextView.text=[NSString stringWithFormat:@"%@",list];
        
        addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@"(" withString:@""];
        addressTextView.text=[addressTextView.text stringByReplacingOccurrencesOfString:@")" withString:@""];
        
        addressTextView.text=[addressTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
    }
    else
    {
        addressTextView.text=@"No Description";
    }
    
}



-(void)showMapView
{
    
    CLLocationCoordinate2D center;
    
    center.latitude=[[appDelegate.storeDetailDictionary objectForKey:@"lat"] doubleValue];
    
    center.longitude=[[appDelegate.storeDetailDictionary objectForKey:@"lng"] doubleValue];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:center.latitude
                                                            longitude:center.longitude
                                                                 zoom:18];
    storeMapView = [GMSMapView mapWithFrame:CGRectMake(0,0, mapView.frame.size.width, mapView.frame.size.height) camera:camera];
    
    storeMapView.delegate = self;
    
    pinImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mappin12.png"]];
    
    pinImageView.center = storeMapView.center;
    
    [storeMapView addSubview:pinImageView];
    
    [mapView insertSubview:storeMapView atIndex:0];
    
    [self.view addSubview:mapView];
    
    
}

-(void)UpdateMapView
{
    CLLocationCoordinate2D center;
    [appDelegate.storeDetailDictionary removeObjectForKey:@"changedAddress"];
    center.latitude=[[appDelegate.storeDetailDictionary objectForKey:@"lat"] doubleValue];
    center.longitude=[[appDelegate.storeDetailDictionary objectForKey:@"lng"] doubleValue];
    GMSCameraUpdate *cams = [GMSCameraUpdate setTarget:center zoom:18];
    storeMapView.delegate = self;
    [storeMapView animateWithCameraUpdate:cams];
    
   
}


#pragma mark - Textview Delegate methods.
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    [toolBar setHidden:NO];
    textView.inputAccessoryView = toolBar;
    customRighNavButton.hidden = NO;
    return YES;
}


-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    
    rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customRighNavButton];
    self.navigationItem.rightBarButtonItem = rightBtnItem;
    customRighNavButton.hidden = NO;
    return YES;
}


-(void)textViewDidBeginEditing:(UITextView *)textView
{
    CGRect textFieldRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator = midline - viewRect.origin.y - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION) * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    
    if(heightFraction < 0.0){
        
        heightFraction = 0.0;
        
    }else if(heightFraction > 1.0){
        
        heightFraction = 1.0;
    }
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if(orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown){
        
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
        
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
}


-(void)textViewDidEndEditing:(UITextView *)textView
{
    //[toolBar setHidden:YES];
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
   
    return YES;
}




#pragma mark - GMSMapView Delegate methods.



-(void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position
{
  
}




-(void)makeAddressEditable:(id)sender
{
    [addressTextView becomeFirstResponder];
}


-(void)editAddress
{
   
    
    BusinessAddressCell *theCell;
    theCell = (id)[self.businessAddTable1 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    uploadFulladdress = theCell.addressText.text;
    
    
    for (int i=0; i <3; i++){
        
        businessAddressCell1 *theCell;
        theCell = (id)[self.businessAddTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [theCell.addressText1 resignFirstResponder];
        [theCell.addressText2 resignFirstResponder];
        
        
        if (i==0)
        {
            uploadCity           = theCell.addressText1.text;
            uploadPincode            = theCell.addressText2.text;
            
        }
        if (i==1)
        {
            uploadState              = theCell.addressText1.text;
            uploadCountry            = theCell.addressText2.text;
            
        }
        if (i==2)
        {
            
            
        }
        
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:uploadState forKey:@"state"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    
    uploadState = [[NSUserDefaults standardUserDefaults]stringForKey:@"state"];
    
    
    fullAddress = [uploadFulladdress stringByAppendingString:[NSString stringWithFormat:@",%@,%@-%@,%@",uploadCity,uploadState,uploadPincode,uploadCountry]];
    
    
    fullAddress=[fullAddress stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    fullAddress=[fullAddress stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    fullAddress=[fullAddress stringByReplacingOccurrencesOfString:@"(" withString:@""];
    fullAddress=[fullAddress stringByReplacingOccurrencesOfString:@")" withString:@""];
    NSError *error = nil;
    
    NSRegularExpression *regexComma = [NSRegularExpression regularExpressionWithPattern:@", +" options:NSRegularExpressionCaseInsensitive error:&error];
    
    fullAddress = [regexComma stringByReplacingMatchesInString:fullAddress options:0 range:NSMakeRange(0, [fullAddress length]) withTemplate:@" ,"];
    
     NSRegularExpression *regexSpace = [NSRegularExpression regularExpressionWithPattern:@"  +" options:NSRegularExpressionCaseInsensitive error:&error];
    
    fullAddress = [regexSpace stringByReplacingMatchesInString:fullAddress options:0 range:NSMakeRange(0, [fullAddress length]) withTemplate:@" "];
    
    
   fullAddress = [fullAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if(viewHeight == 568)
    {
       
    }
    else
    {
        [customButton setHidden:NO];
    }
    
    
        GetFpAddressDetails *_verifyAddress=[[GetFpAddressDetails alloc]init];
        
        _verifyAddress.delegate=self;
        
        [_verifyAddress downloadFpAddressDetails:fullAddress];
   
}


#pragma FpAddressDelegate

-(void)fpAddressDidFetchLocationWithLocationArray:(NSArray *)locationArray
{
    
    storeLatitude=[[locationArray valueForKey:@"lat"] doubleValue];
    storeLongitude=[[locationArray valueForKey:@"lng"] doubleValue];
    
    @try {
        
        [appDelegate.storeDetailDictionary setValue:fullAddress forKey:@"Address"];
        [appDelegate.storeDetailDictionary setValue:[NSNumber numberWithDouble:storeLatitude] forKey:@"lat"];
        [appDelegate.storeDetailDictionary setValue:[NSNumber numberWithDouble:storeLongitude] forKey:@"lng"];
        addressUpdate = addressTextView.text;
        
        [self UpdateMapView];
        [self showAddress];
        [self updateAddress];
        
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
    
}


-(void)fpAddressDidFail
{
   
    
    [AlertViewController CurrentView:self.view errorString:@"Sorry. We are unable to locate you on the map. Please try again" size:0 success:NO];
    
   
}



-(void)updateAddress
{
    
   
    
    NSMutableArray *uploadArray=[[NSMutableArray alloc]init];
    
    UpdateStoreData *strData=[[UpdateStoreData  alloc]init];
    
    strData.delegate=self;

    
    BusinessAddressCell *theCell;
    theCell = (id)[self.businessAddTable1 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    
    uploadFulladdress = theCell.addressText.text;
    
    
    for (int i=0; i <3; i++){
        
        businessAddressCell1 *theCell;
        theCell = (id)[self.businessAddTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        [theCell.addressText1 resignFirstResponder];
        [theCell.addressText2 resignFirstResponder];
        
        
        if (i==0)
        {
            uploadCity           = theCell.addressText1.text;
            uploadPincode            = theCell.addressText2.text;
            
        }
        if (i==1)
        {
            uploadState              = theCell.addressText1.text;
            uploadCountry            = theCell.countryButton.titleLabel.text;
            
        }
        if (i==2)
        {
            
            
        }
        
    }
    
    NSArray *countryCodes = [NSLocale ISOCountryCodes];
    NSMutableArray *countries = [NSMutableArray arrayWithCapacity:[countryCodes count]];
    
    for (NSString *countryCode in countryCodes)
    {
        NSString *identifier = [NSLocale localeIdentifierFromComponents: [NSDictionary dictionaryWithObject: countryCode forKey: NSLocaleCountryCode]];
        NSString *newcountry = [[[NSLocale alloc] initWithLocaleIdentifier:@"en_UK"] displayNameForKey: NSLocaleIdentifier value: identifier];
        [countries addObject: newcountry];
    }
    
    NSDictionary *codeForCountryDictionary = [[NSDictionary alloc] initWithObjects:countryCodes forKeys:countries];
    NSDictionary *dictDialingCodes = [[NSDictionary alloc]initWithObjectsAndKeys:
                                      @"972", @"IL",
                                      @"93", @"AF",
                                      @"355", @"AL",
                                      @"213", @"DZ",
                                      @"1", @"AS",
                                      @"376", @"AD",
                                      @"244", @"AO",
                                      @"1", @"AI",
                                      @"1", @"AG",
                                      @"54", @"AR",
                                      @"374", @"AM",
                                      @"297", @"AW",
                                      @"61", @"AU",
                                      @"43", @"AT",
                                      @"994", @"AZ",
                                      @"1", @"BS",
                                      @"973", @"BH",
                                      @"880", @"BD",
                                      @"1", @"BB",
                                      @"375", @"BY",
                                      @"32", @"BE",
                                      @"501", @"BZ",
                                      @"229", @"BJ",
                                      @"1", @"BM", @"975", @"BT",
                                      @"387", @"BA", @"267", @"BW", @"55", @"BR", @"246", @"IO",
                                      @"359", @"BG", @"226", @"BF", @"257", @"BI", @"855", @"KH",
                                      @"237", @"CM", @"1", @"CA", @"238", @"CV", @"345", @"KY",
                                      @"236", @"CF", @"235", @"TD", @"56", @"CL", @"86", @"CN",
                                      @"61", @"CX", @"57", @"CO", @"269", @"KM", @"242", @"CG",
                                      @"682", @"CK", @"506", @"CR", @"385", @"HR", @"53", @"CU",
                                      @"537", @"CY", @"420", @"CZ", @"45", @"DK", @"253", @"DJ",
                                      @"1", @"DM", @"1", @"DO", @"593", @"EC", @"20", @"EG",
                                      @"503", @"SV", @"240", @"GQ", @"291", @"ER", @"372", @"EE",
                                      @"251", @"ET", @"298", @"FO", @"679", @"FJ", @"358", @"FI",
                                      @"33", @"FR", @"594", @"GF", @"689", @"PF", @"241", @"GA",
                                      @"220", @"GM", @"995", @"GE", @"49", @"DE", @"233", @"GH",
                                      @"350", @"GI", @"30", @"GR", @"299", @"GL", @"1", @"GD",
                                      @"590", @"GP", @"1", @"GU", @"502", @"GT", @"224", @"GN",
                                      @"245", @"GW", @"595", @"GY", @"509", @"HT", @"504", @"HN",
                                      @"36", @"HU", @"354", @"IS", @"91", @"IN", @"62", @"ID",
                                      @"964", @"IQ", @"353", @"IE", @"972", @"IL", @"39", @"IT",
                                      @"1", @"JM", @"81", @"JP", @"962", @"JO", @"77", @"KZ",
                                      @"254", @"KE", @"686", @"KI", @"965", @"KW", @"996", @"KG",
                                      @"371", @"LV", @"961", @"LB", @"266", @"LS", @"231", @"LR",
                                      @"423", @"LI", @"370", @"LT", @"352", @"LU", @"261", @"MG",
                                      @"265", @"MW", @"60", @"MY", @"960", @"MV", @"223", @"ML",
                                      @"356", @"MT", @"692", @"MH", @"596", @"MQ", @"222", @"MR",
                                      @"230", @"MU", @"262", @"YT", @"52", @"MX", @"377", @"MC",
                                      @"976", @"MN", @"382", @"ME", @"1", @"MS", @"212", @"MA",
                                      @"95", @"MM", @"264", @"NA", @"674", @"NR", @"977", @"NP",
                                      @"31", @"NL", @"599", @"AN", @"687", @"NC", @"64", @"NZ",
                                      @"505", @"NI", @"227", @"NE", @"234", @"NG", @"683", @"NU",
                                      @"672", @"NF", @"1", @"MP", @"47", @"NO", @"968", @"OM",
                                      @"92", @"PK", @"680", @"PW", @"507", @"PA", @"675", @"PG",
                                      @"595", @"PY", @"51", @"PE", @"63", @"PH", @"48", @"PL",
                                      @"351", @"PT", @"1", @"PR", @"974", @"QA", @"40", @"RO",
                                      @"250", @"RW", @"685", @"WS", @"378", @"SM", @"966", @"SA",
                                      @"221", @"SN", @"381", @"RS", @"248", @"SC", @"232", @"SL",
                                      @"65", @"SG", @"421", @"SK", @"386", @"SI", @"677", @"SB",
                                      @"27", @"ZA", @"500", @"GS", @"34", @"ES", @"94", @"LK",
                                      @"249", @"SD", @"597", @"SR", @"268", @"SZ", @"46", @"SE",
                                      @"41", @"CH", @"992", @"TJ", @"66", @"TH", @"228", @"TG",
                                      @"690", @"TK", @"676", @"TO", @"1", @"TT", @"216", @"TN",
                                      @"90", @"TR", @"993", @"TM", @"1", @"TC", @"688", @"TV",
                                      @"256", @"UG", @"380", @"UA", @"971", @"AE", @"44", @"GB",
                                      @"1", @"US", @"598", @"UY", @"998", @"UZ", @"678", @"VU",
                                      @"681", @"WF", @"967", @"YE", @"260", @"ZM", @"263", @"ZW",
                                      @"591", @"BO", @"673", @"BN", @"61", @"CC", @"243", @"CD",
                                      @"225", @"CI", @"500", @"FK", @"44", @"GG", @"379", @"VA",
                                      @"852", @"HK", @"98", @"IR", @"44", @"IM", @"44", @"JE",
                                      @"850", @"KP", @"82", @"KR", @"856", @"LA", @"218", @"LY",
                                      @"853", @"MO", @"389", @"MK", @"691", @"FM", @"373", @"MD",
                                      @"258", @"MZ", @"970", @"PS", @"872", @"PN", @"262", @"RE",
                                      @"7", @"RU", @"590", @"BL", @"290", @"SH", @"1", @"KN",
                                      @"1", @"LC", @"590", @"MF", @"508", @"PM", @"1", @"VC",
                                      @"239", @"ST", @"252", @"SO", @"47", @"SJ", @"963",
                                      @"SY",@"886",
                                      @"TW", @"255",
                                      @"TZ", @"670",
                                      @"TL",@"58",
                                      @"VE",@"84",
                                      @"VN",
                                      @"284", @"VG",
                                      @"340", @"VI",
                                      @"678",@"VU",
                                      @"681",@"WF",
                                      @"685",@"WS",
                                      @"967",@"YE",
                                      @"262",@"YT",
                                      @"27",@"ZA",
                                      @"260",@"ZM",
                                      @"263",@"ZW",
                                      nil];
    
    NSString *countryCode = [codeForCountryDictionary objectForKey:uploadCountry];
    
    
    NSString *countryCodeVal = [NSString stringWithFormat:@"+%@",[dictDialingCodes objectForKey:countryCode]];
    
    
    
   NSString *uploadString=[NSString stringWithFormat:@"%f,%f",storeLatitude ,storeLongitude];
    NSDictionary *upLoadDictionary=@{@"value":uploadString,@"key":@"GEOLOCATION"};
    NSDictionary *uploadAddressDictionary1 = @{@"value":uploadCity,@"key":@"CITY"};
    NSDictionary *uploadAddressDictionary2 = @{@"value":uploadCountry,@"key":@"COUNTRY"};
    NSDictionary *uploadAddressDictionary3 = @{@"value":uploadPincode,@"key":@"PINCODE"};
    NSDictionary *uploadAddressDictionary4 = @{@"value":fullAddress,@"key":@"ADDRESS"};
    
    [uploadArray addObject:upLoadDictionary];
    [uploadArray addObject:uploadAddressDictionary1];
    [uploadArray addObject:uploadAddressDictionary2];
    [uploadArray addObject:uploadAddressDictionary3];
    [uploadArray addObject:uploadAddressDictionary4];
    [strData updateStore:uploadArray];
}


-(void)storeUpdateComplete
{
    
    Mixpanel *mixPanel=[Mixpanel sharedInstance];
    
    [mixPanel track:@"update_Business Address"];
    [customButton setHidden:YES];
    [AlertViewController CurrentView:self.view errorString:@"Business Address Updated" size:0 success:YES];
    
    [appDelegate.storeDetailDictionary setObject:uploadCountry forKey:@"Country"];
    [appDelegate.storeDetailDictionary setObject:uploadPincode forKey:@"PinCode"];
    [appDelegate.storeDetailDictionary setObject:uploadCity forKey:@"City"];

    
}


-(void)storeUpdateFailed
{

    
    [AlertViewController CurrentView:self.view errorString:@"Business Address could not be updated" size:0 success:NO];
    
}


#pragma SWRevealViewControllerDelegate


- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    if ( position == FrontViewPositionLeft ) str = @"FrontViewPositionLeft";
    else if ( position == FrontViewPositionRight ) str = @"FrontViewPositionRight";
    else if ( position == FrontViewPositionRightMost ) str = @"FrontViewPositionRightMost";
    else if ( position == FrontViewPositionRightMostRemoved ) str = @"FrontViewPositionRightMostRemoved";
    
    else if ( position == FrontViewPositionLeftSide ) str = @"FrontViewPositionLeftSide";
    
    else if ( position == FrontViewPositionLeftSideMostRemoved ) str = @"FrontViewPositionLeftSideMostRemoved";
    
    return str;
}




-(void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    BusinessAddress *businessMapView = [[BusinessAddress alloc] initWithNibName:@"BusinessAddress" bundle:nil];
    isMapClicked = NO;
   
    [self presentViewController:businessMapView animated:YES completion:nil];
}


- (IBAction)cancelButton:(id)sender
{
    [self.view endEditing:YES];
}

-(IBAction)cancelToolBarButton:(id)sender{
    [self cancelButton:nil];
}

-(IBAction)doneToolBarButton:(id)sender
{
    [self doneButton:nil];
}

- (IBAction)doneButton:(id)sender
{
    [addressTextView resignFirstResponder];
    
    if(viewHeight == 568)
    {
        rightBtnItem = nil;
        customButton.hidden = NO;
        rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
        self.navigationItem.rightBarButtonItem = rightBtnItem;
    }
    else
    {
        if(version.floatValue < 7.0)
        {
           
            [customButton setHidden:NO];
        }
        else
        {
            rightBtnItem = nil;
            customButton.hidden = NO;
            rightBtnItem = [[UIBarButtonItem alloc] initWithCustomView:customButton];
            self.navigationItem.rightBarButtonItem = rightBtnItem;
        }
        
    }
}



- (IBAction)revealFrontController:(id)sender
{
    
    SWRevealViewController *revealController = [self revealViewController];
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeftSide"]) {
        
        [revealController performSelector:@selector(rightRevealToggle:)];
        
    }
    
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionRight"]) {
        
        [revealController performSelector:@selector(revealToggle:)];
        
    }
    
}


- (void)revealController:(SWRevealViewController *)revealController didMoveToPosition:(FrontViewPosition)position;
{
    
    frontViewPosition=[self stringFromFrontViewPosition:position];
    
    //FrontViewPositionLeft
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeftSide"])
    {
        
        [revealFrontControllerButton setHidden:NO];
        
    }
    
    //FrontViewPositionCenter
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeft"]) {
        
        [revealFrontControllerButton setHidden:YES];
        
    }
    
    //FrontViewPositionRight
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionRight"])
    {
        [revealFrontControllerButton setHidden:NO];        
    }
    
}







-(void)backBtnClicked
{
    if (isFromOtherViews) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillDisappear:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (version.floatValue<7.0)
    {
        if(isMapClicked)
        {
        self.navigationController.navigationBarHidden=YES;
           
        }
         isMapClicked = YES;
    }
    
    
}
- (void)viewDidUnload
{
    addressTextView = nil;
    [super viewDidUnload];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)_pickerView;
{
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)_pickerView numberOfRowsInComponent:(NSInteger)component;
{
    
return countryListArray.count;
    
}


- (NSString *)pickerView:(UIPickerView *)_pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *text;
    text=[countryListArray objectAtIndex: row];
    return text;
    
}


- (void)pickerView:(UIPickerView *)_pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
{
    
    country = [countryListArray objectAtIndex: row];
    
    
}

-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 35;
}

-(void)selectCountry
{
    [self.view endEditing:YES];
//    countryPickerView.frame = CGRectMake(0, 320, 320, 400);
//    [self.view addSubview:countryPickerView];
}


- (IBAction)cancelCountry:(id)sender {
    
    countryPickerView.frame = CGRectMake(0, 800, 320, 400);
}

- (IBAction)doneCountry:(id)sender {
    
    countryPickerView.frame = CGRectMake(0, 800, 320, 400);
    for (int i=0; i <3; i++){
        
        businessAddressCell1 *theCell;
        theCell = (id)[self.businessAddTable2 cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        
        
        if (i==1)
        {
            
            [theCell.countryButton setTitle:[NSString stringWithFormat:@"%@",country] forState:UIControlStateNormal];
            
        }
        
        
    }
    
    customRighNavButton.hidden=NO;

}
@end
