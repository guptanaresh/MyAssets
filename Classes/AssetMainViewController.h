//
//  FirstViewController.h
//  MyAssets
//
//  Created by naresh gupta on 2/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Asset.h"
#import <iAd/iAd.h>
#import "Constants.h"
#import "MyAssetsAppDelegate.h"


#define kAssetTableViewTag	1
#define kAssetTotalViewTag	2

#define kADBannerView			70

@interface AssetMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>
{
	NSMutableArray			*assetList;
	UITableView				*myTableView;
	UILabel					*myTotalView;
	MyAssetsAppDelegate *deleg;
	ADBannerView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	UIView *modelView;
	BOOL bannerVisible;
}
@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, assign) NSMutableArray *assetList;
@property (nonatomic, retain) UILabel				*myTotalView;
@property (nonatomic, assign) BOOL bannerVisible;

@end
