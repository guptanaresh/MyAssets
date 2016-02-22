//
//  FirstViewController.h
//  MyAssets
//
//  Created by naresh gupta on 2/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Place.h";
#import <iAd/iAd.h>;
#import "Constants.h";
#import "MyAssetsAppDelegate.h";
#import "Asset.h";


#define kPlaceTableViewTag	1
@interface PlaceMainViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, ADBannerViewDelegate>
{
	NSMutableArray			*placeList;
	UITableView				*myTableView;
	MyAssetsAppDelegate *deleg;
	Asset *myAsset;
	ADBannerView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	bool	picker;
	BOOL bannerVisible;
}
@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, retain) UITableView *myTableView;
@property (nonatomic, assign) NSMutableArray *placeList;
@property (nonatomic, assign) bool	picker;
@property (nonatomic, assign) Asset *myAsset;
@property (nonatomic, assign) BOOL bannerVisible;


- (id)initAsPicker:(Asset *) asset;

@end
