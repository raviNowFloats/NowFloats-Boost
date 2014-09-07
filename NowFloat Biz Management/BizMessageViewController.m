//
//  BizMessageViewController.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 26/01/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import "BizMessageViewController.h"
#import "SWRevealViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UITableView+ZGParallelView.h"
#import "UIColor+HexaString.h"
#import "MessageDetailsViewController.h"
#import "NSString+CamelCase.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <QuartzCore/QuartzCore.h>
#import "KGModal.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "Mixpanel.h"
#import "Helpshift.h"
#import "BizMessage.h"
#import "SearchQueryController.h"
#import "BizWebViewController.h"
#import "WBNoticeView.h"
#import "WBErrorNoticeView.h"
#import "WBSuccessNoticeView.h"
#import "WBStickyNoticeView.h"
#import "NSOperationQueue+WBNoticeExtensions.h"
#import "FileManagerHelper.h"
#import "PopUpView.h"
#import "PrimaryImageViewController.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMessageComposeViewController.h>
#import <Social/Social.h>
#import "RegisterChannel.h"
#import "UIImage+ImageWithColor.h"
#import "NFActivityView.h"
#import "CreatePictureDeal.h"
#import "CreateStoreDeal.h"
#import "BizStoreDetailViewController.h"
#import "SocialSettingsFBHelper.h"
#import "SA_OAuthTwitterEngine.h"
#import "NFTutorialOverlay.h"
#import "NFCameraOverlay.h"
#import "UIImage+fixOrientation.h"
#import "EmailShareController.h"
#import "BizStoreViewController.h"
#import "SettingsViewController.h"
#import "TalkToBuisnessViewController.h"
#import "AnalyticsViewController.h"
#import "UserSettingsViewController.h"
#import "NFInstaPurchase.h"
#import "LatestVisitors.h"
#import "NewVersionController.h"
#import "NFCropOverlay.h"
#import "ChangePasswordController.h"
#import "ReferFriendViewController.h"
#import "DeleteFloatController.h"
#import "HomeViewMsgCell.h"
#import "RIATipsController.h"
#import "RIATips1Controller.h"
#import "BusinessProfileController.h"
#import "AlertViewController.h"
#import "PostUpdateViewController.h"
#import "URBMediaFocusViewController.h"
#import "SitemeterDetailView.h"
#import "SiteMeterHomeView.h"
#import "BusinessContactViewController.h"
#import "BusinessAddressViewController.h"
#import "BusinessDetailsViewController.h"



#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define kOAuthConsumerKey	  @"h5lB3rvjU66qOXHgrZK41Q"
#define kOAuthConsumerSecret  @"L0Bo08aevt2U1fLjuuYAMtANSAzWWi8voGuvbrdtcY4"




static inline CGFloat degreesToRadians(CGFloat degrees)
{
    return M_PI * (degrees / 180.0);
}

static inline CGSize swapWidthAndHeight(CGSize size)
{
    CGFloat  swap = size.width;
    
    size.width  = size.height;
    
    size.height = swap;
    
    return size;
}



@interface BizMessageViewController ()<MessageDetailsDelegate,BizMessageControllerDelegate,SearchQueryProtocol,PopUpDelegate,MFMailComposeViewControllerDelegate,PostMessageViewControllerDelegate,RegisterChannelDelegate,pictureDealDelegate,updateDelegate,UIImagePickerControllerDelegate,NFInstaPurchaseDelegate,NFCameraOverlayDelegate,LatestVisitorDelegate,UIScrollViewDelegate,NFCropOverlayDelegate,updateBizMessage,MFMessageComposeViewControllerDelegate>
{
    float viewWidth;
    float viewHeight;
    NFActivityView *nfActivity;
    NFActivityView *socialActivity;
    BOOL isPictureMessage;
    BOOL isFacebookSelected;
    BOOL isFacebookPageSelected;
    BOOL isTwitterSelected;
    BOOL isSendToSubscribers;
    BOOL isGoingToStore;
    BOOL isGoingToEmailShare;
    BOOL isCancelPictureMessage;
    SA_OAuthTwitterEngine *_engine;
    BOOL isPostPictureMessage;
    BOOL isFromCamera;
    UIImageOrientation imageOrientation;
    Mixpanel *mixpanel;
    SWRevealViewController *revealController;
    NFInstaPurchase *instaPurchasePopUp;
    WBErrorNoticeView *notice;
    WBSuccessNoticeView *referNotice;
    BOOL didShowNotice;
    NSTimer *scrollTimer, *newTimer;
    UIScrollView *bannerScrollView;
    UIPageControl *pageControl;
    NSMutableArray *bannerArray;
    UILabel *storeFpTag, *storeDescription, *websiteUrl;
    UITapGestureRecognizer* tapRecon;
    int lastWeekVisits;
    UILabel *visitorCount,*lastWeekTrend;
    
    UIView* errorView;
    UIImageView *primaryImage;
    BOOL isPrimaryImage;
    BOOL isPosted;
    BOOL isAnimation;
    UIView *coverView;
    
    CGSize postSize;
    UIImage *animateImage;
    int notificationType;
    BOOL isAlertViewSet;
    int loadCell;
    
    UIImage *uploadImage;
    
    int percentageComplete;
    
    float percentComplete;
    
    NSMutableArray *percentageArray, *headArray, *descArray;
    
    NSMutableArray *completedHeadArray, *completedPercentageArray, *completedDescArray;
    
}
@property (nonatomic, strong) URBMediaFocusViewController *mediaFocusController;
@property UIViewController *currentDetailViewController;
@property NFCameraOverlay *overlay;
@property(nonatomic,strong)BizStoreViewController *store;
@end

#define FONT_SIZE 14.0f
#define CELL_CONTENT_WIDTH 300.0f
#define CELL_CONTENT_MARGIN 25.0f

#define kOAuthConsumerKey	  @"h5lB3rvjU66qOXHgrZK41Q"
#define kOAuthConsumerSecret  @"L0Bo08aevt2U1fLjuuYAMtANSAzWWi8voGuvbrdtcY4"


@implementation BizMessageViewController

@synthesize parallax,messageTableView,storeDetailDictionary,dealDescriptionArray,dealDateArray,dealImageArray,picker=_picker;

@synthesize dealDateString,dealDescriptionString,dealIdString;

@synthesize isLoadedFirstTime;

@synthesize detailViewController, youtubeView;

@synthesize chunkArray,request,dataObj,uniqueIdString,theConnection;
@synthesize overlay = _overlay;

@synthesize store;
@synthesize primaryImageButton;
@synthesize uploadText;

typedef enum
{
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
    
} PIXELS;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self)
    {
        
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{

    isAnimation = YES;
    
    percentageComplete = 0;
    
    percentComplete = 0.0;
    
     [self siteMeter];
    
    [messageTableView reloadData];
    
    self.navigationController.navigationItem.rightBarButtonItem = nil;
    
    if([appDelegate.storeDetailDictionary objectForKey:@"openContentCreation"] == [NSNumber numberWithBool:YES])
    {
        
        [self createContentBtnClicked:nil];
        [appDelegate.storeDetailDictionary removeObjectForKey:@"openContentCreation"];
    }
    
    UIView *layer = [[UIView alloc]initWithFrame:CGRectMake(240, 0, 100, 40)];
    layer.backgroundColor = [UIColor colorFromHexCode:@"ffb900"];
    [self.navigationController.navigationBar addSubview:layer];
    
    if([appDelegate.storeDetailDictionary objectForKey:@"fromNewVersion"] == [NSNumber numberWithBool:YES])
    {
        if(version.floatValue < 7.0)
        {
            if(self.navigationController.navigationBarHidden == YES)
            {
                self.navigationController.navigationBarHidden = NO;
            }
        }
        else
        {
            if(self.navigationController.navigationBarHidden == YES)
            {
                self.navigationController.navigationBarHidden = NO;
            }
        }
    }
    
    if(self.title.length != 0)
    {
        self.title = @"";
    }
    
    if (navBackgroundview.isHidden)
    {
        [navBackgroundview setHidden:NO];
    }
    
    
    
    
    if (isGoingToStore)
    {
        [nfActivity showCustomActivityView];
        [self performSelector:@selector(syncView) withObject:nil afterDelay:0.4];
    }
    
    else if (isGoingToEmailShare)
    {
        [self isTutorialView:NO];
    }
    
    
    //--Hide or show noUpdateSubView--//
    [self showNoUpdateView];
    
    
    //Set Primary Image here
    [self setStoreImage];
    
    if(isPosted)
    {
        [self setUpArray];
        
        [self showNoUpdateView];
        
        [messageTableView reloadData];
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
        
        if (![appDelegate.storeWidgetArray containsObject:@"IMAGEGALLERY"] && ![appDelegate.storeWidgetArray containsObject:@"TIMINGS"] && ![appDelegate.storeWidgetArray containsObject:@"TOB"] && ![appDelegate.storeWidgetArray containsObject:@"SITESENSE"])
        {
            [nfActivity hideCustomActivityView];
            
            if ([fHelper openUserSettings] != NULL)
            {
                [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
                
                if ([userSetting objectForKey:@"userFirstMessage"]!=nil)
                {
                    if ([[userSetting objectForKey:@"userFirstMessage"] boolValue])
                    {
                        if (![appDelegate.storeWidgetArray containsObject:@"SITESENSE"] && appDelegate.dealDescriptionArray.count>=1)
                        {
                            //[self showBuyAutoSeoPlugin];
                        }
                        
                        else
                        {
                            [self syncView];
                        }
                    }
                    
                    else
                    {
                        [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"userFirstMessage"];
                        [self showPostFirstUserMessage];
                    }
                }
                
                else
                {
                    [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"userFirstMessage"];
                    [self showPostFirstUserMessage];//PopUp Tag is 1 or 2.
                }
            }
        }
        
        else if (![appDelegate.storeWidgetArray containsObject:@"SITESENSE"] && appDelegate.dealDescriptionArray.count>=1)
        {
            //[self showBuyAutoSeoPlugin];
        }
        
        else
        {
            [self syncView];
        }
        
        
    }
    
    
}

-(void)viewDidAppear:(BOOL)animated
{
    if([appDelegate.storeDetailDictionary objectForKey:@"isUpdateNotification"] != nil)
    {
        if([appDelegate.storeDetailDictionary objectForKey:@"isUpdateNotification"] == [NSNumber numberWithBool:YES])
        {
            [appDelegate.storeDetailDictionary removeObjectForKey:@"isUpdateNotification"];
            [self createContentBtnClicked:nil];
        }
    }
    
    if([appDelegate.storeDetailDictionary objectForKey:@"isSiteMeter"] != nil)
    {
        if([appDelegate.storeDetailDictionary objectForKey:@"isSiteMeter"] == [NSNumber numberWithBool:YES])
        {
            [appDelegate.storeDetailDictionary removeObjectForKey:@"isSiteMeter"];
            [self talkToUs];
        }
    }
    
   
    if ([appDelegate.storeDetailDictionary objectForKey:@"movetoseoplugin"] == [NSNumber numberWithBool:YES])
    {
        BizStoreDetailViewController *storeViewContl = [[BizStoreDetailViewController alloc] init];
        storeViewContl.selectedWidget = 1008;
        [self.navigationController pushViewController:storeViewContl animated:YES];
        [appDelegate.storeDetailDictionary removeObjectForKey:@"movetoseoplugin"];
    }
   
    if([userDetails objectForKey:@"showLatestVisitorsInfo"] == [NSNumber numberWithBool:YES])
    {
        scrollTimer = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                       target: self
                                                     selector: @selector(showLatestVisitor)
                                                     userInfo: nil
                                                      repeats: NO];
       // [self showLatestVisitor];
        [appDelegate.storeDetailDictionary removeObjectForKey:@"showLatestVisitorsInfo"];
    }
    else
    {
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
        
        [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
        
        if([userSetting objectForKey:@"referScreenShown"] != nil)
        {
            NSDate *dateNow = [NSDate date];
            NSDate *dateShown = [userSetting objectForKey:@"referScreenShown"];
            NSInteger dayDifference=[self daysBetweenDate:dateNow andDate:dateShown];
            if([[NSNumber numberWithInteger:dayDifference] intValue] > 14)
            {
                NSDate *dateNow = [NSDate date];
                NSDate *dateShown = [userSetting objectForKey:@"referScreenShown"];
                NSInteger dayDifference=[self daysBetweenDate:dateNow andDate:dateShown];
                if([[NSNumber numberWithInteger:dayDifference] intValue] > 14 && appDelegate.dealDescriptionArray.count>3)
                {
                    [fHelper updateUserSettingWithValue:dateNow forKey:@"referScreenShown"];
                    [self showReferAFriendView];
                    
                }
                
            }
        }
        else
        {
            if(appDelegate.dealDescriptionArray.count>3)
            {
                NSDate *shownDate = [NSDate date];
                [fHelper updateUserSettingWithValue:shownDate forKey:@"referScreenShown"];
                [self showReferAFriendView];
                
            }
        }
        
    }
    
    
    
    //New Version screen
    
        if([appDelegate.storeDetailDictionary objectForKey:@"isNewVersion"] == [NSNumber numberWithBool:YES])
        {
            NewVersionController *newUpdates = [[NewVersionController alloc] init];
            [appDelegate.storeDetailDictionary removeObjectForKey:@"isNewVersion"];
    
            [self.navigationController pushViewController:newUpdates animated:NO];
        }
    
    tapRecon = [[UITapGestureRecognizer alloc]
                initWithTarget:self action:@selector(navigationBarDoubleTap:)];
    tapRecon.numberOfTapsRequired = 1;
    tapRecon.numberOfTouchesRequired=1;
    [self.navigationController.navigationBar addGestureRecognizer:tapRecon];
    
    
    [self engageUser];
    
    if([appDelegate.storeDetailDictionary objectForKey:@"showTutorial"] == [NSNumber numberWithBool:YES])
    {
        
        [self isTutorialView:NO];
        [appDelegate.storeDetailDictionary removeObjectForKey:@"showTutorial"];
    }
    
   
    
    
}


- (void)navigationBarDoubleTap:(UIGestureRecognizer*)recognizer
{
    [messageTableView setContentOffset:CGPointMake(0,0) animated:YES];
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    
    coverView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 100, 700)];
    coverView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:coverView];
    coverView.hidden = YES;
    [self.view endEditing:YES];
    notificationType = 0;
    
    
    
    if([uploadText isEqualToString:@"YES"])
    {
        [self performSelector:@selector(createContentBtnClicked:) withObject:self afterDelay:0.2f];
    }
    
    UITapGestureRecognizer *openNotification = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openAction)];
    openNotification.numberOfTapsRequired = 1;
    openNotification.numberOfTouchesRequired = 1;
    [errorView addGestureRecognizer:openNotification];
    
    
    
    UITapGestureRecognizer *openMobVersion = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(openMobileView)];
    openMobVersion.numberOfTapsRequired = 1;
    openMobVersion.numberOfTouchesRequired = 1;
    [webUrl addGestureRecognizer:openMobVersion];
    [webUrl setUserInteractionEnabled:YES];
    
    userDetails=[NSUserDefaults standardUserDefaults];
    
    
    animateImage = [[UIImage alloc]init];
    
    self.mediaFocusController = [[URBMediaFocusViewController alloc] init];
	self.mediaFocusController.delegate = self;
    
    mixpanel = [Mixpanel sharedInstance];
    
    primaryImage = [[UIImageView alloc]init];
    
    mixpanel.showNotificationOnActive = YES;
    
    primaryImageBtn.frame = CGRectMake(19, 83, 80, 80);
    
    [self.view addSubview:primaryImageBtn];
    
    editDescription.frame = CGRectMake(0, 100, 320, 55);
    
    editDescription.hidden = YES;
    
    [self.view addSubview:editDescription];
    
    [self.view setBackgroundColor:[UIColor colorWithHexString:@"dedede"]];
    
    version = [[UIDevice currentDevice] systemVersion];
    
    if ([version intValue] >= 7)
    {
        self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexCode:@"ffb900"];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
    
    
    [notificationView setFrame:CGRectMake(0, 0,notificationView.frame.size.width, notificationView.frame.size.height)];
    
    
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
    
    /*FP messages initialization*/
    
    dealDescriptionArray=[[NSMutableArray alloc]init];
    dealDateArray=[[NSMutableArray   alloc]init];
    dealId=[[NSMutableArray alloc]init];
    dealImageArray=[[NSMutableArray alloc]init];
    arrayToSkipMessage=[[NSMutableArray alloc]init];
    
    dealIdString=[[NSMutableString alloc]init];
    dealDescriptionString=[[NSMutableString alloc]init];
    dealDateString=[[NSMutableString alloc]init];
    
    frontViewPosition=[[NSString alloc]init];
    
    nfActivity=[[NFActivityView alloc]init];
    nfActivity.activityTitle=@"Updating";
    
    socialActivity = [[NFActivityView alloc]init];
    socialActivity.activityTitle=@"Connecting";
    
    
    isPictureMessage=NO;
    isGoingToStore=NO;
    isGoingToEmailShare=NO;
    
    isPostPictureMessage = NO;
    isFromCamera = NO;
    didShowNotice = NO;
    
    isFacebookSelected=NO;
    isFacebookPageSelected=NO;
    isTwitterSelected=NO;
    isSendToSubscribers=YES;
    
    isCancelPictureMessage=NO;
    
    [selectedFacebookButton setHidden:YES];
    
    [selectedFacebookPageButton setHidden:YES];
    
    [selectedTwitterButton setHidden:YES];
    
    [sendToSubscribersOffButton setHidden:YES];
    
    [sendToSubscribersOnButton setHidden:NO];
    
    fbPageSubView.center=[[[UIApplication sharedApplication] delegate] window].center;
    
    [fbPageSubView setHidden:YES];
    
    
    /*Create an AppDelegate object*/
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    revealController = [self revealViewController];
    
    revealController.delegate=self;
    
    uploadImage = [[UIImage alloc] init];
    
    percentageArray = [[NSMutableArray alloc] init];
    
    headArray = [[NSMutableArray alloc] init];
    
    descArray = [[NSMutableArray alloc] init];
    
    completedDescArray = [[NSMutableArray alloc] init];
    
    completedHeadArray = [[NSMutableArray alloc] init];
    
    completedPercentageArray = [[NSMutableArray alloc] init];
    
    
    
    /*Create a custom Navigation Bar here*/
    
    if ([version floatValue]<7)
    {
        [messageTableView setFrame:CGRectMake(0,0, messageTableView.frame.size.width, messageTableView.frame.size.height)];
        
        self.navigationController.navigationBarHidden=NO;
        
        UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [leftCustomButton setFrame:CGRectMake(25,0,35,15)];
        [leftCustomButton setImage:[UIImage imageNamed:@"Menu-Burger.png"] forState:UIControlStateNormal];
        
        [leftCustomButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftCustomButton];
        
        
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
        
        UIImage *navBackgroundImage = [UIImage imageNamed:@"header-logo.png"];
        navBackgroundview = [[UIView alloc]initWithFrame:CGRectMake(50, 0,230, 44)];
        UIImageView *navBgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(-10,10,256,20)];
        [navBackgroundview setBackgroundColor:[UIColor clearColor]];
        navBgImageView.image=navBackgroundImage;
        navBgImageView.contentMode=UIViewContentModeScaleAspectFit;
        
        self.navigationItem.titleView=navBgImageView;
        
        [parallax setFrame:CGRectMake(0,0,320,160)];
        
    }
    
    else
    {
        [parallax setFrame:CGRectMake(0,0, 320, 160)];
        
        self.navigationController.navigationBarHidden=NO;
        
        UIImage *navBackgroundImage = [UIImage imageNamed:@"header-logo.png"];
        navBackgroundview = [[UIView alloc]initWithFrame:CGRectMake(50, 0,230, 44)];
        UIImageView *navBgImageView=[[UIImageView alloc]initWithFrame:CGRectMake(-10,10,256,20)];
        [navBackgroundview setBackgroundColor:[UIColor clearColor]];
        navBgImageView.image=navBackgroundImage;
        navBgImageView.contentMode=UIViewContentModeScaleAspectFit;
        [navBackgroundview addSubview:navBgImageView];
        [self.navigationController.navigationBar addSubview:navBackgroundview];
        
        
        UIButton *leftCustomButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [leftCustomButton setFrame:CGRectMake(25,0,35,15)];
        [leftCustomButton setImage:[UIImage imageNamed:@"Menu-Burger.png"] forState:UIControlStateNormal];
        
        [leftCustomButton addTarget:revealController action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
        
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftCustomButton];
        
        
        [self.navigationItem setLeftBarButtonItem:barButtonItem];
        
        
       
        
    }
    
    
    
    
    /*Show create content subview*/
    [self showCreateContentSubview];
    
    //Setup post message subview
    [self setUpPostMessageSubView];
    
    //Set the RightRevealWidth 0
    revealController.rightViewRevealWidth=100.0;
    revealController.rightViewRevealOverdraw=0.0;
    
    [self.view addGestureRecognizer:revealController.panGestureRecognizer];
    
    /*Post Message Controller*/
    
    postMessageController=[[PostMessageViewController alloc]initWithNibName:@"PostMessageViewController" bundle:nil];
    
    [self.messageTableView addParallelViewWithUIView:self.parallax withDisplayRadio:0.7 cutOffAtMax:YES];
    
    [self.messageTableView setScrollsToTop:YES];
    
    
    
    [fbPageTableView setScrollsToTop:NO];
    
    fpMessageDictionary=[[NSMutableDictionary alloc]initWithDictionary:appDelegate.fpDetailDictionary];
    
    ismoreFloatsAvailable=[[fpMessageDictionary objectForKey:@"moreFloatsAvailable"] boolValue];
    
    //--set the array--//
    [self setUpArray];
    
    [messageTableView addInfiniteScrollingWithActionHandler:^
     {
         [self insertRowAtBottom];
     }];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateView) name:@"updateMessages" object:nil];
    
    
    
    //--Set the store tag--//
    
    [storeTagLabel setBackgroundColor:[UIColor whiteColor]];
    
    [storeTitleLabel setTextColor:[UIColor whiteColor]];
    
    storeTitleLabel.textAlignment = NSTextAlignmentLeft;
    
    [storeTitleLabel setText:[[[NSString stringWithFormat:@"%@",appDelegate.businessName] lowercaseString] stringByConvertingCamelCaseToCapitalizedWords]];
    
    
    webUrl = [[UILabel alloc]init];
    
    webUrl.textColor = [UIColor whiteColor];
    
    webUrl.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    
    if([appDelegate.storeDetailDictionary objectForKey:@"RootAliasUri"] != [NSNull null])
    {
        webUrl.text = [appDelegate.storeDetailDictionary objectForKey:@"RootAliasUri"];
    }
    else
    {
        webUrl.text = [[NSString stringWithFormat:@"%@.nowfloats.com",[appDelegate.storeDetailDictionary objectForKey:@"Tag"] ]lowercaseString];
    }
    
    
    NSString *webURL = webUrl.text;
    
    if([webURL rangeOfString:@"http://"].location != NSNotFound)
    {
        webUrl.text = [webURL stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    }
    else
    {
        webUrl.text = webURL;
    }
    
    
    if (storeTitleLabel.text.length>19)
    {
        //storeTagLabel.frame=CGRectMake(0,120, 320, 55);
        
        //storeTitleLabel.frame=CGRectMake(135,120, 177, 55);
        
        storeTagButton.frame = CGRectMake(135, 80, 177, 55);
        
        storeTitleLabel.frame = CGRectMake(108, 50, storeTitleLabel.frame.size.width, storeTitleLabel.frame.size.height);
        
        storeTagButton.backgroundColor = [UIColor blueColor];
    }
    else
    {
        storeTitleLabel.frame = CGRectMake(109, 60, storeTitleLabel.frame.size.width, storeTitleLabel.frame.size.height);
    }
    
    [self.messageTableView setSeparatorColor:[UIColor colorWithHexString:@"ffb900"]];
    
    
    //--Set parallax image's here--//
    [self setparallaxImage];
    
    //--Engage user with popups--//
    
    
    
    
    
    
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
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Business Name"];
        [descArray addObject:@"Add Business Name"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Business Name"];
        [completedDescArray addObject:@"Add Business Name"];
    }
    
    if([appDelegate.businessDescription length] == 0)
    {
        [percentageArray addObject:@"(+10%)"];
        [headArray addObject:@"Business Description"];
        [descArray addObject:@"Describe your business"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"(+10%)"];
        [completedHeadArray addObject:@"Business Description"];
        [completedDescArray addObject:@"Describe your business"];
    }
    
    if([appDelegate.storeCategoryName length] == 0)
    {
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Business Category"];
        [descArray addObject:@"Add a Business Category"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Business Category"];
        [completedDescArray addObject:@"Add a Business Category"];
    }
    
   
    
    if([appDelegate.storeDetailDictionary objectForKey:@"PrimaryNumber"] == NULL)
    {
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Phone Number"];
        [descArray addObject:@"Help customers reach you instantly"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Phone Number"];
        [completedDescArray addObject:@"Help customers reach you instanlty"];
    }
    if([appDelegate.storeDetailDictionary objectForKey:@"Email"] == NULL)
    {
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Email"];
        [descArray addObject:@"Add Email"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Email"];
        [completedDescArray addObject:@"Add Email"];
    }
    if([appDelegate.storeDetailDictionary objectForKey:@"Address"] == NULL)
    {
        [percentageArray addObject:@"(+10%)"];
        [headArray addObject:@"Help your customers find you"];
        [descArray addObject:@"Add Business Address"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"(+10%)"];
        [completedHeadArray addObject:@"Help your customers find you"];
        [completedDescArray addObject:@"Add Business Address"];
    }
    if(![appDelegate.storeWidgetArray containsObject:@"TIMINGS"])
    {
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Business Hours"];
        [descArray addObject:@"Display Business timings"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Business Hours"];
        [completedDescArray addObject:@"Display Business timings"];
    }
    
    if([appDelegate.socialNetworkNameArray count]==0)
    {
        [percentageArray addObject:@"(+10%)"];
        [headArray addObject:@"Get Social"];
        [descArray addObject:@"Post on Facebook / Twitter"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"(+10%)"];
        [completedHeadArray addObject:@"Get Social"];
        [completedDescArray addObject:@"Post on Facebook / Twitter"];
    }
    
    
    if([appDelegate.dealDescriptionArray count] < 5)
    {
        if([appDelegate.dealDescriptionArray count] == 0)
        {
            [percentageArray addObject:@"(+15%)"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Update your website"];
        }
        else if([appDelegate.dealDescriptionArray count] == 1)
        {
            [percentageArray addObject:@"(+12%)"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Update your website"];
            
            
            percentageComplete += 3;
            percentComplete += 0.03;
            [completedPercentageArray addObject:@"(+12%)"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Update your website"];
        }
        else if([appDelegate.dealDescriptionArray count] == 2)
        {
            [percentageArray addObject:@"(+9%)"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Update your website"];
            
            percentageComplete += 6;
            percentComplete += 0.06;
            [completedPercentageArray addObject:@"(+9%)"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Update your website"];
        }
        else if([appDelegate.dealDescriptionArray count] == 3)
        {
            [percentageArray addObject:@"(+6%)"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Update your website"];
            
            
            percentageComplete += 9;
            percentComplete += 0.09;
            [completedPercentageArray addObject:@"(+6%)"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Update your website"];
        }
        else if([appDelegate.dealDescriptionArray count] == 1)
        {
            [percentageArray addObject:@"(+3%)"];
            [headArray addObject:@"Post 5 Updates"];
            [descArray addObject:@"Update your website"];
            
            percentageComplete += 12;
            percentComplete += 0.1;
            [completedPercentageArray addObject:@"(+15%)"];
            [completedHeadArray addObject:@"Post 5 Updates"];
            [completedDescArray addObject:@"Update your website"];
        }
        
       
    }
    else
    {
        percentageComplete += 15;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"(+15%)"];
        [completedHeadArray addObject:@"Post 5 Updates"];
        [completedDescArray addObject:@"Update your website"];
    }
    if(![appDelegate.storeWidgetArray containsObject:@"SITESENSE"])
    {
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Get Discovered"];
        [descArray addObject:@"Get Discovered with Auto-SEO"];
    }
    else
    {
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Get Discovered"];
        [completedDescArray addObject:@"Get Discovered with Auto-SEO"];
    }
    if([appDelegate.storeRootAliasUri isEqualToString:@""])
    {
        [percentageArray addObject:@"(+10%)"];
        [headArray addObject:@"Get your own identity"];
        [descArray addObject:@"Get your own domain"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"(+10%)"];
        [completedHeadArray addObject:@"Get your own identity"];
        [completedDescArray addObject:@"Get your own domain"];
    }
    
    if([userDetails objectForKey:@"hasShared"] == [NSNumber numberWithBool:YES])
    {
        
        percentageComplete += 5;
        percentComplete += 0.05;
        [completedPercentageArray addObject:@"(+5%)"];
        [completedHeadArray addObject:@"Share"];
        [completedDescArray addObject:@"Tell the world"];
        
    }
    else
    {
        [percentageArray addObject:@"(+5%)"];
        [headArray addObject:@"Share"];
        [descArray addObject:@"Tell the world"];
    }
    
    if([appDelegate.primaryImageUri length] == 0)
    {
        [percentageArray addObject:@"(+10%)"];
        [headArray addObject:@"Featured Image"];
        [descArray addObject:@"Add a relevant Image"];
    }
    else
    {
        percentageComplete += 10;
        percentComplete += 0.1;
        [completedPercentageArray addObject:@"(+10%)"];
        [completedHeadArray addObject:@"Featured Image"];
        [completedDescArray addObject:@"Add a relevant Image"];
    }
    
    
    NSNumber *updateCount = [NSNumber numberWithInt:percentageComplete];
    
    int Level = [[appDelegate.storeDetailDictionary objectForKey:@"PaymentLevel"] intValue];
    
    NSNumber *PaymentLevel = [NSNumber numberWithInt:Level];

    NSDictionary *specialProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                       updateCount,@"$SiteScore",
                                       PaymentLevel,@"Payment Level",
                                       nil];
    
    
    [mixpanel.people set:specialProperties];
    [mixpanel.people addPushDeviceToken:appDelegate.deviceTokenData];
    
}

-(void)talkToUs
{
    
    SitemeterDetailView *siteMeter = [[SitemeterDetailView alloc] initWithNibName:@"SitemeterDetailView" bundle:nil];
    
    [self setTitle:@"Home"];

    [self.navigationController pushViewController:siteMeter animated:YES];
    
}


-(void)setUpPostMessageSubView
{
    
    [uploadPictureImgView  setContentMode:UIViewContentModeScaleAspectFill];
    
    [uploadPictureImgView.layer setCornerRadius:6.0];
    
    [uploadPictureImgView.layer setBorderColor:[UIColor colorWithHexString:@"dcdcda"].CGColor];
    
    CALayer * l = [uploadPictureImgView layer];
    
    [l setMasksToBounds:YES];
    
    [l setCornerRadius:6.0];
    
    l=nil;
    
    postUpdateBtn.enabled = NO;
    
    postUpdateBtn.alpha = 0.5;
    
    dummyTextView.inputAccessoryView = postMessageSubView;
    
    [dummyTextView setScrollsToTop:NO];
    
    [createContentTextView setScrollsToTop:NO];
    
    [createContentTextView setAutocapitalizationType:UITextAutocapitalizationTypeWords];
    
    
    [postMsgViewBgView.layer setBorderColor:[UIColor colorWithHexString:@"c8c8c8"].CGColor];
    
    postMsgViewBgView.layer.borderWidth = 1.0;
    
    [postMsgViewBgView.layer setCornerRadius:6.0];
    
    if (version.floatValue>=7.0)
    {
        if (viewHeight==568)
        {
            [postMessageSubView setFrame:CGRectMake(0, 0, 320, postMessageSubView.frame.size.height)];
            
            postMessageContentCreateSubview.center=postMessageSubView.center;
        }
    }
    
    else
    {
        if (viewHeight == 568)
        {
            [postMessageSubView setFrame:CGRectMake(0, 0, 320, postMessageSubView.frame.size.height)];
            
            postMessageContentCreateSubview.center=postMessageSubView.center;
        }
    }
    
    
    
}


-(void)showVisitors:(NSString *)visits
{
    
    visitorCount.text=[NSString stringWithFormat:@"%@",visits];
    
    NSString *visitorString = [visitorCount.text
                               stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    visitorCount.text=[NSString stringWithFormat:@"%@",visitorString];
    
    
}

-(void)showSubscribers:(NSString *)subscribers
{
    
}

-(void)showTrends
{
    @try {
        NSMutableArray *vistorCountArray=[[NSMutableArray alloc]init];
        NSMutableArray *vistorWeekArray=[[NSMutableArray alloc]init];
        
        for (int i=0; i<[appDelegate.storeVisitorGraphArray count]-1; i++)
        {
            [vistorCountArray insertObject:[[appDelegate.storeVisitorGraphArray objectAtIndex:i]objectForKey:@"visitCount" ] atIndex:i];
            [vistorWeekArray insertObject:[[appDelegate.storeVisitorGraphArray objectAtIndex:i]objectForKey:@"WeekNumber" ] atIndex:i];
            
        }
        
        
        
        NSString *timeStamp= [appDelegate.storeDetailDictionary objectForKey:@"CreatedOn"];
        
        NSDate *signUpDate =  [self mfDateFromDotNetJSONString:timeStamp];
        
        NSDate *presentDay=[NSDate date];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy-MM-dd"];
        
        
        NSString *visitorDetails = [[NSString alloc] init];
        
        
        if(signUpDate == NULL || presentDay == NULL)
        {
            
        }
        else
        {
            
            NSInteger *dayDifference = -[self daysBetween:presentDay and:signUpDate];
            
            
            
            if ([NSNumber numberWithInteger:dayDifference].intValue > 6)
            {
                if([NSNumber numberWithInteger:dayDifference].intValue > 13)
                {
                    if([NSNumber numberWithInteger:dayDifference].intValue > 20)
                    {
                        if([NSNumber numberWithInteger:dayDifference].intValue > 26)
                        {
                            visitorDetails = [vistorCountArray objectAtIndex:3];
                            NSString *lastVisitorDetails = [vistorCountArray objectAtIndex:2];
                            int visitorNumber = [visitorDetails intValue];
                            int lastWeek = [lastVisitorDetails intValue];
                            
                            lastWeekVisits = visitorNumber-lastWeek;
                            
                        }
                        else
                        {
                            visitorDetails = [vistorCountArray objectAtIndex:2];
                            NSString *lastVisitorDetails = [vistorCountArray objectAtIndex:1];
                            int visitorNumber = [visitorDetails intValue];
                            int lastWeek = [lastVisitorDetails intValue];
                            
                            lastWeekVisits = visitorNumber-lastWeek;
                        }
                        
                    }
                    else
                    {
                        visitorDetails = [vistorCountArray objectAtIndex:1];
                        NSString *lastVisitorDetails = [vistorCountArray objectAtIndex:0];
                        int visitorNumber = [visitorDetails intValue];
                        int lastWeek = [lastVisitorDetails intValue];
                        
                        lastWeekVisits = visitorNumber-lastWeek;
                        
                    }
                }
                else
                {
                    visitorDetails = [vistorCountArray objectAtIndex:0];
                    
                    NSString *lastVisitorDetails = visitorCount.text;
                    int visitorNumber = [visitorDetails intValue];
                    int lastWeek = [lastVisitorDetails intValue];
                    
                    lastWeekVisits = visitorNumber-lastWeek;
                    
                }
                
                
            }
            
            else
            {
                visitorDetails = visitorCount.text;
                
                lastWeekVisits = [visitorDetails intValue];
            }
        }
        
        lastWeekTrend.text = [NSString stringWithFormat:@"%d",lastWeekVisits];
        
    }
    @catch (NSException *exception) {
        NSLog(@"Exception is %@",exception);
    }
    
    
}


-(void)moveTableViewUp
{
    @try {
        
        
        const int movementDistance = -150; // tweak as needed
        const float movementDuration = 0.3f; // tweak as needed
        BOOL up = YES;
        int movement = (up ? movementDistance : -movementDistance);
        
        [UIView beginAnimations: @"animateTextField" context: nil];
        [UIView setAnimationBeginsFromCurrentState: YES];
        [UIView setAnimationDuration: movementDuration];
        messageTableView.frame = CGRectOffset(messageTableView.frame, 0, movement);
        [UIView commitAnimations];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception at Animation moving up is %@",exception);
    }
    
}


-(void)moveTableViewDown
{
    
    const int movementDistance = -150; // tweak as needed
    const float movementDuration = 0.6f; // tweak as needed
    BOOL up = NO;
    int movement = (up ? movementDistance : -movementDistance);
    
    [UIView beginAnimations: @"animateTextField" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    messageTableView.frame = CGRectOffset(messageTableView.frame, 0, movement);
    [UIView commitAnimations];
}



-(void)showCreateContentSubview
{
    if (viewHeight==480)
    {
        [createContentSubView setFrame:CGRectMake(createContentSubView.frame.origin.x, 370, createContentSubView.frame.size.width, createContentSubView.frame.size.height)];
    }
    
    else
    {
        [createContentSubView setFrame:CGRectMake(createContentSubView.frame.origin.x, 458, createContentSubView.frame.size.width, createContentSubView.frame.size.height)];
    }
    
}



-(void)showNoUpdateView
{
    [noUpdateSubView setHidden:YES];
}

-(void)talkToSupport
{
    [mixpanel track:@"talktous_homeview"];
    [[Helpshift sharedInstance] showConversation:self withOptions:nil];
}


-(void)engageUser
{
    FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
    
    fHelper.userFpTag=appDelegate.storeTag;
    
    NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
    
    [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
    
    //--First Login--//
    
    
        if([userDetails objectForKey:@"showTutorialView"] == [NSNumber numberWithBool:YES])
        {
            if([appDelegate.storeDetailDictionary objectForKey:@"stopTutorialView"]== [NSNumber numberWithBool:YES])
            {
                [appDelegate.storeDetailDictionary removeObjectForKey:@"stopTutorialView"];
            }
            else
            {
                [self isTutorialView:NO];
                [userDetails setObject:[NSNumber numberWithBool:NO] forKey:@"showTutorialView"];
            }
            
        }
    
    
    
    
    //--Second Login is only available.If business messages are updated regularly--//
    
    if ([fHelper openUserSettings] != NULL)
    {
        if ([userSetting objectForKey:@"1st Login"]!=nil)
        {
            if ([[userSetting objectForKey:@"1st Login"] boolValue] )
            {
                if ([[userSetting allKeys] containsObject:@"1stLoginCloseDate"] && appDelegate.dealDescriptionArray.count>0 )
                {
                    NSDate *appStartDate=[userDetails objectForKey:@"appStartDate"];
                    
                    NSDate *appCloseDate=[userSetting  objectForKey:@"1stLoginCloseDate"];
                    
                    NSInteger *dayDifference=[self daysBetweenDate:appCloseDate andDate:appStartDate];
                    
                    if ([NSNumber numberWithInteger:dayDifference].intValue>[NSNumber numberWithInt:0].intValue)
                    {
                        if ([userSetting objectForKey:@"2nd Login"]!=nil)
                        {
                            if ([userSetting objectForKey:@"2nd Login"])
                            {
                                [self is2ndLoginView:YES];
                            }
                            else
                            {
                                [self is2ndLoginView:NO];
                            }
                        }
                        else
                        {
                            [self is2ndLoginView:NO];
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    //--Third Login share within existing email id's--//
    
    BOOL emailShared = [[userSetting objectForKey:@"isEmailShared"] boolValue];
    
    if ([fHelper openUserSettings] != NULL)
    {
        if ([userSetting objectForKey:@"2nd Login"]!= nil && !emailShared)
        {
            //  [self popUpEmailShare];
            
            [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"isEmailShared"];
        }
    }
    
    if([fHelper openUserSettings] != NULL)
    {
        if ([userSetting objectForKey:@"3rd Login"] != nil)
        {
            PopUpView *customPopUp=[[PopUpView alloc]init];
            customPopUp.delegate=self;
            customPopUp.titleText=@"Tell the world!";
            customPopUp.descriptionText=@"Your website is turning out well.Why don't you tell your friends about it? Share it on facebook and twitter";
            customPopUp.popUpImage=[UIImage imageNamed:@"sharewebsite.png"];
            customPopUp.successBtnText=@"Share Now";
            customPopUp.cancelBtnText=@"Later";
            customPopUp.tag=1002;
            [customPopUp showPopUpView];
            
            FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
            
            fHelper.userFpTag=appDelegate.storeTag;
            
            [fHelper removeUserSettingforKey:@"3rd Login"];
        }
    }
    
    
    
    
}

//Time stamp calculation functions


-(NSDate *)mfDateFromDotNetJSONString:(NSString *)string {
    static NSRegularExpression *dateRegEx = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateRegEx = [[NSRegularExpression alloc] initWithPattern:@"^\\/date\\((-?\\d++)(?:([+-])(\\d{2})(\\d{2}))?\\)\\/$" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    NSTextCheckingResult *regexResult = [dateRegEx firstMatchInString:string options:0 range:NSMakeRange(0, [string length])];
    
    if (regexResult) {
        // milliseconds
        NSTimeInterval seconds = [[string substringWithRange:[regexResult rangeAtIndex:1]] doubleValue] / 1000.0;
        // timezone offset
        if ([regexResult rangeAtIndex:2].location != NSNotFound) {
            NSString *sign = [string substringWithRange:[regexResult rangeAtIndex:2]];
            // hours
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:3]]] doubleValue] * 60.0 * 60.0;
            // minutes
            seconds += [[NSString stringWithFormat:@"%@%@", sign, [string substringWithRange:[regexResult rangeAtIndex:4]]] doubleValue] * 60.0;
        }
        
        return [NSDate dateWithTimeIntervalSince1970:seconds];
    }
    return nil;
}

- (int)hoursBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSHourCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components hour]-5;
}

- (int)minutesBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSMinuteCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components minute]-330;
}

- (int)yearsBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSYearCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components year];
}

- (int)daysBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSDayCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components day];
}

- (int)monthsBetween:(NSDate *)firstDate and:(NSDate *)secondDate {
    NSUInteger unitFlags = NSMonthCalendarUnit;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:unitFlags fromDate:firstDate toDate:secondDate options:0];
    return [components month];
}


#pragma LatestVisitor delegate methods

-(void)lastVisitDetails:(NSMutableDictionary *)visits
{
    
    if(visits != NULL)
    {
        NSString *cityName = [[visits objectForKey:@"city"] lowercaseString];
        NSString *countryName = [[visits objectForKey:@"country"] lowercaseString];
        
        NSString *timeStamp = [visits objectForKey:@"ArrivalTimeStamp"];
        
        NSDate *newStartDate = [self mfDateFromDotNetJSONString:timeStamp];
        NSDate *currentdate = [NSDate date];
        
        int dayDifference = -[self daysBetween:currentdate and:newStartDate];
        
        dayDifference = dayDifference < 0? 0: dayDifference;
        
        int hoursDifference = -[self hoursBetween:currentdate and:newStartDate];
        
        hoursDifference = hoursDifference < 0? 0:hoursDifference;
        
        int minDifference = -[self minutesBetween:currentdate and:newStartDate];
        
        minDifference = minDifference < 0? 0: minDifference;
        
        int monthDifference = [self monthsBetween:currentdate and:newStartDate];
        
        monthDifference = monthDifference < 0? 0: monthDifference;
        
        int yearDifference = [self yearsBetween:currentdate and:newStartDate];
        
        yearDifference =  yearDifference < 0 ? 0 : yearDifference;
        
        
        
        NSString *lastSeen;
        
        if(minDifference < 60)
        {
            if(minDifference == 0)
            {
                lastSeen = [NSString stringWithFormat:@"few seconds ago"];
            }
            else if(minDifference == 1)
            {
                lastSeen = [NSString stringWithFormat:@"%d minute ago", minDifference];
            }
            else
            {
                lastSeen = [NSString stringWithFormat:@"%d minutes ago",minDifference];
            }
        }
        else
        {
            if(hoursDifference < 24)
            {
                if(hoursDifference <= 1)
                {
                    lastSeen = [NSString stringWithFormat:@"1 hour ago"];
                }
                else
                {
                    lastSeen = [NSString stringWithFormat:@"%d hours ago",hoursDifference];
                }
                
            }
            else
            {
                if(dayDifference < 30)
                {
                    if(dayDifference <= 1)
                    {
                        lastSeen = [NSString stringWithFormat:@"1 days ago"];
                    }
                    else
                    {
                        lastSeen = [NSString stringWithFormat:@"%d days ago",dayDifference];
                    }
                }
                else
                {
                    if(monthDifference < 12)
                    {
                        if(monthDifference <= 1)
                        {
                            lastSeen = [NSString stringWithFormat:@"1 month ago"];
                        }
                        else
                        {
                            lastSeen = [NSString stringWithFormat:@"%d months ago",monthDifference];
                        }
                    }
                    else
                    {
                        if(yearDifference == 1)
                        {
                            lastSeen = [NSString stringWithFormat:@"1 year ago"];
                        }
                        else
                        {
                            lastSeen = [NSString stringWithFormat:@"%d years ago",yearDifference];
                        }
                    }
                    
                }
                
            }
        }
        
        
        BOOL shownVisitorInfo = NO;
        
        NSString *ipAddress = [visits objectForKey:@"ip"];
        
        
        
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
        
        [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
        
        
        if([userSetting objectForKey:@"visitorTimeStamp"] == nil)
        {
            
            [fHelper updateUserSettingWithValue:timeStamp forKey:@"visitorTimeStamp"];
            
            [fHelper updateUserSettingWithValue:ipAddress forKey:@"visitorIpAddr"];
        }
        else
        {
            if([[userSetting objectForKey:@"visitorTimeStamp"] isEqualToString:timeStamp])
            {
                if([[userSetting objectForKey:@"visitorIpAddr"] isEqualToString:ipAddress])
                {
                    shownVisitorInfo = YES;
                }
            }
            else
            {
                [fHelper updateUserSettingWithValue:timeStamp forKey:@"visitorTimeStamp"];
                
                [fHelper updateUserSettingWithValue:ipAddress forKey:@"visitorIpAddr"];
            }
        }
        
        // NSLog(@"%@", userSetting);
        
        cityName = [cityName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[cityName substringToIndex:1] uppercaseString]];
        countryName = [countryName stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:[[countryName substringToIndex:1] uppercaseString]];
        
        
        if(shownVisitorInfo)
        {
           
        }
        else
        {
            if(!isAlertViewSet)
            {
                [userDetails setObject:[NSNumber numberWithBool:NO] forKey:@"showLatestVisitorsInfo"];
                [self customalert:[NSString stringWithFormat:@"%@, %@",cityName,countryName] Seen:[NSString stringWithFormat:@"%@",lastSeen] category:3];
                isAlertViewSet = YES;
                
            }
        }
        
    }
    else
    {
        
    }
    
}


-(void)showReferAFriendView
{
    
    [self customalert:@"" Seen:@"" category:2];
    notificationType = 2;
    
    
}



- (IBAction)cameraButtonClicked:(id)sender {
    isFromCamera = YES;
    [self addImageBtnClicked:nil];
    
}


-(void)failedToGetVisitDetails
{
    UIAlertView *alerView=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Something went wrong in fetching last visitor details" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
    
    [alerView show];
    
    alerView=nil;
}

-(void)showLatestVisitor
{
    LatestVisitors *visitorDetails = [[LatestVisitors alloc] init];
    
    visitorDetails.delegate = self;
    
    [visitorDetails getLastVisitorDetails];
    
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if(didShowNotice == YES)
    {
        [notice dismissNotice];
        [referNotice dismissNotice];
        didShowNotice = NO;
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    
    
    if (scrollView == bannerScrollView)
    {
        UIScrollView *bScrollView = (UIScrollView *)scrollView;
        
        CGFloat pageWidth = bScrollView.frame.size.width;
        
        int page = floor((bScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
        
        pageControl.currentPage = page;
        
        if(page == 0)
        {
            storeTagButton.hidden = NO;
            storeTagLabel.hidden = NO;
            storeTitleLabel.hidden = NO;
            primaryImageBtn.hidden = NO;
            editDescription.hidden = YES;
            [primaryImageView setHidden:NO];
            if ([[appDelegate.storeDetailDictionary objectForKey:@"PaymentLevel"] floatValue]<10 && appDelegate.dealDescriptionArray.count>=4)
            {
                noAdsBtn.hidden = NO;
                noAdsSubView.hidden = NO;
            }
        }
        if(page == 1)
        {
            [bannerScrollView setFrame:CGRectMake(bannerScrollView.frame.origin.x, bannerScrollView.frame.origin.y, bannerScrollView.frame.size.width, bannerScrollView.frame.size.height)];
            
            storeTagButton.hidden = YES;
            storeTagLabel.hidden = YES;
            storeTitleLabel.hidden = YES;
            noAdsSubView.hidden = YES;
            editDescription.hidden = YES;
            [primaryImageBtn setHidden:YES];
            [primaryImageView setHidden:YES];
            [noAdsBtn setHidden:YES];
        }
    }
    
}


-(void)showPostUpdateOverLay
{
    FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
    
    fHelper.userFpTag=appDelegate.storeTag;
    
    NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
    
    if ([fHelper openUserSettings] != NULL)
    {
        [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
        
        if ([userSetting objectForKey:@"updateMsgtutorial"]==nil)
        {
            NFTutorialOverlay *updateMsg=[[NFTutorialOverlay alloc]initWithOverlay];
            
            [updateMsg showOverlay:NFPostUpdate];
            
            fHelper.userFpTag=appDelegate.storeTag;
            
            [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"updateMsgtutorial"];
        }
    }
    
}

-(void)isTutorialView:(BOOL)available
{
    
    if (!available)
    {
        if(viewHeight == 480)
        {
            [[[[UIApplication sharedApplication] delegate] window] addSubview:tutorialOverlayiPhone4View];
        }
        
        else
        {
            [[[[UIApplication sharedApplication] delegate] window]addSubview:tutorialOverlayView];
        }
        
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"1st Login"];
        
        NSDate *secondLoginTime = [NSDate date];
        
        [fHelper updateUserSettingWithValue:secondLoginTime forKey:@"1stLoginCloseDate"];
    }
    
}


-(void)is2ndLoginView:(BOOL)available
{
    if (!available)
    {
        PopUpView *customPopUp=[[PopUpView alloc]init];
        customPopUp.delegate=self;
        customPopUp.titleText=@"Tell the world!";
        customPopUp.descriptionText=@"Your website is turning out well.Why don't you tell your friends about it? Share it on facebook and twitter";
        customPopUp.popUpImage=[UIImage imageNamed:@"sharewebsite.png"];
        customPopUp.successBtnText=@"Share Now";
        customPopUp.cancelBtnText=@"Later";
        customPopUp.tag=1001;
        [customPopUp showPopUpView];
        
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"2nd Login"];
        
        NSDate *secondLoginTime = [NSDate date];
        
        [fHelper updateUserSettingWithValue:secondLoginTime forKey:@"SecondLoginTimeStamp"];
    }
}


-(void)is3rdLoginView:(BOOL)isAvailable
{
    if (!isAvailable)
    {
        PopUpView *customPopUp=[[PopUpView alloc]init];
        customPopUp.delegate=self;
        customPopUp.titleText=@"Tell the world!";
        customPopUp.descriptionText=@"Your website is turning out well.Why don't you tell your friends about it? Share it on facebook and twitter";
        customPopUp.popUpImage=[UIImage imageNamed:@"sharewebsite.png"];
        customPopUp.successBtnText=@"Share Now";
        customPopUp.cancelBtnText=@"Later";
        customPopUp.tag=1002;
        [customPopUp showPopUpView];
        
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"3rd Login"];
    }
}


-(void)isPostUpdateTutorialView: (BOOL)isAvailable
{
    if (!isAvailable)
    {
        if(viewHeight == 480)
        {
            //[[[[UIApplication sharedApplication] delegate] window] addSubview:tutorialOverlayiPhone4View];
            
        }
        
        else
        {
            //[[[[UIApplication sharedApplication] delegate] window]addSubview:tutorialOverlayView];
        }
        
        FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
        
        fHelper.userFpTag=appDelegate.storeTag;
        
        [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"1st Login"];
        
        NSDate *secondLoginTime = [NSDate date];
        
        [fHelper updateUserSettingWithValue:secondLoginTime forKey:@"1stLoginCloseDate"];
    }
    
}



-(void)setparallaxImage
{
    
    NSString *catText = [appDelegate.storeDetailDictionary objectForKey:@"Categories"];
    
    UIImageView *gradient = [[UIImageView alloc]initWithFrame:CGRectMake(parallelaxImageView.frame.origin.x, parallelaxImageView.frame.origin.y, parallelaxImageView.frame.size.width, parallelaxImageView.frame.size.height)];
    
    gradient.image = [UIImage imageNamed:@"Cover-Gradient"];
    
    
    
    if ([catText isEqualToString:@"GENERAL"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"yellow.jpg"]];
        
        
    }
    
    else if ([catText isEqualToString:@"FLOATINGPOINT"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"yellow.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"FASHION"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"fashion.jpg"]];
    }
    
    
    else if ([catText isEqualToString:@"HEALTH"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"health.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"AYURVEDA"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"ayurveda.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"REAL ESTATE"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"realestate.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"KIDS"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"kids.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"MARBLES"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"marbles.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"BEAUTY"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"make-over.jpg"]];
    }
    
    
    else if ([catText isEqualToString:@"RESTAURANT"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"Restaurant.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"RETAIL"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"retails.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"JEWELLRY"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"jewellry.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"LEATHER"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"leather.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"CAFE"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"cafe.jpg"]];
    }
    
    
    else if ([catText isEqualToString:@"GYM"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"gym.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"CHEMICAL"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"chemical.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"EDUCATION"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"education.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"HOMEAPPLIANCES"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"homeappliances.jpg"]];
    }
    
    else if ([catText isEqualToString:@"OILGAS"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"oil&gas.jpg"]];
        
    }
    
    else if ([catText isEqualToString:@"TRAVEL"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"travel.jpg"]];
    }
    
    
    else if ([catText isEqualToString:@"ICE-CREAM"])
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"icecream.jpg"]];
        
    }
    else
    {
        [parallelaxImageView setImage:[UIImage imageNamed:@"yellow.jpg"]];
        
    }
    
    [parallelaxImageView addSubview:gradient];
    
    websiteUrl = [[UILabel alloc] initWithFrame:CGRectMake(10, 140, 300, 30)];
    
    websiteUrl.textColor = [UIColor colorFromHexCode:@"#FFFFFF"];
    
    websiteUrl.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:14];
    
    websiteUrl.textAlignment = NSTextAlignmentCenter;
    [websiteUrl setText:[NSString stringWithFormat:@"%@.nowfloats.com",[appDelegate.storeTag lowercaseString]]];
    [parallelaxImageView addSubview:storeTagLabel];
    
   // webUrl.text = [webUrl.text stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    
    
    [parallelaxImageView addSubview:storeTitleLabel];
    webUrl.frame = CGRectMake(108, 80, 200, 60);
    
    
    
    [parallelaxImageView addSubview:webUrl];
    
    //[parallelaxImageView addSubview:imageBackView];
    
    [parallax addSubview:parallelaxImageView];
    
    
    
}


-(void)setStoreImage
{
    if (![appDelegate.primaryImageUri isEqualToString:@""])
    {
        [primaryImageView setAlpha:1.0];
        
        NSString *imageUriSubString=[appDelegate.primaryImageUri  substringToIndex:5];
        
        if ([imageUriSubString isEqualToString:@"local"])
        {
            NSString *imageStringUrl=[NSString stringWithFormat:@"%@",[appDelegate.primaryImageUri substringFromIndex:5]];
            
            [primaryImageView setImage:[UIImage imageWithContentsOfFile:imageStringUrl]];
        }
        
        else
        {
            NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,appDelegate.primaryImageUri];
            
            [primaryImageView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
        }
    }
    
    else
    {
        [primaryImageView   setImage:[UIImage imageNamed:@"defaultPrimaryimage.png"]];
        [primaryImageView setAlpha:0.6];
    }
    
    CALayer* containerLayer = [CALayer layer];
    //primaryImageView.layer.cornerRadius = 5.0;
    primaryImageView.layer.masksToBounds = YES;
    containerLayer.borderWidth=5.0;
    containerLayer.borderColor=[UIColor whiteColor].CGColor;
    [containerLayer addSublayer:primaryImageView.layer];
    [parallax.layer addSublayer:containerLayer];
    
    
    primaryImageView.layer.borderWidth = 2.50f;
    primaryImageView.layer.borderColor = [UIColor whiteColor].CGColor;
    primaryImageView.layer.cornerRadius = 3.0f;
    
    [primaryImageView setContentMode:UIViewContentModeScaleAspectFill];
}


-(void)setUpArray
{
    [self clearObjectInArray];
    
    if ([appDelegate.deletedFloatsArray count])
    {
        for (int i=0; i<[appDelegate.deletedFloatsArray count]; i++)
        {
            for (int j=0; j<[appDelegate.dealId count]; j++)
            {
                if ([[appDelegate.dealId objectAtIndex:j] isEqual:[appDelegate.deletedFloatsArray objectAtIndex:i]])
                {
                    [appDelegate.dealId removeObjectAtIndex:j];
                    [appDelegate.dealDescriptionArray removeObjectAtIndex:j];
                    [appDelegate.dealDateArray removeObjectAtIndex:j];
                    [appDelegate.dealImageArray removeObjectAtIndex:j];
                    [appDelegate.arrayToSkipMessage removeObjectAtIndex:j];
                }
            }
        }
        
        [dealDescriptionArray addObjectsFromArray:appDelegate.dealDescriptionArray];
        [dealDateArray addObjectsFromArray:appDelegate.dealDateArray];
        [dealId addObjectsFromArray:appDelegate.dealId];
        [dealImageArray addObjectsFromArray:appDelegate.dealImageArray];
        [arrayToSkipMessage addObjectsFromArray:appDelegate.arrayToSkipMessage];
        
    }
    
    
    else
    {
        [dealDescriptionArray addObjectsFromArray:appDelegate.dealDescriptionArray];
        [dealDateArray addObjectsFromArray:appDelegate.dealDateArray];
        [dealId addObjectsFromArray:appDelegate.dealId];
        [dealImageArray addObjectsFromArray:appDelegate.dealImageArray];
        [arrayToSkipMessage addObjectsFromArray:appDelegate.arrayToSkipMessage];
    }
    
    //--Set the initial skip by value here--//
    messageSkipCount=[arrayToSkipMessage count];
}


-(void)clearObjectInArray
{
    
    [dealDescriptionArray removeAllObjects];
    
    [dealDateArray removeAllObjects];
    
    [dealId removeAllObjects];
    
    [dealImageArray removeAllObjects];
    
    [arrayToSkipMessage removeAllObjects];
    
}


- (void)updateView
{
    [self.messageTableView
     reloadData];
    
    if (dealDescriptionArray.count==0)
    {
        [self showNoUpdateView];
    }
}


- (IBAction)noUpdateBtnClicked:(id)sender
{
    [self pushPostMessageController];
}


-(UIImage*)rotate:(UIImageOrientation)orient
{
    CGRect             bnds = CGRectZero;
    UIImage*           copy = nil;
    CGContextRef       ctxt = nil;
    CGRect             rect = CGRectZero;
    CGAffineTransform  tran = CGAffineTransformIdentity;
    
    bnds.size = uploadPictureImgView.image.size;
    rect.size = uploadPictureImgView.image.size;
    
    switch (orient)
    {
        case UIImageOrientationUp:
            return uploadPictureImgView.image;
            
        case UIImageOrientationUpMirrored:
            tran = CGAffineTransformMakeTranslation(rect.size.width, 0.0);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown:
            tran = CGAffineTransformMakeTranslation(rect.size.width,
                                                    rect.size.height);
            tran = CGAffineTransformRotate(tran, degreesToRadians(180.0));
            break;
            
        case UIImageOrientationDownMirrored:
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.height);
            tran = CGAffineTransformScale(tran, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeft:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeTranslation(0.0, rect.size.width);
            tran = CGAffineTransformRotate(tran, degreesToRadians(-90.0));
            break;
            
        case UIImageOrientationLeftMirrored:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeTranslation(rect.size.height,
                                                    rect.size.width);
            tran = CGAffineTransformScale(tran, -1.0, 1.0);
            tran = CGAffineTransformRotate(tran, degreesToRadians(-90.0));
            break;
            
        case UIImageOrientationRight:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeTranslation(rect.size.height, 0.0);
            tran = CGAffineTransformRotate(tran, degreesToRadians(90.0));
            break;
            
        case UIImageOrientationRightMirrored:
            bnds.size = swapWidthAndHeight(bnds.size);
            tran = CGAffineTransformMakeScale(-1.0, 1.0);
            tran = CGAffineTransformRotate(tran, degreesToRadians(90.0));
            break;
            
        default:
            // orientation value supplied is invalid
            assert(false);
            return nil;
    }
    
    UIGraphicsBeginImageContext(bnds.size);
    ctxt = UIGraphicsGetCurrentContext();
    
    switch (orient)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextScaleCTM(ctxt, -1.0, 1.0);
            CGContextTranslateCTM(ctxt, -rect.size.height, 0.0);
            break;
            
        default:
            CGContextScaleCTM(ctxt, 1.0, -1.0);
            CGContextTranslateCTM(ctxt, 0.0, -rect.size.height);
            break;
    }
    
    CGContextConcatCTM(ctxt, tran);
    CGContextDrawImage(ctxt, rect, uploadPictureImgView.image.CGImage);
    
    copy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return copy;
}


-(void)writeImageToDocuments
{
    
    NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    
    NSRange range = NSMakeRange (0,5);
    
    uuid=[uuid substringWithRange:range];
    
    NSCharacterSet *removeCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
    
    uuid = [[uuid componentsSeparatedByCharactersInSet: removeCharSet] componentsJoinedByString: @""];
    
    NSString *imageName=[NSString stringWithFormat:@"%@.jpg",uuid];
    
    NSData* imageData = UIImageJPEGRepresentation(uploadPictureImgView.image, 0.1);
    
    NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString* documentsDirectory = [paths objectAtIndex:0];
    
    NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
    
    appDelegate.localImageUri=[NSMutableString stringWithFormat:@"local%@",fullPathToFile];
    
    [imageData writeToFile:fullPathToFile atomically:NO];
    
}

-(void)pushPostMessageController
{
    PostMessageViewController *messageController=[[PostMessageViewController alloc]initWithNibName:@"PostMessageViewController" bundle:nil];
    
    messageController.isFromHomeView=YES;
    
    messageController.delegate=self;
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:messageController];
    
    navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    //navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:navigationController animated:YES completion:nil];
}


#pragma UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (alertView.tag==1)
    {
        if (buttonIndex==1)
        {
            [self pushPostMessageController];
        }
    }
    
    else if (alertView.tag==2)
    {
        if (buttonIndex==1)
        {
            [sendToSubscribersOnButton setHidden:YES];
            [sendToSubscribersOffButton setHidden:NO];
            isSendToSubscribers=NO;
        }
    }
    
    else if(alertView.tag==4)
    {
        if (buttonIndex==1)
        {
            if(!_engine)
            {
                _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
                _engine.consumerKey    = kOAuthConsumerKey;
                _engine.consumerSecret = kOAuthConsumerSecret;
            }
            
            if(![_engine isAuthorized])
            {
                UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];
                if (controller)
                {
                    [self presentViewController:controller animated:YES completion:nil];
                }
            }
        }
    }
    
    
    
    else if (alertView.tag==1100)
    {
        if (buttonIndex==1)
        {
            isPictureMessage = NO;
            isCancelPictureMessage = NO;
            [self closeContentCreateSubview];
            uploadPictureImgView.image=[UIImage imageNamed:@""];
            [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimageplaceholder.png"] forState:UIControlStateNormal];
            [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimagepostupdateonclick.png"] forState:UIControlStateHighlighted];
        }
    }
    
    else if (alertView.tag ==2001)
    {
        {
            if (buttonIndex==1)
            {
                [self closeContentCreateSubview];
                [socialActivity showCustomActivityView];
                
                
                [[SocialSettingsFBHelper sharedInstance]requestLoginAsAdmin:NO WithCompletionHandler:^(BOOL Success, NSDictionary *fbUserDetails)
                 {
                     if (Success)
                     {
                         [facebookButton setHidden:YES];
                         [selectedFacebookButton setHidden:NO];
                         isFacebookSelected = YES;
                         [userDetails setObject:[fbUserDetails objectForKey:@"id"] forKey:@"NFManageFBUserId"];
                         [userDetails setObject:[fbUserDetails objectForKey:@"name"] forKey:@"NFFacebookName"];
                         [userDetails synchronize];
                         [socialActivity hideCustomActivityView];
                         [self openContentCreateSubview];
                     }
                     
                     else
                     {
                         isFacebookSelected = NO;
                         [facebookButton setHidden:NO];
                         [selectedFacebookButton setHidden:YES];
                         [socialActivity hideCustomActivityView];
                         [self openContentCreateSubview];
                     }
                 }];
                
            }
        }
        
    }
    
    
    else if (alertView.tag == 2002)
    {
        if (buttonIndex==1)
        {
            [self closeContentCreateSubview];
            
            [socialActivity showCustomActivityView];
            
            [[SocialSettingsFBHelper sharedInstance]requestLoginAsAdmin:YES WithCompletionHandler:^(BOOL Success, NSDictionary *fbPageUserDetails)
             {
                 if (Success)
                 {
                     if ([[fbPageUserDetails objectForKey:@"data"] count]>0)
                     {
                         [appDelegate.socialNetworkNameArray removeAllObjects];
                         [appDelegate.fbUserAdminArray removeAllObjects];
                         [appDelegate.fbUserAdminIdArray removeAllObjects];
                         [appDelegate.fbUserAdminAccessTokenArray removeAllObjects];
                         
                         NSMutableArray *userAdminInfo=[[NSMutableArray alloc]init];
                         
                         [userAdminInfo addObjectsFromArray:[fbPageUserDetails objectForKey:@"data"]];
                         
                         [self assignFbDetails:[fbPageUserDetails objectForKey:@"data"]];
                         
                         for (int i=0; i<[userAdminInfo count]; i++)
                         {
                             [appDelegate.fbUserAdminArray insertObject:[[userAdminInfo objectAtIndex:i]objectForKey:@"name" ] atIndex:i];
                             
                             [appDelegate.fbUserAdminAccessTokenArray insertObject:[[userAdminInfo objectAtIndex:i]objectForKey:@"access_token" ] atIndex:i];
                             
                             [appDelegate.fbUserAdminIdArray insertObject:[[userAdminInfo objectAtIndex:i]objectForKey:@"id" ] atIndex:i];
                         }
                         [self showFbPagesSubView];
                     }
                     
                 }
                 
                 else
                 {
                     [socialActivity  hideCustomActivityView];
                     [self openContentCreateSubview];
                 }
             }];
        }
        
    }
    
    else if (alertView.tag == 1897)
    {
        if(buttonIndex == 1)
        {
            
            BizStoreViewController *storeController=[[BizStoreViewController alloc]initWithNibName:@"BizStoreViewController" bundle:Nil];
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:storeController];
            
            [revealController setFrontViewController:navigationController animated:NO];
        }
    }
    
    
    
}

#pragma UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if(headArray.count == 0)
    {
        return dealDescriptionArray.count;
    }
    else
    {
        return dealDescriptionArray.count + 1;
    }
    
}




- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
   
    @try {
        
        if(headArray.count != 0)
        {
            if(indexPath.row == 0)
            {
                static  NSString *identifier = @"SiteMeterHomeView";
                
                SiteMeterHomeView *cell = (SiteMeterHomeView *)[tableView dequeueReusableCellWithIdentifier:identifier];
                
                
                if (cell==nil)
                {
                    
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"SiteMeterHomeView" owner:self options:nil];
                    
                    cell = [nib objectAtIndex:0];
                }
                
                cell.frame = CGRectMake(10, cell.frame.origin.y, 300, cell.frame.size.height);
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                
                
                cell.progressText.text = [NSString stringWithFormat:@"%d%@ Site Complete",percentageComplete,@"%"];
                
                cell.myProgress.progress = percentComplete;
                CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 20.0f);
                cell.myProgress.transform = transform;
                
                
                NSString *descText = [descArray objectAtIndex:0];
                
                NSString *percentText = [percentageArray objectAtIndex:0];
                
                cell.headLabel.text = [NSString stringWithFormat:@"%@ %@",descText,percentText];
                
                
                
                
                UIButton *actButton  = [[UIButton alloc] initWithFrame:CGRectMake(235, 8, 70, 25)];
                [actButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                
                [actButton addTarget:self action:@selector(siteMeterBtnClicked) forControlEvents:UIControlEventTouchUpInside];
                actButton.backgroundColor = [UIColor colorFromHexCode:@"#ffb900"];
                
                if([descText isEqualToString:@"Add Business Name"])
                {
                    [actButton setTitle:@"Add" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newTwitter.png"];
                }
                
                else if([descText isEqualToString:@"Describe your business"])
                {
                    [actButton setTitle:@"Add" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"Description.png"];
                }
                else if([descText isEqualToString:@"Add Business Category"])
                {
                    [actButton setTitle:@"Add" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newTwitter.png"];
                }
                else if([descText isEqualToString:@"Add a relevant Image"])
                {
                    [actButton setTitle:@"Upload" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"Picture-Update.png"];
                }
                else if([descText isEqualToString:@"Help customers reach you instantly"])
                {
                    [actButton setTitle:@"Add" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newPhone.png"];
                }
                else if([descText isEqualToString:@"Add Email"])
                {
                    [actButton setTitle:@"Add" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newMail.png"];
                }
                else if([descText isEqualToString:@"Add Business Address"])
                {
                    [actButton setTitle:@"Add" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newAddress.png"];
                }
                else if([descText isEqualToString:@"Display Business timings"])
                {
                    [actButton setTitle:@"Buy" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newTimings.png"];
                }
                else if([descText isEqualToString:@"Post on Facebook / Twitter"])
                {
                    [actButton setTitle:@"Connect" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newTwitter.png"];
                }
                else if([descText isEqualToString:@"Update your website"])
                {
                    [actButton setTitle:@"Post" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"text-update.png"];
                    
                }
                else if([descText isEqualToString:@"Get Discovered with Auto-SEO"])
                {
                    [actButton setTitle:@"YES" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newSEO.png"];
                }
                else if([descText isEqualToString:@"Get your own domain"])
                {
                    [actButton setTitle:@"Buy" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"newCom.png"];
                }
                else if([descText isEqualToString:@"Tell the world"])
                {
                    [actButton setTitle:@"Share" forState:UIControlStateNormal];
                    cell.headImage.image = [UIImage imageNamed:@"Share-website.png"];
                }
                actButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:14];
                
                [cell.buttonView addSubview:actButton];
                
                
                
                
                
                return cell;
            }
            else
            {
                static  NSString *identifier = @"TableViewCell";
                
                
                
                HomeViewMsgCell *cell = [self.messageTableView dequeueReusableCellWithIdentifier:identifier];
                
                
                if (cell==nil)
                {
                    
                    NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"HomeViewMsgCell" owner:self options:nil];
                    
                    cell = [nib objectAtIndex:0];
                }
                
                NSString *text = [dealDescriptionArray objectAtIndex:[indexPath row]-1];
                
                
                
                NSString *_imageUriString=[dealImageArray  objectAtIndex:[indexPath row]-1];
                
                NSString *imageUriSubString;
                
                if([_imageUriString isEqualToString:@""])
                {
                    if ([text rangeOfString:@"youtube"].location==NSNotFound)
                    {
                        imageUriSubString=[_imageUriString  substringToIndex:5];
                    }
                    else
                    {
                        imageUriSubString= _imageUriString;
                    }
                }
                else
                {
                    imageUriSubString=[_imageUriString  substringToIndex:5];
                }
                
                
                
                
                
                NSString *dateString=[dealDateArray objectAtIndex:[indexPath row]-1 ];
                NSDate *date;
                
                
                if ([dateString hasPrefix:@"/Date("])
                {
                    dateString=[dateString substringFromIndex:5];
                    dateString=[dateString substringToIndex:[dateString length]-1];
                    date=[self getDateFromJSON:dateString];
                    
                }
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"IST"]];
                [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
                [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
                
                NSString *dealDate=[dateFormatter stringFromDate:date];
                
                
                
                
                NSString *stringData;
                
                if ([[dealImageArray objectAtIndex:[indexPath row]-1] isEqualToString:@"/Deals/Tile/deal.png"])
                {
                    stringData=[NSString stringWithFormat:@"%@\n\n%@\n",text,dealDate];
                }
                
                
                else if ( [[dealImageArray objectAtIndex:[indexPath row]-1]isEqualToString:@"/BizImages/Tile/.jpg" ])
                {
                    stringData=[NSString stringWithFormat:@"%@\n\n%@\n",text,dealDate];
                }
                
                else
                {
                    
                    version = [[UIDevice currentDevice] systemVersion];
                    
                    if ([version floatValue]<7.0)
                    {
                        stringData=[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n%@\n\n%@\n",text,dealDate];
                    }
                    
                    
                    else
                    {
                        stringData=[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n%@\n\n%@\n",text,dealDate];
                    }
                    
                }
                
                [cell.postedDateLabel setText:[NSString stringWithFormat:@"%@",dealDate]];
                
                [cell.postDateLabel1 setText:[NSString stringWithFormat:@"%@",dealDate]];
                [cell.postDateLabel2 setText:[NSString stringWithFormat:@"%@",dealDate]];
                
                [cell.postDateLabel4 setText:[NSString stringWithFormat:@"%@",dealDate]];
                [cell.postConLabel2 setText:text];
                [cell.postConLabel1 setText:text];
                [cell.postConLabel3 setText:text];
                [cell.postConLabel4 setText:text];
                
                UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
                NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                                 NSForegroundColorAttributeName: [UIColor blackColor]};
                NSString *text1 = cell.postConLabel1.text;
                postSize = [text1 sizeWithAttributes: userAttributes];
                
                
                if ([[dealImageArray objectAtIndex:[indexPath row]-1] isEqualToString:@"/Deals/Tile/deal.png"] )
                {
                    
                    cell.posteImageView.image =[UIImage imageNamed:@""];
                    
                    if(postSize.width < 265)
                    {
                        
                        
                        cell.ImageConView.hidden = YES;
                        cell.ImageConView1.hidden = YES;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = NO;
                        
                    }
                    else
                    {
                        
                        cell.ImageConView.hidden = YES;
                        cell.ImageConView1.hidden = YES;
                        cell.postView.hidden = NO;
                        cell.postView1.hidden = YES;
                    }
                    
                    
                    
                    
                }
                
                else if ( [[dealImageArray objectAtIndex:[indexPath row]-1]isEqualToString:@"/BizImages/Tile/.jpg" ])
                {
                    NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]-1]];
                    
                    [cell.posteImageView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                    [cell.posteImageView1 setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                    
                    if(postSize.width < 265)
                    {
                        
                        
                        cell.ImageConView.hidden = YES;
                        cell.ImageConView1.hidden = NO;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = YES;
                        
                    }
                    else
                    {
                        
                        cell.ImageConView.hidden = NO;
                        cell.ImageConView1.hidden = YES;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = YES;
                    }
                    
                    
                    
                }
                
                else if ([imageUriSubString isEqualToString:@"local"])
                {
                    
                    NSString *imageStringUrl=[NSString stringWithFormat:@"%@",[[dealImageArray objectAtIndex:[indexPath row]-1] substringFromIndex:5]];
                    
                    cell.posteImageView.image=[UIImage imageWithContentsOfFile:imageStringUrl];
                    cell.posteImageView1.image=[UIImage imageWithContentsOfFile:imageStringUrl];
                    
                    if(postSize.width < 265)
                    {
                        
                        
                        cell.ImageConView.hidden = YES;
                        cell.ImageConView1.hidden = NO;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = YES;
                        
                    }
                    else
                    {
                        
                        cell.ImageConView.hidden = NO;
                        cell.ImageConView1.hidden = YES;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = YES;
                    }
                }
                
                else
                {
                    NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]-1]];
                    
                    if([text rangeOfString:@"youtube"].location == NSNotFound)
                    {
                        cell.playIcon.image = [UIImage imageNamed:@""];
                    }
                    else
                    {
                        cell.playIcon.image = [UIImage imageNamed:@"playIcon.png"];
                    }
                    
                    [cell.posteImageView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                    [cell.posteImageView1 setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                    
                    if(postSize.width < 265)
                    {
                        
                        
                        cell.ImageConView.hidden = YES;
                        cell.ImageConView1.hidden = NO;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = YES;
                        
                    }
                    else
                    {
                        
                        cell.ImageConView.hidden = NO;
                        cell.ImageConView1.hidden = YES;
                        cell.postView.hidden = YES;
                        cell.postView1.hidden = YES;
                    }
                    
                }
                
                
                UITapGestureRecognizer *imgOpen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFocusView:)];
                imgOpen.numberOfTapsRequired    = 1;
                imgOpen.numberOfTouchesRequired = 1;
                cell.posteImageView.userInteractionEnabled = YES;
                [cell.posteImageView addGestureRecognizer:imgOpen];
                
                UITapGestureRecognizer *imgOpen1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFocusView:)];
                imgOpen.numberOfTapsRequired    = 1;
                imgOpen.numberOfTouchesRequired = 1;
                
                cell.posteImageView1.userInteractionEnabled = YES;
                [cell.posteImageView1 addGestureRecognizer:imgOpen1];
                cell.selectionStyle=UITableViewCellSelectionStyleNone;
                return cell;
                
                
            }
            
        }
        else
        {
            static  NSString *identifier = @"TableViewCell";
            
            
            
            HomeViewMsgCell *cell = [self.messageTableView dequeueReusableCellWithIdentifier:identifier];
            
            
            if (cell==nil)
            {
                
                NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"HomeViewMsgCell" owner:self options:nil];
                
                cell = [nib objectAtIndex:0];
            }
            
            NSString *text = [dealDescriptionArray objectAtIndex:[indexPath row]];
            
            
            
            NSString *_imageUriString=[dealImageArray  objectAtIndex:[indexPath row]];
            
            NSString *imageUriSubString;
            
            if([_imageUriString isEqualToString:@""])
            {
                if ([text rangeOfString:@"youtube"].location==NSNotFound)
                {
                    imageUriSubString=[_imageUriString  substringToIndex:5];
                }
                else
                {
                    imageUriSubString= _imageUriString;
                }
            }
            else
            {
                imageUriSubString=[_imageUriString  substringToIndex:5];
            }
            
            
            NSString *dateString=[dealDateArray objectAtIndex:[indexPath row] ];
            NSDate *date;
            
            
            if ([dateString hasPrefix:@"/Date("])
            {
                dateString=[dateString substringFromIndex:5];
                dateString=[dateString substringToIndex:[dateString length]-1];
                date=[self getDateFromJSON:dateString];
                
            }
            NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"IST"]];
            [dateFormatter setTimeStyle:NSDateFormatterLongStyle];
            [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
            
            NSString *dealDate=[dateFormatter stringFromDate:date];
            
            NSString *stringData;
            
            if ([[dealImageArray objectAtIndex:[indexPath row]] isEqualToString:@"/Deals/Tile/deal.png"])
            {
                stringData=[NSString stringWithFormat:@"%@\n\n%@\n",text,dealDate];
            }
            
            
            else if ( [[dealImageArray objectAtIndex:[indexPath row]]isEqualToString:@"/BizImages/Tile/.jpg" ])
            {
                stringData=[NSString stringWithFormat:@"%@\n\n%@\n",text,dealDate];
            }
            
            else
            {
                
                version = [[UIDevice currentDevice] systemVersion];
                
                if ([version floatValue]<7.0)
                {
                    stringData=[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n%@\n\n%@\n",text,dealDate];
                }
                
                
                else
                {
                    stringData=[NSString stringWithFormat:@"\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n%@\n\n%@\n",text,dealDate];
                }
                
            }
            
            [cell.postedDateLabel setText:[NSString stringWithFormat:@"%@",dealDate]];
            
            [cell.postDateLabel1 setText:[NSString stringWithFormat:@"%@",dealDate]];
            [cell.postDateLabel2 setText:[NSString stringWithFormat:@"%@",dealDate]];
            
            [cell.postDateLabel4 setText:[NSString stringWithFormat:@"%@",dealDate]];
            [cell.postConLabel2 setText:text];
            [cell.postConLabel1 setText:text];
            [cell.postConLabel3 setText:text];
            [cell.postConLabel4 setText:text];
            
            UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                             NSForegroundColorAttributeName: [UIColor blackColor]};
            NSString *text1 = cell.postConLabel1.text;
            postSize = [text1 sizeWithAttributes: userAttributes];
            
            if ([[dealImageArray objectAtIndex:[indexPath row]] isEqualToString:@"/Deals/Tile/deal.png"] )
            {
                cell.posteImageView.image =[UIImage imageNamed:@""];
                
                if(postSize.width < 265)
                {
                    
                    
                    cell.ImageConView.hidden = YES;
                    cell.ImageConView1.hidden = YES;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = NO;
                    
                }
                else
                {
                    
                    cell.ImageConView.hidden = YES;
                    cell.ImageConView1.hidden = YES;
                    cell.postView.hidden = NO;
                    cell.postView1.hidden = YES;
                }
            }
            
            else if ( [[dealImageArray objectAtIndex:[indexPath row]]isEqualToString:@"/BizImages/Tile/.jpg" ])
                
            {
                NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]]];
                
                [cell.posteImageView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                [cell.posteImageView1 setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                
                if(postSize.width < 265)
                {
                    
                    
                    cell.ImageConView.hidden = YES;
                    cell.ImageConView1.hidden = NO;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = YES;
                    
                }
                else
                {
                    
                    cell.ImageConView.hidden = NO;
                    cell.ImageConView1.hidden = YES;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = YES;
                }
                
                
                
            }
            
            else if ([imageUriSubString isEqualToString:@"local"])
            {
                
                NSString *imageStringUrl=[NSString stringWithFormat:@"%@",[[dealImageArray objectAtIndex:[indexPath row]] substringFromIndex:5]];
                
                cell.posteImageView.image=[UIImage imageWithContentsOfFile:imageStringUrl];
                cell.posteImageView1.image=[UIImage imageWithContentsOfFile:imageStringUrl];
                
                if(postSize.width < 265)
                {
                    
                    
                    cell.ImageConView.hidden = YES;
                    cell.ImageConView1.hidden = NO;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = YES;
                    
                }
                else
                {
                    
                    cell.ImageConView.hidden = NO;
                    cell.ImageConView1.hidden = YES;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = YES;
                }
            }
            
            else
            {
                NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]]];
                
                if([text rangeOfString:@"youtube"].location == NSNotFound)
                {
                    cell.playIcon.image = [UIImage imageNamed:@""];
                }
                else
                {
                    cell.playIcon.image = [UIImage imageNamed:@"playIcon.png"];
                }
                
                [cell.posteImageView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                [cell.posteImageView1 setImageWithURL:[NSURL URLWithString:imageStringUrl]];
                if(postSize.width < 265)
                {
                    
                    
                    cell.ImageConView.hidden = YES;
                    cell.ImageConView1.hidden = NO;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = YES;
                    
                }
                else
                {
                    
                    cell.ImageConView.hidden = NO;
                    cell.ImageConView1.hidden = YES;
                    cell.postView.hidden = YES;
                    cell.postView1.hidden = YES;
                }
                
            }
            
            
            UITapGestureRecognizer *imgOpen = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFocusView:)];
            imgOpen.numberOfTapsRequired    = 1;
            imgOpen.numberOfTouchesRequired = 1;
            cell.posteImageView.userInteractionEnabled = YES;
            [cell.posteImageView addGestureRecognizer:imgOpen];
            
            UITapGestureRecognizer *imgOpen1 = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showFocusView:)];
            imgOpen.numberOfTapsRequired    = 1;
            imgOpen.numberOfTouchesRequired = 1;
            
            cell.posteImageView1.userInteractionEnabled = YES;
            [cell.posteImageView1 addGestureRecognizer:imgOpen1];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            return cell;
            
            
            
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in populating tableview %@",exception);
    }
    
    
    
    
}



#pragma UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    
    @try {
        if (tableView.tag==1)
        {
            if(headArray.count == 0)
            {
                [mixpanel track:@"Message details"];
                
                MessageDetailsViewController *messageDetailsController=[[MessageDetailsViewController alloc]initWithNibName:@"MessageDetailsViewController" bundle:nil];
                
                messageDetailsController.delegate=self;
                [self.navigationController.navigationBar removeGestureRecognizer:tapRecon];
                
                NSString *dateString=[dealDateArray objectAtIndex:[indexPath row]];
                
                NSDate *date;
                
                if ([dateString hasPrefix:@"/Date("])
                {
                    dateString=[dateString substringFromIndex:5];
                    
                    dateString=[dateString substringToIndex:[dateString length]-1];
                    
                    date=[self getDateFromJSON:dateString];
                    
                }
                
                NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
                
                [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
                
                messageDetailsController.messageDate=[dateFormatter stringFromDate:date];
                
                messageDetailsController.messageDescription=[dealDescriptionArray objectAtIndex:[indexPath row]];
                
                messageDetailsController.messageId=[dealId objectAtIndex:[indexPath row]];
                
                messageDetailsController.dealImageUri=[dealImageArray objectAtIndex:[indexPath row]];
                
                messageDetailsController.currentRow=[NSNumber numberWithInt:[indexPath row]];
                
                messageDetailsController.rawMessageDate=date;
                
                [self setTitle:@"Home"];
                
                [self.navigationController pushViewController:messageDetailsController animated:YES];
            }
            else
            {
                if(indexPath.row != 0)
                {
                    [mixpanel track:@"Message details"];
                    
                    MessageDetailsViewController *messageDetailsController=[[MessageDetailsViewController alloc]initWithNibName:@"MessageDetailsViewController" bundle:nil];
                    
                    messageDetailsController.delegate=self;
                    [self.navigationController.navigationBar removeGestureRecognizer:tapRecon];
                    
                    NSString *dateString=[dealDateArray objectAtIndex:[indexPath row]-1];
                    
                    NSDate *date;
                    
                    if ([dateString hasPrefix:@"/Date("])
                    {
                        dateString=[dateString substringFromIndex:5];
                        
                        dateString=[dateString substringToIndex:[dateString length]-1];
                        
                        date=[self getDateFromJSON:dateString];
                        
                    }
                    
                    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc] init];
                    
                    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"PST"]];
                    
                    [dateFormatter setDateFormat:@"dd MMMM, yyyy"];
                    
                    messageDetailsController.messageDate=[dateFormatter stringFromDate:date];
                    
                    messageDetailsController.messageDescription=[dealDescriptionArray objectAtIndex:[indexPath row]-1];
                    
                    messageDetailsController.messageId=[dealId objectAtIndex:[indexPath row]-1];
                    
                    messageDetailsController.dealImageUri=[dealImageArray objectAtIndex:[indexPath row]-1];
                    
                    messageDetailsController.currentRow=[NSNumber numberWithInt:[indexPath row]-1];
                    
                    messageDetailsController.rawMessageDate=date;
                    
                    [self setTitle:@"Home"];
                    
                    [self.navigationController pushViewController:messageDetailsController animated:YES];
                }
                else
                {
                    [mixpanel track:@"Site meter clicked"];
                    
                    [self talkToUs];
                }
                
                
            }
            
            
        }
        
        else
        {
            NSArray *a1=[NSArray arrayWithObject:[appDelegate.fbUserAdminArray objectAtIndex:[indexPath  row]]];
            
            NSArray *a2=[NSArray arrayWithObject:[appDelegate.fbUserAdminAccessTokenArray objectAtIndex:[indexPath row]]];
            
            NSArray *a3=[NSArray arrayWithObject:[appDelegate.fbUserAdminIdArray objectAtIndex:[indexPath row]]];
            
            [appDelegate.socialNetworkNameArray addObjectsFromArray:a1];
            [appDelegate.socialNetworkAccessTokenArray addObjectsFromArray:a2];
            [appDelegate.socialNetworkIdArray addObjectsFromArray:a3];
            
            [tableView deselectRowAtIndexPath:indexPath animated:NO];
            
            [userDetails setObject:a1 forKey:@"FBUserPageAdminName"];
            [userDetails setObject:a2 forKey:@"FBUserPageAdminAccessToken"];
            [userDetails setObject:a3 forKey:@"FBUserPageAdminId"];
            
            [userDetails synchronize];
            
            [fbPageSubView setHidden:YES];
            
            [selectedFacebookPageButton setHidden:NO];
            [facebookPageButton setHidden:YES];
            
            isFacebookPageSelected = YES;
            
            [self openContentCreateSubview];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Exception in did select is %@",exception);
        
    }
    
    
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(headArray.count > 0)
    {
        if(indexPath.row == 0)
        {
            return 100;
        }
        else
        {
            NSString *stringData=[NSString stringWithFormat:@"%@",[dealDescriptionArray objectAtIndex:[indexPath row]-1]];
            
            
            UITextView *text1 = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 273, 79)];
            
            text1.text = stringData;
            
            UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
            NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                             NSForegroundColorAttributeName: [UIColor blackColor]};
            NSString *text2 = text1.text;
            CGSize size = [text2 sizeWithAttributes: userAttributes];
            
            
                if ([[dealImageArray objectAtIndex:[indexPath row]-1] isEqualToString:@"/Deals/Tile/deal.png"] )
                {
                    if(size.width < 265)
                    {
                        return 80.0f;
                    }
                    else
                    {
                        return 117.0f;
                        
                    }
                    
                }
                
                else
                {
                    if(size.width < 265)
                    {
                        return 208.0f;
                    }
                    else
                    {
                        return 252.0f;
                    }
                }
            }
   
    }
    else
    {
        NSString *stringData=[NSString stringWithFormat:@"%@",[dealDescriptionArray objectAtIndex:[indexPath row]]];
        
        
        UITextView *text1 = [[UITextView alloc]initWithFrame:CGRectMake(0, 0, 273, 79)];
        
        text1.text = stringData;
        
        UIFont *font = [UIFont fontWithName:@"Helvetica Neue" size:15];
        NSDictionary *userAttributes = @{NSFontAttributeName: font,
                                         NSForegroundColorAttributeName: [UIColor blackColor]};
        NSString *text2 = text1.text;
        CGSize size = [text2 sizeWithAttributes: userAttributes];
        
        
        if ([[dealImageArray objectAtIndex:[indexPath row]] isEqualToString:@"/Deals/Tile/deal.png"] )
        {
            if(size.width < 265)
            {
                return 80.0f;
            }
            else
            {
                return 117.0f;
                
            }
            
        }
        
        else
        {
            if(size.width < 265)
            {
                return 208.0f;
            }
            else
            {
                return 252.0f;
            }
        }
    }
}

-(void)siteMeterBtnClicked
{
    if([[headArray objectAtIndex:0] isEqualToString:@"Business Name"])
    {
        BusinessDetailsViewController *businessName=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessName animated:YES completion:nil];
    }
    
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Business Description"])
    {
        BusinessDetailsViewController *businessName=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessName animated:YES completion:nil];
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Business Category"])
    {
        BusinessDetailsViewController *businessName=[[BusinessDetailsViewController alloc]initWithNibName:@"BusinessDetailsViewController" bundle:Nil];
        
        [self.navigationController presentViewController:businessName animated:YES completion:nil];
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Featured Image"])
    {
        
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Phone Number"])
    {
        BusinessContactViewController *mobileNumber=[[BusinessContactViewController alloc]initWithNibName:@"BusinessContactViewController" bundle:Nil];
        
        [self.navigationController pushViewController:mobileNumber animated:YES];
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Email"])
    {
        BusinessContactViewController *mobileNumber=[[BusinessContactViewController alloc]initWithNibName:@"BusinessContactViewController" bundle:Nil];
        
        [self.navigationController pushViewController:mobileNumber animated:YES];
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Help your customers find you"])
    {
        BusinessAddressViewController *businessAddress=[[BusinessAddressViewController alloc]initWithNibName:@"BusinessAddressViewController" bundle:Nil];
        
        [self.navigationController pushViewController:businessAddress animated:YES];
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Business Hours"])
    {
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
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Get Social"])
    {
        SettingsViewController *facebook=[[SettingsViewController alloc]initWithNibName:@"SettingsViewController" bundle:Nil];
        facebook.isGestureAvailable = NO;
        
        [self.navigationController pushViewController:facebook animated:YES];
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Post 5 Updates"])
    {
        
        
        [self performSelector:@selector(createContentBtnClicked:) withObject:self afterDelay:0.3f];
        
    }
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Get Discovered"])
    {
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
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Get your own identity"])
    {
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
    else if([[headArray objectAtIndex:0]  isEqualToString:@"Share"])
    {
        UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Message",@"Facebook",@"Twitter",@"Whatsapp", nil];
        selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        selectAction.tag=4;
        [selectAction showInView:self.view];
    }
}



- (void)showFocusView:(UITapGestureRecognizer *)gestureRecognizer {
    
    
    
	NSIndexPath *indexPath = [self.messageTableView indexPathForRowAtPoint:[gestureRecognizer locationInView:self.messageTableView]];
    
    UIImageView *animateImgView = [[UIImageView alloc]init];
    
    if(headArray.count > 0)
    {
        
        NSString *text = [dealDescriptionArray objectAtIndex:[indexPath row]-1];
        
        
        
        NSString *_imageUriString=[dealImageArray  objectAtIndex:[indexPath row]-1];
        
        NSString *imageUriSubString;
        
        if([_imageUriString isEqualToString:@""])
        {
            if ([text rangeOfString:@"youtube"].location==NSNotFound)
            {
                imageUriSubString=[_imageUriString  substringToIndex:5];
            }
            else
            {
                imageUriSubString= _imageUriString;
            }
        }
        else
        {
            imageUriSubString=[_imageUriString  substringToIndex:5];
        }
        
        if ([[dealImageArray objectAtIndex:[indexPath row]-1] isEqualToString:@"/Deals/Tile/deal.png"] )
        {
            
        }
        
        else if ( [[dealImageArray objectAtIndex:[indexPath row]-1]isEqualToString:@"/BizImages/Tile/.jpg" ])
        {
            NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]-1]];
            
            [animateImgView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
            
            
            
        }
        
        else if ([imageUriSubString isEqualToString:@"local"])
        {
            
            NSString *imageStringUrl=[NSString stringWithFormat:@"%@",[[dealImageArray objectAtIndex:[indexPath row]-1] substringFromIndex:5]];
            
            animateImgView.image=[UIImage imageWithContentsOfFile:imageStringUrl];
            
            
            
        }
        
        else
        {
            NSString *text = [dealDescriptionArray objectAtIndex:[indexPath row]-1];
            
            if([text rangeOfString:@"youtube"].location == NSNotFound)
            {
                NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]-1]];
                
                [animateImgView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
            }
            else
            {
                NSString *vID = nil;
                NSString *url = text;
                
                NSString *query = [url componentsSeparatedByString:@"?"][1];
                NSArray *pairs = [query componentsSeparatedByString:@"&"];
                for (NSString *pair in pairs) {
                    NSArray *kv = [pair componentsSeparatedByString:@"="];
                    if ([kv[0] isEqualToString:@"v"]) {
                        vID = kv[1];
                        break;
                    }
                }
                UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(20, 100, 280, 180)];
                self.navigationController.navigationBarHidden = YES;
                
                [youtubeView addSubview:webview];
                [self.view addSubview:youtubeView];
                
                
                NSString *newEmbedCode = [NSString stringWithFormat:@"<iframe width=\"265\" height=\"200\" src=\"https://www.youtube.com/embed/%@?modestbranding=0&;rel=0&;showinfo=0;autohide=1\" frameborder=\"0\" allowfullscreen></iframe>",vID];
                
                [webview loadHTMLString:newEmbedCode baseURL:nil];
                
            }
            
        }
        
        
    }
    else
    {
        NSString *text = [dealDescriptionArray objectAtIndex:[indexPath row]-1];
        
        
        
        NSString *_imageUriString=[dealImageArray  objectAtIndex:[indexPath row]-1];
        
        NSString *imageUriSubString;
        
        if([_imageUriString isEqualToString:@""])
        {
            if ([text rangeOfString:@"youtube"].location==NSNotFound)
            {
                imageUriSubString=[_imageUriString  substringToIndex:5];
            }
            else
            {
                imageUriSubString= _imageUriString;
            }
        }
        else
        {
            imageUriSubString=[_imageUriString  substringToIndex:5];
        }
        
        if ([[dealImageArray objectAtIndex:[indexPath row]] isEqualToString:@"/Deals/Tile/deal.png"] )
        {
            
        }
        
        else if ( [[dealImageArray objectAtIndex:[indexPath row]]isEqualToString:@"/BizImages/Tile/.jpg" ])
            
        {
            NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]]];
            
            [animateImgView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
            
            
            
        }
        
        else if ([imageUriSubString isEqualToString:@"local"])
        {
            
            NSString *imageStringUrl=[NSString stringWithFormat:@"%@",[[dealImageArray objectAtIndex:[indexPath row]] substringFromIndex:5]];
            
            animateImgView.image=[UIImage imageWithContentsOfFile:imageStringUrl];
            
            
            
        }
        
        else
        {
            NSString *text = [dealDescriptionArray objectAtIndex:[indexPath row]];
            
            if([text rangeOfString:@"youtube"].location == NSNotFound)
            {
                NSString *imageStringUrl=[NSString stringWithFormat:@"%@%@",appDelegate.apiUri,[dealImageArray objectAtIndex:[indexPath row]]];
                
                [animateImgView setImageWithURL:[NSURL URLWithString:imageStringUrl]];
            }
            else
            {
                NSString *vID = nil;
                NSString *url = text;
                
                NSString *query = [url componentsSeparatedByString:@"?"][1];
                NSArray *pairs = [query componentsSeparatedByString:@"&"];
                for (NSString *pair in pairs) {
                    NSArray *kv = [pair componentsSeparatedByString:@"="];
                    if ([kv[0] isEqualToString:@"v"]) {
                        vID = kv[1];
                        break;
                    }
                }
                UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(20, 100, 280, 180)];
                self.navigationController.navigationBarHidden = YES;
                
                [youtubeView addSubview:webview];
                [self.view addSubview:youtubeView];
                
                
                NSString *newEmbedCode = [NSString stringWithFormat:@"<iframe width=\"265\" height=\"200\" src=\"https://www.youtube.com/embed/%@?modestbranding=0&;rel=0&;showinfo=0;autohide=1\" frameborder=\"0\" allowfullscreen></iframe>",vID];
                
                [webview loadHTMLString:newEmbedCode baseURL:nil];
                
            }
            
        }
        
        
    }
    
    
    
    if(animateImgView.image!=nil)
    {
        
        [self.mediaFocusController showImage:animateImgView.image fromView:gestureRecognizer.view];
        
    }
	
}




-(void)removeObjectFromTableView:(id)row
{
    [dealDescriptionArray removeObjectAtIndex:[row integerValue]];
    [dealDateArray removeObjectAtIndex:[row integerValue]];
    [dealId removeObjectAtIndex:[row integerValue]];
    [dealImageArray removeObjectAtIndex:[row integerValue]];
    [arrayToSkipMessage removeObjectAtIndex:[row integerValue]];
    messageSkipCount=arrayToSkipMessage.count+appDelegate.deletedFloatsArray.count;
    [self updateView];
}


#pragma Convert Unix Timestamp
- (NSDate*)getDateFromJSON:(NSString *)dateString
{
    // Expect date in this format "/Date(1268123281843)/"
    int startPos = [dateString rangeOfString:@"("].location+1;
    int endPos = [dateString rangeOfString:@")"].location;
    NSRange range = NSMakeRange(startPos,endPos-startPos);
    unsigned long long milliseconds = [[dateString substringWithRange:range] longLongValue];
    NSTimeInterval interval = milliseconds/1000;
    return [NSDate dateWithTimeIntervalSince1970:interval];
}


#pragma Difference Between Dates

-(NSInteger)daysBetweenDate:(NSDate*)fromDateTime andDate:(NSDate*)toDateTime
{
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&fromDate
                 interval:NULL forDate:fromDateTime];
    [calendar rangeOfUnit:NSDayCalendarUnit startDate:&toDate
                 interval:NULL forDate:toDateTime];
    
    NSDateComponents *difference = [calendar components:NSDayCalendarUnit
                                               fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}


-(void)setFooterForTableView
{
    
    if (ismoreFloatsAvailable)
    {
        
        [loadMoreButton setHidden:NO];
        
        loadMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
        
        loadMoreButton.frame = CGRectMake(80,0, 200, 50);
        
        loadMoreButton.backgroundColor=[UIColor clearColor];
        
        [loadMoreButton.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
        
        [loadMoreButton setTitle:@"Tap here for older message's" forState:UIControlStateNormal];
        
        [loadMoreButton setTitleColor:[UIColor colorWithHexString:@"454545"] forState:UIControlStateNormal];
        
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 80)];
        [footerView addSubview:loadMoreButton];
        
        messageTableView.tableFooterView=footerView;
        
        [loadMoreButton addTarget:self action:@selector(fetchMoreMessages) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
    else
    {
        [loadMoreButton setHidden:YES];
        
    }
    
    
    
}


-(void)fetchMoreMessages
{
    
    //[self performSelector:@selector(fetchMessages) withObject:nil afterDelay:0.5];
    
}


- (void)insertRowAtBottom
{
    
    dispatch_async(dispatch_get_main_queue(), ^(void)
                   
                   {
                       
                       [messageTableView.infiniteScrollingView startAnimating];
                       
                       [self fetchMessages];
                       
                   });
    
    
}


-(void)fetchMessages
{
    
    NSString *urlString=[NSString stringWithFormat:
                         @"%@/bizFloats?clientId=%@&skipBy=%d&fpId=%@",appDelegate.apiWithFloatsUri,appDelegate.clientId,messageSkipCount,[userDetails objectForKey:@"userFpId"]];
    
    NSURL *url=[NSURL URLWithString:urlString];
    
    
    BizMessage *messageController=[[BizMessage alloc]init];
    
    messageController.delegate=self;
    
    [messageController downloadBizMessages:url];
    
    
}


-(void)updateBizMessage:(NSMutableDictionary *)responseDictionary
{
    
    if (responseDictionary!=NULL)
    {
        for (int i=0; i<[[responseDictionary objectForKey:@"floats"] count]; i++)
        {
            
            [dealDescriptionArray addObject:[[[responseDictionary objectForKey:@"floats"]objectAtIndex:i ]objectForKey:@"message" ]];
            
            [dealDateArray addObject:[[[responseDictionary objectForKey:@"floats"]objectAtIndex:i ]objectForKey:@"createdOn" ]];
            
            [dealId addObject:[[[responseDictionary objectForKey:@"floats"]objectAtIndex:i ]objectForKey:@"_id" ]];
            
            [arrayToSkipMessage addObject:[[[responseDictionary objectForKey:@"floats"]objectAtIndex:i ]objectForKey:@"_id" ]];
            
            [dealImageArray addObject:[[[responseDictionary objectForKey:@"floats"]objectAtIndex:i ]objectForKey:@"tileImageUri" ]];
            
        }
        
        messageSkipCount=arrayToSkipMessage.count+appDelegate.deletedFloatsArray.count;
        
        [messageTableView.infiniteScrollingView stopAnimating];
        
        [self updateView];
        
    }
    
    else
    {
        [messageTableView.infiniteScrollingView stopAnimating];
        [self customalert:@"Check Network Connection" Seen:@"" category:1];
        
    }
    
}


-(UIImage*)grayishImage:(UIImage *)inputImage
{
    
    // Create a graphic context.
    UIGraphicsBeginImageContextWithOptions(inputImage.size, YES, 1.0);
    CGRect imageRect = CGRectMake(0, 0, inputImage.size.width, inputImage.size.height);
    
    // Draw the image with the luminosity blend mode.
    // On top of a white background, this will give a black and white image.
    [inputImage drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0];
    
    // Get the resulting image.
    UIImage *filteredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return filteredImage;
}


#pragma SWRevealViewControllerDelegate


- (NSString*)stringFromFrontViewPosition:(FrontViewPosition)position
{
    NSString *str = nil;
    
    
    
    if (position == FrontViewPositionLeft )
    {
        str = @"FrontViewPositionLeft";
        coverView.hidden = YES;
        messageTableView.scrollEnabled = YES;
        isAnimation = YES;
        
        
    }
    else if ( position == FrontViewPositionRight )
    {
        str = @"FrontViewPositionRight";
        coverView.hidden = NO;
        messageTableView.scrollEnabled = NO;
        primaryImageButton.userInteractionEnabled = NO;
        isAnimation = NO;
    }
    else if ( position == FrontViewPositionRightMost )
    {
        str = @"FrontViewPositionRightMost";
        
    }
    else if ( position == FrontViewPositionRightMostRemoved )
    {
        str = @"FrontViewPositionRightMostRemoved";
        
    }
    else if ( position == FrontViewPositionLeftSide )
    {
        str = @"FrontViewPositionLeftSide";
    }
    
    else if ( position == FrontViewPositionLeftSideMostRemoved )
    {
        str = @"FrontViewPositionLeftSideMostRemoved";
    }
    
    return str;
    
    
}



- (IBAction)cancelYoutubeVideo:(id)sender {
    
    self.navigationController.navigationBarHidden = NO;
    [youtubeView removeFromSuperview];
    
}

- (IBAction)revealFrontController:(id)sender
{
    
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeftSide"]) {
        
        [revealController performSelector:@selector(rightRevealToggle:)];
        
    }
    
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionRight"]) {
        
        [revealController performSelector:@selector(revealToggle:)];
        
    }
    
}


- (IBAction)storeTagBtnClicked:(id)sender
{
    BizWebViewController *webViewController=[[BizWebViewController alloc]initWithNibName:@"BizWebViewController" bundle:nil];
    
    
    UINavigationController *navController=[[UINavigationController  alloc]initWithRootViewController:webViewController];
    
    [self presentViewController:navController animated:YES completion:nil];
    
    webViewController=nil;
}

-(void)openMobileView
{
    [self storeTagBtnClicked:nil];
}


- (IBAction)dismissTutorialOverLayBtnClicked:(id)sender
{
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            [tutorialOverlayiPhone4View removeFromSuperview];
        }
        
        else
        {
            [tutorialOverlayView removeFromSuperview];
        }
    }
    
    
    /*
     UIButton *clickedBtn=(UIButton *)sender;
     
     if (clickedBtn.tag==1) {
     
     PopUpView *customPopUp=[[PopUpView alloc]init];
     customPopUp.delegate=self;
     customPopUp.titleText=@"Post an update";
     customPopUp.descriptionText=@"Start engaging with your customers by posting a business update.";
     customPopUp.popUpImage=[UIImage imageNamed:@"updatemsg popup.png"];
     customPopUp.successBtnText=@"Yes, Now";
     customPopUp.cancelBtnText=@"Later";
     customPopUp.tag=1003;
     [customPopUp showPopUpView];
     }
     */
    
}


- (IBAction)dismissUpdateMsgOverLayBtnClicked:(id)sender
{
    [updateMsgOverlay removeFromSuperview];
}


- (IBAction)primaryImageBtnClicked:(id)sender
{
    
    if(isAnimation)
    {
        UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Gallery", nil];
        selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        selectAction.tag=1;
        [selectAction showInView:self.view];
    }
    
    
}


-(void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    if (actionSheet.tag==1)
    {
        
        if(buttonIndex == 0)
        {
            _picker = [[UIImagePickerController alloc] init];
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            _picker.delegate = self;
            _picker.allowsEditing=YES;
            _picker.navigationBar.barStyle=UIBarStyleBlackOpaque;
            [self presentViewController:_picker animated:NO completion:nil];
            _picker=nil;
            [_picker setDelegate:nil];
        }
        
        
        if (buttonIndex==1)
        {
            _picker=[[UIImagePickerController alloc] init];
            _picker.allowsEditing=YES;
            [_picker setDelegate:self];
            //          [picker setSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
            _picker.navigationBar.barStyle=UIBarStyleBlackOpaque;
            [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:_picker animated:YES completion:NULL];
            _picker=nil;
            [_picker setDelegate:nil];
            
        }
        
    }
    
    else if (actionSheet.tag==2)
    {
        if(buttonIndex == 0)
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
        
        
        if (buttonIndex==1)
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
    }
    
    else if (actionSheet.tag == 3)
    {
        
        if(buttonIndex == 0)
        {
            if(isFromCamera)
            {
                [self createContentBtnClicked:nil];
            }
            [self closeContentCreateSubview];
            isFromCamera = NO;
            _overlay = [[NFCameraOverlay alloc] initWithNibName:@"NFCameraOverlay" bundle:nil];
            
            _picker = [[UIImagePickerController alloc] init];
            _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //  _picker.delegate=self;
            _picker.navigationBar.barStyle = UIBarStyleBlackOpaque;
            
            _picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            _picker.cameraDevice = UIImagePickerControllerCameraDeviceRear;
            _picker.cameraFlashMode= UIImagePickerControllerCameraFlashModeAuto;
            _picker.showsCameraControls = NO;
            //_picker.navigationBarHidden = YES;
            _picker.wantsFullScreenLayout = YES;
            _overlay.pickerReference = _picker;
            _picker.delegate = _overlay;
            _overlay.delegate= self;
            _picker.cameraOverlayView = _overlay.view;
            _picker.cameraViewTransform = CGAffineTransformMakeScale(1.5, 1.5);
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDelay:2.2f];
            _overlay.bottomBarSubView.alpha = 1.0f;
            [UIView commitAnimations];
            [self presentViewController:_picker animated:NO completion:nil];
        }
        
        
        else if (buttonIndex==1)
        {
            if(isFromCamera)
            {
                [self createContentBtnClicked:nil];
            }
            isFromCamera = NO;
            [self closeContentCreateSubview];
            _picker=[[UIImagePickerController alloc] init];
            [_picker setDelegate:self];
            _picker.navigationBar.contentMode = UIViewContentModeScaleAspectFit;
            [_picker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self presentViewController:_picker animated:NO completion:nil];
            _picker=nil;
            [_picker setDelegate:nil];
            
        }
        
        
        else if (buttonIndex == 2)
        {
            uploadPictureImgView.image=nil;
            
            isPictureMessage = NO;
            
            isPostPictureMessage = NO;
            
            isFromCamera = NO;
            
            [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimageplaceholder.png"] forState:UIControlStateNormal];
            
            [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimagepostupdateonclick.png"] forState:UIControlStateHighlighted];
            
            [addPhotoLbl setHidden:NO];
            
        }
    }
    
    else if (actionSheet.tag == 4)
    {
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

#pragma NFCameraOverlayDelegate

-(void)NFOverlayDidFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //if (isPostPictureMessage)
    {
        // NSData* imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage], 0.1);
        
        //  uploadPictureImgView.image=[[UIImage imageWithData:imageData] fixOrientation];
        
        [self writeImageToDocuments];//Write the Image
        
        [addImageBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [addImageBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
        isPictureMessage=YES;
        
        [addPhotoLbl setHidden:YES];
        
        [_picker dismissViewControllerAnimated:NO completion:^{
            
            [self openContentCreateSubview];
            
            isPostPictureMessage = NO;
            
        }];
    }
    
}


-(void)NFOverlayDidCancelPickingMedia
{
    [_picker dismissViewControllerAnimated:NO completion:nil];
    [self openContentCreateSubview];
}

-(void)NFOverlayDidFinishCroppingWithImage:(UIImage *)croppedImage
{
    [uploadPictureImgView setImage:croppedImage];
    [self NFOverlayDidFinishPickingMediaWithInfo:nil];
}

-(void)NFCropOverlayDidFinishCroppingWithImage:(UIImage *)croppedImage
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [uploadPictureImgView setImage:croppedImage];
    
    uploadImage = croppedImage;
    
    [self NFOverlayDidFinishPickingMediaWithInfo:nil];
}


- (void)imagePickerController:(UIImagePickerController *)picker1 didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if (isPostPictureMessage)
    {
        [self openContentCreateSubview];
        
        isPostPictureMessage = YES;
        
        NSMutableDictionary *imageInfo = [[NSMutableDictionary alloc]initWithDictionary:info];
        
        NFCropOverlay *cropController = [[NFCropOverlay alloc]initWithNibName:@"NFCropOverlay" bundle:nil];
        
        cropController.delegate = self;
        
        cropController.imageInfo = imageInfo;
        
        [picker1 presentViewController:cropController animated:YES completion:nil];
        
        [addImageBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        
        [addImageBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
        isPictureMessage=YES;
        
        [addPhotoLbl setHidden:YES];
        
    }
    
    else{
        
        primaryImage.image =  [info objectForKey:UIImagePickerControllerEditedImage];
        
        
        
        
        NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
        
        NSRange range = NSMakeRange (0,5);
        
        uuid=[uuid substringWithRange:range];
        
        NSCharacterSet *removeCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
        
        uuid = [[uuid componentsSeparatedByCharactersInSet: removeCharSet] componentsJoinedByString: @""];
        
        NSString *imageName=[NSString stringWithFormat:@"%@.jpg",uuid];
        
        NSData* imageData = UIImageJPEGRepresentation([info objectForKey:UIImagePickerControllerEditedImage], 0.1);
        
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        NSString* documentsDirectory = [paths objectAtIndex:0];
        
        NSString* fullPathToFile = [documentsDirectory stringByAppendingPathComponent:imageName];
        
        NSString *localImageUri=[NSMutableString stringWithFormat:@"local%@",fullPathToFile];
        appDelegate.primaryImageUploadUrl = [NSMutableString stringWithFormat:@"%@",localImageUri];
        
        [imageData writeToFile:fullPathToFile atomically:NO];
        
        [picker1 dismissViewControllerAnimated:YES completion:nil];
        
        [self performSelector:@selector(displayPrimaryImageModalView:) withObject:localImageUri afterDelay:1.0];
    }
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    if (isPostPictureMessage)
    {
        [picker dismissViewControllerAnimated:YES completion:nil];
        [self openContentCreateSubview];
    }
    
    else{
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
}


-(void)displayPrimaryImageModalView:(NSString *)path
{
    
    isPrimaryImage = YES;
    
    PrimaryImageViewController *primaryController=[[PrimaryImageViewController alloc]initWithNibName:@"PrimaryImageViewController" bundle:Nil];
    
    primaryController.isFromHomeVC=YES;
    
    primaryController.localImagePath=path;
    
    // UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:primaryController];
    
    // [self presentViewController:navController animated:YES completion:nil];
    
    chunkArray = [[NSMutableArray alloc]init];
    
    
    NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    
    NSRange range = NSMakeRange (0, 36);
    
    uuid=[uuid substringWithRange:range];
    
    NSCharacterSet *removeCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
    
    uuid = [[uuid componentsSeparatedByCharactersInSet: removeCharSet] componentsJoinedByString: @""];
    
    uniqueIdString=[[NSString alloc]initWithString:uuid];
    
    UIImage *img = primaryImage.image;
    
    dataObj=UIImageJPEGRepresentation(img,0.1);
    
    NSUInteger length = [dataObj length];
    
    NSUInteger chunkSize = 3000*10;
    
    NSUInteger offset = 0;
    
    int numberOfChunks=0;
    
    do
    {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[dataObj bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;
        
        [chunkArray insertObject:chunk atIndex:numberOfChunks];
        
        numberOfChunks++;
        
    }
    
    while (offset < length);
    
    totalImageDataChunks=[chunkArray count];
    
    request=[[NSMutableURLRequest alloc] init];
    
    for (int i=0; i<[chunkArray count]; i++)
    {
        
        NSString *urlString=[NSString stringWithFormat:@"%@/createImage?clientId=%@&fpId=%@&reqType=parallel&reqtId=%@&totalChunks=%d&currentChunkNumber=%d",appDelegate.apiWithFloatsUri,appDelegate.clientId,[userDetails objectForKey:@"userFpId"],uniqueIdString,[chunkArray count],i];
        
        NSString *postLength=[NSString stringWithFormat:@"%ld",(unsigned long)[[chunkArray objectAtIndex:i] length]];
        
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *uploadUrl=[NSURL URLWithString:urlString];
        
        NSMutableData *tempData =[[NSMutableData alloc]initWithData:[chunkArray objectAtIndex:i]] ;
        
        [request setURL:uploadUrl];
        [request setTimeoutInterval:30000];
        [request setHTTPMethod:@"PUT"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"binary/octet-stream" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:tempData];
        [request setCachePolicy:NSURLCacheStorageAllowed];
        
        theConnection=[[NSURLConnection  alloc]initWithRequest:request delegate:self startImmediately:YES];
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
    if ([frontViewPosition isEqualToString:@"FrontViewPositionLeft"])
    {
        [revealFrontControllerButton setHidden:YES];
        
        [self clearObjectInArray];
        
        [self setUpArray];
        
        [messageTableView reloadData];
    }
    
    //FrontViewPositionRight
    
    if ([frontViewPosition isEqualToString:@"FrontViewPositionRight"])
    {
        [revealFrontControllerButton setHidden:NO];
    }
    
    
    
}


#pragma RightViewControllerDelegate
-(void)messageDidUpdate
{
    [messageTableView reloadData];
}




#pragma PostMessageViewControllerDelegate

-(void)messageUpdatedSuccessFully
{
    [self clearObjectInArray];
    
    [self setUpArray];
    
    [self showNoUpdateView];
    
    [messageTableView reloadData];
}


-(void)messageUpdateFailed;
{
    [self popUpFirstUserMessage];
}

-(void)popUpFirstUserMessage
{
    PopUpView *customPopUp=[[PopUpView alloc]init];
    customPopUp.delegate=self;
    customPopUp.titleText=@"Post an update";
    customPopUp.descriptionText=@"Start engaging with your customers by posting a business update.";
    customPopUp.popUpImage=[UIImage imageNamed:@"updatemsg popup.png"];
    customPopUp.successBtnText=@"Yes, Now";
    customPopUp.cancelBtnText=@"Later";
    customPopUp.tag=1003;
    [customPopUp showPopUpView];
    
}

-(void)popUpEmailShare
{
    PopUpView *emailShare = [[PopUpView alloc]init];
    emailShare.delegate=self;
    emailShare.titleText=@"Tell your friend's";
    emailShare.descriptionText=@"Your website is turning out well. Why don't you tell your friends about it? ";
    emailShare.popUpImage=[UIImage imageNamed:@"sharewebsite.png"];
    emailShare.successBtnText=@"Share Now";
    emailShare.cancelBtnText=@"Later";
    emailShare.tag=201;
    [emailShare showPopUpView];
}


-(void)freeFromAdsPopUp
{
    [mixpanel track:@"removeads_btnClicked"];
    
    if(![[appDelegate.storeDetailDictionary objectForKey:@"CountryPhoneCode"]  isEqual: @"91"])
    {
        instaPurchasePopUp=[[NFInstaPurchase alloc]init];
        
        instaPurchasePopUp.delegate=self;
        
        instaPurchasePopUp.selectedWidget=1100;
        
        [instaPurchasePopUp showInstantBuyPopUpView];
    }
    else
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"It's Upgrade Time!" message:@"Check NowFloats Store for more information on upgrade plans" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Go To Store", nil];
        
        alertView.tag = 1897;
        
        [alertView show];
        
        alertView = nil;
    }
    
    
    
    
    
}



#pragma NFInstaPurchaseDelegate

-(void)instaPurchaseViewDidClose
{
    [instaPurchasePopUp removeFromSuperview];
}


#pragma RegisterChannel
-(void)setRegisterChannel
{
    RegisterChannel *regChannel=[[RegisterChannel alloc]init];
    
    regChannel.delegate=self;
    
    [regChannel registerNotificationChannel];
}


#pragma RegisterChannelDelegate

-(void)channelDidRegisterSuccessfully
{
    //    NSLog(@"channelDidRegisterSuccessfully");
}


-(void)channelFailedToRegister
{
    //    NSLog(@"channelFailedToRegister");
}


#pragma ShowKeyboard

-(void)showKeyboard
{
    [dummyTextView becomeFirstResponder];
}


-(void)hideKeyboard
{
    if (version.floatValue<7.0)
    {
        [dummyTextView resignFirstResponder];
        [createContentTextView resignFirstResponder];
    }
    
    else
    {
        [dummyTextView becomeFirstResponder];
        [dummyTextView resignFirstResponder];
    }
}


-(void)showAnotherKeyboard
{
    if ([dummyTextView isFirstResponder])
    {
        [createContentTextView becomeFirstResponder];
        [dummyTextView resignFirstResponder];
        
        
        
        //-- Post Update Tutorial View --//
        [self showPostUpdateOverLay];
        
    }
}


#pragma UITextViewDelegate


-(void)textViewDidChange:(UITextView *)textView
{
    NSString *substring = [NSString stringWithString:textView.text];
    
    createMessageLbl.hidden=YES;
    
    substring = [substring stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (substring.length > 0)
    {
        characterCount.hidden = NO;
        
        characterCount.text = [NSString stringWithFormat:@"%d", substring.length];
        
        [postUpdateBtn setEnabled:YES];
        
        postUpdateBtn.alpha = 1.0;
    }
    
    
    if (substring.length == 0)
    {
        characterCount.hidden = YES;
        
        createMessageLbl.hidden=NO;
        
        [postUpdateBtn setEnabled:NO];
        
        postUpdateBtn.alpha = 0.5;
    }
}


- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
{
    
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView;
{
    
    
}


- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    BOOL flag = NO;
    if([text length] == 0)
    {
        if([textView.text length] != 0)
        {
            flag = YES;
            return YES;
        }
        
        else
        {
            return NO;
        }
    }
    return YES;
}


- (IBAction)createContentBtnClicked:(id)sender
{
    
    
    PostUpdateViewController *post = [[PostUpdateViewController alloc]initWithNibName:@"PostUpdateViewController" bundle:nil];
    [self presentViewController:post animated:YES completion:nil];
    
    
    
    
    
    isPosted = YES;
    
}

- (IBAction)createContentCloseBtnClicked:(id)sender
{
    
    [UIView animateWithDuration:0.4 animations:^
     {
         [self.navigationController setNavigationBarHidden:NO animated:YES];
         CATransition *animation = [CATransition animation];
         animation.type = kCATransitionFade;
         animation.duration = (version.floatValue<7.0)?0.2:0.6;
         [detailViewController.layer addAnimation:animation forKey:nil];
         [detailViewController setHidden:NO];
         [self.view setBackgroundColor:[UIColor colorWithHexString:@"dedede"]];
         if (version.floatValue<7.0)
         {
             [self hideKeyboard];
         }
         
         if (version.floatValue>=7.0)
         {
             [self hideKeyboard];
         }
         
     } completion:^(BOOL finished)
     {
         
         isPictureMessage = NO;
         
         createContentTextView.text=@"";
         
         [postUpdateBtn setEnabled:NO];
         
         [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimageplaceholder.png"] forState:UIControlStateNormal];
         
         [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimagepostupdateonclick.png"] forState:UIControlStateHighlighted];
         
         uploadPictureImgView.image=[UIImage imageNamed:@""];
         
     }];
    
}


- (IBAction)dismissKeyboardBtnClicked:(id)sender
{
    [self createContentCloseBtnClicked:sender];
}


- (IBAction)postUpdateBtnClicked:(id)sender
{
    [self createContentCloseBtnClicked:sender];
    [nfActivity showCustomActivityView];
   
    [self createMessage];
}

-(void)isYoutubeVideo
{
    if ([createContentTextView.text rangeOfString:@"youtube"].location==NSNotFound)
    {
        
        
    }
    else
    {
        NSString *vID = nil;
        NSString *url = createContentTextView.text;
        
        NSString *query = [url componentsSeparatedByString:@"?"][1];
        NSArray *pairs = [query componentsSeparatedByString:@"&"];
        for (NSString *pair in pairs) {
            NSArray *kv = [pair componentsSeparatedByString:@"="];
            if ([kv[0] isEqualToString:@"v"]) {
                vID = kv[1];
                break;
            }
        }
        
        isPictureMessage = YES;
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://img.youtube.com/vi/%@/mqdefault.jpg",vID]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        uploadPictureImgView.image = [UIImage imageWithData:imageData];
    }
}


- (IBAction)addImageBtnClicked:(id)sender
{
    isPostPictureMessage = YES;
    if(isFromCamera)
    {
        UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Gallery", nil];
        selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        selectAction.tag=3;
        [selectAction showInView:self.view];
        
    }
    else
    {
        if (uploadPictureImgView.image!=nil)
        {
            UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Gallery",@"Cancel Image",nil];
            selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            selectAction.tag=3;
            [selectAction showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:1]];
        }
        
        else
        {
            UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Gallery", nil];
            selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            selectAction.tag=3;
            [selectAction showInView:[[[UIApplication sharedApplication] windows] objectAtIndex:1]];
        }
    }
    
    
}


-(void)createMessage
{
    if (isPictureMessage)
    {
        CreatePictureDeal *createDeal=[[CreatePictureDeal alloc]init];
        
        createDeal.dealUploadDelegate=self;
        
        NSMutableDictionary *uploadDictionary=[[NSMutableDictionary alloc]initWithObjectsAndKeys:
                                               createContentTextView.text,@"message",
                                               [NSNumber numberWithBool:isSendToSubscribers],@"sendToSubscribers",
                                               [appDelegate.storeDetailDictionary  objectForKey:@"_id"],@"merchantId",
                                               appDelegate.clientId,@"clientId",
                                               uploadPictureImgView.image,@"pictureMessage",
                                               nil];
        
        createDeal.offerDetailDictionary=[[NSMutableDictionary alloc]init];
        
        [createDeal createDeal:uploadDictionary postToTwitter:isTwitterSelected postToFB:isFacebookSelected postToFbPage:isFacebookPageSelected ];
    }
    
    else
    {
        CreateStoreDeal *createStrDeal=[[CreateStoreDeal alloc]init];
        
        createStrDeal.delegate=self;
        
        NSMutableDictionary *uploadDictionary=[[NSMutableDictionary alloc]initWithObjectsAndKeys:                                               [createContentTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]],@"message",
                                               [NSNumber numberWithBool:isSendToSubscribers],@"sendToSubscribers",[appDelegate.storeDetailDictionary  objectForKey:@"_id"],@"merchantId",appDelegate.clientId,@"clientId",nil];
        
        createStrDeal.offerDetailDictionary=[[NSMutableDictionary alloc]init];
        
        [createStrDeal createDeal:uploadDictionary isFbShare:isFacebookSelected isFbPageShare:isFacebookPageSelected isTwitterShare:isTwitterSelected];
    }
}


#pragma updateDelegate


-(void)updateMessageSucceed
{
    id sender;
    [self createContentCloseBtnClicked:sender];
    [self updateViewController];
}


-(void)updateMessageFailed
{
    [nfActivity hideCustomActivityView];
    id sender;
    [self createContentCloseBtnClicked:sender];
}


#pragma pictureDealDelegate
-(void)successOnDealUpload
{
    [self uploadPictureMessage];
}


-(void)failedOnDealUpload:(NSString *)dealid
{
    [nfActivity hideCustomActivityView];
    
    UIAlertView *failedPictureTextMsg=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Failed to upload the message. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [failedPictureTextMsg show];
    
    failedPictureTextMsg= nil;
    
    DeleteFloatController *delController=[[DeleteFloatController alloc]init];
    delController.DeleteBizFloatdelegate=self;
    [delController deletefloat:dealid];
    delController=nil;
    
}


-(void)updateBizMessage
{
    
    
}

-(void)uploadPictureMessage
{
    chunkArray=[[NSMutableArray alloc]init];
    
    receivedData=[[NSMutableData alloc]init];
    
    totalImageDataChunks=0;
    
    successCode = 0;
    
    NSString *uuid = [[NSProcessInfo processInfo] globallyUniqueString];
    
    NSRange range = NSMakeRange (0, 36);
    
    uuid=[uuid substringWithRange:range];
    
    NSCharacterSet *removeCharSet = [NSCharacterSet characterSetWithCharactersInString:@"-"];
    
    uuid = [[uuid componentsSeparatedByCharactersInSet: removeCharSet] componentsJoinedByString: @""];
    
    uniqueIdString=[[NSString alloc]initWithString:uuid];
    
    UIImage *img =uploadImage;
    
    dataObj=UIImageJPEGRepresentation(img,0.4);
    
    NSUInteger length = [dataObj length];
    
    NSUInteger chunkSize = 3000*10;
    
    NSUInteger offset = 0;
    
    int numberOfChunks=0;
    
    do
    {
        NSUInteger thisChunkSize = length - offset > chunkSize ? chunkSize : length - offset;
        
        NSData* chunk = [NSData dataWithBytesNoCopy:(char *)[dataObj bytes] + offset
                                             length:thisChunkSize
                                       freeWhenDone:NO];
        offset += thisChunkSize;
        
        [chunkArray insertObject:chunk atIndex:numberOfChunks];
        
        numberOfChunks++;
        
    }
    
    while (offset < length);
    
    totalImageDataChunks=[chunkArray count];
    
    request=[[NSMutableURLRequest alloc] init];
    
    NSString *imageDealString= [appDelegate.dealId objectAtIndex:0];
    
    for (int i=0; i<[chunkArray count]; i++)
    {
        
        NSString *urlString=[NSString stringWithFormat:@"%@/createBizImage?clientId=%@&bizMessageId=%@&requestType=parallel&requestId=%@&totalChunks=%d&currentChunkNumber=%d",appDelegate.apiWithFloatsUri,appDelegate.clientId,imageDealString,uniqueIdString,[chunkArray count],i];
        
        NSString *postLength=[NSString stringWithFormat:@"%ld",(unsigned long)[[chunkArray objectAtIndex:i] length]];
        
        urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        NSURL *uploadUrl=[NSURL URLWithString:urlString];
        
        NSMutableData *tempData =[[NSMutableData alloc]initWithData:[chunkArray objectAtIndex:i]] ;
        
        [request setURL:uploadUrl];
        [request setTimeoutInterval:30000];
        [request setHTTPMethod:@"PUT"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"binary/octet-stream" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:tempData];
        [request setCachePolicy:NSURLCacheStorageAllowed];
        
        theConnection=[[NSURLConnection  alloc]initWithRequest:request delegate:self startImmediately:YES];
    }
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data1
{
    [receivedData appendData:data1];
}


- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    
    int code = [httpResponse statusCode];
    
    NSLog(@"code:%d",code);
    
    if(isPrimaryImage)
    {
        if (code==200)
        {
            successCode++;
            
            if (successCode==totalImageDataChunks)
            {
                successCode=0;
                
                appDelegate.primaryImageUri=[NSMutableString stringWithFormat:@"%@",appDelegate.primaryImageUploadUrl];
                
                primaryImageView.image =primaryImage.image;
                
                [mixpanel track:@"Change featured image"];
            }
        }
        
        else
        {
            successCode=0;
            
            [connection cancel];
            
            UIAlertView *imageUploadFailAlert=[[UIAlertView alloc]initWithTitle:@"Failed" message:@"Yikes! Image upload failed please try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            
            [imageUploadFailAlert  show];
            
            imageUploadFailAlert=nil;
            
            
            
        }
        
    }
    else
    {
        
        if (code==200)
        {
            successCode++;
            
            if (successCode==totalImageDataChunks)
            {
                [self finishUpload];
                [nfActivity hideCustomActivityView];
            }
        }
        
        else
        {
            [nfActivity hideCustomActivityView];
            id sender;
            [self createContentCloseBtnClicked:sender];
            
            UIAlertView *failedPictureTextMsg=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Failed to upload the message. Please try again." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            
            [failedPictureTextMsg show];
            
            failedPictureTextMsg= nil;
        }
    }
}


-(void)finishUpload
{
    [appDelegate.dealImageArray insertObject:appDelegate.localImageUri atIndex:0];
    
    if (isFacebookPageSelected)
    {
        [self performSelector:@selector(uploadPictureToFaceBookPage) withObject:Nil afterDelay:2.0];
    }
    
    if (isPictureMessage)
    {
        [self performSelector:@selector(uploadPictureToFaceBook) withObject:Nil afterDelay:2.0];
    }
    
    [self closeContentCreateSubview];
    
    
}


-(void)updateViewController
{
    FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
    
    fHelper.userFpTag=appDelegate.storeTag;
    
    NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
    
    if (![appDelegate.storeWidgetArray containsObject:@"IMAGEGALLERY"] && ![appDelegate.storeWidgetArray containsObject:@"TIMINGS"] && ![appDelegate.storeWidgetArray containsObject:@"TOB"] && ![appDelegate.storeWidgetArray containsObject:@"SITESENSE"])
    {
        [nfActivity hideCustomActivityView];
        
        if ([fHelper openUserSettings] != NULL)
        {
            [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
            
            if ([userSetting objectForKey:@"userFirstMessage"]!=nil)
            {
                if ([[userSetting objectForKey:@"userFirstMessage"] boolValue])
                {
                    if (![appDelegate.storeWidgetArray containsObject:@"SITESENSE"] && appDelegate.dealDescriptionArray.count>=1)
                    {
                       // [self showBuyAutoSeoPlugin];
                    }
                    
                    else
                    {
                        [self syncView];
                    }
                }
                
                else
                {
                    [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"userFirstMessage"];
                    [self showPostFirstUserMessage];
                }
            }
            
            else
            {
                [fHelper updateUserSettingWithValue:[NSNumber numberWithBool:YES] forKey:@"userFirstMessage"];
                [self showPostFirstUserMessage];//PopUp Tag is 1 or 2.
            }
        }
    }
    
    else if (![appDelegate.storeWidgetArray containsObject:@"SITESENSE"] && appDelegate.dealDescriptionArray.count>=1)
    {
      //  [self showBuyAutoSeoPlugin];
    }
    
    else
    {
        [self syncView];
    }
}


-(void)syncView
{
    [nfActivity hideCustomActivityView];//Do not delete.
    
    if (isPictureMessage)
    {
        [mixpanel track:@"Post Image Deal"];
        
        isPictureMessage= NO;
        
        isCancelPictureMessage=NO;
        
        uploadPictureImgView.image=[UIImage imageNamed:@""];
        
        [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimageplaceholder.png"] forState:UIControlStateNormal];
        
        [addImageBtn setBackgroundImage:[UIImage imageNamed:@"addimagepostupdateonclick.png"] forState:UIControlStateHighlighted];
        
        if (addPhotoLbl.isHidden)
        {
            [addPhotoLbl setHidden:NO];
        }
        
        
        if (createMessageLbl.isHidden)
        {
            [createMessageLbl setHidden:NO];
        }
    }
    
    else
    {
        
        [mixpanel track:@"Post Message"];
    }
    
    [createContentTextView setText:@""];
    
    [postUpdateBtn setEnabled:NO];
    
    
    if (isFacebookPageSelected)
    {
        [selectedFacebookPageButton setHidden:YES];
        
        if (isFacebookPageSelected)
        {
            [facebookPageButton setHidden:NO];
        }
        
        isFacebookPageSelected = NO;
    }
    
    
    if (isFacebookSelected)
    {
        isFacebookSelected = NO;
        
        if (facebookPageButton.isHidden)
        {
            [facebookPageButton setHidden:NO];
        }
        
        [selectedFacebookButton setHidden:YES];
    }
    
    
    if (isTwitterSelected)
    {
        isTwitterSelected = NO;
        
        if (twitterButton.isHidden)
        {
            [twitterButton setHidden:NO];
        }
        
        [selectedTwitterButton setHidden:YES];
    }
    
    
    if (!isSendToSubscribers) {
        
        if (sendToSubscribersOnButton.isHidden)
        {
            [sendToSubscribersOnButton setHidden:NO];
            [sendToSubscribersOffButton setHidden:YES];
        }
    }
    
    [self clearObjectInArray];
    
    [self setUpArray];
    
    [self showNoUpdateView];
    
    [messageTableView reloadData];
    
}


-(void)showPostFirstUserMessage
{
    
    
    RIATips1Controller *ria = [[RIATips1Controller alloc]initWithNibName:@"RIATips1Controller" bundle:nil];
    [self presentViewController:ria animated:YES completion:nil];
    
    
}






#pragma PopUpViewDelegate

-(void)successBtnClicked:(id)sender
{
    [nfActivity hideCustomActivityView];
    
    if ([[sender objectForKey:@"tag"] intValue]==1001)
    {
        if (version.floatValue<6.0)
        {
            UIActionSheet *selectAction=[[UIActionSheet alloc]initWithTitle:@"Select from" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter", nil];
            selectAction.actionSheetStyle = UIActionSheetStyleBlackOpaque;
            selectAction.tag=2;
            [selectAction showInView:self.view];
        }
        
        else
        {
            NSString* shareText = [NSString stringWithFormat:@"Woohoo! We have a new website. Visit it at %@.nowfloats.com",[appDelegate.storeTag lowercaseString]];
            
            NSArray* dataToShare = @[shareText];
            
            UIActivityViewController* activityViewController =
            [[UIActivityViewController alloc] initWithActivityItems:dataToShare
                                              applicationActivities:nil];
            
            [self presentViewController:activityViewController animated:YES completion:nil];
        }
    }
    
    else if([[sender objectForKey:@"tag"] intValue]==1003)
    {
        id sender;
        
        [self createContentBtnClicked:sender];
        
    }
    
    else if ([[sender objectForKey:@"tag"]intValue ]==1 || [[sender objectForKey:@"tag"]intValue ]==2)
    {
        [mixpanel track:@"popup_goToStoreBtnClicked"];
        
        if([[appDelegate.storeDetailDictionary objectForKey:@"CountryPhoneCode"]  isEqual: @"91"])
        {
            
        }
        else
        {
            
            
            BizStoreDetailViewController *storeController=[[BizStoreDetailViewController alloc]initWithNibName:@"BizStoreDetailViewController" bundle:Nil];
            
            storeController.isFromOtherViews=YES;
            storeController.selectedWidget=1008;
            
            isGoingToStore = YES;
            
            UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:storeController];
            
            [self presentViewController:navigationController animated:YES completion:nil];
        }
        
        
    }
    
    else if ([[sender objectForKey:@"tag"]intValue ]== 201)
    {
        
        [mixpanel track:@"popup_shareEmailBtnClicked"];
        
        EmailShareController *emailController= [[EmailShareController alloc] initWithNibName:@"EmailShareController" bundle:nil];
        
        isGoingToEmailShare = YES;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:emailController];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
    
    else if ([[sender objectForKey:@"tag"]intValue ]== 204)
    {
        isGoingToStore = YES;
        
        BizStoreViewController *storeController=[[BizStoreViewController alloc]initWithNibName:@"BizStoreViewController" bundle:nil];
        
        storeController.isFromOtherViews = YES;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:storeController];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
    
}



-(void)cancelBtnClicked:(id)sender
{
    if ([[sender objectForKey:@"tag"]intValue ]==1 || [[sender objectForKey:@"tag"]intValue ]==2)
    {
        [self syncView];
    }
}


-(void)mixpanelInAppNotification:(NSURL *)url
{
    [self inAppNotificationDeepLink:url];
}

-(void)inAppNotificationDeepLink:(NSURL *) url
{
    UIViewController *DeepLinkController = [[UIViewController alloc] init];
    
    BOOL isNotValidUrl = NO;
    
    BOOL isUpdateScreen = NO;
    
    BOOL isLockedTTB = NO;
    
    if([url isEqual:[NSString stringWithFormat:@"%@/%@",bundleUrl,storeUrl]])
    {
        isGoingToStore = YES;
        
        BizStoreViewController *BAddress = [[BizStoreViewController alloc] initWithNibName:@"BizStoreViewController" bundle:nil];
        
        [mixpanel track:@"store_FromInapp"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,buySeo]]])
    {
        BizStoreDetailViewController *BAddress = [[BizStoreDetailViewController alloc] initWithNibName:@"BizStoreDetailViewController" bundle:nil];
        
        BAddress.isFromOtherViews=YES;
        BAddress.selectedWidget=1008;
        
        [mixpanel track:@"buySEO_FromInapp"];
        
        isGoingToStore = YES;
        
        [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromDeeplink"];
        
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,buyTtb]]])
    {
        BizStoreDetailViewController *BAddress = [[BizStoreDetailViewController alloc] initWithNibName:@"BizStoreDetailViewController" bundle:nil];
        
        BAddress.isFromOtherViews=YES;
        BAddress.selectedWidget=1002;
        
        [mixpanel track:@"buyTTB_FromInapp"];
        
        isGoingToStore = YES;
        
        [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromDeeplink"];
        
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,noAdsUrl]]])
    {
        BizStoreDetailViewController *BAddress = [[BizStoreDetailViewController alloc] initWithNibName:@"BizStoreDetailViewController" bundle:nil];
        
        BAddress.isFromOtherViews=YES;
        BAddress.selectedWidget=11000;
        
        [mixpanel track:@"buynoAds_FromInapp"];
        isGoingToStore = YES;
        
        [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromDeeplink"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,googlePlacesUrl]]])
    {
        BizStoreDetailViewController *BAddress = [[BizStoreDetailViewController alloc] initWithNibName:@"BizStoreDetailViewController" bundle:nil];
        
        BAddress.isFromOtherViews=YES;
        BAddress.selectedWidget=1010;
        
        isGoingToStore = YES;
        [mixpanel track:@"buygPlaces_FromInapp"];
        
        [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromDeeplink"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,buyFeatureImage]]])
    {
        BizStoreDetailViewController *BAddress = [[BizStoreDetailViewController alloc] initWithNibName:@"BizStoreDetailViewController" bundle:nil];
        
        BAddress.isFromOtherViews=YES;
        BAddress.selectedWidget=1004;
        
        [mixpanel track:@"buyImage_FromInapp"];
        isGoingToStore = YES;
        
        [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"isFromDeeplink"];
        
        
        DeepLinkController = BAddress;
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,ttbUrl]]])
    {
        if([appDelegate.storeWidgetArray containsObject:@"TOB"])
        {
            
            TalkToBuisnessViewController *BAddress = [[TalkToBuisnessViewController alloc] initWithNibName:@"TalkToBuisnessViewController" bundle:nil];
            
            [mixpanel track:@"TTB_FromInapp"];
            
            DeepLinkController = BAddress;
        }
        else
        {
            isLockedTTB = YES;
        }
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,analyticsUrl]]])
    {
        AnalyticsViewController *BAddress = [[AnalyticsViewController alloc] initWithNibName:@"AnalyticsViewController" bundle:nil];
        
        [mixpanel track:@"analytics_FromInapp"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,changePasswordUrl]]])
    {
        ChangePasswordController *BAddress = [[ChangePasswordController alloc] initWithNibName:@"ChangePasswordController" bundle:nil];
        
        [mixpanel track:@"changePassword_FromInapp"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,referAfriendUrl]]])
    {
        ReferFriendViewController *BAddress = [[ReferFriendViewController alloc] initWithNibName:@"ReferFriendViewController" bundle:nil];
        
        [mixpanel track:@"refer_FromInapp"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,settingsUrl]]])
    {
        
        UserSettingsViewController *BAddress = [[UserSettingsViewController alloc] initWithNibName:@"UserSettingsViewController" bundle:nil];
        
        [mixpanel track:@"settings_FromInapp"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,businessProfileUrl]]])
    {
        
        BusinessProfileController *BAddress = [[BusinessProfileController alloc] initWithNibName:@"BusinessProfileController" bundle:nil];
        
        [mixpanel track:@"profile_FromInapp"];
        
        DeepLinkController = BAddress;
        
    }
    else if([url isEqual:[NSURL URLWithString:[NSString stringWithFormat:@"%@/%@",bundleUrl,updateLink]]])
    {
        isUpdateScreen = YES;
    }
    else
    {
        isNotValidUrl = YES;
    }
    
    if(isNotValidUrl)
    {
        
    }
    
    else
    {
        if(isUpdateScreen)
        {
            [self createContentBtnClicked:nil];
        }
        else
        {
            
            if(isLockedTTB)
            {
                UIAlertView *logoAlertView=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Please buy Talk to Business widget from NowFloats Store" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                
                [logoAlertView show];
                
                logoAlertView=nil;
            }
            else
            {
                self.navigationController.navigationBarHidden=NO;
                UINavigationController *navbarController = [[UINavigationController alloc] initWithRootViewController:DeepLinkController];
                [self presentViewController:navbarController animated:YES completion:nil];
                //  [self.navigationController pushViewController:DeepLinkController animated:YES];
            }
        }
        
    }
    
    
    
}

#pragma SocialOptionsMethods

- (IBAction)facebookBtnClicked:(id)sender
{
    [mixpanel track:@"Facebook Sharing"];
    
    
    if ([userDetails objectForKey:@"NFManageFBAccessToken"] && [userDetails objectForKey:@"NFManageFBUserId"])
    {
        isFacebookSelected=YES;
        [facebookButton setHidden:YES];
        [selectedFacebookButton setHidden:NO];
    }
    
    else
    {
        UIAlertView *fbAlert=[[UIAlertView alloc]initWithTitle:@"Facebook" message:@"To connect to Facebook,\n please sign in." delegate:self    cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
        [fbAlert setTag:2001];
        [fbAlert show];
        fbAlert=nil;
    }
}


- (IBAction)selectedFaceBookClicked:(id)sender
{
    isFacebookSelected=NO;
    [selectedFacebookButton setHidden:YES];
    [facebookButton setHidden:NO];
}


- (IBAction)facebookPageBtnClicked:(id)sender
{
    [mixpanel track:@"Facebook page sharing"];
    
    if (!appDelegate.socialNetworkNameArray.count)
    {
        UIAlertView *fbPageAlert=[[UIAlertView alloc]initWithTitle:@"Facebook Page" message:@"To connect to Facebook Page,\n Please sign in." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect ", nil];
        
        fbPageAlert.tag=2002;
        
        [fbPageAlert show];
        
        fbPageAlert=nil;
    }
    
    else if (appDelegate.socialNetworkNameArray.count)
    {
        isFacebookPageSelected=YES;
        [selectedFacebookPageButton setHidden:NO];
        [facebookPageButton setHidden:YES];
    }
}


- (IBAction)selectedFbPageBtnClicked:(id)sender
{
    isFacebookPageSelected=NO;
    [facebookPageButton setHidden:NO];
    [selectedFacebookPageButton setHidden:YES];
}


- (IBAction)fbPageSubViewCloseBtnClicked:(id)sender
{
    
}


- (IBAction)twitterBtnClicked:(id)sender
{
    [mixpanel track:@"Twitter sharing"];
    
    if (![userDetails objectForKey:@"authData"])
    {
        UIAlertView *twitterAlert=[[UIAlertView alloc]initWithTitle:@"Twitter" message:@"To connect to Twitter,\n Please sign in." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Connect", nil];
        
        twitterAlert.tag=4;
        
        [twitterAlert show];
        
        twitterAlert=nil;
    }
    
    else
    {
        
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];
        _engine.consumerKey    = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;
        
        [_engine isAuthorized];
        
        isTwitterSelected=YES;
        [twitterButton setHidden:YES];
        [selectedTwitterButton setHidden:NO];
        
    }
}


- (IBAction)selectedTwitterBtnClicked:(id)sender
{
    isTwitterSelected=NO;
    [twitterButton setHidden:NO];
    [selectedTwitterButton setHidden:YES];
}


- (IBAction)sendToSubscibersOnClicked:(id)sender
{
    UIAlertView *sendToSubscribersAlert=[[UIAlertView alloc]initWithTitle:@"Confirm" message:@"Are you sure you don't want your subscribers to receive this message?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Ok", nil];
    
    sendToSubscribersAlert.tag=2;
    
    [sendToSubscribersAlert show];
    
    sendToSubscribersAlert=nil;
}


- (IBAction)sendToSubscribersOffClicked:(id)sender
{
    
    [sendToSubscribersOnButton setHidden:NO];
    [sendToSubscribersOffButton setHidden:YES];
    isSendToSubscribers=YES;
    
}


- (IBAction)cancelFaceBookPages:(id)sender
{
    [fbPageSubView setHidden:YES];
    [self openContentCreateSubview];
}




- (IBAction)showMenu:(id)sender
{
    
    
}





-(void)assignFbDetails:(NSArray*)sender
{
    [userDetails setObject:sender forKey:@"NFManageUserFBAdminDetails"];
    [userDetails synchronize];
}


-(void)showFbPagesSubView
{
    [fbPageSubView setHidden:NO];
    [self reloadFBpagesTableView];
    [socialActivity hideCustomActivityView];
}

-(void)reloadFBpagesTableView
{
    [fbPageTableView reloadData];
}


#pragma mark SA_OAuthTwitterEngineDelegate

- (void) storeCachedTwitterOAuthData: (NSString *) strData forUsername: (NSString *) username
{
	NSUserDefaults	*defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:strData forKey: @"authData"];
	[defaults synchronize];
}


- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username
{
	return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
}


#pragma SA_OAuthTwitterControllerDelegate

- (void) OAuthTwitterControllerFailed: (SA_OAuthTwitterController *) controller
{
    [self check];
}


- (void) OAuthTwitterController: (SA_OAuthTwitterController *) controller authenticatedWithUsername: (NSString *) username
{
    
    [userDetails setObject:username forKey:@"NFManageTwitterUserName"];
    
    [userDetails synchronize];
    
    isTwitterSelected=YES;
    [twitterButton setHidden:YES];
    [selectedTwitterButton setHidden:NO];
    
}

-(void)check
{
    isTwitterSelected=NO;
    [twitterButton setHidden:NO];
    [selectedTwitterButton setHidden:YES];
}


-(void)openContentCreateSubview
{
    [UIView animateWithDuration:0.4 animations:^
     {
         [self.view setBackgroundColor:[UIColor colorWithHexString:@"ffffff"]];
         
         if (version.floatValue<7.0)
         {
             [self showKeyboard];
         }
         
     }completion:^(BOOL finished)
     {
         if (version.floatValue>=7.0)
         {
             [self showKeyboard];
         }
         
         [self performSelector:@selector(showAnotherKeyboard) withObject:nil afterDelay:0.1];
     }];
    
}


-(void)closeContentCreateSubview
{
    
    [UIView animateWithDuration:0.4 animations:^
     {
         [self.view setBackgroundColor:[UIColor colorWithHexString:@"dedede"]];
         
         if (version.floatValue<7.0)
         {
             [self hideKeyboard];
         }
         
         if (version.floatValue>=7.0)
         {
             [self hideKeyboard];
         }
         
     } completion:^(BOOL finished)
     {
         
     }];
}

-(void)customalert:(NSString*)SeenContry Seen:(NSString*)lastSeen category:(int)type
{
    
    errorView = [[UIView alloc]init];
    errorView.frame = CGRectMake(0, -2000, 320, 40);
    
    UIImageView *borderImage = [[UIImageView alloc]initWithFrame:CGRectMake(7, 7, 306, 52)];
    
    borderImage.image = [UIImage imageNamed:@"Frame.png"];
    
    UIImageView *typeImage = [[UIImageView alloc]initWithFrame:CGRectMake(40, 18, 28, 28)];
    
    
    
    UILabel *someoneLabel = [[UILabel alloc]initWithFrame:CGRectMake(82, 12, 200, 20)];
    someoneLabel.textColor = [UIColor whiteColor];
    
    someoneLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:11];
    
    
    UILabel *vistedLabel = [[UILabel alloc]initWithFrame:CGRectMake(82, 27, 200, 20)];
    vistedLabel.textColor = [UIColor colorFromHexCode:@"#ffb900"];
    vistedLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
    
    UILabel *TimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(82, 40, 200, 20)];
    TimeLabel.textColor = [UIColor colorFromHexCode:@"#b9b9b9"];
    TimeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Italic" size:8];
    
    UIButton *referDirect = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    
    [referDirect addTarget:self action:@selector(openAction) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    UIButton *closeButton =[UIButton buttonWithType:UIButtonTypeCustom];
    [closeButton addTarget:self action:@selector(closeView) forControlEvents:UIControlEventTouchUpInside];
    closeButton.frame =CGRectMake(270, 0, 100, 40);
    
    
    UIImageView *closeImage = [[UIImageView alloc]initWithFrame:CGRectMake(35, 5, 8, 8)];
    [closeImage setImage:[UIImage imageNamed:@"Latest_visitor_Cross"]];
    
    [closeButton addSubview:closeImage];
    closeImage.userInteractionEnabled = NO;
    UILabel  *errorLabel = [[UILabel alloc]init];
    errorLabel.textAlignment =NSTextAlignmentCenter;
    
    if(type==1)
    {
        errorView.backgroundColor = [UIColor colorWithRed:224.0f/255.0f green:34.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        errorLabel.frame = CGRectMake(20, -12, 280, 40);
        errorLabel.font = [UIFont fontWithName:@"Helvetica Neue" size:12.0];
        errorLabel.textColor = [UIColor whiteColor];
        errorView.frame=CGRectMake(0, -20, 320, 20);
        errorLabel.text = SeenContry;
        [errorView addSubview:errorLabel];
        
    }
    
    else if(type==2)
    {
        
        errorView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        
        typeImage.image = [UIImage imageNamed:@"Banner-Refer_alert.png"];
        someoneLabel.text =@"Invite your Friends to use";
        someoneLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        vistedLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:13];
        someoneLabel.frame =CGRectMake(82, 20, 200, 20);
        vistedLabel.frame =CGRectMake(232, 20, 200, 20);
        vistedLabel.text =@"Boost";
        errorView.frame=CGRectMake(0, -80, 320, 66);
        
        
        
        
    }
    else if(type==3)
    {
        errorView.backgroundColor = [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0];
        
        typeImage.image = [UIImage imageNamed:@"Banner-Visitor_alert.png"];
        someoneLabel.text =@"Someone visited your site from";
        vistedLabel.text = SeenContry;
        TimeLabel.text   = lastSeen;
        errorView.frame=CGRectMake(0, -80, 320, 66);
        
    }
    
    
    
    
    errorLabel.backgroundColor = [UIColor clearColor];
    errorLabel.textColor = [UIColor whiteColor];
    [errorLabel setNumberOfLines:0];
    errorView.tag = 55;
    
    
    
    
    
    messageTableView.frame = CGRectMake(0, 0, messageTableView.frame.size.width, messageTableView.frame.size.height);
    
    
    
    [UIView animateWithDuration:0.8f
                          delay:0.03f
                        options:UIViewAnimationOptionTransitionFlipFromTop
                     animations:^{
                         
                         
                         
                         
                         if(type==1)
                         {
                             errorView.frame=CGRectMake(0, 0, 320, 20);
                             messageTableView.frame = CGRectMake(0, 20, messageTableView.frame.size.width, messageTableView.frame.size.height);
                             
                             
                         }
                         else if (type==2)
                         {
                             errorView.frame=CGRectMake(0, 0, 320, 66);
                             referDirect.frame = CGRectMake(0, 0, 320, 66);
                             messageTableView.frame = CGRectMake(0, 66, messageTableView.frame.size.width, messageTableView.frame.size.height);
                             
                             [errorView addSubview:referDirect];
                             
                             [errorView addSubview:borderImage];
                             [errorView addSubview:typeImage];
                             [errorView addSubview:someoneLabel];
                             [errorView addSubview:vistedLabel];
                             [errorView addSubview:closeButton];
                         }
                         else if (type==3)
                         {
                             errorView.frame=CGRectMake(0, 0, 320, 66);
                             messageTableView.frame = CGRectMake(0, 66, messageTableView.frame.size.width, messageTableView.frame.size.height);
                             
                             [errorView addSubview:borderImage];
                             [errorView addSubview:typeImage];
                             [errorView addSubview:someoneLabel];
                             [errorView addSubview:vistedLabel];
                             [errorView addSubview:TimeLabel];
                             [errorView addSubview:closeButton];
                             
                         }
                         
                         [self.view addSubview:errorView];
                         
                         
                         
                         
                     }completion:^(BOOL finished){
                         
                         double delayInSeconds = 1.5;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             
                             
                             
                             [UIView animateWithDuration:1.0f
                                                   delay:0.10f
                                                 options:UIViewAnimationOptionTransitionFlipFromBottom
                                              animations:^{
                                                  
                                                  
                                                  
                                                  if(type==1)
                                                  {
                                                      messageTableView.frame = CGRectMake(0, 0, messageTableView.frame.size.width, messageTableView.frame.size.height);
                                                      
                                                      errorView.frame = CGRectMake(0, -80, 320, 20);
                                                      
                                                  }
                                                  
                                                  
                                                  
                                              }completion:^(BOOL finished){
                                                  
                                                  for (UIView *errorRemoveView in [self.view subviews]) {
                                                      if (errorRemoveView.tag == 55) {
                                                          
                                                          
                                                          if(type==1)
                                                          {
                                                              [errorView removeFromSuperview];
                                                          }
                                                          
                                                      }
                                                      
                                                  }
                                                  
                                              }];
                             
                         });
                         
                     }];
    
    
}

-(void)closeView
{
    [UIView animateWithDuration:0.8f
                          delay:0.10f
                        options:UIViewAnimationOptionTransitionFlipFromBottom
                     animations:^{
                         
                         
                         
                         messageTableView.frame = CGRectMake(0, 0, messageTableView.frame.size.width, messageTableView.frame.size.height);
                         
                         errorView.frame = CGRectMake(0, -80, 320, 66);
                         
                         
                         
                         
                     }completion:^(BOOL finished){
                         
                         for (UIView *errorRemoveView in [self.view subviews]) {
                             if (errorRemoveView.tag == 55) {
                                 
                                 
                                 [errorView removeFromSuperview];
                                 
                                 
                             }
                             
                         }
                         
                     }];
    
    
}

-(void)openAction
{
    
    if (notificationType==2)
    {
      
        [self closeView];
            ReferFriendViewController *referScreen = [[ReferFriendViewController alloc] initWithNibName:@"ReferFriendViewController" bundle:nil];
            [self.navigationController pushViewController:referScreen animated:NO];
            
        
    }
    
    
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
}


- (void)viewDidUnload
{
    [self setParallax:nil];
    [self setMessageTableView:nil];
    parallelaxImageView = nil;
    revealFrontControllerButton = nil;
    notificationView = nil;
    primaryImageView = nil;
    userDetails= nil;
    postMessageController= nil;
    dealsArray= nil;
    appDelegate= nil;
    data= nil;
    dealId= nil;
    storeTagLabel = nil;
    storeTitleLabel = nil;
    fpMessageDictionary= nil;
    messageSkipCount= nil;
    loadMoreButton= nil;
    ismoreFloatsAvailable= nil;
    arrayToSkipMessage= nil;    //_picker= nil;
    parallelaxImageView= nil;
    frontViewPosition= nil;
    revealFrontControllerButton= nil;
    navBar= nil;
    notificationBadgeImageView= nil;
    notificationLabel= nil;
    notificationView= nil;
    primaryImageView= nil;
    tutorialOverlayView= nil;
    tutorialOverlayiPhone4View= nil;
    shareWebSiteOverlayiPhone4= nil;
    shareWebSiteOverlay= nil;
    updateMsgOverlay= nil;
    version= nil ;
    navBackgroundview= nil;
    noUpdateSubView= nil;
    createContentSubView= nil;
    postMessageSubView= nil;
    createContentTextView= nil;
    createMessageLbl= nil;
    dummyTextView= nil;
    postMsgViewBgView= nil;
    postMessageContentCreateSubview= nil;
    postMessageSubviewHeaderView= nil;
    postUpdateBtn = nil;
    [super viewDidUnload];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [scrollTimer invalidate];
    [newTimer invalidate];
    [navBackgroundview setHidden:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController.navigationBar removeGestureRecognizer:tapRecon];
    
}

@end
