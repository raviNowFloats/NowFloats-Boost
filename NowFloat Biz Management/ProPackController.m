//
//  ProPackController.m
//  NowFloats Biz Management
//
//  Created by Ravindra Naik on 13/08/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "ProPackController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+HexaString.h"
#import "BizStoreIAPHelper.h"
#import "BuyStoreWidget.h"
#import "FileManagerHelper.h"
#import "Mixpanel.h"
#import "DomainSelectViewController.h"

@interface ProPackController ()<BuyStoreWidgetDelegate,SKProductsRequestDelegate>
{
    int viewHeight;
    
    NSString *versionString;
    
     NSArray *_products;
    
    UIButton *buyButton;
}

@end

@implementation ProPackController

@synthesize isFromOtherViews;

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
    mainTableView.contentSize = CGSizeMake(320, 620);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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
    
    versionString=[[UIDevice currentDevice]systemVersion];
    
    appDelegate=(AppDelegate *)[UIApplication sharedApplication].delegate;
    
    mixPanel = [Mixpanel sharedInstance];
    
    if (versionString.floatValue<7.0)
    {
        self.navigationController.navigationBarHidden=NO;
        /*
         CGFloat width = self.view.frame.size.width;
         
         navBar = [[UINavigationBar alloc] initWithFrame:
         CGRectMake(0,0,width,44)];
         
         [self.view addSubview:navBar];
         */
        UIImage *buttonImage = [UIImage imageNamed:@"back-btn.png"];
        
        customCancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
        
        [customCancelButton setImage:buttonImage forState:UIControlStateNormal];
        
        [customCancelButton setTitleColor:[UIColor colorWithHexString:@"464646"] forState:UIControlStateNormal];
        
        customCancelButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:12.0];
        
        [customCancelButton setFrame:CGRectMake(5,0,50,44)];
        
        [customCancelButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
        [customCancelButton setShowsTouchWhenHighlighted:YES];
        
        UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc]initWithCustomView:    customCancelButton];
        
        self.navigationItem.leftBarButtonItem = leftBtnItem;
        
        
    }
    
    else
    {
      //   bizStoreDetailsTableView.separatorInset=UIEdgeInsetsZero;
        
     //   self.navigationItem.backBarButtonItem.title = @"NFStore";
        
        if (isFromOtherViews)
        {
            self.navigationController.navigationBarHidden=NO;
            self.navigationController.navigationBar.barTintColor = [UIColor colorFromHexCode:@"ffb900"];
            self.navigationController.navigationBar.translucent = NO;
            self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
            
            
            UIImage *buttonImage = [UIImage imageNamed:@"back-btn.png"];
            
            customCancelButton=[UIButton buttonWithType:UIButtonTypeCustom];
            
            [customCancelButton setImage:buttonImage forState:UIControlStateNormal];
            
            [customCancelButton setTitleColor:[UIColor colorWithHexString:@"464646"] forState:UIControlStateNormal];
            
            customCancelButton.titleLabel.font=[UIFont fontWithName:@"Helvetica" size:12.0];
            
            [customCancelButton setFrame:CGRectMake(5,0,50,44)];
            
            [customCancelButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
            
            [customCancelButton setShowsTouchWhenHighlighted:YES];
            
            UIBarButtonItem *leftBtnItem=[[UIBarButtonItem alloc]initWithCustomView:customCancelButton];
            
            self.navigationItem.leftBarButtonItem = leftBtnItem;
        }
        else
        {
            
        }
        
        
    }

    priceButton.tag = 1017;
   
    
    [mainScroll addSubview:priceButton];
    
    featureLabel.textColor = [UIColor colorFromHexCode:@"#6e6e6e"];
    
    mainTableView.frame = CGRectMake(mainTableView.frame.origin.x, mainTableView.frame.origin.y, 320, mainTableView.frame.size.height + 60);

    
    [self setScrollViews];
    
    newBanner.frame = CGRectMake(0, 177, 320, 20);
    
    mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    [mainTableView addSubview:newBanner];
   
}

-(void)setScrollViews
{
    FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
    
    fHelper.userFpTag=appDelegate.storeTag;
    
    NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
    
    [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
    
    NSString *titlePrice ;
    
    if ([fHelper openUserSettings] != NULL)
    {
        if([userSetting objectForKey:@"propackpurchased"] == [NSNumber numberWithBool:YES])
        {
            titlePrice = @"Purchased";
        }
        else
        {
            titlePrice = [appDelegate.productDetailsDictionary objectForKey:@"com.biz.nowfloatsthepropack"];
        }
    }
    
    
    buyButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 132, 240, 30)];
    [buyButton setTitleColor:[UIColor colorFromHexCode:@"#ffb900"] forState:UIControlStateNormal];
    [buyButton setTitle:titlePrice forState:UIControlStateNormal];
    buyButton.titleLabel.font = [UIFont fontWithName:@"Helvetica-Light" size:16];
    if([titlePrice isEqualToString:@"Purchased"])
    {
        buyButton.enabled = NO;
        buyButton.alpha = 0.5;
        [self bookDomain];
    }
    else
    {
        [buyButton addTarget:self action:@selector(buyWidget:) forControlEvents:UIControlEventTouchUpInside];
    }
    
   
    buyButton.layer.borderColor = [UIColor colorFromHexCode:@"#ffb900"].CGColor;
    buyButton.layer.borderWidth = 1;
    
    buyButton.layer.cornerRadius = 5.0;
    buyButton.layer.masksToBounds = YES;
   
    [mainTableView addSubview:buyButton];
   
    
    
    UIImageView *dotComImageView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 225, 50, 13)];
    dotComImageView.image = [UIImage imageNamed:@"storecom.png"];
    [mainTableView addSubview:dotComImageView];
    
    UILabel *domainHeadText = [[UILabel alloc] initWithFrame:CGRectMake(100, 200, 220, 20)];
    domainHeadText.text = @".COM";
    domainHeadText.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    domainHeadText.textColor = [UIColor colorFromHexCode:@"#535353"];
    [mainTableView addSubview:domainHeadText];
    
    UILabel *domainText = [[UILabel alloc] initWithFrame:CGRectMake(100, 205, 220, 80)];
//    domainText.text = @"Give your business an identity of its own. The domain is valid for one year. Check domain availability here";
    
    NSMutableAttributedString *yourString = [[NSMutableAttributedString alloc] initWithString:@"here"];
    [yourString addAttribute:NSUnderlineStyleAttributeName
                       value:[NSNumber numberWithInt:1]
                       range:(NSRange){0,4}];
    
    
   

    UILabel *checkDomain = [[UILabel alloc] initWithFrame:CGRectMake(252, 250, 40, 20)];
    checkDomain.attributedText = [yourString copy];
    checkDomain.textAlignment = NSTextAlignmentLeft;
    checkDomain.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0];
    checkDomain.textColor = [UIColor colorFromHexCode:@"#858585"];
    
    UITapGestureRecognizer *openMobVersion = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showDomain)];
    openMobVersion.numberOfTapsRequired = 1;
    openMobVersion.numberOfTouchesRequired = 1;
    [checkDomain addGestureRecognizer:openMobVersion];
    [checkDomain setUserInteractionEnabled:YES];
   
    [mainTableView addSubview:checkDomain];
    
    
    
    domainText.text = @"Give your business an identity of its own. The domain is valid for one year. Check domain availability";
    domainText.numberOfLines = 3;
    domainText.textAlignment = NSTextAlignmentLeft;
    domainText.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0];
    domainText.textColor = [UIColor colorFromHexCode:@"#858585"];
    [mainTableView addSubview:domainText];
    
    
    
    UIImageView *ttbImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 290, 30, 30)];
    ttbImageView.image = [UIImage imageNamed:@"ttbDetail.png"];
    [mainTableView addSubview:ttbImageView];
    
    UILabel *ttbHeadText = [[UILabel alloc] initWithFrame:CGRectMake(100, 276, 220, 20)];
    ttbHeadText.text = @"Business Enquiries";
    ttbHeadText.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    ttbHeadText.textColor = [UIColor colorFromHexCode:@"#535353"];
    [mainTableView addSubview:ttbHeadText];
    
    UILabel *ttbText = [[UILabel alloc] initWithFrame:CGRectMake(100, 281, 220, 80)];
    ttbText.text = @"Let customers directly contact you. Enquiries sent from website are delivered to you instantly in the app.";
    ttbText.numberOfLines = 3;
    ttbText.textAlignment = NSTextAlignmentLeft;
    ttbText.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0];
    ttbText.textColor = [UIColor colorFromHexCode:@"#858585"];
    [mainTableView addSubview:ttbText];
    
    
    
    UIImageView *galleryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 363, 30, 30)];
    galleryImageView.image = [UIImage imageNamed:@"galleryDetail.png"];
    [mainTableView addSubview:galleryImageView];
    
    UILabel *galleryHeadText = [[UILabel alloc] initWithFrame:CGRectMake(100, 351, 220, 20)];
    galleryHeadText.text = @"Image Gallery";
    galleryHeadText.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    galleryHeadText.textColor = [UIColor colorFromHexCode:@"#535353"];
    [mainTableView addSubview:galleryHeadText];
    
    UILabel *galleryText = [[UILabel alloc] initWithFrame:CGRectMake(100, 368, 220, 40)];
    galleryText.text = @"Display your wares, services, promos, etc. ";
    galleryText.numberOfLines = 3;
    galleryText.textAlignment = NSTextAlignmentLeft;
    galleryText.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0];
    galleryText.textColor = [UIColor colorFromHexCode:@"#858585"];
    [mainTableView addSubview:galleryText];
    
    UIImageView *hoursImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 432, 30, 30)];
    hoursImageView.image = [UIImage imageNamed:@"Business-Hours.png"];
    [mainTableView addSubview:hoursImageView];
    
    UILabel *hoursHeadText = [[UILabel alloc] initWithFrame:CGRectMake(100, 415, 220, 20)];
    hoursHeadText.text = @"Business Timings";
    hoursHeadText.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    hoursHeadText.textColor = [UIColor colorFromHexCode:@"#535353"];
    [mainTableView addSubview:hoursHeadText];
    
    UILabel *hoursText = [[UILabel alloc] initWithFrame:CGRectMake(100, 430, 220, 40)];
    hoursText.text = @"Inform the public what time your business is open.";
    hoursText.numberOfLines = 3;
    hoursText.textAlignment = NSTextAlignmentLeft;
    hoursText.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0];
    hoursText.textColor = [UIColor colorFromHexCode:@"#858585"];
    [mainTableView addSubview:hoursText];
    
    UIImageView *adFreeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 487, 30, 30)];
    adFreeImageView.image = [UIImage imageNamed:@"Block-Ads.png"];
    [mainTableView addSubview:adFreeImageView];
    
    UILabel *adFreeHeadText = [[UILabel alloc] initWithFrame:CGRectMake(100, 478, 220, 20)];
    adFreeHeadText.text = @"Ad Free Site";
    adFreeHeadText.font = [UIFont fontWithName:@"Helvetica-Neue" size:17.0];
    adFreeHeadText.textColor = [UIColor colorFromHexCode:@"#535353"];
    [mainTableView addSubview:adFreeHeadText];
    
    UILabel *adFreeText = [[UILabel alloc] initWithFrame:CGRectMake(100, 497, 220, 20)];
    adFreeText.text = @"Make your site third party ad-free";
    adFreeText.numberOfLines = 3;
    adFreeText.textAlignment = NSTextAlignmentLeft;
    adFreeText.font = [UIFont fontWithName:@"Helvetica-Light" size:13.0];
    adFreeText.textColor = [UIColor colorFromHexCode:@"#858585"];
    [mainTableView addSubview:adFreeText];

    
    
}




-(void)back
{
     [self.navigationController popViewControllerAnimated:YES];
}

-(void)productsRequest:(SKProductsRequest *)request
    didReceiveResponse:(SKProductsResponse *)response
{
    SKProduct *validProduct = nil;
    int count = [response.products count];
    if (count>0) {
        
        validProduct = [response.products objectAtIndex:0];
        if ([validProduct.productIdentifier isEqualToString:@"com.biz.ttbdomaincombo"])
        {
            NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
            [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
            [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
            [numberFormatter setLocale:validProduct.priceLocale];
           
        }
    } else {
        UIAlertView *tmp = [[UIAlertView alloc]
                            initWithTitle:@"Not Available"
                            message:@"No products to purchase"
                            delegate:self
                            cancelButtonTitle:nil
                            otherButtonTitles:@"Ok", nil];
        [tmp show];
    }
    
}

-(void)buyStoreWidgetDidSucceed
{
    
    [appDelegate.storeWidgetArray insertObject:@"TOB" atIndex:0];
    [appDelegate.storeWidgetArray insertObject:@"NOADS" atIndex:1];
    [appDelegate.storeWidgetArray insertObject:@"IMAGEGALLERY" atIndex:2];
    [appDelegate.storeWidgetArray insertObject:@"TIMINGS" atIndex:3];
    [appDelegate.storeWidgetArray insertObject:@"SITESENSE" atIndex:3];
    
}


-(void)buyStoreWidgetDidFail
{
   
    UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@"Oops" message:@"Something went wrong while adding this widget. Reach us at ria@nowfloats.com" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [alertView show];
    
    alertView=nil;
}


- (IBAction)buyWidget:(id)sender
{
    buyButton.alpha = 0.5;
    
    
        [mixPanel track:@"buyProPack_BtnClicked"];
        
        [[BizStoreIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products)
         {
             _products = nil;
             
             if (success)
             {
                 _products = products;
                 
                 SKProduct *product = _products[5];
                 [[BizStoreIAPHelper sharedInstance] buyProduct:product];
             }
             
             else
             {
                 
                 
                 UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:@":(" message:@"Looks like something went wrong. Check back later." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                 [alertView show];
                 alertView=nil;
             }
         }];

}

- (void)productPurchased:(NSNotification *)notification
{
    BuyStoreWidget *buyWidget=[[BuyStoreWidget alloc]init];
    
    buyWidget.delegate=self;
    
    
    FileManagerHelper *fHelper=[[FileManagerHelper alloc]init];
    
    fHelper.userFpTag=appDelegate.storeTag;
    
    NSMutableDictionary *userSetting=[[NSMutableDictionary alloc]init];
    
    [userSetting addEntriesFromDictionary:[fHelper openUserSettings]];
    
    if ([fHelper openUserSettings] != NULL)
    {
        [userSetting setObject:[NSNumber numberWithBool:YES] forKey:@"propackpurchased"];
    }
   
    buyButton.alpha = 1.0;
        
        [mixPanel track:@"purchased_propack"];
    
    
    
        [buyWidget purchaseStoreWidget:1100];
    
        [buyWidget purchaseStoreWidget:1008];
    
        [buyWidget purchaseStoreWidget:1002];
    
        
        [buyWidget purchaseStoreWidget:1004];
  
        [buyWidget purchaseStoreWidget:1006];
         
        [buyWidget purchaseStoreWidget:11000];
   
    [self bookDomain];
}

-(void)showDomain
{
    [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"propackShowview"];
    DomainSelectViewController *selectController=[[DomainSelectViewController alloc]initWithNibName:@"DomainSelectViewController" bundle:Nil];
    
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:selectController];
    
    [self presentViewController:navController animated:YES completion:nil];
}


-(void)bookDomain
{
    if([appDelegate.storeRootAliasUri isEqualToString:@""])
    {
        
    }
    else
    {
        DomainSelectViewController *selectController=[[DomainSelectViewController alloc]initWithNibName:@"DomainSelectViewController" bundle:Nil];
        
        UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:selectController];
        
        [self presentViewController:navController animated:YES completion:nil];
    }
   
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
