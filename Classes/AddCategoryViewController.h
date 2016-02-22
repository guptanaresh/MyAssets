//
//  DownloadViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>;
#import "Category.h";
#import "MyAssetsAppDelegate.h";


#define kNameViewTag		1
#define kField1ViewTag		2
#define kField2ViewTag		3

#define kADBannerView			70


@interface AddCategoryViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, ADBannerViewDelegate, UIImagePickerControllerDelegate>
{
	UITextField				*nameView;
	UITextField				*field1View;
	UITextField				*field2View;
	MyAssetsAppDelegate *deleg;
	Category					*myCategory;
	bool					editCategory;
	ADBannerView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	BOOL bannerVisible;
}

@property (nonatomic, retain) UITextField				*nameView;
@property (nonatomic, retain) UITextField				*field1View;
@property (nonatomic, retain) UITextField				*field2View;
@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, assign) Category *myCategory;
@property (nonatomic, assign) bool editCategory;
@property (nonatomic, assign) BOOL bannerVisible;

- (id)initWithCategory:(Category *)cat;


@end
