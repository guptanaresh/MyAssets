//
//  FirstViewController.m
//  MyAssets
//
//  Created by naresh gupta on 2/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "AssetMainViewController.h"
#import "AddAssetViewController.h"
#import "CategoryMainViewController.h"
#import "Place.h"
#import "Category.h"


@implementation AssetMainViewController

@synthesize myTableView, assetList, deleg, myTotalView, bannerVisible;

static NSString *kCellIdentifier = @"CourseViewIdentifier";

- (id)init
{
	if (self = [super init])
	{
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Assets", @"");
		self.tabBarItem.image = [UIImage imageNamed:@"assets.png"];
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
    
    CGRect cRect= [[UIScreen mainScreen] bounds];
    cRect.origin.y -=100;
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:cRect];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"AssetView" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	myTableView = (UITableView *)[cView viewWithTag:kAssetTableViewTag];
	myTableView.delegate=self;
	myTableView.dataSource=self;

	myTotalView = (UILabel *)[cView viewWithTag:kAssetTotalViewTag];
	

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
								  target:self action:@selector(addAssetButtonAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self action:@selector(editAssetButtonAction:)];
	self.navigationItem.leftBarButtonItem = editButton;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}


/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
/*
*/
- (void)viewDidLoad {
	[self showSplash];
}
-(void)showSplash
{
    SplashViewController *modalViewController = [[SplashViewController alloc] init];
    [self presentModalViewController:modalViewController animated:NO];
    [self performSelector:@selector(hideSplash) withObject:nil afterDelay:kSplashDelay];
}

//hide splash screen
- (void)hideSplash{
    [[self modalViewController] dismissModalViewControllerAnimated:YES];
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

- (void)viewWillAppear:(BOOL)animated
{
	// this UIViewController is about to re-appear, make sure we remove the current selection in our table view
	NSIndexPath *tableSelection = [myTableView indexPathForSelectedRow];
	[myTableView deselectRowAtIndexPath:tableSelection animated:NO];
	self.assetList = [Asset retrieveAllAssets:deleg.database];
	[myTableView reloadData];
	double total=0;
	for(NSUInteger i=0; i<[assetList count];i++){
		Asset *ass=(Asset *)[assetList objectAtIndex:i];
		total += ass.cost*ass.quantity;
	}
	myTotalView.text= [NSString stringWithFormat:kCostFormat, total];

}

- (void)addAssetButtonAction:(id)sender
{
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[AddAssetViewController alloc] initWithAsset:nil]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
}

- (void)editAssetButtonAction:(id)sender
{
	[myTableView setEditing:TRUE animated:TRUE];
	UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								   target:self action:@selector(doneAssetButtonAction:)];
	self.navigationItem.leftBarButtonItem = doneButton;
}
- (void)doneAssetButtonAction:(id)sender
{
	[myTableView setEditing:FALSE animated:TRUE];
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
								   target:self action:@selector(editAssetButtonAction:)];
	self.navigationItem.leftBarButtonItem = editButton;
}


- (void)dealloc {
	adMobAd.delegate=nil;
	[adMobAd release];
    [super dealloc];
}



#pragma mark UITableView delegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0;
}

// tell our table how many sections or groups it will have (always 1 in our case)
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
		NSInteger catCount=1;
	/*	NSMutableArray *cats=[Category retrieveAllCategories:deleg.database];
		NSMutableDictionary *catSet=[[NSMutableDictionary alloc] initWithCapacity:[cats count]];
	
		for(NSUInteger i=0; i<[cats count];i++){
			Category *cat=(Category *)[cats objectAtIndex:i];
			NSMutableArray *assCat=[Asset retrieveAllAssets:deleg.database byCategory:cat.pk];
			if([assCat count] > 0)
				[catSet setObject:assCat forKey:cat];
		}
		catCount=[catSet count];
	 */
		return  catCount;
}

// the table's selection has changed, switch to that item's UIViewController
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[AddAssetViewController alloc] initWithAsset:[assetList objectAtIndex: indexPath.row]]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
	//UIViewController *targetViewController = [[AddAssetViewController alloc] initWithAsset:[assetList objectAtIndex: indexPath.row]];
	//[[self navigationController] pushViewController:targetViewController animated:YES];
}


#pragma mark UITableView datasource methods

// tell our table how many rows it will have, in our case the size of our courseList
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [assetList count];
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
	Asset	*asset = [assetList objectAtIndex:indexPath.row];
    cell.textLabel.text = asset.name;
	NSString	*str=nil;
	Place *plc=nil;
	Category *cat=nil;
	if(asset.containerID > 0){
		plc=[[Place alloc] initWithPrimaryKey:asset.containerID database:deleg.database];
		str=plc.name;
	}
	else{
		str=kUnassignedStr;
	}
	if(asset.catID > 0){
		cat=[[Category alloc] initWithPrimaryKey:asset.catID database:deleg.database];
		str=[NSString stringWithFormat:@"%@ : %@", str, cat.name];
	}
	else{
		str=[NSString stringWithFormat:@"%@ : %@", str, kUnassignedStr];
	}
    cell.detailTextLabel.text = str;
    //NSString *path = [[NSBundle mainBundle] pathForResource:[AddAssetViewController getPhotoPath:1]];
	UIImage *image=[UIImage imageWithContentsOfFile:[AddAssetViewController getPhotoPath:1 forAsset:asset]];
    cell.imageView.image = image;
	cell.accessoryType= UITableViewCellAccessoryDisclosureIndicator;
	return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete){
		Asset	*ass = [assetList objectAtIndex:indexPath.row];
		[ass deleteFromDatabase];
		
		[assetList removeObjectAtIndex:indexPath.row];
		
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
