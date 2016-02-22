//
//  PhotoViewController.m
//  MyAssets
//
//  Created by naresh gupta on 4/16/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "AddAssetViewController.h"

#define ZOOM_STEP 1.5


@interface PhotoViewController (UtilityMethods)
- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center;
@end


@implementation PhotoViewController

@synthesize deleg, photoScrollView, myAsset, photoNumber;

- (id)initWithAsset:(Asset *)ass photo:(NSInteger)num
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
		myAsset=ass;
		photoNumber=num;
		// this will appear as the title in the navigation bar
		self.title = @"Photo";
	}
	return self;
}


- (void)loadView
{
	/*
    [super loadView];
    
    // set up main scroll view
    photoScrollView = [[UIScrollView alloc] initWithFrame:[[self view] bounds]];
    [photoScrollView setBackgroundColor:[UIColor blackColor]];
    [photoScrollView setDelegate:self];
    [photoScrollView setBouncesZoom:YES];
    [[self view] addSubview:photoScrollView];
	[photoScrollView setContentMode:UIViewContentModeScaleToFill];
    
    // add touch-sensitive image view to the scroll view
	NSString *imageStr = [AddAssetViewController getPhotoPath:photoNumber forAsset:myAsset];
	UIImage *bkImage = [UIImage imageWithContentsOfFile:imageStr];
    PhotoView *imageView = [[PhotoView alloc] initWithImage:bkImage];
    [imageView setDelegate:self];
    [imageView setTag:kPhotoViewTag];
    [photoScrollView setContentSize:[imageView frame].size];
	[imageView setContentMode:UIViewContentModeScaleToFill];
    [photoScrollView addSubview:imageView];
    [imageView release];
    
    // calculate minimum scale to perfectly fit image width, and begin at that scale
    float minimumScale = [photoScrollView frame].size.width  / [imageView frame].size.width;
    [photoScrollView setMinimumZoomScale:minimumScale];
    [photoScrollView setZoomScale:minimumScale];

	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								  target:self action:@selector(doneAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
								   target:self action:@selector(cameraButtonAction:)];
	self.navigationItem.leftBarButtonItem = editButton;
*/
	
	
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"PhotoViewController" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];
	
	photoScrollView=(UIScrollView *)[cView viewWithTag:kScrollViewTag];
	[photoScrollView setDelegate:self];
	PhotoView *photoView=[[PhotoView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
	[photoView setTag:kPhotoViewTag];
	NSString *imageStr = [AddAssetViewController getPhotoPath:photoNumber forAsset:myAsset];
	UIImage *bkImage = [UIImage imageWithContentsOfFile:imageStr];
	if(bkImage!=nil){
		photoView.image=bkImage;
	}
	[photoView setDelegate:self];
	
	[photoScrollView addSubview:photoView];
			   
	
	// add our custom add button as the nav bar's custom right view
	UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
								  initWithBarButtonSystemItem:UIBarButtonSystemItemDone
								  target:self action:@selector(doneAction:)];
	self.navigationItem.rightBarButtonItem = addButton;
	
	UIBarButtonItem *editButton = [[UIBarButtonItem alloc]
								   initWithBarButtonSystemItem:UIBarButtonSystemItemCamera
								   target:self action:@selector(cameraButtonAction:)];
	self.navigationItem.leftBarButtonItem = editButton;
	
	// add it as the parent/content view to this UIViewController
	self.view = contentView;
	[contentView release];
	
}

- (void)doneAction:(id)sender
{
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
}	

- (void)cameraButtonAction:(id)sender
{
		UIImagePickerController *cam= [[UIImagePickerController alloc] init];
		if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] == YES){
			cam.sourceType=UIImagePickerControllerSourceTypeCamera;
		}
		else{
			cam.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
		}
		cam.delegate=self;
		[self presentModalViewController:cam animated:TRUE];
		[cam release];
		
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
	[self dismissModalViewControllerAnimated:TRUE];
	//[cameraView setBackgroundImage:image forState:UIControlStateNormal];
	UIImage *newImage=[Asset scaleAndRotateImage:image];
	//	UIImage *newImage=image;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSData *imageData = UIImageJPEGRepresentation(newImage, [defaults floatForKey:kImageQuality]);
	NSLog(@"orig image height, width:%i, %i",CGImageGetHeight(image.CGImage), CGImageGetWidth(image.CGImage));
	NSLog(@"new image height, width:%i, %i",CGImageGetHeight(newImage.CGImage), CGImageGetWidth(newImage.CGImage));
	if(imageData != nil){
		NSString *imagePath=[AddAssetViewController getPhotoPath:self.photoNumber forAsset:myAsset];
		NSFileManager *fileManager = [NSFileManager defaultManager];
		NSError *error=nil;
		if( [fileManager fileExistsAtPath:imagePath])
			[fileManager removeItemAtPath:imagePath error:&error];
		
		[imageData writeToFile:imagePath options:NSAtomicWrite error:&error];
		if(error == nil){
			NSDictionary *dData = [fileManager attributesOfItemAtPath:imagePath error:&error];
			NSLog(imagePath);
			NSLog(@"File size: %qi\n", [[dData objectForKey:@"NSFileSize"] unsignedLongLongValue]);
		}
		else{
			NSLog([error localizedDescription]);
		}
	}
	else{
		NSLog(@"error capturing image");
	}
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
	[self dismissModalViewControllerAnimated:TRUE];
}


- (void)dealloc {
	[photoScrollView release];
    [super dealloc];
}


#pragma mark UIScrollViewDelegate methods

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [photoScrollView viewWithTag:kPhotoViewTag];
}

#pragma mark PhotoViewDelegate methods

- (void)photoView:(PhotoView *)view gotSingleTapAtPoint:(CGPoint)tapPoint {
    // single tap does nothing for now
}

- (void)photoView:(PhotoView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint {
    // double tap zooms in
    float newScale = [photoScrollView zoomScale] * ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [photoScrollView zoomToRect:zoomRect animated:YES];
}

- (void)photoView:(PhotoView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint {
    // two-finger tap zooms out
    float newScale = [photoScrollView zoomScale] / ZOOM_STEP;
    CGRect zoomRect = [self zoomRectForScale:newScale withCenter:tapPoint];
    [photoScrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark Utility methods

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates. 
    //    At a zoom scale of 1.0, it would be the size of the photoScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = [photoScrollView frame].size.height / scale;
    zoomRect.size.width  = [photoScrollView frame].size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}


@end
