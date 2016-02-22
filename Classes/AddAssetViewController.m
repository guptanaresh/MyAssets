//
//  AddAssetViewController.m
//  MyAssets
//
//  Created by naresh gupta on 2/12/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AddAssetViewController.h"
#import "CategoryMainViewController.h"
#import "PlaceMainViewController.h"
#import "PhotoViewController.h"


@implementation AddAssetViewController

@synthesize nameView, myAsset, deleg, editAsset, photoNumber, containerButton, catButton, photo1Button, photo2Button, photo3Button, photo4Button;
@synthesize costView, quantityView, notesView, field1View, field2View, field1Label, field2Label, dateButton, datePickerView, myDate, scrollView, bannerVisible;


- (id)initWithAsset:(Asset *)asset
{
	if (self = [super init])
	{
		UIApplication *app = [UIApplication sharedApplication];
		deleg = (MyAssetsAppDelegate *)[app delegate];
		// this will appear as the title in the navigation bar
		self.title = NSLocalizedString(@"Asset", @"");
		if(asset == nil){
			NSInteger pk=[Asset insertNewAssetIntoDatabase:deleg.database];
			myAsset = [[Asset alloc] initWithPrimaryKey:pk database:deleg.database];
			editAsset=FALSE;
		}
		else{
			editAsset=true;
			myAsset = asset;
		}
		photoNumber=1;
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
	
	
	return self;
}


- (void)loadView {
	// create a the content view
	UIView *contentView = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	
	// setup our content view so that it auto-rotates along with the UViewController
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	
	UIView *cView = [[[NSBundle mainBundle] loadNibNamed:@"AddAssetViewController" owner:self options:nil] lastObject ];
	[contentView addSubview:cView];

	scrollView = (UIScrollView *)[cView viewWithTag:kScrollView];

	nameView = (UITextField *)[cView viewWithTag:kNameViewTag];
	nameView.text=myAsset.name;
	nameView.delegate=self;
	
	//[nameView addTarget:self action:@selector(nameTextChanged:) forControlEvents:UIControlEventEditingChanged];
	
	quantityView = (UITextField *)[cView viewWithTag:kQuantityViewTag];
	if(myAsset.quantity > 0)
	quantityView.text=[NSString stringWithFormat:@"%d", myAsset.quantity];
	quantityView.delegate=self;
	//[quantityView addTarget:self action:@selector(quantityTextChanged:) forControlEvents:UIControlEventEditingChanged];
	
	costView = (UITextField *)[cView viewWithTag:kCostViewTag];
	if(myAsset.cost > 0)
	costView.text=[NSString stringWithFormat:kCostFormat, myAsset.cost];
	costView.delegate=self;
	//[costView addTarget:self action:@selector(costTextChanged:) forControlEvents:UIControlEventEditingChanged];

	notesView = (UITextView *)[cView viewWithTag:kNotesViewTag];
	notesView.text=myAsset.notes;
	notesView.delegate=self;
	//[notesView addTarget:self action:@selector(notesTextChanged:) forControlEvents:UIControlEventEditingChanged];
	field1View = (UITextField *)[cView viewWithTag:kField1ViewTag];
	field2View = (UITextField *)[cView viewWithTag:kField2ViewTag];
	field1Label = (UILabel *)[cView viewWithTag:kField1LabelTag];
	field2Label = (UILabel *)[cView viewWithTag:kField2LabelTag];
	
	catButton = (UIButton *)[cView viewWithTag:kCategoryButtonTag];
	[catButton addTarget:self action:@selector(catButtonAction:) forControlEvents:UIControlEventTouchDown];
	containerButton = (UIButton *)[cView viewWithTag:kContainerButtonTag];
	[containerButton addTarget:self action:@selector(containerButtonAction:) forControlEvents:UIControlEventTouchDown];
	dateButton = (UIButton *)[cView viewWithTag:kDateButtonTag];
	[dateButton addTarget:self action:@selector(dateButtonAction:) forControlEvents:UIControlEventTouchDown];
	myDate=myAsset.acqrDate;
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	NSString *dt = [dateFormat stringFromDate:myDate];
	[dateFormat release];
	[dateButton setTitle:dt forState:UIControlStateNormal];
	
	photo1Button = (UIButton *)[cView viewWithTag:kPhoto1ButtonTag];
	[photo1Button addTarget:self action:@selector(photo1action:) forControlEvents:UIControlEventTouchUpInside];
	photo2Button = (UIButton *)[cView viewWithTag:kPhoto2ButtonTag];
	[photo2Button addTarget:self action:@selector(photo2action:) forControlEvents:UIControlEventTouchUpInside];
	photo3Button = (UIButton *)[cView viewWithTag:kPhoto3ButtonTag];
	[photo3Button addTarget:self action:@selector(photo3action:) forControlEvents:UIControlEventTouchUpInside];
	photo4Button = (UIButton *)[cView viewWithTag:kPhoto4ButtonTag];
	[photo4Button addTarget:self action:@selector(photo4action:) forControlEvents:UIControlEventTouchUpInside];
	
	
	
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
	//[self viewWillAppear:FALSE];
	
	
}

- (void) keyboardWillShow: (NSNotification*) aNotification;
{	
	if(scrollView){
		[UIView beginAnimations:nil context:NULL];
		
		[UIView setAnimationDuration:0.3];
		
		CGRect rect = scrollView.frame;
		
		if([nameView isFirstResponder])
		   rect.origin.y -= 0; 
		else if([costView isFirstResponder] || [quantityView isFirstResponder])
			rect.origin.y -= kADBannerViewSizeOffset+60; 
		else if([notesView isFirstResponder])
			rect.origin.y -= kADBannerViewSizeOffset+120; 
		else if([field1View isFirstResponder])
			rect.origin.y -= kADBannerViewSizeOffset+150; 
		else if([field2View isFirstResponder])
			rect.origin.y -= kADBannerViewSizeOffset+180; 
		
		[[self view] setFrame: rect];
		
		[UIView commitAnimations];
	}
	
}

- (void) keyboardWillHide: (NSNotification*) aNotification;
{
	[UIView beginAnimations:nil context:NULL];
	
	[UIView setAnimationDuration:0.3];
	
	CGRect rect = scrollView.frame;
	
	if([nameView isFirstResponder])
		rect.origin.y += 0; 
	else if([costView isFirstResponder] || [quantityView isFirstResponder])
		rect.origin.y += 60-kADBannerViewSizeOffset; 
	else if([notesView isFirstResponder])
		rect.origin.y += 120-kADBannerViewSizeOffset; 
	else if([field1View isFirstResponder])
		rect.origin.y += 150-kADBannerViewSizeOffset; 
	else if([field2View isFirstResponder])
		rect.origin.y += 180-kADBannerViewSizeOffset; 
	
	[[self view] setFrame: rect];
	
	[UIView commitAnimations];
}

- (void)viewWillAppear:(BOOL)animated
{
	//[myAsset fromDB];
	nameView.text=myAsset.name;
	if(myAsset.quantity > 0)
		quantityView.text=[NSString stringWithFormat:@"%d", myAsset.quantity];
	if(myAsset.cost > 0)
		costView.text=[NSString stringWithFormat:kCostFormat, myAsset.cost];
	notesView.text=myAsset.notes;

	Category *cat = [[Category alloc] initWithPrimaryKey:myAsset.catID database:deleg.database];
	if(cat.pk > kUnassignedCatID){
		[catButton setTitle:cat.name forState:UIControlStateNormal];
		if(cat.fieldname1 && [cat.fieldname1 length] > 0){
			field1View.hidden=FALSE;
			field1Label.hidden=FALSE;
			field1Label.text=cat.fieldname1;
			field1View.text=myAsset.fieldvalue1;
		}
		else{
			field1View.hidden=TRUE;
			field1Label.hidden=TRUE;
		}
		if(cat.fieldname2 && [cat.fieldname2 length] > 0){
			field2View.hidden=FALSE;
			field2Label.hidden=FALSE;
			field2Label.text=cat.fieldname2;
			field2View.text=myAsset.fieldvalue2;
		}
		else{
			field2View.hidden=TRUE;
			field2Label.hidden=TRUE;
		}
	}
	else{
		field1View.hidden=TRUE;
		field1Label.hidden=TRUE;
		field2View.hidden=TRUE;
		field2Label.hidden=TRUE;
	}

	Place *plc = [[Place alloc] initWithPrimaryKey:myAsset.containerID database:deleg.database];
	if(plc.pk > kUnassignedContainerID)
		[containerButton setTitle:plc.name forState:UIControlStateNormal];

	myDate=myAsset.acqrDate;
	NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
	dateFormat.dateStyle = kCFDateFormatterShortStyle;
	NSString *dt = [dateFormat stringFromDate:myDate];
	[dateFormat release];
	[dateButton setTitle:dt forState:UIControlStateNormal];
	
	[self setPhotoImage:1];
	
	[self setPhotoImage:2];
	
	[self setPhotoImage:3];
	
	[self setPhotoImage:4];
	
	
}

- (CGRect)pickerFrameWithSize:(CGSize)size
{
	CGRect screenRect = [[UIScreen mainScreen] applicationFrame];
	/*CGRect pickerRect = CGRectMake(	0.0,
	 screenRect.size.height - kToolbarHeight - size.height,
	 size.width,
	 size.height);
	 */
	CGRect pickerRect = CGRectMake(	0.0,
								  0.0,
								   screenRect.size.width,
								   screenRect.size.height);
	return pickerRect;
}

- (void)dateButtonAction:(id)sender
{
	/*
	 UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[DatePickerController alloc] init]];
	 [self presentModalViewController:dViewC animated:TRUE];
	 [dViewC release];
	 */
	[self resignKeyboard];
	if(datePickerView==nil){
		datePickerView = [[UIDatePicker alloc] initWithFrame:CGRectZero];
		datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		datePickerView.datePickerMode = UIDatePickerModeDate;
		
		// note we are using CGRectZero for the dimensions of our picker view,
		// this is because picker views have a built in optimum size,
		// you just need to set the correct origin in your view.
		//
		// position the picker at the bottom
		CGSize pickerSize = CGSizeMake(300, 200);
		datePickerView.frame = [self pickerFrameWithSize:pickerSize];
		
		[self.view addSubview:datePickerView];
		//[dateButton setTitle:kDateEnterString forState:UIControlStateNormal];
	}
	else{
		
		if(datePickerView.hidden==FALSE){
			[self hideDatePicker:TRUE];
		}
		else{
			datePickerView.hidden = FALSE;
			//[dateButton setTitle:kDateEnterString forState:UIControlStateNormal];
		}
	}
	datePickerView.date=myDate;
	
}

- (void)hideDatePicker:(BOOL)sav
{
	if((datePickerView != nil) && (datePickerView.hidden==FALSE)){
		if(sav){
			myDate=datePickerView.date;
			NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
			dateFormat.dateStyle = kCFDateFormatterShortStyle;
			NSString *dt = [dateFormat stringFromDate:myDate];
			[dateFormat release];
			[dateButton setTitle:dt forState:UIControlStateNormal];
		}
		else{
			NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
			dateFormat.dateStyle = kCFDateFormatterShortStyle;
			NSString *dt = [dateFormat stringFromDate:myDate];
			[dateFormat release];
			[dateButton setTitle:dt forState:UIControlStateNormal];
		}
		datePickerView.hidden=TRUE;
	}
}




- (void)nameTextChanged:(id)sender
{
	UITextField *txView= (UITextField *)sender;
	NSString *str=txView.text; 
	if([str rangeOfString:@" "].length > 0)
		NSLog(txView.text);
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
/*
- (void)nameTextChanged:(id)sender
{
	UITextField *txView= (UITextField *)sender;
	NSString *str=txView.text; 
	if([str rangeOfString:@" "].length > 0)
		NSLog(txView.text);
}
- (void)quantityTextChanged:(id)sender
{
	UITextField *txView= (UITextField *)sender;
	NSString *str=txView.text; 
	if([str rangeOfString:@" "].length > 0)
		NSLog(txView.text);
}
- (void)nameTextChanged:(id)sender
{
	UITextField *txView= (UITextField *)sender;
	NSString *str=txView.text; 
	if([str rangeOfString:@" "].length > 0)
		NSLog(txView.text);
}
*/
- (void)doneButtonAction:(id)sender
{
	if(datePickerView && datePickerView.hidden==FALSE){
		[self hideDatePicker:TRUE];
	}
	else{
		[self resignKeyboard];
		//myAsset.name = nameView.text;
		if([myAsset.name length] <=0){
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Asset Name" message:@"Please enter the asset name."
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
			[alert show];
			[alert release];
		}
		else{
			//myAsset.notes = notesView.text;
			//myAsset.quantity=[quantityView.text intValue];
			//myAsset.cost=[costView.text doubleValue];
			NSDateFormatter	*dateFormat = [[NSDateFormatter alloc] init];
			dateFormat.dateStyle = kCFDateFormatterShortStyle;
			myAsset.acqrDate = [dateFormat dateFromString:dateButton.titleLabel.text];
			[dateFormat release];
			Category *cat = [[Category alloc] initWithPrimaryKey:myAsset.catID database:deleg.database];
			if(cat.pk > kUnassignedCatID && cat.fieldname1 && [cat.fieldname1 length] > 0){
				myAsset.fieldvalue1 = field1View.text;
			}
			if(cat.pk > kUnassignedCatID && cat.fieldname2 && [cat.fieldname2 length] > 0){
				myAsset.fieldvalue2 = field2View.text;
			}
			[myAsset toDB];
			[[self parentViewController] dismissModalViewControllerAnimated:YES];
			/*
			User *myUser = [[User alloc] initWithDB:deleg.database];
			if((myUser.service & kServiceBackup) == 0){
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Signup For Online Backup" message:@"You can backup your asset information on a secure website. Click the Pay button to buy this option."
															   delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Pay", nil];
				[alert show];
				[alert release];
			}
			*/	
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 1){
		[deleg.pay requestProductData:kMyAssets_BackupProductIdentifier];
	}
}



- (void)cancelButtonAction:(id)sender
{
	if(datePickerView && datePickerView.hidden==FALSE){
		[self hideDatePicker:FALSE];
	}
	else{
		if(!editAsset)
		[myAsset deleteFromDatabase];
	[[self parentViewController] dismissModalViewControllerAnimated:YES];
	}
	
}

- (void)catButtonAction:(id)sender
{
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[CategoryMainViewController alloc] initAsPicker:myAsset]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
}
- (void)containerButtonAction:(id)sender
{
	UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[PlaceMainViewController alloc] initAsPicker:myAsset]];
	[self presentModalViewController:dViewC animated:TRUE];
	[dViewC release];
}


+(NSString *)getPhotoPath:(int)num forAsset:(Asset *) pAsset
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
	/*
	 NSFileManager *fileManager = [NSFileManager defaultManager];
	 NSError *error;
	 NSArray *files = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
	 for(int i=0; i<files.count;i++){
	 NSObject *fl=[files objectAtIndex:i];
	 NSLog(fl);
	 NSDictionary *dData = [fileManager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:fl] error:&error];
	 NSLog(@"File size: %qi\n", [[dData objectForKey:@"NSFileSize"] unsignedLongLongValue]);
	 }
	 */
	NSString *str;
	str=[[NSString alloc] initWithFormat:@"%i.%i.jpg", pAsset.pk,num];
	
	NSString *writablePath = [documentsDirectory stringByAppendingPathComponent:str];
	[str release];
	return writablePath;
}



- (void)photo1action:(id)sender
{
	photoNumber=1;
	[self photoaction:sender];
}
- (void)photo2action:(id)sender
{
	photoNumber=2;
	[self photoaction:sender];
}
- (void)photo3action:(id)sender
{
	photoNumber=3;
	[self photoaction:sender];
}
- (void)photo4action:(id)sender
{
	photoNumber=4;
	[self photoaction:sender];
}
- (void)photoaction:(id)sender
{
	[self resignKeyboard];
	NSString *imageStr = [AddAssetViewController getPhotoPath:photoNumber forAsset:myAsset];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if( [fileManager fileExistsAtPath:imageStr]){
		UINavigationController *dViewC = [[UINavigationController alloc] initWithRootViewController:[[PhotoViewController alloc] initWithAsset:myAsset photo:photoNumber]];
		[self presentModalViewController:dViewC animated:TRUE];
		[dViewC release];
	}
	else{
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
}

-(void)setPhotoImage:(int)num
{
	NSString *imageStr = [AddAssetViewController getPhotoPath:num forAsset:myAsset];
	UIImage *bkImage = [UIImage imageWithContentsOfFile:imageStr];
	if(bkImage!=nil){
		if(num==1){
			[photo1Button setBackgroundImage:bkImage forState:UIControlStateNormal];
			[photo1Button setImage:nil forState:UIControlStateNormal];
		}
		else if(num==2){
			[photo2Button setBackgroundImage:bkImage forState:UIControlStateNormal];
			[photo2Button setImage:nil forState:UIControlStateNormal];
		}
		else if(num==3){
			[photo3Button setBackgroundImage:bkImage forState:UIControlStateNormal];
			[photo3Button setImage:nil forState:UIControlStateNormal];
		}
		else if(num==4){
			[photo4Button setBackgroundImage:bkImage forState:UIControlStateNormal];
			[photo4Button setImage:nil forState:UIControlStateNormal];
		}
	}

}

-(void) resignKeyboard
{
	if([nameView isFirstResponder])
		[nameView resignFirstResponder];
	if([quantityView isFirstResponder])
		[quantityView resignFirstResponder];
	if([costView isFirstResponder])
		[costView resignFirstResponder];
	if([notesView isFirstResponder])
		[notesView resignFirstResponder];
	
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
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
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
			[self setPhotoImage:self.photoNumber];			
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

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
{
	return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField              // called when 'return' key pressed. return NO to ignore.
{
	if([textField isFirstResponder])
	[textField resignFirstResponder];
	return TRUE;
}

- (void)textFieldDidEndEditing:(UITextField *)textField             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
{
	if(textField == nameView)
		myAsset.name = nameView.text;
	if(textField == quantityView)
		myAsset.quantity=[quantityView.text intValue];
	if(textField == costView)
		myAsset.cost=[costView.text doubleValue];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
	if(textView == notesView)
		myAsset.notes = notesView.text;
}
/*
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[self resignKeyboard];
	[self hideDatePicker:TRUE];
}
*/
/*
 - (BOOL)textFieldShouldEndEditing:(UITextField *)textField          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
 {
 //[self resignKeyboard];
 [textField resignFirstResponder];
 return TRUE;
 }
 
*/


#pragma mark -
#pragma mark ADBannerViewDelegate methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
	NSLog(@"bannerViewDidLoadAd");
    if (!self.bannerVisible)
    {
        banner.hidden = NO;
		bannerVisible=TRUE;
    }
}
- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
	NSLog(@"didFailToReceiveAdWithError");
	if (self.bannerVisible)
    {
		banner.hidden = TRUE;
		self.bannerVisible=FALSE;
    }
}




@end
