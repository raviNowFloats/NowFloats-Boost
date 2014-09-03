//
//  IAPHelper.m
//  NowFloats Biz Management
//
//  Created by Sumanta Roy on 23/09/13.
//  Copyright (c) 2013 NowFloats Technologies. All rights reserved.
//

#import "IAPHelper.h"

NSString *const IAPHelperProductPurchasedNotification = @"IAPHelperProductPurchasedNotification";

NSString *const IAPHelperProductPurchaseFailedNotification = @"IAPHelperProductPurchaseFailedNotification";

NSString *const IAPHelperProductPurchaseRestoredNotification = @"IAPHelperProductPurchaseRestoredNotification";

NSString *const kSubscriptionExpirationDateKey = @"ExpirationDate";


@interface IAPHelper()<SKProductsRequestDelegate, SKPaymentTransactionObserver>

@end

@implementation IAPHelper

{

    SKProductsRequest *_productsRequest;
    RequestProductsCompletionHandler _completionHandler;
    NSSet * _productIdentifiers;
    NSMutableSet * _purchasedProductIdentifiers;

}
@synthesize delegate;

- (id)initWithProductIdentifiers:(NSSet *)productIdentifiers
{
    
    if ((self = [super init]))
    {        
        [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"com.biz.nowfloats.buydomain"];
        
        _productIdentifiers = productIdentifiers;
        
        _purchasedProductIdentifiers = [NSMutableSet set];
        
        for (NSString * productIdentifier in _productIdentifiers)
        {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:productIdentifier];
            
            if (productPurchased)
            {
                [_purchasedProductIdentifiers addObject:productIdentifier];
            }
            else
            {
                
            }
        }
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];

    }
    return self;
}


- (void)requestProductsWithCompletionHandler:(RequestProductsCompletionHandler)completionHandler
{
    _completionHandler = [completionHandler copy];
    
    _productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:_productIdentifiers];
    
    _productsRequest.delegate = self;
    
    [_productsRequest start];
}


- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [_purchasedProductIdentifiers containsObject:productIdentifier];
}


- (void)buyProduct:(SKProduct *)product
{
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}


#pragma mark - SKProductsRequestDelegate

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    _productsRequest = nil;
    NSArray * skProducts = response.products;
    _completionHandler(YES, skProducts);
    _completionHandler = nil;
}


- (void)request:(SKRequest *)request didFailWithError:(NSError *)error
{
    _productsRequest = nil;
    
    _completionHandler(NO, nil);
    
    _completionHandler = nil;
}


- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction * transaction in transactions) {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
            default:
                break;
        }
    };
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    
    [self provideContentForProductIdentifier:transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    /*
    UIAlertView *completeAlertView=[[UIAlertView alloc]initWithTitle:@"Success" message:@"Product Purchased Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
    
    [completeAlertView show];
*/
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    
    [self provideContentForProductIdentifier:transaction.originalTransaction.payment.productIdentifier];
    
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseRestoredNotification object:nil userInfo:nil];

}


- (void)failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled)
    {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];

    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchaseFailedNotification object:nil userInfo:nil];
}


- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [_purchasedProductIdentifiers addObject:productIdentifier];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

@end
