//
//  ScoreWebViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAssetsAppDelegate.h"
#import "Asset.h"
#import "Reachability.h"

#define kAssetsWebViewTag	1
#define kEmailButtonTag	2
#define kCancelEmailButtonTag	3



@interface AssetWebViewController : UIViewController {
	MyAssetsAppDelegate	*deleg;
	UIWebView				*assetView;	
	UIButton				*emailButton;
	UIButton				*cancelButton;
}

@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, assign) UIWebView				*assetView;
@property (nonatomic, retain) UIButton					*emailButton;
@property (nonatomic, retain) UIButton					*cancelButton;

@end

