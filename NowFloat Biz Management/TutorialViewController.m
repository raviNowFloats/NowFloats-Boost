//
//  TutorialViewController.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 04/08/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import "TutorialViewController.h"
#import "UIColor+HexaString.h"
#import "SignUpViewController.h"
#import "LoginViewController.h"
#import "Mixpanel.h"
#import "LoginController.h"
#import "PreSignupViewController.h"

#define LEFT_EDGE_OFSET 0




@interface TutorialViewController ()<UIScrollViewDelegate>
{
    double WIDTH_OF_SCROLL_PAGE;
    double HEIGHT_OF_SCROLL_PAGE;
    double WIDTH_OF_IMAGE;
    double HEIGHT_OF_IMAGE;
}
@end

@implementation TutorialViewController


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
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden=YES;
}



- (void)viewDidLoad
{
    
    
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [bottomLabel setBackgroundColor:[UIColor colorWithHexString:@"ffb900"]];
    
    tutorialImageArray=[[NSMutableArray alloc]init];
    
    self.navigationController.navigationBarHidden=YES;
    
    version = [[UIDevice currentDevice] systemVersion];
    
    self.title = @"Home";
    
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            if (version.floatValue>=7.0)
            {
                [tutorialImageArray addObject:@"iphone47home.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen2.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen3.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen4.png"];
                [tutorialImageArray addObject:@"iphone4.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen6.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen7.png"];
                
                WIDTH_OF_SCROLL_PAGE= 320;
                HEIGHT_OF_SCROLL_PAGE= 436;
                WIDTH_OF_IMAGE =320;
                
                HEIGHT_OF_IMAGE =436;
                
                [bottomBarSignInButton  setFrame:CGRectMake(161,436, 159, 44)];
                [bottomBarSignInButton setTitleColor:[UIColor colorWithHexString:@"ffb900"] forState:UIControlStateNormal];
                
                [bottomBarRegisterButton setFrame:CGRectMake(0,436, 159, 44)];
                [bottomBarRegisterButton setTitleColor:[UIColor colorWithHexString:@"ffb900"] forState:UIControlStateNormal];
                
                
                CGRect frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width, 436);
                
                [bottomLabel setFrame:CGRectMake(0, 436, [[UIScreen mainScreen] bounds].size.width, 44)];
                
                [tutorialScrollView setFrame:frame];
                
                
                pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(115,380, 116, 20)];
                pageControl.numberOfPages =tutorialImageArray.count;
                [pageControl sizeToFit];
                [pageControl setPageIndicatorTintColor:[UIColor colorWithHexString:@"969696"]];
                [pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:@"4b4b4b"]];
                
                [self.view addSubview:pageControl];
            }
            
            else
            {
                [tutorialImageArray addObject:@"iphone47home.png"];
                [tutorialImageArray addObject:@"iOS6Newtutorialscreen2.png"];
                [tutorialImageArray addObject:@"iOS6Newtutorialscreen3.png"];
                [tutorialImageArray addObject:@"iOS6Newtutorialscreen4.png"];
                [tutorialImageArray addObject:@"iphone4.png"];
                [tutorialImageArray addObject:@"iOS6Newtutorialscreen6.png"];
                [tutorialImageArray addObject:@"iOS6Newtutorialscreen7.png"];
                
                WIDTH_OF_SCROLL_PAGE= 320;
                HEIGHT_OF_SCROLL_PAGE= 416;
                WIDTH_OF_IMAGE =320;
                
                HEIGHT_OF_IMAGE =416;
                
                [bottomBarSignInButton  setFrame:CGRectMake(161,416, 159, 44)];
                [bottomBarSignInButton setTitleColor:[UIColor colorWithHexString:@"ffb900"] forState:UIControlStateNormal];
                
                [bottomBarRegisterButton setFrame:CGRectMake(0,416, 159, 44)];
                [bottomBarRegisterButton setTitleColor:[UIColor colorWithHexString:@"ffb900"] forState:UIControlStateNormal];
                
                
                CGRect frame=CGRectMake(0, 0,[[UIScreen mainScreen] bounds].size.width, 416);
                
                [bottomLabel setFrame:CGRectMake(0, 416, [[UIScreen mainScreen] bounds].size.width, 44)];
                
                [tutorialScrollView setFrame:frame];
                
                
                pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(115,360, 116, 20)];
                pageControl.numberOfPages =tutorialImageArray.count;
                [pageControl sizeToFit];
                [pageControl setPageIndicatorTintColor:[UIColor colorWithHexString:@"969696"]];
                [pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:@"4b4b4b"]];
                
                [self.view addSubview:pageControl];
            }
        }
        
        else
        {
            if (version.floatValue>=7.0)
            {
                
                WIDTH_OF_SCROLL_PAGE= 320;
                HEIGHT_OF_SCROLL_PAGE= 524;
                WIDTH_OF_IMAGE =320;
                HEIGHT_OF_IMAGE =524;
                
                [tutorialImageArray addObject:@"iphone5home.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen2-568h@2x.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen3-568h@2x.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen4-568h@2x.png"];
                [tutorialImageArray addObject:@"iphone5.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen6-568h@2x.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen7-568h@2x.png"];
                
                pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(115,470,80, 20)];
                pageControl.numberOfPages = tutorialImageArray.count;
                [pageControl sizeToFit];
                [pageControl setPageIndicatorTintColor:[UIColor colorWithHexString:@"969696"]];
                [pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:@"4b4b4b"]];
                [self.view addSubview:pageControl];
                
            }
            
            else
            {
                WIDTH_OF_SCROLL_PAGE= 320;
                HEIGHT_OF_SCROLL_PAGE= 504;
                WIDTH_OF_IMAGE =320;
                HEIGHT_OF_IMAGE =504;
                
                [tutorialImageArray addObject:@"iphone5home.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen2-568h@2x.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen3-568h@2x.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen4-568h@2x.png"];
                [tutorialImageArray addObject:@"iphone5.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen6-568h@2x.png"];
                [tutorialImageArray addObject:@"Newtutorialscreen7-568h@2x.png"];
                
                pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(115,450,80, 20)];
                pageControl.numberOfPages = tutorialImageArray.count;
                [pageControl sizeToFit];
                [pageControl setPageIndicatorTintColor:[UIColor colorWithHexString:@"969696"]];
                [pageControl setCurrentPageIndicatorTintColor:[UIColor colorWithHexString:@"4b4b4b"]];
                [self.view addSubview:pageControl];
                
                [bottomLabel setFrame:CGRectMake(0, 504, [[UIScreen mainScreen] bounds].size.width, 44)];
                
                [bottomBarSignInButton  setFrame:CGRectMake(161,504, 159, 44)];
                [bottomBarSignInButton setTitleColor:[UIColor colorWithHexString:@"ffb900"] forState:UIControlStateNormal];
                
                [bottomBarRegisterButton setFrame:CGRectMake(0,504, 159, 44)];
                [bottomBarRegisterButton setTitleColor:[UIColor colorWithHexString:@"ffb900"] forState:UIControlStateNormal];
                
            }
        }
        
    }
    
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[tutorialImageArray objectAtIndex:([tutorialImageArray count]-1)]]];
    imageView.frame = CGRectMake(LEFT_EDGE_OFSET, 0, WIDTH_OF_IMAGE, HEIGHT_OF_IMAGE);
    [tutorialScrollView addSubview:imageView];
    
    
    for (int i = 0;i<[tutorialImageArray count];i++)
    {
    	//loop this bit
    	UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[tutorialImageArray objectAtIndex:i]]];
    	imageView.frame = CGRectMake((WIDTH_OF_IMAGE * i) + LEFT_EDGE_OFSET + 320, 0, WIDTH_OF_IMAGE, HEIGHT_OF_IMAGE);
    	[tutorialScrollView addSubview:imageView];
    	//
    }
    
    
    
    //add the first image at the end
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[tutorialImageArray objectAtIndex:0]]];
    imageView.frame = CGRectMake((WIDTH_OF_IMAGE * ([tutorialImageArray count] + 1)) + LEFT_EDGE_OFSET, 0, WIDTH_OF_IMAGE, HEIGHT_OF_IMAGE);
    [tutorialScrollView addSubview:imageView];
    
    
    
    [tutorialScrollView setContentSize:CGSizeMake(WIDTH_OF_SCROLL_PAGE * ([tutorialImageArray count] + 2), HEIGHT_OF_IMAGE)];
    [tutorialScrollView setContentOffset:CGPointMake(0, 0)];
    
    [tutorialScrollView scrollRectToVisible:CGRectMake(WIDTH_OF_IMAGE,0,WIDTH_OF_IMAGE,HEIGHT_OF_IMAGE) animated:NO];
    
    
}

-(void)pushRegisterViewController
{
    SignUpViewController *registerController=[[SignUpViewController alloc]initWithNibName:@"SignUpViewController" bundle:nil ];
    
    [self.navigationController pushViewController:registerController animated:YES];
    
    registerController=nil;
}

-(void)pushLoginViewController
{
    self.title = @"Home";
    
    LoginController *loginController=[[LoginController alloc]initWithNibName:@"LoginController" bundle:nil];
    
    [self.navigationController pushViewController:loginController animated:YES];
    
    loginController=nil;
}


#pragma UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView;
{
    
    [scrollTimer invalidate];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    
    CGFloat pageWidth = tutorialScrollView.frame.size.width;
    
    int page = floor((tutorialScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    if(page == 4)
    {
        Mixpanel *mixPanel = [Mixpanel sharedInstance];
        
        [mixPanel track:@"Verisign Screen Shown"];
    }
    
    if (page==1)
    {
        [bottomBarSignInButton setBackgroundImage:[UIImage imageNamed:@"login-landing.png"] forState:UIControlStateNormal];
        
        [bottomBarRegisterButton setBackgroundImage:[UIImage imageNamed:@"create-landing.png"] forState:UIControlStateNormal];
        
        [bottomLabel setBackgroundColor:[UIColor colorWithHexString:@"ffb900"]];
        
        [bottomBarSignInButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
        [bottomBarRegisterButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
    }
    
    else
    {
        [bottomBarSignInButton setBackgroundImage:[UIImage imageNamed:@"login-rest.png"] forState:UIControlStateNormal];
        
        [bottomBarRegisterButton setBackgroundImage:[UIImage imageNamed:@"create-rest.png"] forState:UIControlStateNormal];
        
        [bottomLabel setBackgroundColor:[UIColor whiteColor]];
        
        
        [bottomBarSignInButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
        [bottomBarRegisterButton setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateHighlighted];
        
        
    }
    
    pageControl.currentPage = page-1;
    
}

/*
 - (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
 {
 w=scrollView.contentOffset.x;
 
 }
 */

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    w=scrollView.contentOffset.x;
    
    int currentPage = floor((tutorialScrollView.contentOffset.x - tutorialScrollView.frame.size.width / ([tutorialImageArray count]+2)) / tutorialScrollView.frame.size.width) + 1;
    if (currentPage==0)
    {
    	[tutorialScrollView scrollRectToVisible:CGRectMake(WIDTH_OF_IMAGE * [tutorialImageArray count],0,WIDTH_OF_IMAGE,HEIGHT_OF_IMAGE) animated:NO];
        
    }
    else if (currentPage==([tutorialImageArray count]+1))
    {
    	[tutorialScrollView scrollRectToVisible:CGRectMake(WIDTH_OF_IMAGE,0,WIDTH_OF_IMAGE,HEIGHT_OF_IMAGE) animated:NO];
    }
    
}


- (IBAction)finalRegisterBtnClicked:(id)sender
{
    [self setUpSignUpViewController];
}


- (IBAction)finalLoginBtnClicked:(id)sender
{
    [self setUpLoginViewController];
    
}


- (IBAction)bottomBarRegisterBtnClicked:(id)sender
{
    [self setUpSignUpViewController];
    
}


- (IBAction)bottomBarLoginBtnClicked:(id)sender
{
    [self setUpLoginViewController];
}


-(void)setUpSignUpViewController
{
    Mixpanel *mixPanel=[Mixpanel sharedInstance];
    
    [mixPanel track:@"goToRegister_BtnClicked"];
    
    PreSignupViewController *signUpController=[[PreSignupViewController alloc]initWithNibName:@"PreSignupViewController" bundle:nil];
    
    [self.navigationController pushViewController: signUpController animated:YES];
    
    signUpController=nil;
}


-(void)setUpLoginViewController
{
    Mixpanel *mixPanel=[Mixpanel sharedInstance];
    
    [mixPanel track:@"goToLogin_BtnClicked"];
    
    [self pushLoginViewController];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)viewDidUnload
{
    tutorialScrollView = nil;
    bottomLabel = nil;
    bottomBarSignInButton = nil;
    bottomBarRegisterButton = nil;
    finalRegisterButton = nil;
    finalSignInButton = nil;
    finalSubView = nil;
    getStartedSubView = nil;
    [super viewDidUnload];
}


-(void)viewDidAppear:(BOOL)animated
{
    scrollTimer= [NSTimer scheduledTimerWithTimeInterval:4.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
}


-(void)viewDidDisappear:(BOOL)animated
{
    
    [scrollTimer invalidate];
    
}


- (void)onTimer
{
    
    w += 320;
    
    if (w==1920+320+320)
    {
        w=320;
        
        [tutorialScrollView scrollRectToVisible:CGRectMake(WIDTH_OF_IMAGE * [tutorialImageArray count],0,WIDTH_OF_IMAGE,HEIGHT_OF_IMAGE) animated:NO];
        
    }
    else
    {
        
        [tutorialScrollView setContentOffset:CGPointMake(w,0) animated:YES];
    }
    
    
    
    
}



@end
