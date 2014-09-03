//
//  BusinessDetailsViewController.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 31/01/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"




@interface BusinessDetailsViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate, SWRevealViewControllerDelegate,UITableViewDataSource,UITableViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{

    int textFieldTag;
    AppDelegate *appDelegate;
    
    NSMutableDictionary *upLoadDictionary;
    NSDictionary *textDescriptionDictionary;
    NSDictionary *textTitleDictionary;
    
    
    NSString *businessNameString;
    NSString *businessDescriptionString;
    
    BOOL isStoreTitleChanged;
    
    BOOL isStoreDescriptionChanged;
    
    IBOutlet UIScrollView *detailScrollView;
    
    UINavigationBar *navBar;
    
    UIButton *customButton;
    
    IBOutlet UILabel *businessNamePlaceHolderLabel;
    
    IBOutlet UILabel *businessDescriptionPlaceHolderLabel;
    
    NSString *frontViewPosition;
    
    IBOutlet UIButton *revealFrontControllerButton;

    IBOutlet UIView *contentSubView;

    __weak IBOutlet UIPickerView *catPicker;
    
    __weak IBOutlet UIToolbar *pickerToolBar;
    
    __weak IBOutlet UITextField *categoryText;
    NSString *version ;
    
    int totalImageDataChunks;
    
    NSMutableData *receivedData;
    
    int successCode;
    NSUserDefaults *userDetails; 
    
}
@property (weak, nonatomic) IBOutlet UITextView *businessNameTextView;
@property (weak, nonatomic) IBOutlet UITextView *businessDescriptionTextView;
@property (nonatomic,strong)    NSMutableArray *uploadArray;

@property (nonatomic,strong) NSMutableArray *chunkArray;

@property (nonatomic,strong) NSMutableURLRequest *request;

@property (nonatomic,strong) NSData *dataObj;

@property (nonatomic,strong) NSString *uniqueIdString;

@property (nonatomic,strong) NSURLConnection *theConnection;



- (IBAction)cancelPicker:(id)sender;
- (IBAction)donePicker:(id)sender;

- (IBAction)businessCategories:(id)sender;

-(IBAction)dismissKeyboardOnTap:(id)sender;

- (IBAction)revealFrontController:(id)sender;

@property (strong, nonatomic) IBOutlet UITableView *businessDetTable;
@property (strong, nonatomic) IBOutlet UIImageView *primaryImageView;
- (IBAction)closeView:(id)sender;
@property (strong, nonatomic) IBOutlet UIView *errorView;
@property (nonatomic,strong) UIImagePickerController *picker;
@property (strong, nonatomic) IBOutlet UIButton *cancelLabel;

@end
