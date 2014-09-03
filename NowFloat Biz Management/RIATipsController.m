//
//  RIATipsController.m
//  NowFloats Biz Management
//
//  Created by jitu keshri on 7/25/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "RIATipsController.h"
#import "RIATips1Controller.h"
#import "BizMessageViewController.h"
#import "Mixpanel.h"

NSMutableArray *subViewArray;
long viewHeight;
long viewWidth;
UIButton *tip1Button;
UIButton *tip2Button ;
UIButton *tip3Button ;
UIImageView *riaImage ;
@interface RIATipsController ()

@end

@implementation RIATipsController
@synthesize skipLbael1,skipLbael2;
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
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
     appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    // Do any additional setup after loading the view from its nib.
    
    
    UIButton *tip1Button = [[UIButton alloc]init];
    UIButton *tip2Button = [[UIButton alloc]init];
    UIButton *tip3Button = [[UIButton alloc]init];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        viewWidth=result.width;
        if(result.height == 480)
        {
            //For iphone 3,3gS,4,42
            viewHeight=480;
            
            tip1Button.frame = CGRectMake(10, 390, 300, 60);
            tip2Button.frame = CGRectMake(10, 390, 300, 60);
            tip3Button.frame = CGRectMake(10, 390, 300, 60);
        }
        
        
        if(result.height == 568)
        {
            //For iphone 5
            viewHeight=568;
            
            
            tip1Button.frame = CGRectMake(10, 440, 300, 60);
            tip2Button.frame = CGRectMake(10, 440, 300, 60);
            tip3Button.frame = CGRectMake(10, 440, 300, 60);
            
        }
    }
    
    
    
    [tip1Button setImage:[UIImage imageNamed:@"OnBoarding-Screen#1Asset.png"] forState:UIControlStateNormal];
    [tip1Button addTarget:self action:@selector(tip1Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.step1View addSubview:tip1Button];
    
    
    [tip2Button setImage:[UIImage imageNamed:@"OnBoarding-Screen#1.1-Asset.png"] forState:UIControlStateNormal];
    
    [tip2Button addTarget:self action:@selector(tip2Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.step2View addSubview:tip2Button];
    
    
    [tip3Button setImage:[UIImage imageNamed:@"OnBoarding-Screen#1Asset.png"] forState:UIControlStateNormal];
    [tip3Button addTarget:self action:@selector(tip3Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.step3View addSubview:tip3Button];
    
    
    
    
    
    subViewArray = [[NSMutableArray alloc]init];
    
    [subViewArray addObject:self.step1View];
    [subViewArray addObject:self.step2View];
    [subViewArray addObject:self.step3View];
    
    
    for (int i = 0; i < subViewArray.count; i++)
    {
        CGRect frame;
        frame.origin.x = self.riaScrollview.frame.size.width * i;
        frame.origin.y = 0;
        
        if(viewHeight==568)
        {
            frame.size.height = 548;
        }
        else
        {
            frame.size.height = 460;//460
            
            
        }
        frame.size.width= 320;
        
        UIView *subview = [[UIView alloc] initWithFrame:frame];
        [subview addSubview:[subViewArray objectAtIndex:i]];
        [self.riaScrollview addSubview:subview];
    }
    
    self.riaScrollview.contentSize = CGSizeMake(self.riaScrollview.frame.size.width * subViewArray.count,548);
    
    
    self.riaScrollview.scrollEnabled = NO;
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated
{

    
    
    
}



- (void)checkMovieStatus:(NSNotification *)notification {
    if(self.moviePlayerController.loadState & (MPMovieLoadStatePlayable | MPMovieLoadStatePlaythroughOK))
    {
        [self.step2View addSubview:self.moviePlayerController.view];
        [self.moviePlayerController play];
    }
}

- (void)checkMovieStatus1:(NSNotification *)notification {
    
}

-(void)firstVideo
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkMovieStatus:) name:MPMoviePlayerLoadStateDidChangeNotification object:nil];
    [self.moviePlayerController prepareToPlay];
    
}

- (IBAction)tip1Action:(id)sender {

    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    [mixPanel track:@"PlayVideo_RiaTips"];
    
    
    CGRect frame = CGRectMake(320,self.riaScrollview .frame.origin.y, self.riaScrollview .frame.size.width, self.riaScrollview .frame.size.height);
    
    [self.riaScrollview scrollRectToVisible:frame animated:YES];

    
    [self firstVideo];
    
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(20, 240, 280, 200)];
    [self.view addSubview:webview];
    NSString *EmbedCode = @"<iframe width=\"265\" height=\"140\" src=\"http://www.youtube.com/embed/an9QTxLKnfg?modestbranding=0&;rel=0&;showinfo=0;autohide=1\" frameborder=\"0\" allowfullscreen></iframe>";
    [webview loadHTMLString:EmbedCode baseURL:nil];
    
    
    
}


- (IBAction)tip2Action:(id)sender {
    
    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    [mixPanel track:@"ShowHome_RiaTips"];
    
    BizMessageViewController *frontController=[[BizMessageViewController alloc]initWithNibName:@"BizMessageViewController" bundle:nil];
    frontController.isLoadedFirstTime=YES;
    frontController.uploadText = @"YES";
    [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"showTutorial"];
    [self.navigationController pushViewController:frontController animated:YES];
    
}




- (IBAction)skipView1:(id)sender {
    
    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    [mixPanel track:@"SkipRiaVideo_RiaTips"];
    
    skipLbael1.alpha = 0.4f;
    
    BizMessageViewController *frontController=[[BizMessageViewController alloc]initWithNibName:@"BizMessageViewController" bundle:nil];
    frontController.isLoadedFirstTime=YES;
    //frontController.uploadText = @"YES";
    
      [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"stopTutorialView"];
    
    [self.navigationController pushViewController:frontController animated:YES];
    
    
}

- (IBAction)skipView2:(id)sender {
    skipLbael2.alpha = 0.4f;
    BizMessageViewController *frontController=[[BizMessageViewController alloc]initWithNibName:@"BizMessageViewController" bundle:nil];
    
    frontController.isLoadedFirstTime=YES;
    
      [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"stopTutorialView"];
    [self.navigationController pushViewController:frontController animated:YES];
    
    
}
@end
