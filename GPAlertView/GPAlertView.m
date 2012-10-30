//
//  GPAlertView.m
//
//  Created by Giancarlo Pacheco on 2012-10-28.
//  Copyright (c) 2012 Giancarlo Pacheco. All rights reserved.
//

#import "GPAlertView.h"
#import "GPButton.h"
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#define kTitleTopOffset 15.f
#define KTitleFont [UIFont fontWithName:@"Helvetica-Bold" size:18]
#define kMessageFont [UIFont fontWithName:@"Helvetica" size:16]
#define kPaddingButton 7.f
#define kAlertViewWidth 260.f

#define FONT_HEIGHT(font) font.ascender + (-1)*font.descender + 1.f

static void radialGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef  endColor) {
	CGPoint startCenter, endCenter;
	startCenter = endCenter = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
	CGFloat startRadius = 0.0;
	CGFloat endRadius = CGRectGetMidX(rect) > CGRectGetMidY(rect) ? CGRectGetMidX(rect): CGRectGetMidY(rect);
    
	CGFloat locations[] = { 0.0, 1.0 };
    
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
	CGColorSpaceRelease(colorSpace);
    
	CGContextDrawRadialGradient(context, gradient, startCenter, startRadius, endCenter, endRadius, kCGGradientDrawsAfterEndLocation);
	CGGradientRelease(gradient);
}

@interface QPDimView : UIView

@end

@implementation QPDimView

- (void)drawRect:(CGRect)rect {
    radialGradient(UIGraphicsGetCurrentContext(), rect, [UIColor colorWithWhite:0.8 alpha:0.750].CGColor, [UIColor colorWithWhite:0.4 alpha:0.600].CGColor);
}

@end

@interface GPAlertView () {
    NSMutableArray *_buttons;
    NSMutableArray *_textFields;
    UILabel *_titleLabel;
    UILabel *_subtitleLabel;
    UILabel *_bodyTextLabel;
    
    int _dismissButtonIndex;
    
    UIWindow *_originalWindow;
    UIWindow *_dimWindow;
    
    QPDimView *_dimView;
    UIView *_backgroundImageView;
    
    float _startY;
}
- (void) showWithAnimation;
@end

@implementation GPAlertView

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id /*<GPAlertViewDelegate>*/)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ... {
	self = [super initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        // Defaults
        self.alertViewStyle = GPAlertViewStyleDefault;
        self.delegate = delegate;
        _buttons = [[NSMutableArray alloc] init];
        _textFields = [[NSMutableArray alloc] init];
        
        // Background radial gradient view
        _originalWindow = [[[UIApplication sharedApplication] delegate] window];
        
        _backgroundImageView = [[UIView alloc] initWithFrame:CGRectInset(self.bounds, 5.f, 0.f)];
        [self addSubview:_backgroundImageView];
        
        if (title) self.title = title;
        if (message) self.message = message;
        
        _numberOfButtons = 0;
        _cancelButtonIndex = -1;        // Default index for cancel button
        
        if (cancelButtonTitle) {
            _cancelButtonIndex = 0;
            [self addButtonWithTitle:cancelButtonTitle];
        }
        
        if (self) {
            va_list args;
            va_start (args, otherButtonTitles);
            for (NSString *arg = otherButtonTitles; arg != nil; arg = va_arg(args, NSString*))
            {
                [self addButtonWithTitle:arg];
            }
            
            va_end (args);
        }
        [self layout];
    }
	return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIWindowDidBecomeVisibleNotification object:nil];
    [_title release];
    [_message release];
    
    // Private ivars
    [_buttons release];
    [_textFields release];
    [_titleLabel release];
    [_subtitleLabel release];
    [_bodyTextLabel release];
    [_dimView release];
    [_dimWindow release];
    [_backgroundImageView release];
	[super dealloc];
}

#pragma mark -
#pragma mark Accessors

- (void)setAlertViewStyle:(GPAlertViewStyle)alertViewStyle {
    switch (alertViewStyle) {
        case GPAlertViewStyleLoginAndPasswordInput:
            // Add Text fields
            for (int i=0;i<2;i++) {
                [self _addTextFieldWithTag:i];
            }
            [self layout];
            break;
            
        default:
            break;
    }
}

- (void)setTitle:(NSString *)title {
    if (_title != title) {
        [_title release];
        _title = [title retain];
        
        CGSize size = [title sizeWithFont:KTitleFont constrainedToSize:CGSizeMake(kAlertViewWidth, CGFLOAT_MAX) lineBreakMode:UILineBreakModeTailTruncation];
        
        if (!_titleLabel) {
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _titleLabel.backgroundColor = [UIColor clearColor];
            _titleLabel.font = KTitleFont;
            _titleLabel.numberOfLines = 0;
            _titleLabel.shadowOffset = CGSizeMake(0, -1);
            _titleLabel.shadowColor = [UIColor blackColor];
            _titleLabel.textColor = [UIColor whiteColor];
            _titleLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:_titleLabel];
        }
        
        _titleLabel.frame = CGRectMake((self.center.x - kAlertViewWidth/2), 20.f, kAlertViewWidth, size.height);
        _titleLabel.text = title;
    }
}

- (void)setMessage:(NSString *)message {
    if (_message != message) {
        [_message release];
        _message = [message retain];
        
        CGSize size = [message sizeWithFont:kMessageFont constrainedToSize:CGSizeMake(kAlertViewWidth, [self _sizeFont:kMessageFont] * [self bodyMaxLineCount]) lineBreakMode:UILineBreakModeTailTruncation];
        
        if (!_bodyTextLabel) {
            _bodyTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            _bodyTextLabel.backgroundColor = [UIColor clearColor];
            _bodyTextLabel.font = kMessageFont;
            _bodyTextLabel.numberOfLines = [self bodyMaxLineCount];
            _bodyTextLabel.shadowOffset = CGSizeMake(0, -1);
            _bodyTextLabel.shadowColor = [UIColor blackColor];
            _bodyTextLabel.textColor = [UIColor whiteColor];
            _bodyTextLabel.textAlignment = UITextAlignmentCenter;
            [self addSubview:_bodyTextLabel];
        }
        
        _bodyTextLabel.frame = CGRectMake((self.center.x - kAlertViewWidth/2), (_titleLabel) ? _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.f : 20.f, kAlertViewWidth, size.height);
        _bodyTextLabel.text = message;
    }
}

#pragma mark -
#pragma mark Public Methods

- (NSInteger)addButtonWithTitle:(NSString *)title {
    GPButton *btn = [GPButton buttonWithType:UIButtonTypeCustom];
    btn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin;
    btn.backgroundColor = [UIColor clearColor];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn.titleLabel setShadowColor:[UIColor blackColor]];
    [btn.titleLabel setShadowOffset:CGSizeMake(0.f, -1.f)];
    [btn setReversesTitleShadowWhenHighlighted:YES];
    btn.color = [UIColor colorWithRed:0.173 green:0.392 blue:1.000 alpha:1.000];

    [btn addTarget:self action:@selector(_buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    [_buttons addObject:btn];
    btn.tag = [_buttons indexOfObject:btn];
    [self addSubview:btn];
    return _numberOfButtons++;
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex {
    return ((GPButton  *)[_buttons objectAtIndex:buttonIndex]).titleLabel.text;
}

- (UITextField *)textFieldAtIndex:(NSInteger)textFieldIndex {
    return nil;
}

- (void)show {
    
    if (!_dimWindow) {
    
        _dimWindow = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        _dimWindow.windowLevel = UIWindowLevelStatusBar;
        
        _dimView = [[QPDimView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
        _dimView.backgroundColor = [UIColor clearColor];
        _dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [_dimWindow addSubview:_dimView];
        [_dimWindow addSubview:self];
        [_dimWindow makeKeyAndVisible];
    }
    
    if ([self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
        [self.delegate willPresentAlertView:self];
    }
    [self showWithAnimation];
}

#pragma mark -
#pragma mark Private Methods

- (void)layout {
    
    _startY = 20.f;
    
    if (_bodyTextLabel) {
        _startY = _bodyTextLabel.frame.origin.y + _bodyTextLabel.frame.size.height + 15.f;
    }
    else {
        if (_titleLabel) {
            _startY = _titleLabel.frame.origin.y + _titleLabel.frame.size.height + 8.f;
        }
    }
    
    BOOL hasTextFields = [self textFieldCount] == 0 ? NO : YES;
    
    if (hasTextFields) {
        
        for (UITextField *textField in _textFields) {
            CGRect frame = textField.frame;
            frame.origin = CGPointMake(self.center.x - kAlertViewWidth/2, _startY);
            textField.frame = frame;
            _startY += textField.frame.size.height;
        }
        //_startY += ((UITextField *)[_textFields lastObject]).frame.size.height * [self textFieldCount];
        _startY += 7.f;
    }
    /*
     * cancel button - left if 2, last if more or 1
     * other buttons - right if 2, top is more or 1
     *               - if no cancel, last button is cancel
     */
    
    BOOL hasCancelButton = NO;
    CGFloat buttonWidth = kAlertViewWidth;
    CGFloat otherButtonOriginX = (self.center.x - kAlertViewWidth/2);
    
    int index = 0;
    
    for (GPButton *btn in _buttons) {
        if (_cancelButtonIndex == 0 && !hasCancelButton) {
            hasCancelButton = YES;
            index++;
            continue;
        }
        
        if ([_buttons count] == 2) {
            buttonWidth = kAlertViewWidth/2 - 4.f;
            if (index > 0) {
                otherButtonOriginX = self.center.x + 4.f;
            }
        }
        
        [btn setFrame:CGRectMake(otherButtonOriginX, _startY, buttonWidth, [self _buttonHeight])];
        if ([_buttons count] != 2) _startY += btn.frame.size.height;
        if (index < [_buttons count] -1) _startY += kPaddingButton;
        
        index++;
    }
    
    if (hasCancelButton) {
        if ([_buttons count] != 2) _startY += 20.f;
        GPButton *btn = ((GPButton *)[_buttons objectAtIndex:0]);
        [btn setFrame:CGRectMake((self.center.x - kAlertViewWidth/2), _startY, buttonWidth, [self _buttonHeight])];
        _startY += ((GPButton *)[_buttons objectAtIndex:_cancelButtonIndex]).frame.size.height;
    }
    
    _startY += 10.f;
    
    CGRect frame = self.frame;
    frame.size.height = _startY;
    self.frame = frame;
}

- (void)_setupKBWatcher {
    
}

- (void)_cleanupKBWatcher {
    
}

- (void)_updateFrameForDisplay {
    
}

- (void)_addTextFieldWithTag:(int)tag {
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(0.f, 0.f, kAlertViewWidth, 29.f)];
    textField.backgroundColor = [UIColor whiteColor];
    textField.borderStyle = UITextBorderStyleRoundedRect;
    textField.font = [UIFont systemFontOfSize:20];
    textField.placeholder = (tag == 0) ? @"Login" : @"Password";
    textField.tag = tag;
    [_textFields addObject:textField];
    [self addSubview:textField];
    [textField release];
}

- (id)_textFieldAtIndex:(int)arg1 {
    return nil;
}

- (int)textFieldCount {
    return [_textFields count];
}

- (int)bodyMaxLineCount {
    return 7;
}

- (int)numberOfLinesInTitle {
    return (int)_titleLabel.frame.size.height/[self _sizeFont:KTitleFont];
}

- (float)_buttonHeight {
    return 44.f;
}

- (CGFloat)_sizeFont:(UIFont *)font {
    return font.ascender + (-1)*font.descender + 1.f;
}

- (void)dismissAnimated:(BOOL)animated {
    if (!animated) {
        [UIView animateWithDuration:0.15
                              delay:0
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             _dimWindow.alpha = 0.f;
                         }
                         completion:^(BOOL finished) {
                             [self removeFromSuperview];
                             [_originalWindow makeKeyWindow];
                         }];
    }
    if ([self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
        [self.delegate alertView:self didDismissWithButtonIndex:_dismissButtonIndex];
    }
}

- (void)dismissWithClickedButtonIndex:(int)index animated:(BOOL)animated {
    if ([self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        [self.delegate alertView:self clickedButtonAtIndex:_dismissButtonIndex];
    }
    if ([self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
        [self.delegate alertView:self willDismissWithButtonIndex:_dismissButtonIndex];
    }
    [self dismissAnimated:animated];
}

- (void)_buttonClicked:(id)sender {
    _dismissButtonIndex = ((GPButton *)sender).tag;
    [self dismissWithClickedButtonIndex:_dismissButtonIndex animated:NO];
}

#pragma mark -
#pragma mark Layout

- (void)layoutIfNeeded {
    [super layoutIfNeeded];
}

- (void)layoutSubviews {
    //[super layoutSubviews];
    self.center = _dimWindow.center;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	rect = CGRectMake((self.center.x - kAlertViewWidth/2) - 12.f, (self.bounds.size.height - _startY)/2, kAlertViewWidth + 24.f, _startY);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, 5.f, 5.f) cornerRadius:10.f];
	
	// Shadow
	CGContextSaveGState(context);
	//CGMutablePathRef shadowPath = createRoundedRectForRect(CGRectInset(rect, 5, 5), 10.0f, RoundCornersAll);
	CGContextAddRect(context, rect);
	CGContextAddPath(context, path.CGPath);
	CGContextEOClip(context);
	
	CGContextAddPath(context, path.CGPath);
	CGContextSetShadowWithColor(context, CGSizeZero, 5.0f, [UIColor blackColor].CGColor);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	// Stroke
	CGContextSaveGState(context);
	//CGMutablePathRef outerPath = createRoundedRectForRect(CGRectInset(rect, 5, 5), 10.0f, RoundCornersAll);
	CGContextAddPath(context, path.CGPath);
	CGContextSetLineWidth(context, 4.0f);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:1.0 alpha:0.8].CGColor);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	
	// Fill
	CGContextSaveGState(context);
	//CGMutablePathRef fillPath = createRoundedRectForRect(CGRectInset(rect, 5, 5), 10.0f, RoundCornersAll);
	CGContextAddRect(context, rect);
	CGContextAddPath(context, path.CGPath);
	CGContextClip(context);
	
	CGContextAddPath(context, path.CGPath);
	CGContextSetFillColorWithColor(context,[UIColor colorWithRed:0.000 green:0.032 blue:0.646 alpha:0.760].CGColor);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	/*
	// Image
	CGContextSaveGState(context);
	CGMutablePathRef imagePath = createRoundedRectForRect(CGRectInset(rect, 5, 5), 10.0f, RoundCornersAll);
	CGContextAddPath(context, imagePath);
	CGContextClip(context);
	CGContextDrawImage(context, rect, [UIImage imageNamed:@"bg-public.png"].CGImage);
	CGContextRestoreGState(context);
     */
}

- (void)showWithAnimation
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation
									  animationWithKeyPath:@"transform"];
	
    CATransform3D scale1 = CATransform3DMakeScale(0.5, 0.5, 1);
    CATransform3D scale2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D scale3 = CATransform3DMakeScale(0.9, 0.9, 1);
    CATransform3D scale4 = CATransform3DMakeScale(1.0, 1.0, 1);
	
    NSArray *frameValues = [NSArray arrayWithObjects:
							[NSValue valueWithCATransform3D:scale1],
							[NSValue valueWithCATransform3D:scale2],
							[NSValue valueWithCATransform3D:scale3],
							[NSValue valueWithCATransform3D:scale4],
							nil];
    [animation setValues:frameValues];
	
    NSArray *frameTimes = [NSArray arrayWithObjects:
						   [NSNumber numberWithFloat:0.0],
						   [NSNumber numberWithFloat:0.5],
						   [NSNumber numberWithFloat:0.9],
						   [NSNumber numberWithFloat:1.0],
						   nil];
    [animation setKeyTimes:frameTimes];
	
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = .2;
	
    [self.layer addAnimation:animation forKey:@"popup"];
    
    
    if ([self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
        [self.delegate didPresentAlertView:self];
    }
}

@end
