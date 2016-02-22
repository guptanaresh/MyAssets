//
//  DownloadViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>;
#import "Asset.h";
#import "User.h";
#import "MyAssetsAppDelegate.h";


#define kNameViewTag		1
#define kContainerButtonTag	2
#define kCategoryButtonTag	3
#define kPhoto1ButtonTag	4
#define kPhoto2ButtonTag	5
#define kPhoto3ButtonTag	6
#define kPhoto4ButtonTag	7
#define kCostViewTag		8
#define kQuantityViewTag	9
#define kNotesViewTag	10
#define kDateButtonTag	11
#define kField1LabelTag	12
#define kField1ViewTag	13
#define kField2LabelTag	14
#define kField2ViewTag	15

#define kScrollView		20


#define kADBannerView			70

#define kADBannerViewSizeOffset			60

@interface AddAssetViewController : UIViewController <UITextFieldDelegate, UITextViewDelegate, ADBannerViewDelegate, UIImagePickerControllerDelegate>
{
	UIScrollView			*scrollView;
	UITextField				*nameView;
	UITextField				*quantityView;
	UITextField				*costView;
	UITextView				*notesView;
	int						photoNumber;
	UIButton				*catButton;
	UIButton				*containerButton;
	UIButton				*dateButton;
	MyAssetsAppDelegate *deleg;
	Asset					*myAsset;
	UITextField				*field1View;
	UITextField				*field2View;
	UILabel					*field1Label;
	UILabel					*field2Label;
	UIButton				*photo1Button;
	UIButton				*photo2Button;
	UIButton				*photo3Button;
	UIButton				*photo4Button;
	bool					editAsset;
	ADBannerView *adMobAd;   // the actual ad; self.view is the location where the ad will be placed
	UIDatePicker *datePickerView;
	NSDate *myDate;
	BOOL bannerVisible;
}

@property (nonatomic, retain) UIScrollView				*scrollView;
@property (nonatomic, retain) UITextField				*nameView;
@property (nonatomic, retain) UITextField				*costView;
@property (nonatomic, retain) UITextField				*quantityView;
@property (nonatomic, retain) UITextView				*notesView;
@property (nonatomic, retain) UITextField				*field1View;
@property (nonatomic, retain) UILabel					*field1Label;
@property (nonatomic, retain) UITextField				*field2View;
@property (nonatomic, retain) UILabel					*field2Label;
@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, retain) UIButton *catButton;
@property (nonatomic, retain) UIButton *containerButton;
@property (nonatomic, retain) UIButton *dateButton;
@property (nonatomic, assign) Asset *myAsset;
@property (nonatomic, assign) UIButton				*photo1Button;
@property (nonatomic, assign) UIButton				*photo2Button;
@property (nonatomic, assign) UIButton				*photo3Button;
@property (nonatomic, assign) UIButton				*photo4Button;
@property (nonatomic, assign) bool editAsset;
@property (nonatomic, assign) int photoNumber;
@property (nonatomic, assign) NSDate *myDate;
@property (nonatomic, assign) UIDatePicker *datePickerView;
@property (nonatomic, assign) BOOL bannerVisible;

- (id)initWithAsset:(Asset *)asset;

+(NSString *)getPhotoPath:(int)num forAsset:(Asset *) pAsset;
-(void)setPhotoImage:(int)num;


@end
