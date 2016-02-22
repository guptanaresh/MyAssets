//
//  DownloadViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>;
#import "Place.h";
#import "MyAssetsAppDelegate.h";



#define kNameViewTag		1

#define kADBannerView			70

@interface AddPlaceViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, ADBannerViewDelegate, UIImagePickerControllerDelegate>
{
	UITextField				*nameView;
	MyAssetsAppDelegate *deleg;
	Place					*myPlace;
	bool					editPlace;
	ADBannerView			*adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	BOOL bannerVisible;
}

@property (nonatomic, retain) UITextField				*nameView;
@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, assign) Place *myPlace;
@property (nonatomic, assign) bool editPlace;
@property (nonatomic, assign) BOOL bannerVisible;

- (id)initWithPlace:(Place *)cat;


@end
