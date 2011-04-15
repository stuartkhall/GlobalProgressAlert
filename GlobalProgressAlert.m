//
//  GlobalProgressAlert.m
//
//  Created by Stuart Hall on 14/03/11.
//

#import "GlobalProgressAlert.h"
#import <QuartzCore/QuartzCore.h>

// Private methods
@interface GlobalProgressAlert (Private)
- (void)updateForOrientation:(BOOL)animated;
@end

@implementation GlobalProgressAlert

// Our singleton
static GlobalProgressAlert *instance = nil;

// Dimensions
static int const GLOBAL_POPUP_WIDTH = 126;
static int const GLOBAL_POPUP_HEIGHT = 126;
static int const LARGE_ACTIVITY_SIZE = 36;

@synthesize roundView;
@synthesize label;

+ (UIWindow*)mainWindow {
    return [UIApplication sharedApplication].keyWindow;
}

- (void)dealloc {
    // Remove ourselves from the notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    // Cleanup
    self.label = nil;
    self.roundView = nil;
    
    [super dealloc];
}

- (id) init {
    if (self == [super init]) {
        // The black background
        roundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, GLOBAL_POPUP_WIDTH, GLOBAL_POPUP_HEIGHT)];
        roundView.autoresizingMask = UIViewAutoresizingNone;
        roundView.backgroundColor = [UIColor blackColor];
        roundView.layer.masksToBounds = YES;
        roundView.alpha = 0;
        roundView.hidden = YES;
        [[self.roundView layer] setCornerRadius:10.0];
        
        // Label
        label = [[UILabel alloc] initWithFrame:CGRectMake(0, GLOBAL_POPUP_HEIGHT-40, GLOBAL_POPUP_WIDTH, 30)];
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.textAlignment = UITextAlignmentCenter;
        [roundView addSubview:label];
        
        // Activity
        UIActivityIndicatorView* activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        activityView.frame = CGRectMake((GLOBAL_POPUP_WIDTH / 2) - (LARGE_ACTIVITY_SIZE/2), (GLOBAL_POPUP_HEIGHT / 2) - (LARGE_ACTIVITY_SIZE/2), LARGE_ACTIVITY_SIZE, LARGE_ACTIVITY_SIZE);
        [roundView addSubview:activityView];
        [activityView startAnimating];
        [activityView release];
        
        // Set for the current orientation
        [self updateForOrientation:NO];
        
        // Alert the the orientation changes
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(deviceOrientationDidChange:)
                                                     name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

+ (id)allocWithZone:(NSZone*)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
        }
        return instance;
    }
    return nil;
}

/**
 * The global access, all access should be via
 * this function
**/
+ (GlobalProgressAlert*)sharedInstance {
    @synchronized (self) {
        if (instance == nil) {
            instance = [[self alloc] init];
        }
    }
    
    return instance;
}

/**
 * Displays the alert with the specific string
**/
+ (void)show:(NSString*)text {
    GlobalProgressAlert* instance = [GlobalProgressAlert sharedInstance];
    
    [instance.roundView removeFromSuperview];
    
	instance.roundView.center = [self mainWindow].center;
	instance.label.text = text;
	instance.roundView.alpha = 1;
	instance.roundView.hidden = NO;
    [instance.roundView setNeedsDisplay];
    
    [[self mainWindow] addSubview:instance.roundView];
    [[self mainWindow] bringSubviewToFront:instance.roundView];
}

/**
 * Displays the alert with the specific string and fades out
 **/
+ (void)show:(NSString*)text andFadeOutAfter:(double)secs {
    [GlobalProgressAlert show:text];
    [GlobalProgressAlert fadeOutAfter:secs];
}

/**
 * Displays the alert zooming it up
 **/
+ (void)show:(NSString*)text andZoomUpOver:(double)secs {
    GlobalProgressAlert* instance = [GlobalProgressAlert sharedInstance];
    instance.roundView.transform = CGAffineTransformMakeScale(0.1, 0.1);

    [GlobalProgressAlert show:text];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:secs];
    instance.roundView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [UIView commitAnimations];
}

/**
 * Hides the popup immediately
 **/
+ (void)hide {
	[GlobalProgressAlert sharedInstance].roundView.hidden = YES;
}

/**
 * Fades the popup out
 **/
+ (void)fadeOutAfter:(double)secs {
    GlobalProgressAlert* instance = [GlobalProgressAlert sharedInstance];
    
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDelay:secs];
    [UIView setAnimationDuration:1];
	instance.roundView.alpha = 0;
	[UIView commitAnimations];
}

/**
 * Sets the background color
 **/
+ (void)setBackgroundColor:(UIColor*)color {
    [GlobalProgressAlert sharedInstance].roundView.backgroundColor = color;
}

/**
 * Sets the label color
 **/
+ (void)setLabelColor:(UIColor*)color {
    [GlobalProgressAlert sharedInstance].label.textColor = color;
}

/**
 * Determines the transformation for the current orientation
 **/
- (CGAffineTransform)transformForOrientation {
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return CGAffineTransformMakeRotation(M_PI*1.5);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return CGAffineTransformMakeRotation(M_PI/2);
    } else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return CGAffineTransformMakeRotation(-M_PI);
    } else {
        return CGAffineTransformIdentity;
    }
}

/**
 * Updates the orientation
**/
- (void)updateForOrientation:(BOOL)animated {
    // Transform the alert to the correct orientation
    if (animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
    }
    
    [GlobalProgressAlert sharedInstance].roundView.transform = [self transformForOrientation];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

/**
 * UIDeviceOrientationDidChangeNotification callback
**/
- (void)deviceOrientationDidChange:(void*)object {
    [self updateForOrientation:YES];
}

@end

