//
//  StoreAnalytics.h
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 14/02/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "LoginViewController.h"




@interface StoreAnalytics : NSObject

{

    NSString *subscriberString;
    
    NSMutableData *vistorPatternData;
    
    AppDelegate *appDelegate;

    NSMutableData *receivedData;
    

}




-(NSString *)getStoreAnalytics:(NSData *)data;

-(void)getVistorPattern;


@end
