//
//  MyAssetsAppDelegate.m
//  MyAssets
//
//  Created by naresh gupta on 2/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MyAssetsAppDelegate.h"
#import "AssetMainViewController.h"
#import "CategoryMainViewController.h"
#import "PlaceMainViewController.h"
#import "LoginViewController.h"


@interface MyAssetsAppDelegate (Private)
- (void)createEditableCopyOfDatabaseIfNeeded;
- (void)initializeDatabase;
- (void)initializeSettings;
@end


@implementation MyAssetsAppDelegate

// Private interface for AppDelegate - internal only methods.
@synthesize database;
@synthesize window;
@synthesize viewController, pay;
@synthesize tabBarController;



- (void)applicationDidFinishLaunching:(UIApplication *)application {

	// The application ships with a default database in its bundle. If anything in the application
    // bundle is altered, the code sign will fail. We want the database to be editable by users, 
    // so we need to create a copy of it in the application's Documents directory.  

    [self createEditableCopyOfDatabaseIfNeeded];
    // Call internal method to initialize database connection
    [self initializeDatabase];
    [self initializeSettings];
		
	firstViewC = [[UINavigationController alloc] initWithRootViewController:[[AssetMainViewController alloc] init]];
	secondViewC = [[UINavigationController alloc] initWithRootViewController:[[CategoryMainViewController alloc] init]];
	thirdViewC = [[UINavigationController alloc] initWithRootViewController:[[PlaceMainViewController alloc] init]];
	fourthViewC = [[UINavigationController alloc] initWithRootViewController:[[LoginViewController alloc] init]];
	tabBarController.viewControllers = [NSArray arrayWithObjects:firstViewC, secondViewC, thirdViewC, fourthViewC, nil];
	//tabBarController.viewControllers = [NSArray arrayWithObjects:firstViewC, secondViewC, thirdViewC, nil];
	tabBarController.delegate=self;

	
    // Add the tab bar controller's current view as a subview of the window
    //[window addSubview:tabBarController.view];
    [window setRootViewController:tabBarController];
    
	pay=[[PayObserver alloc] init];
	[[SKPaymentQueue defaultQueue] addTransactionObserver:pay];
}


/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
}
*/

/*
// Optional UITabBarControllerDelegate method
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed {
}
*/


- (void)dealloc {
    [tabBarController release];
    [window release];
    [super dealloc];
}

- (void)createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:kDatabaseFile];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (!success)
	{
		// The writable database does not exist, so copy the default to the appropriate location.
		NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:kDatabaseFile];
		success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
		if (!success) {
			NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
		}
	}
}


// Open the database connection and retrieve minimal information for all objects.
- (void)initializeDatabase {
    // The database is stored in the application bundle. 
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kDatabaseFile];
    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK) {
		
    } else {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
        // Additional error handling, as appropriate...
    }
}

- (void)initializeSettings {
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	if ([defaults objectForKey:kImageQuality] == nil)
	{
		//Get the bundle path
		NSString *bPath = [[NSBundle mainBundle] bundlePath];
		NSString *settingsPath = [bPath stringByAppendingPathComponent:@"Settings.bundle"];
		NSString *plistFile = [settingsPath stringByAppendingPathComponent:@"Root.plist"];
		
		//Get the Preferences Array from the dictionary
		NSDictionary *settingsDictionary = [NSDictionary dictionaryWithContentsOfFile:plistFile];
		NSArray *preferencesArray = [settingsDictionary objectForKey:@"PreferenceSpecifiers"];
		
		
		NSDictionary *appPrerfs = [NSDictionary dictionaryWithObjectsAndKeys:
								   [NSNumber numberWithFloat:0.75], kImageQuality,
								   nil];
		
		//Register and save the dictionary to the disk
		[[NSUserDefaults standardUserDefaults] registerDefaults:appPrerfs];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}




@end

