//
//  PhotoView.h
//  MyAssets
//
//  Created by naresh gupta on 4/17/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PhotoViewDelegate;


@interface PhotoView : UIImageView {
	
    id <PhotoViewDelegate> delegate;
    
    // Touch detection
    CGPoint tapLocation;         // Needed to record location of single tap, which will only be registered after delayed perform.
    BOOL multipleTouches;        // YES if a touch event contains more than one touch; reset when all fingers are lifted.
    BOOL twoFingerTapIsPossible; // Set to NO when 2-finger tap can be ruled out (e.g. 3rd finger down, fingers touch down too far apart, etc).
}

@property (nonatomic, assign) id <PhotoViewDelegate> delegate;

@end


/*
 Protocol for the tap-detecting image view's delegate.
 */
@protocol PhotoViewDelegate <NSObject>

@optional
- (void)photoView:(PhotoView *)view gotSingleTapAtPoint:(CGPoint)tapPoint;
- (void)photoView:(PhotoView *)view gotDoubleTapAtPoint:(CGPoint)tapPoint;
- (void)photoView:(PhotoView *)view gotTwoFingerTapAtPoint:(CGPoint)tapPoint;

@end
