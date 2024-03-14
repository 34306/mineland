#import <UIKit/UIKit.h>
#include <substrate.h>

@interface _SBGainMapView : UIView
@end

@interface SBSystemApertureViewController : UIViewController
@end

#define height [UIScreen mainScreen].bounds.size.width

NSMutableDictionary *MutDiction;

static Boolean isUseDefault;
static Boolean isHide;
static Boolean isCustomPosition;
static CGFloat valueX;
static CGFloat valueY;
static Boolean isScalePosition;
static CGFloat percent;
static Boolean isCustomAlpha;
static CGFloat valueAlpha;

void loadprefs() {
    MutDiction = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.34306.mineland.plist"];
    isUseDefault = [[MutDiction objectForKey:@"isUseDefault"] boolValue] ?: FALSE;
    isHide = [[MutDiction objectForKey:@"isHide"] boolValue] ?: FALSE;
    isCustomPosition = [[MutDiction objectForKey:@"isCustomPosition"] boolValue] ?: FALSE;
    valueX = [[MutDiction objectForKey:@"valueX"] floatValue] ?: 20;
    valueY = [[MutDiction objectForKey:@"valueY"] floatValue] ?: 20;
    isScalePosition = [[MutDiction objectForKey:@"isScalePosition"] boolValue] ?: FALSE;
    percent = [[MutDiction objectForKey:@"percent"] floatValue] ?: 0.065;
    isCustomAlpha = [[MutDiction objectForKey:@"isCustomAlpha"] boolValue] ?: FALSE;
    valueAlpha = [[MutDiction objectForKey:@"valueAlpha"] floatValue] ?: 0.6;
}

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
        self.view.frame = CGRectOffset(self.view.frame, 0, height*0.065);
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = 1.0;
    }
    else if(isCustomPosition){
        self.view.frame = CGRectOffset(self.view.frame, valueX, valueY);
    }
    else if(isScalePosition){
        self.view.frame = CGRectOffset(self.view.frame, 0, height*percent);
    }
    if(isCustomAlpha){
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = valueAlpha;
    }
    else{
        MSHookIvar<UIView *>(self, "_containerBackgroundParent").alpha = 1.0;
    }
}
%end


%ctor {
    loadprefs();
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)loadprefs, CFSTR("com.34306.mineland.settingschanged"), NULL, CFNotificationSuspensionBehaviorCoalesce);
}
