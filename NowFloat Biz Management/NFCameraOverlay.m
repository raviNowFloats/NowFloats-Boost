//
//  NFCameraOverlay.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 23/03/14.
//  Copyright (c) 2014 NowFloats Technologies. All rights reserved.
//

#import "NFCameraOverlay.h"
#import "NFCropOverlay.h"
#import "UIImage+fixOrientation.h"
#import "UIColor+HexaString.h"

@interface NFCameraOverlay ()<NFCropOverlayDelegate>
{
    float viewHeight;
    NSString *version;
    NSMutableDictionary *imageInfo;
    UIImage *pickedImage;
}
@property(nonatomic,strong)  NFCropOverlay *cropController;

@end

@implementation NFCameraOverlay
@synthesize pickerReference = _pickerReference;
@synthesize delegate;
@synthesize takePictureBtn;
@synthesize bottomBarSubView;
@synthesize cropController;


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
    
    version = [[UIDevice currentDevice] systemVersion];
    
    self.navigationController.navigationBarHidden = YES;
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [capturedImageView setHidden:NO];
    
    [bottomBarSubView setHidden:NO];
    
    [_pickerReference setDelegate:self];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize result = [[UIScreen mainScreen] bounds].size;
        if(result.height == 480)
        {
            
            viewHeight=480;
            [captureImageToolBar setFrame:CGRectMake(0, 411, captureImageToolBar.frame.size.width,captureImageToolBar.frame.size.height)];
        }
        
        else
        {
            
            viewHeight=568;
        }
    }
    
    if (viewHeight == 480)
    {
       
        [bottomBarSubView setFrame:CGRectMake(bottomBarSubView.frame.origin.x, 200, bottomBarSubView.frame.size.width, bottomBarSubView.frame.size.height)];
        
        [capturedImageView setFrame:CGRectMake(capturedImageView.frame.origin.x, capturedImageView.frame.origin.y, capturedImageView.frame.size.width, 328)];
        
    }
  
    [self.view addSubview:captureImageToolBar];
   

}


//-(void)useBtnClicked
//{
//    
//    [self performSelector:@selector(pushCropController) withObject:nil afterDelay:0.2];
//}


- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //[imageInfo addEntriesFromDictionary:info];
    
    imageInfo = [[NSMutableDictionary alloc]initWithDictionary:info];

    [tabBar removeFromSuperview];
    
    [self pushCropController];
    
}


-(void)pushCropController
{
    cropController = [[NFCropOverlay alloc]initWithNibName:@"NFCropOverlay" bundle:nil];
    
    cropController.delegate = self;
    
    cropController.imageInfo = imageInfo;
    
    [_pickerReference presentViewController:cropController animated:NO completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;
{
    [delegate performSelector:@selector(NFOverlayDidCancelPickingMedia)];
}


- (IBAction)takePictureBtnClicked:(id)sender
{
    [_pickerReference takePicture];
}

- (IBAction)cameraCloseBtnClicked:(id)sender
{
    [delegate performSelector:@selector(NFOverlayDidCancelPickingMedia)];    
}


#pragma mark- NFCropOverlayDelegate
-(void)NFCropOverlayDidFinishCroppingWithImage:(UIImage *)croppedImage
{
    [delegate performSelector:@selector(NFOverlayDidFinishCroppingWithImage:) withObject:croppedImage];
    
    [_pickerReference dismissViewControllerAnimated:NO completion:nil];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

}

- (IBAction)captureImage:(id)sender {
    [self takePictureBtnClicked:nil];
}

- (IBAction)cameraClosed:(id)sender {
    [self cameraCloseBtnClicked:nil];
}
@end
