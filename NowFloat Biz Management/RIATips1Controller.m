//
//  RIATips1Controller.m
//  NowFloats Biz Management
//
//  Created by jitu keshri on 7/26/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "RIATips1Controller.h"
#import "Mixpanel.h"
#import "BizStoreDetailViewController.h"

long viewHeight;
long viewWidth;
@interface RIATips1Controller ()

@end

@implementation RIATips1Controller

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
    // Do any additional setup after loading the view from its nib.
    
    UIButton *tip3Button = [[UIButton alloc]init];
    
    appDelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        viewWidth=result.width;
        if(result.height == 480)
        {
            //For iphone 3,3gS,4,42
            viewHeight=480;
            
            
            tip3Button.frame = CGRectMake(10, 390, 300, 60);
        }
        
        
        if(result.height == 568)
        {
            //For iphone 5
            viewHeight=568;
            
            
            
            tip3Button.frame = CGRectMake(10, 440, 300, 60);
            
        }
    }
    
    
    
    
    [tip3Button setImage:[UIImage imageNamed:@"OnBoarding-Screen#2-Button.png"] forState:UIControlStateNormal];
    [tip3Button addTarget:self action:@selector(tip3Action:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:tip3Button];
    
    
    
    

    
    
    UIWebView *webview = [[UIWebView alloc]initWithFrame:CGRectMake(20, 240, 280, 150)];
    [self.view addSubview:webview];
    NSString *EmbedCode = @"<iframe width=\"265\" height=\"140\" src=\"http://www.youtube.com/embed/v-AO1i5k8ws?modestbranding=0&;rel=0&;showinfo=0;autohide=1\" frameborder=\"0\" allowfullscreen></iframe>";
    [webview loadHTMLString:EmbedCode baseURL:nil];
    
}

- (IBAction)tip3Action:(id)sender {
    
    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    [mixPanel track:@"BuySEO_RiaTips"];
    
     [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"movetoseoplugin"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (IBAction)cancelAction:(id)sender
{
    
    Mixpanel *mixPanel = [Mixpanel sharedInstance];
    
    [mixPanel track:@"SkipBuySEO_RiaTips"];
    
    [appDelegate.storeDetailDictionary setObject:[NSNumber numberWithBool:YES] forKey:@"movetoseoplugin"];
    
    [self dismissViewControllerAnimated:NO completion:nil];
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
