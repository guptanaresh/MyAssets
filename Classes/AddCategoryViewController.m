//
//  AddCategoryViewController.m
//  MyAssets
//Category
//  Created by naresh gupta on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddCategoryViewController.h"


@implementation AddCategoryViewController

@synthesize nameView, myCategory, deleg, editCategory, field1View, field2View, bannerVisible;


- (id)initWithCategory:(Category *)cat
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Category", @"");
		if(cat == nil){
			NSInteger pk=[Category insertNewCategoryIntoDatabase:deleg.database];
			myCategory = [[Category alloc] initWithPrimaryKey:pk database:deleg.database];
			editCategory=FALSE;
		}
		else{
			editCategory=true;
			myCategory = cat;
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"AddCategoryViewController" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	nameView = (UITextField *)[cView viewWithTag:kNameViewTag];
	nameView.text=myCategory.name;
	nameView.delegate=self;
	field1View = (UITextField *)[cView viewWithTag:kField1ViewTag];
	field1View.text=myCategory.fieldname1;
	field1View.delegate=self;
	field2View = (UITextField *)[cView viewWithTag:kField2ViewTag];
	field2View.text=myCategory.fieldname2;
	field2View.delegate=self;
	//nameView.delegate=self;
	//[nameView addTarget:self action:@selector(nameTextChanged:) forControlEvents:UIControlEventEditingChanged];
	
	
	
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
	myCategory.name = nameView.text;
	myCategory.fieldname1 = field1View.text;
	myCategory.fieldtype1 = kStringFieldType;
	myCategory.fieldname2 = field2View.text;
	myCategory.fieldtype2 = kStringFieldType;
	[myCategory toDB];
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}

- (void)cancelButtonAction:(id)sender
{
	if(!editCategory)
		[myCategory deleteFromDatabase];
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
	
}


-(void) resignKeyboard
{
	//if([nameView isFirstResponder])
		[nameView resignFirstResponder];
	//if([field1View isFirstResponder])
		[field1View resignFirstResponder];
	//if([field2View isFirstResponder])
		[field2View resignFirstResponder];
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
