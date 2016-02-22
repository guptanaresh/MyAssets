//
//  PayViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "PayObserver.h"
#import "Constants.h"
#import "MyAssetsAppDelegate.h"
#import "User.h"
#import <StoreKit/SKPayment.h>
#import <StoreKit/SKPaymentTransaction.h>


@implementation PayObserver

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
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
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    [self recordTransaction: transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) failedTransaction: (SKPaymentTransaction *)transaction
{
	NSError *err=transaction.error;
    if (err !=nil)
    {
		NSLog([err description]);
    }
	
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void) recordTransaction: (SKPaymentTransaction *)transaction
{
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
	UIApplication *app = [UIApplication sharedApplication];
	MyAssetsAppDelegate *deleg = (MyAssetsAppDelegate *)[app delegate];
	User *myUser=[[User alloc] initWithDB:deleg.database];
	
	myUser.service=kServiceBackup;
	
	[myUser toDB];
	//[myUser uploadService];
	
}

-(void) requestProductData:(NSString *)pID
{
	NSString *appName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleIdentifierKey];
	NSString *pIDStr = [NSString stringWithFormat:@"%@.%@",appName, pID];
	
	SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers: [NSSet setWithObject: pIDStr]];
	request.delegate = self;
	[request start];
	/*
	 SKPayment *payment = [SKPayment paymentWithProductIdentifier:pID];
	 [[SKPaymentQueue defaultQueue] addPayment:payment];
	 
	 */
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
	for (SKProduct *myProduct in response.products){
		SKPayment *payment = [SKPayment paymentWithProductIdentifier:[myProduct productIdentifier]];
		[[SKPaymentQueue defaultQueue] addPayment:payment];
	}
}

- (void)dealloc {
    [super dealloc];
}


@end
