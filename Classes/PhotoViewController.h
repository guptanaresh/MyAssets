//
//  PhotoViewController.h
//  MyAssets
//
//  Created by naresh gupta on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAssetsAppDelegate.h"
#import "Asset.h"
#import "PhotoView.h"
#import "Reachability.h"
	
#define kScrollViewTag	1
#define kPhotoViewTag	2
	
	
	
@interface PhotoViewController : UIViewController  <UIScrollViewDelegate, PhotoViewDelegate, UIImagePickerControllerDelegate>{
		MyAssetsAppDelegate	*deleg;
		UIScrollView	*photoScrollView;	
		Asset				*myAsset;
		NSInteger				photoNumber;
	}
	
	@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
	@property (nonatomic, assign) UIScrollView	*photoScrollView;
	@property (nonatomic, assign) Asset				*myAsset;
	@property (nonatomic, assign) NSInteger				photoNumber;
	
@end
