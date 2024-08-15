#import <UIKit/UIKit.h>
#include <substrate.h>

//@import UIKit;

@interface SBSystemApertureViewController : UIViewController
@end

#define kHeight [UIScreen mainScreen].bounds.size.width

NSMutableDictionary *MutDiction;

static uint16_t forcePadIdiom = 0;

static Boolean isUseDefault;
static Boolean isHide;
static Boolean isCustomPosition;
static CGFloat valueX;
static CGFloat valueY;
static Boolean isScalePosition;
static CGFloat percent;
static Boolean isCustomAlpha;
static CGFloat valueAlpha;

static Boolean isUpsideDown;
static Boolean isUpsideDownFixedForDynamicIsland;
static Boolean isTransparent;

void loadprefs() {
    MutDiction = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.34306.mineland.plist"];
    isUpsideDown = [[MutDiction objectForKey:@"isUpsideDown"] boolValue] ?: FALSE;
    isUpsideDownFixedForDynamicIsland = [[MutDiction objectForKey:@"isUpsideDownFixedForDynamicIsland"] boolValue] ?: FALSE;
    isUseDefault = [[MutDiction objectForKey:@"isUseDefault"] boolValue] ?: FALSE;
    isHide = [[MutDiction objectForKey:@"isHide"] boolValue] ?: FALSE;
    isCustomPosition = [[MutDiction objectForKey:@"isCustomPosition"] boolValue] ?: FALSE;
    valueX = [[MutDiction objectForKey:@"valueX"] floatValue] ?: 20;
    valueY = [[MutDiction objectForKey:@"valueY"] floatValue] ?: 20;
    isScalePosition = [[MutDiction objectForKey:@"isScalePosition"] boolValue] ?: FALSE;
    percent = [[MutDiction objectForKey:@"percent"] floatValue] ?: 0.065;
    isCustomAlpha = [[MutDiction objectForKey:@"isCustomAlpha"] boolValue] ?: FALSE;
    valueAlpha = [[MutDiction objectForKey:@"valueAlpha"] floatValue] ?: 0.6;
    isTransparent = [[MutDiction objectForKey:@"isTransparent"] boolValue] ?: FALSE;
}

//Upside down part

%hook UIDevice
- (UIUserInterfaceIdiom)userInterfaceIdiom {
    if (forcePadIdiom > 0 && isUpsideDown) {
        return UIUserInterfaceIdiomPad;
    } else {
        return %orig;
    }
}
%end

%hook SBTraitsSceneParticipantDelegate
// Allow upside down
- (BOOL)_isAllowedToHavePortraitUpsideDown {
    if(isUpsideDown){
        return YES;
    }
    return %orig;
}

- (NSInteger)_orientationMode {
    forcePadIdiom++;
    NSInteger result = %orig;
    forcePadIdiom--;
    return result;
}
%end

%hook SpringBoard
// Allow landscape Home Screen
- (NSInteger)homeScreenRotationStyle {
    if(isUpsideDown){
        return 1;
    }
    return %orig;
}
%end

%hook SBApplication
- (BOOL)isMedusaCapable {
    if(isUpsideDown){
        return YES;
    }
    return %orig;
}
%end

// Allow upside down Home Screen
%hook SBHomeScreenViewController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(isUpsideDown){
        return %orig | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return %orig;
}
%end

// Allow upside down Lock Screen
%hook SBCoverSheetPrimarySlidingViewController
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if(isUpsideDown){
        return %orig | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return %orig;
}
%end

//Upside down applied for dynamic island
@import UIKit;

@interface UIWindow()
- (void)setAutorotates:(BOOL)autorotates forceUpdateInterfaceOrientation:(BOOL)force;
@end

@interface SBSystemApertureWindow : UIWindow
@end

// SBSystemApertureWindow has a hidden override to always set autorotates to false, we must call super
@implementation SBSystemApertureWindow(hook)
- (void)setAutorotates:(BOOL)autorotates forceUpdateInterfaceOrientation:(BOOL)force {
    [super setAutorotates:YES forceUpdateInterfaceOrientation:force];
}
@end

%hook SBSystemApertureController
- (void)_applyOrientation:(UIInterfaceOrientation)orientation withPreviousOrientation:(UIInterfaceOrientation)prevOrientation animationSettings:(id)settings {
    if(isUpsideDown && isUpsideDownFixedForDynamicIsland){
    UIView *apertureView = MSHookIvar<UIViewController *>(self, "_systemApertureViewController").view;
    CGRect frame = apertureView.frame;

    if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        orientation = UIInterfaceOrientationPortrait;
        // put your code here to reset y offset, for example:
        frame = CGRectMake(0, -7, apertureView.frame.size.width, apertureView.frame.size.height);
    } else if (orientation == UIInterfaceOrientationPortrait) {
        // put your code here to set y offset, for example:
        frame = CGRectMake(0, 20, apertureView.frame.size.width, apertureView.frame.size.height);
    }

    [UIView animateWithDuration:1 animations:^{ 
        apertureView.frame = frame;
    }];

    %orig;
    } else {
        %orig;
    }
}
%end

// allow upside down
%hook SBSystemApertureCaptureVisibilityShimViewController
- (UIInterfaceOrientationMask)__supportedInterfaceOrientations {
    if(isUpsideDown && isUpsideDownFixedForDynamicIsland){
        return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
    }
    return %orig;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(NSInteger)orientation {
    if(isUpsideDown && isUpsideDownFixedForDynamicIsland){
        return YES;
    }
    return %orig;
}
%end

@interface _SBGainMapView : UIView
@end

%hook _SBGainMapView
- (void)setFrame:(CGRect)frame {
    %orig;
    if(isHide){
        [self removeFromSuperview];
    }
}
%end

%hook SBSystemApertureViewController
- (void)viewWillAppear:(BOOL)animated {
    %orig;
    if(isUseDefault){
        self.view.frame = CGRectOffset(self.view.frame, 0, kHeight*0.065);
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = 1.0;
    }
    else if(isCustomPosition){
        self.view.frame = CGRectOffset(self.view.frame, valueX, valueY);
    }
    else if(isScalePosition){
        self.view.frame = CGRectOffset(self.view.frame, 0, kHeight*percent);
    }
    if(isCustomAlpha){
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = valueAlpha;
    }
    else if(isTransparent){
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = - 1.0;
    }
    else {
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = 1.0;
    }
}
%end


%ctor {
    loadprefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadprefs, CFSTR("com.34306.mineland.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
