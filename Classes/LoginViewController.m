//
//  DownloadViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 9/21/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "MyAssetsAppDelegate.h";
#import "LoginViewController.h"
#import "AssetWebViewController.h"
#import "Constants.h"
#import "GTMRegex.h"
#import "Category.h";
#import "Place.h";
#import "Asset.h";



@implementation LoginViewController

@synthesize userNameView, mUser;
@synthesize passwordView;
@synthesize udidView;
@synthesize backupButton, deleg, backupAlert, busy;

- (id)init
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Backup", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"ibackup.png"];
		mUser=[[User alloc] initWithDB:deleg.database];
		if(mUser.udid == nil)
			mUser.udid = [[[UIDevice currentDevice] uniqueIdentifier] retain];
		changeUserName=0;
		changePassword=0;
		changeUDID=0;
	}
	return self;
}




- (void)loadView
{
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"LoginViewController" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	backupButton = (UIButton *)[cView viewWithTag:kBackupButtonTag];
	[backupButton addTarget:self action:@selector(backupAction:) forControlEvents:UIControlEventTouchDown];
	UILabel *helpText = (UILabel *)[cView viewWithTag:kUDIDHelpTag];
	helpText.font = [UIFont systemFontOfSize:10];
	userNameView = (UITextField *)[cView viewWithTag:kUserNameViewTag];
	userNameView.delegate=self;
	passwordView = (UITextField *)[cView viewWithTag:kPasswordViewTag];
	passwordView.delegate=self;
	udidView = (UITextField *)[cView viewWithTag:kUDIDViewTag];
	
	mUser=[[User alloc] initWithDB:deleg.database];
	if(mUser.udid == nil)
		mUser.udid = [[[UIDevice currentDevice] uniqueIdentifier] retain];
	userNameView.text = mUser.userName;
	passwordView.text = mUser.password;
	udidView.text = mUser.udid;
	udidView.font = [UIFont systemFontOfSize:10];
	

	if(mUser.userName == nil){
		userNameView.enabled = TRUE;
		passwordView.enabled = TRUE;
		udidView.enabled = FALSE;
		changeUserName=1;
		changePassword=1;
		changeUDID=1;
	}
	
	
	UIButton *but1=(UIButton *)[cView viewWithTag:kUsernameChangeButtonTag];
	[but1 addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventAllTouchEvents];
	but1=(UIButton *)[cView viewWithTag:kPasswordChangeButtonTag];
	[but1 addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventAllTouchEvents];
	but1=(UIButton *)[cView viewWithTag:kUDIDChangeButtonTag];
	[but1 addTarget:self action:@selector(changeAction:) forControlEvents:UIControlEventAllTouchEvents];
	
	busy=(UIActivityIndicatorView *)[cView viewWithTag:kBusyViewTag];
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}




- (void)dealloc
{
	[super dealloc];
}
- (void)changeAction:(id)sender
{
	UIButton *but1=(UIButton *)sender;
	if(but1.tag == kUsernameChangeButtonTag){
		userNameView.enabled = TRUE;
		changeUserName=1;
		userNameView.selected=TRUE;
	}
	else if(but1.tag == kPasswordChangeButtonTag){
		passwordView.enabled = TRUE;
		changePassword=1;
		passwordView.selected=TRUE;
	}
	else if(but1.tag == kUDIDChangeButtonTag){
		changeUDID=1;
	}
	
	
	
}	

-(void) resignKeyboard
{
	//if([userNameView isFirstResponder])
		[userNameView resignFirstResponder];
	//if([passwordView isFirstResponder])
		[passwordView resignFirstResponder];
	
}

- (BOOL)validateUserName:(NSString  *)str
{
	
	GTMRegex *regex = [GTMRegex regexWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"]; 
	//NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx]; 
	//Valid email address 
	BOOL test =  [regex matchesString:str]; 
	return test;
}

- (BOOL)validatePassword:(NSString  *)str
{
	
	//GTMRegex *regex = [GTMRegex regexWithPattern:@"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"]; 
	return [str length] > 0;
}





- (void)backupAction:(id)sender
{
	/*if((mUser.service & kServiceBackup) == 0){
		backupAlert = [[UIAlertView alloc] initWithTitle:@"Signup For Online Backup" message:@"You can backup your asset information on a secure website. Click the Pay button to buy this option."
													   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pay", nil];
		[backupAlert show];
		[backupAlert release];
	}
	else */
	{
		NSInteger userPK=0;
		if(changeUserName && ![self validateUserName:userNameView.text]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid User Name" message:@"Please use a valid email address for your user name."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			return;
		}
		else if(changePassword && ![self validatePassword:passwordView.text]){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:@"Please use a valid password."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert show];
			[alert release];
			return;
		}
		else if(changeUserName || changePassword || changeUDID){
			userPK = [self registerUser];
			if(userPK == -1){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid User Name" message:@"This user name is already in use. Please enter another user name."
															   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
				[alert show];
				[alert release];
				return;
			}
		}
		[self uploadAssets];
	}
	
}	

-(void) uploadAssets{
	//[self resignKeyboard];
	[busy performSelectorInBackground:@selector(startAnimating) withObject:nil];
	[Category uploadAllCategories:deleg.database forUser:mUser];
	[Place uploadAllPlaces:deleg.database forUser:mUser];
	[Asset uploadAllAssets:deleg.database forUser:mUser];
	[busy stopAnimating];
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[AssetWebViewController alloc] init]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
	
}




-(NSInteger)registerUser{
	NSInteger userPK=-1;
	if([[Reachability sharedReachability] internetConnectionStatus] == NotReachable){
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"Can't upload score information because there is no internet connection available."
													   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alert show];
		[alert release];
	}
	else{
		NSURL *url = [NSURL URLWithString:@"http://www.jajsoftware.com/myassets/user_register.php"]; 
		NSMutableURLRequest *request = [[[NSMutableURLRequest alloc] initWithURL:url] autorelease];
		[request setHTTPMethod:@"POST"];
		
		mUser.userName = userNameView.text;
		mUser.password = passwordView.text;
		mUser.udid = [[[UIDevice currentDevice] uniqueIdentifier] retain];
		
		NSMutableString *post = [NSMutableString stringWithFormat:@"udid=%@&username=%@&password=%@&changeun=%i&changepw=%i&changeudid=%i&service=%i", 
								 mUser.udid,mUser.userName,mUser.password, changeUserName, changePassword, changeUDID, mUser.service];
		
		NSLog(post);
		
		NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
		
		NSString *postLength = [NSString stringWithFormat:@"%d", [postData length]];
		[request setValue:postLength forHTTPHeaderField:@"Content-Length"];
		[request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
		[request setHTTPBody:postData];	
		
		NSError *error;
		NSData *searchData;
		NSHTTPURLResponse *response;
		
		//==== Synchronous call to upload
		searchData = [ NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
		
		if(!searchData) {
			NSLog([error description]);
			[error release];
		} else {
			NSString *str = [[NSString alloc] initWithData:searchData encoding:NSASCIIStringEncoding];
			NSLog(str);
			mUser.serverpk = [str intValue];
			userPK = mUser.serverpk;
			if(mUser.serverpk > 0){
				[mUser toDB];
			}
		}
	}
	
	return userPK;
}	

- (NSString *)urlEncodeValue:(NSString *)str
{
	NSString *result = (NSString *) CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)str, NULL, CFSTR("?=&+"), kCFStringEncodingUTF8);
	return [result autorelease];
}



- (void)textFieldDidEndEditing:(UITextField *)textField            // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
	[textField resignFirstResponder];
}
- (void)textFieldDidBeginEditing:(UITextField *)textField           // became first responder
{
	
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
	[textField resignFirstResponder];
	return TRUE;
}


- (void)viewWillAppear:(BOOL)animated
{
	if((mUser.service & kServiceBackup) == 0){
		backupAlert = [[UIAlertView alloc] initWithTitle:@"Signup For Online Backup" message:@"You can backup your asset information on a secure website. Click the Pay button to buy this option."
													   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pay", nil];
		[backupAlert show];
		[backupAlert release];
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(backupAlert == alertView){
		if(buttonIndex == 1){
			[deleg.pay requestProductData:kMyAssets_BackupProductIdentifier];
		}
		else{
			deleg.tabBarController.selectedIndex=kAssetsTab;
		}
	}
}



@end