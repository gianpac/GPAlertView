//
//  GPAlertView.h
//
//  Created by Giancarlo Pacheco on 2012-10-28.
//  Copyright (c) 2012 Giancarlo Pacheco. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPAlertViewDelegate.h"

typedef enum {
    GPAlertViewStyleDefault =0,
    GPAlertViewStyleLoginAndPasswordInput
}GPAlertViewStyle;

@interface GPAlertView : UIView

@property(nonatomic,assign) id <GPAlertViewDelegate> delegate;    // weak reference
@property(nonatomic,copy) NSString *title;
@property(nonatomic,copy) NSString *message;   // secondary explanation text

@property(nonatomic,readonly) NSInteger numberOfButtons;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<GPAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

// adds a button with the title. returns the index (0 based) of where it was added. buttons are displayed in the order added except for the
// cancel button which will be positioned based on HI requirements. buttons cannot be customized.
- (NSInteger)addButtonWithTitle:(NSString *)title;    // returns index of button. 0 based.
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
@property(nonatomic) NSInteger cancelButtonIndex;      // if the delegate does not implement -alertViewCancel:, we pretend this button was clicked on. default is -1

@property(nonatomic,readonly) NSInteger firstOtherButtonIndex;	// -1 if no otherButtonTitles or initWithTitle:... not used

// shows popup alert animated.
- (void)show;

// Alert view style - defaults to UIAlertViewStyleDefault
@property(nonatomic,assign) GPAlertViewStyle alertViewStyle;

/* Retrieve a text field at an index - raises NSRangeException when textFieldIndex is out-of-bounds.
 The field at index 0 will be the first text field (the single field or the login field), the field at index 1 will be the password field. */
- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex;

@end
