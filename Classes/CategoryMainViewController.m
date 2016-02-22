//
//  FirstViewController.m
//  MyAssets
//
//  Created by naresh gupta on 2/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "CategoryMainViewController.h"
#import "AddCategoryViewController.h"
#import "Asset.h"


@implementation CategoryMainViewController

@synthesize myTableView, categoryList, deleg, picker, myAsset, bannerVisible;
static NSString *kCellIdentifier = @"CategoryViewIdentifier";

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Category", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"categories.png"];
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
	}
	self.picker=false;
	return self;
}
- (id)initAsPicker:(Asset *) asset
{
	[self init];
	self.picker=TRUE;
	self.myAsset=asset;
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"CategoryMainViewController" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	myTableView = (UITableView *)[cView viewWithTag:kCategoryTableViewTag];
	myTableView.delegate=self;
	myTableView.dataSource=self;
	
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
	
	
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
								  target:self action:@selector(addCategoryButtonAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								  target:self action:@selector(editCategoryButtonAction:)];
	self.navigationItem.leftBarButtonItem = editButton;
	
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (void)viewDidAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [myTableView indexPathForSelectedRow];
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	self.categoryList = [Category retrieveAllCategories:deleg.database];
	[myTableView reloadData];
}


- (void)editCategoryButtonAction:(id)sender
{
	[myTableView setEditing:TRUE animated:TRUE];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self action:@selector(doneCategoryButtonAction:)];
	self.navigationItem.leftBarButtonItem = doneButton;
}
- (void)doneCategoryButtonAction:(id)sender
{
	[myTableView setEditing:FALSE animated:TRUE];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self action:@selector(editCategoryButtonAction:)];
	self.navigationItem.leftBarButtonItem = editButton;
}

- (void)addCategoryButtonAction:(id)sender
{
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[AddCategoryViewController alloc] initWithCategory:nil]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
}


- (void)dealloc {
	adMobAd.delegate=nil;
	[adMobAd release];
    [super dealloc];
}



#pragma mark UITableView delegate methods

// tell our table how many sections or groups it will have (always 1 in our case)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.picker){
		UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
		cell.accessoryType=UITableViewCellAccessoryCheckmark;
		Category	*cat = [categoryList objectAtIndex:indexPath.row];
		myAsset.catID=cat.pk;
		[myAsset toDB];
		[[self parentViewController] dismissModalViewControllerAnimated:YES];
	}
	else{
		[tableView deselectRowAtIndexPath:indexPath animated:YES];
		UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[AddCategoryViewController alloc] initWithCategory:[categoryList objectAtIndex: indexPath.row]]];
		[self presentModalViewController:dViewC animated:TRUE];
		[dViewC release];
		//UIViewController *targetViewController = [[AddAssetViewController alloc] initWithAsset:[assetList objectAtIndex: indexPath.row]];
		//[[self navigationController] pushViewController:targetViewController animated:YES];
	}
}


#pragma mark UITableView datasource methods
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 60.0;
}

// tell our table how many rows it will have, in our case the size of our courseList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [categoryList count];
}

// tell our table what kind of cell to use and its title for the given row
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
	if (cell == nil)
	{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	Category	*cat = [categoryList objectAtIndex:indexPath.row];
    cell.textLabel.text = cat.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%i assets", [[Asset retrieveAllAssets:deleg.database byCategory:cat.pk] count]];
    //NSString *path = [[NSBundle mainBundle] pathForResource:[AddAssetViewController getPhotoPath:1]];
    //UIImage *theImage = [UIImage imageWithContentsOfFile:[AddAssetViewController getPhotoPath:1]];
    //cell.imageView.image = theImage;
	
	if(!picker)
		cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	//else
		//cell.accessoryType=UITableViewCellAccessoryCheckmark;
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete){
		Category	*cat = [categoryList objectAtIndex:indexPath.row];
		[cat deleteFromDatabase];
		
		[categoryList removeObjectAtIndex:indexPath.row];

		[self.myTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]  withRowAnimation:UITableViewRowAnimationFade];

		
		[self.myTableView reloadData];
	}

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
