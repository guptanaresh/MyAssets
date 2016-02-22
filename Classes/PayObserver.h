//
//  PayViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 6/12/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/SKPaymentQueue.h>
#import "Constants.h"
#import <StoreKit/SKProductsRequest.h>


@interface PayObserver : NSObject<SKPaymentTransactionObserver, SKProductsRequestDelegate>
{
	
}

-(void) requestProductData:(NSString *)pID;
- (void) recordTransaction: (SKPaymentTransaction *)transaction;
- (void) failedTransaction: (SKPaymentTransaction *)transaction;
- (void) restoreTransaction: (SKPaymentTransaction *)transaction;
- (void) completeTransaction: (SKPaymentTransaction *)transaction;

@end
