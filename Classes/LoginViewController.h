//
//  DownloadViewController.h
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>;
#import "Constants.h";
#import "MyAssetsAppDelegate.h";
#import "User.h";
#import "Reachability.h";


#define kUserNameViewTag	1
#define kPasswordViewTag	2
#define kUDIDViewTag		3
#define kUsernameChangeButtonTag	4
#define kPasswordChangeButtonTag	5
#define kUDIDChangeButtonTag		6
#define kBackupButtonTag				7
#define kUDIDHelpTag				8

#define kBusyViewTag				20

@interface LoginViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate>
{
	User					*mUser;
	NSInteger	changeUserName;
	NSInteger	changePassword;
	NSInteger	changeUDID;
	UIButton				*backupButton;
	UITextField				*userNameView;
	UITextField				*passwordView;
	MyAssetsAppDelegate *deleg;
	UITextField				*udidView;
	UIAlertView *backupAlert;
	UIActivityIndicatorView *busy;
}

@property (nonatomic, retain) UITextField				*userNameView;
@property (nonatomic, retain) UITextField				*passwordView;
@property (nonatomic, retain) UITextField				*udidView;
@property (nonatomic, retain) UIButton					*backupButton;
@property (nonatomic, retain) UIAlertView *backupAlert;
@property (nonatomic, retain) UIActivityIndicatorView *busy;
@property (nonatomic, assign) MyAssetsAppDelegate *deleg;
@property (nonatomic, retain) User *mUser;


- (id)init;
- (void)registerAction:(id)sender;
- (void)backupAction:(id)sender;
-(NSInteger)registerUser;
- (BOOL)validatePassword:(NSString  *)str;
- (BOOL)validateUserName:(NSString  *)str;
-(void) uploadAssets;

@end
