//
//  SitemeterDetailView.m
//  NowFloats Biz Management
//
//  Created by Ravindra Naik on 25/08/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "SitemeterDetailView.h"
#import "sitemetercell.h"
#import "ProgressCell.h"
#import "UIColor+HexaString.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import "BusinessAddressViewController.h"
#import "BusinessDetailsViewController.h"
#import "PrimaryImageViewController.h"
#import "BusinessContactViewController.h"
#import "BusinessHoursViewController.h"
#import "SettingsViewController.h"
#import "BizMessageViewController.h"
#import "BuyStoreWidget.h"
#import "BizStoreDetailViewController.h"
#import "BizStoreViewController.h"
#import "Mixpanel.h"
#import <Social/Social.h>

@interface SitemeterDetailView ()<UIActionSheetDelegate,BuyStoreWidgetDelegate>
{
    float viewHeight;
    
    int percentageComplete;
    
    float percentComplete;
    
    UIImage *primaryImage;
    
    NSMutableArray *percentageArray, *headArray, *descArray;
    
    NSMutableArray *completedHeadArray, *completedPercentageArray, *completedDescArray;
}

@end

@implementation SitemeterDetailView

@synthesize picker = _picker;

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
    percentageComplete = 0;
    
    percentComplete = 0.0;
    
    [self siteMeter];
    
    [mainTableView reloadData];
    
    
}

-(void)siteMeter
{
    [descArray removeAllObjects];
    [headArray removeAllObjects];
    [completedDescArray removeAllObjects];
    [completedHeadArray removeAllObjects];
    [percentageArray removeAllObjects];
    [completedPercentageArray removeAllObjects];
    
    if([appDelegate.businessName length] == 0)
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Business Name"];
        [descArray addObject:@"Add Business Name"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Business Name"];
        [completedDescArray addObject:@"Add Business Name"];
    }
    
    if([appDelegate.businessDescription length] == 0)
    {
        [percentageArray addObject:@"+10%"];
        [headArray addObject:@"Business Description"];
        [descArray addObject:@"Describe your business"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"+10%"];
        [completedHeadArray addObject:@"Business Description"];
        [completedDescArray addObject:@"Describe your business"];
    }
    
    if([appDelegate.storeCategoryName length] == 0)
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Business Category"];
        [descArray addObject:@"Choose a Business Category"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Business Category"];
        [completedDescArray addObject:@"Choose a Business Category"];
    }
    
    if([appDelegate.primaryImageUri length] == 0)
    {
        [percentageArray addObject:@"+10%"];
        [headArray addObject:@"Featured Image"];
        [descArray addObject:@"Add a relevant Image"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"+10%"];
        [completedHeadArray addObject:@"Featured Image"];
        [completedDescArray addObject:@"Add a relevant Image"];
    }
    
    if([appDelegate.storeDetailDictionary objectForKey:@"PrimaryNumber"] == NULL)
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Phone Number"];
        [descArray addObject:@"Help customers reach you instantly"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Phone Number"];
        [completedDescArray addObject:@"Help customers reach you instanlty"];
    }
    if([appDelegate.storeDetailDictionary objectForKey:@"Email"] == NULL)
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Email"];
        [descArray addObject:@"Add Email"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Email"];
        [completedDescArray addObject:@"Add Email"];
    }
    if([appDelegate.storeDetailDictionary objectForKey:@"Address"] == NULL)
    {
        [percentageArray addObject:@"+10%"];
        [headArray addObject:@"Help your customers find you"];
        [descArray addObject:@"Add Business Address"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"+10%"];
        [completedHeadArray addObject:@"Help your customers find you"];
        [completedDescArray addObject:@"Add Business Address"];
    }
    if(![appDelegate.storeWidgetArray containsObject:@"TIMINGS"])
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Business Hours"];
        [descArray addObject:@"Display Business timings"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Business Hours"];
        [completedDescArray addObject:@"Display Business timings"];
    }
    
    if([appDelegate.socialNetworkNameArray count]==0)
    {
        [percentageArray addObject:@"+10%"];
        [headArray addObject:@"Get Social"];
        [descArray addObject:@"Connect to Facebook / Twitter"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"+10%"];
        [completedHeadArray addObject:@"Get Social"];
        [completedDescArray addObject:@"Connect to Facebook / Twitter"];
    }
    if([appDelegate.dealDescriptionArray count] < 5)
    {
        if([appDelegate.dealDescriptionArray count] == 0)
        {
            [percentageArray addObject:@"+15%"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Message regularly & relevantly"];
        }
        else if([appDelegate.dealDescriptionArray count] == 1)
        {
            [percentageArray addObject:@"+12%"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Message regularly & relevantly"];
            
            
            percentageComplete += 3;
            percentComplete += 0.03;
            [completedPercentageArray addObject:@"+3%"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Message regularly & relevantly"];
        }
        else if([appDelegate.dealDescriptionArray count] == 2)
        {
            [percentageArray addObject:@"+9%"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Message regularly & relevantly"];
            
            percentageComplete += 6;
            percentComplete += 0.06;
            [completedPercentageArray addObject:@"+6%"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Message regularly & relevantly"];
        }
        else if([appDelegate.dealDescriptionArray count] == 3)
        {
            [percentageArray addObject:@"+6%"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Message regularly & relevantly"];
            
            
            percentageComplete += 9;
            percentComplete += 0.09;
            [completedPercentageArray addObject:@"+9%"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Message regularly & relevantly"];
        }
        else if([appDelegate.dealDescriptionArray count] == 1)
        {
            [percentageArray addObject:@"+3%"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Message regularly & relevantly"];
            
            percentageComplete += 12;
            percentComplete += 0.12;
            [completedPercentageArray addObject:@"+12%"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Message regularly & relevantly"];
        }
        
        
    }
    else
    {
        percentageComplete += 15;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"+15%"];
        [completedHeadArray addObject:@"Post 5 Updates"];
        [completedDescArray addObject:@"Message regularly & relevantly"];
    }
    if(![appDelegate.storeWidgetArray containsObject:@"SITESENSE"])
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Get Discovered"];
        [descArray addObject:@"Activate Auto-SEO for Free!"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Get Discovered"];
        [completedDescArray addObject:@"Activate Auto-SEO for Free!"];
    }
    if([appDelegate.storeRootAliasUri isEqualToString:@""])
    {
        [percentageArray addObject:@"+10%"];
        [headArray addObject:@"Get your own identity"];
        [descArray addObject:@"Buy a .com"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"+10%"];
        [completedHeadArray addObject:@"Get your own identity"];
        [completedDescArray addObject:@"Buy a .com"];
    }
    
    if([userDetails objectForKey:@"hasShared"] == [NSNumber numberWithBool:YES])
    {
        
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"+5%"];
        [completedHeadArray addObject:@"Share"];
        [completedDescArray addObject:@"Promote your website"];
        
    }
    else
    {
        [percentageArray addObject:@"+5%"];
        [headArray addObject:@"Share"];
        [descArray addObject:@"Promote your website"];
    }

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    version = [[UIDevice currentDevice] systemVersion];
    
    
     self.navigationItem.title = @"Site Score";
    
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
    
    
    
    percentageArray = [[NSMutableArray alloc] init];
    
    headArray = [[NSMutableArray alloc] init];
    
    descArray = [[NSMutableArray alloc] init];
    
    completedDescArray = [[NSMutableArray alloc] init];
    
    completedHeadArray = [[NSMutableArray alloc] init];
    
    completedPercentageArray = [[NSMutableArray alloc] init];
    

    
    
    primaryImage = [[UIImage alloc] init];
    
    userDetails=[NSUserDefaults standardUserDefaults];
    

    
    

    // Do any additional setup after loading the view from its nib.
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    @try {
        
        if(section == 0)
        {
            return 1;
        }
        else if(section == 1)
        {
            return headArray.count;
        }
        else
        {
            return completedHeadArray.count;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in number of rows is %@", exception);
    }
    
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section==0)
    {
        return 115;
    }
    
    else
    {
        return 60;
    }
        
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0)
    {
        return 0;
    }
    else if(section == 1)
    {
        return 25;
    }
    else
    {
        return 0;
    }
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
        static NSString *simpleTableIdentifier = @"Sitemetercell";
        
        sitemetercell *cell = (sitemetercell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
        if (cell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"sitemetercell" owner:self options:nil];
            cell = [nib objectAtIndex:0];
            
        }
        
        
        

    @try
    {
      

        if(indexPath.section == 0)
        {
            ProgressCell *theCell = (ProgressCell *)[tableView dequeueReusableCellWithIdentifier:@"ProgressCell"];
            if(theCell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ProgressCell" owner:self options:nil];
                theCell = [nib objectAtIndex:0];
            }
            
            theCell.selectionStyle = UITableViewCellSelectionStyleNone;
            if(indexPath.row ==0)
            {
                theCell.frame = CGRectMake(theCell.frame.origin.x, theCell.frame.origin.y, 320, 60);
                theCell.progressText.text = [NSString stringWithFormat:@"%d%@ Site Complete",percentageComplete,@"%"];
                //theCell.progressText.font = [UIFont fontWithName:@"HelveticaNueu" size:13];
            
                
                theCell.myProgressView.progress = percentComplete;
                CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 15.0f);
                theCell.myProgressView.transform = transform;
               
                
                
                return theCell;
            }
        }
        else
        {
            static NSString *simpleTableIdentifier = @"Sitemetercell";
            
            sitemetercell *cell = (sitemetercell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
            if (cell == nil)
            {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"sitemetercell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
                
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            if (indexPath.section == 1)
            {
                
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
                cell.percentage.textColor = [UIColor colorFromHexCode:@"#ffb900"];
             
                
                cell.headText.textColor = [UIColor colorFromHexCode:@"#6e6e6e"];
               
                
                cell.descriptionText.textColor= [UIColor colorFromHexCode:@"#8f8f8f"];
              
                cell.descriptionText.numberOfLines = 2;
                
                cell.arrowImage.image = [UIImage imageNamed:@"Arrow.png"];
                
                cell.percentage.text = [percentageArray objectAtIndex:indexPath.row];
                cell.headText.text = [headArray objectAtIndex:indexPath.row];
                cell.descriptionText.text = [descArray objectAtIndex:indexPath.row];
                
            }
            else if (indexPath.section == 2)
            {
                
                cell.accessoryType = UITableViewCellAccessoryNone;

                
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                cell.percentage.textColor = [UIColor colorFromHexCode:@"#b0b0b0"];
                
                cell.headText.textColor = [UIColor colorFromHexCode:@"#b0b0b0"];
           
                
                cell.descriptionText.textColor= [UIColor colorFromHexCode:@"#b0b0b0"];
              
                cell.descriptionText.numberOfLines = 2;
                
                cell.arrowImage.image = [UIImage imageNamed:@"Arrow.png"];
                
                cell.percentage.text = [completedPercentageArray objectAtIndex:indexPath.row];
                cell.headText.text = [completedHeadArray objectAtIndex:indexPath.row];
                cell.descriptionText.text = [completedDescArray objectAtIndex:indexPath.row];
            }
            cell.contentView.backgroundColor = [UIColor whiteColor];
            return cell;
        }
   
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in cell for row is %@", exception);
    }
}




-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try
    {
        
        if(indexPath.section == 1)
        {
            sitemetercell *theSelectedCell = (sitemetercell *) [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section]];
                    
            [self selectedAction:theSelectedCell.headText.text];
                
                  
        }
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in selecting cells is %@",exception);
    }
    
}

-(void)selectedAction:(NSString *)actionText
{
    if([actionText isEqualToString:@"Business Name"])
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Business name Site meter detail clicked"];
        
        BusinessDetailsViewController *businessName=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessName animated:YES completion:nil];
    }
    else if([actionText isEqualToString:@"Business Description"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Business Description Site meter detail clicked"];
        
        BusinessDetailsViewController *businessDesc=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessDesc animated:YES completion:nil];
        
    }
    else if ([actionText isEqualToString:@"Business Category"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Business Category Site meter detail clicked"];
        
        BusinessDetailsViewController *businessCat=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessCat animated:YES completion:nil];
    }
    else if ([actionText isEqualToString:@"Featured Image"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Featured Image Site meter detail clicked"];
        
        BusinessDetailsViewController *businessName=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessName animated:YES completion:nil];
        
    }
    else if ([actionText isEqualToString:@"Phone Number"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Mobile number add Site meter detail clicked"];
        
        BusinessContactViewController *mobileNumber=[[BusinessContactViewController alloc]initWithNibName:@"BusinessContactViewController" bundle:Nil];
        
        [self.navigationController pushViewController:mobileNumber animated:YES];
    }
    else if ([actionText isEqualToString:@"Email"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Add Business email Site meter detail clicked"];
        
        BusinessContactViewController *email=[[BusinessContactViewController alloc]initWithNibName:@"BusinessContactViewController" bundle:Nil];
        
        [self.navigationController pushViewController:email animated:YES];
    }
    else if ([actionText isEqualToString:@"Help your customers find you"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Business Address Site meter detail clicked"];
        
        BusinessAddressViewController *businessAddress=[[BusinessAddressViewController alloc]initWithNibName:@"BusinessAddressViewController" bundle:Nil];
        
        [self.navigationController pushViewController:businessAddress animated:YES];
        
    }
    else if ([actionText isEqualToString:@"Business Hours"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Business hours Site meter detail clicked"];
        
        if(![[appDelegate.storeDetailDictionary objectForKey:@"CountryPhoneCode"]  isEqual: @"91"])
        {
            
            BizStoreDetailViewController *storedetailViewController=[[BizStoreDetailViewController alloc]initWithNibName:@"BizStoreDetailViewController" bundle:Nil];
            
            storedetailViewController.selectedWidget = 1006;
            
            [self.navigationController pushViewController:storedetailViewController animated:YES];
        }
        else
        {
            BizStoreViewController *storeView = [[BizStoreViewController alloc] init];
            
            storeView.isFromOtherViews = YES;
            
            [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromSiteMeter"];
            
            [self.navigationController pushViewController:storeView animated:YES];
        }
        
    }
    else if ([actionText isEqualToString:@"Get Social"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Social sharing Site meter detail clicked"];
        
        SettingsViewController *facebook=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:Nil];
        facebook.isGestureAvailable = NO;
        
        [self.navigationController pushViewController:facebook animated:YES];
    }
    else if ([actionText isEqualToString:@"Post 5 Updates"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"updates Site meter detail clicked"];
        
        [self.navigationController popViewControllerAnimated:YES];
        
        [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"openContentCreation"];
        
    }
    else if ([actionText isEqualToString:@"Get Discovered"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Auto SEO Site meter detail clicked"];
        
        if(![[appDelegate.storeDetailDictionary objectForKey:@"CountryPhoneCode"]  isEqual: @"91"])
        {
            
            BizStoreDetailViewController *storedetailViewController=[[BizStoreDetailViewController alloc]initWithNibName:@"BizStoreDetailViewController" bundle:Nil];
            
            storedetailViewController.selectedWidget = 1008;
            
            [self.navigationController pushViewController:storedetailViewController animated:YES];
        }
        else
        {
            BizStoreViewController *storeView = [[BizStoreViewController alloc] init];
            
            storeView.isFromOtherViews = YES;
            
            [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromSiteMeter"];
            
            [self.navigationController pushViewController:storeView animated:YES];
        }
    }
    else if ([actionText isEqualToString:@"Get your own identity"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@".com Site meter detail clicked"];
        
        if(![[appDelegate.storeDetailDictionary objectForKey:@"CountryPhoneCode"]  isEqual: @"91"])
        {
            
            BizStoreDetailViewController *storedetailViewController=[[BizStoreDetailViewController alloc]initWithNibName:@"BizStoreDetailViewController" bundle:Nil];
            
            storedetailViewController.selectedWidget = 1100;
            
            [self.navigationController pushViewController:storedetailViewController animated:YES];
        }
        else
        {
            BizStoreViewController *storeView = [[BizStoreViewController alloc] init];
            
            storeView.isFromOtherViews = YES;
            
            [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromSiteMeter"];
            
            [self.navigationController pushViewController:storeView animated:YES];
        }
    }
    else if ([actionText isEqualToString:@"Share"] )
    {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        
        [mixpanel track:@"Share your site Site meter detail clicked"];
        
        UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message",@"Facebook",@"Twitter",@"Whatsapp", nil];
        selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        selectAction.tag=1;
        [selectAction showInView:self.view];
        
    }
    
}

-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag==1)
    {
        [userDetails setObject:[NSNumber numberWithBool:YES] forKey:@"hasShared"];
        if(buttonIndex==0)
        {
            if(![MFMessageComposeViewController canSendText]) {
                UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your device doesn't support SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [warningAlert show];
                return;
            }
            
            else
            {
                NSString *message =  [NSString stringWithFormat:@"Take a look at my website.\n %@.nowfloats.com",[appDelegate.storeTag lowercaseString]];
                MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
                messageController.messageComposeDelegate = self;
                [messageController setBody:message];
                
                // Present message view controller on screen
                [self presentViewController:messageController animated:YES completion:nil];
                
            }
            
            
        }
        
        
        if(buttonIndex == 1)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                SLComposeViewController *fbSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                NSString* shareText = [NSString stringWithFormat:@"Take a look at my website.\n %@.nowfloats.com",[appDelegate.storeTag lowercaseString]];
                
                [fbSheet setInitialText:shareText];
                
                [self presentViewController:fbSheet animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Sorry"
                                          message:@"You can't post a feed right now, make sure your device has an internet connection and you have at least one Facebook account setup."
                                          delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                
                [alertView show];
            }
        }
        
        
        if (buttonIndex==2)
        {
            if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
            {
                SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                NSString* shareText = [NSString stringWithFormat:@"Take a look at my website.\n %@.nowfloats.com",[appDelegate.storeTag lowercaseString]];
                [tweetSheet setInitialText:shareText];
                [self presentViewController:tweetSheet animated:YES completion:nil];
            }
            else
            {
                UIAlertView *alertView = [[UIAlertView alloc]
                                          initWithTitle:@"Sorry"
                                          message:@"You can't send a tweet right now, make sure your device has an internet connection and you have at least one Twitter account setup."
                                          delegate:self
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
                
                [alertView show];
            }
        }
        
        if(buttonIndex==3)
        {
            NSString * msg =  [NSString stringWithFormat:@"Take a look at my website.\n %@.nowfloats.com",[appDelegate.storeTag lowercaseString]];
            NSString * urlWhats = [NSString stringWithFormat:@"whatsapp://send?text=%@",msg];
            NSURL * whatsappURL = [NSURL URLWithString:[urlWhats stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            if ([[UIApplication sharedApplication] canOpenURL: whatsappURL]) {
                [[UIApplication sharedApplication] openURL: whatsappURL];
            } else {
                UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"WhatsApp not installed." message:@"Your device has no whatsApp." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
                [alert show];
            }
            
        }
        
    }
    
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to send SMS!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)buyStoreWidgetDidSucceed
{
    
        [appDelegate.storeWidgetArray insertObject:@"SITESENSE" atIndex:0];
    
}

-(void)buyStoreWidgetDidFail
{
    
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end


