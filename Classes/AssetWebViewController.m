//
//  AssetWebViewController.m
//  GolfMemoir
//
//  Created by naresh gupta on 11/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "AssetWebViewController.h"
#import "Constants.h"


@implementation AssetWebViewController
@synthesize deleg,assetView, emailButton, cancelButton;

- (id)init
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = @"Assets";
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
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"AssetWebView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	/*
	 emailButton = (UIButton *)[cView viewWithTag:kEmailButtonTag];
	 [emailButton addTarget:self action:@selector(emailAction:) forControlEvents:UIControlEventTouchDown];
	 cancelButton = (UIButton *)[cView viewWithTag:kCancelEmailButtonTag];
	 [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchDown];
	 */
	assetView=(UIWebView *)[cView viewWithTag:kAssetsWebViewTag];
	NSString *str=[NSString stringWithFormat:@"http://www.jajsoftware.com/myassets/index.php?panel=%@", [[UIDevice currentDevice] uniqueIdentifier]];
	[assetView loadRequest:[[[NSURLRequest alloc] initWithURL:[NSURL URLWithString: str]] autorelease]];
	
	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithTitle:NSLocalizedString(@" OK ", @"") style:UIBarButtonItemStyleBordered
								  target:self action:@selector(cancelAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}


- (void)dealloc
{
	[super dealloc];
}

- (void)cancelAction:(id)sender
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}	


@end