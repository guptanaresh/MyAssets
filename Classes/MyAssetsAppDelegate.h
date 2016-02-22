//
//  MyAssetsAppDelegate.h
//  MyAssets
//
//  Created by naresh gupta on 2/7/10.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
/*
MyAssets is an inventory application for your valuables. You can use it to get organized and have information handy in case you need to settle insurance claims. You never know when a disaster will hit or an emergency will come up. Use MyAssets to track your valuables before it’s too late.
* record description, category, location, price, quantity and notes for each item.
* add multiple photos of each item, receipt and other important documentations.
* create custom category and add your own custom fields.
* create custom locations.
* designed for owners and renters.
* backup your information to a secure website for extra piece of mind.
*/

#import <UIKit/UIKit.h>
#import <sqlite3.h>
#import "Constants.h"
#import "SplashViewController.h"
#import "PayObserver.h"

@interface MyAssetsAppDelegate : NSObject <UIApplicationDelegate, UITabBarControllerDelegate> {
    IBOutlet UIWindow *window;
    IBOutlet UITabBarController *tabBarController;
    sqlite3 *database;
	UINavigationController *firstViewC;
	UINavigationController *secondViewC;
	UINavigationController *thirdViewC;
	UINavigationController *fourthViewC;
    IBOutlet SplashViewController *viewController;
	PayObserver *pay;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SplashViewController *viewController;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, assign) sqlite3 *database;
@property (nonatomic, retain) PayObserver *pay;

@end
