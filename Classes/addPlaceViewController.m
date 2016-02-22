//
//  AddPlaceViewController.m
//  MyAssets
//Place
//  Created by naresh gupta on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddPlaceViewController.h"


@implementation AddPlaceViewController

@synthesize nameView, myPlace, deleg, editPlace, bannerVisible;


- (id)initWithPlace:(Place *)cat
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Where", @"");
		if(cat == nil){
			NSInteger pk=[Place insertNewPlaceIntoDatabase:deleg.database];
			myPlace = [[Place alloc] initWithPrimaryKey:pk database:deleg.database];
			editPlace=FALSE;
		}
		else{
			editPlace=true;
			myPlace = cat;
		}
	}
	
	return self;
}


- (void)loadView {
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"AddPlaceViewController" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	nameView = (UITextField *)[cView viewWithTag:kNameViewTag];
	
	nameView.text=myPlace.name;
	nameView.delegate=self;
	[nameView addTarget:self action:@selector(nameTextChanged:) forControlEvents:UIControlEventEditingChanged];
	
	
	
	if(kAllowAd){
		// Request an ad
		adMobAd = [[ADBannerView alloc] initWithFrame:CGRectZero]; // start a new ad request
		[adMobAd retain];
		adMobAd.currentContentSizeIdentifier = ADBannerContentSizeIdentifier320x50;
		[cView addSubview:adMobAd];
		adMobAd.delegate=self;
		bannerVisible=TRUE;
	}
	else{
		adMobAd=nil;
	}
	
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemSave
								   target:self action:@selector(doneButtonAction:)];
	self.navigationItem.rightBarButtonItem = doneButton;
	UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc]
									 initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
									 target:self action:@selector(cancelButtonAction:)];
	self.navigationItem.leftBarButtonItem = cancelButton;
	
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)nameTextChanged:(id)sender
{
	UITextField *txView= (UITextField *)sender;
	NSString *str=txView.text; 
	if([str rangeOfString:@" "].length > 0)
		NSLog(txView.text);
}

- (void)doneButtonAction:(id)sender
{
	myPlace.name = nameView.text;
	[myPlace toDB];
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender
{
	if(!editPlace)
		[myPlace deleteFromDatabase];
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
	
}


-(void) resignKeyboard
{
	//	if([myScoreDistanceView isFirstResponder])
	[nameView resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
	adMobAd.delegate=nil;
	[adMobAd release];
    [super dealloc];
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
	[self resignKeyboard];
	//[textField resignFirstResponder];
	return TRUE;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self resignKeyboard];
}



#pragma mark -
#pragma mark ADBannerViewDelegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	NSLog(@"bannerViewDidLoadAd");
    if (!self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOn" context:NULL];
        //banner.hidden = NO;
		// assumes the banner view is offset 50 pixels so that it is not visible.
        banner.frame = CGRectOffset(banner.frame, 0, 50);
		bannerVisible=TRUE;
        [UIView commitAnimations];
    }
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	NSLog(@"didFailToReceiveAdWithError");
	if (self.bannerVisible)
    {
        [UIView beginAnimations:@"animateAdBannerOff" context:NULL];
		// assumes the banner view is at the top of the screen.
        banner.frame = CGRectOffset(banner.frame, 0, -50);
		//banner.hidden = TRUE;
		self.bannerVisible=FALSE;
        [UIView commitAnimations];
    }
}





@end
