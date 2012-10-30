//
//  GPAlertViewDelegate.h
//
//  Created by Giancarlo Pacheco on 2012-10-28.
//  Copyright (c) 2012 Giancarlo Pacheco. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPAlertView;

@protocol GPAlertViewDelegate <NSObject>
@optional

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)alertView:(GPAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
// If not defined in the delegate, we simulate a click in the cancel button
- (void)alertViewCancel:(GPAlertView *)alertView;

- (void)willPresentAlertView:(GPAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(GPAlertView *)alertView;  // after animation

- (void)alertView:(GPAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(GPAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

// Called after edits in any of the default fields added by the style
- (BOOL)alertViewShouldEnableFirstOtherButton:(GPAlertView *)alertView;

@end
