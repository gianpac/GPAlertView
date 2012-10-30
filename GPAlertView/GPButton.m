//
//  GPButton.m
//
//  Created by Giancarlo Pacheco on 2012-10-28.
//  Copyright (c) 2012 Giancarlo Pacheco. All rights reserved.
//

#import "GPButton.h"

static void linearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor, BOOL isAxial) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = [NSArray arrayWithObjects:(id)startColor, (id)endColor, nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    if (isAxial) {
        startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect));
        endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    }
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
	CGColorSpaceRelease(colorSpace);
}

@implementation GPButton

#define CornerRadius 4.0f

@synthesize color;
@synthesize text;

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	CGRect frame = CGRectInset(rect, 2.0, 2.0);
	
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:frame cornerRadius:CornerRadius];
	
	// Fill
	CGContextSaveGState(context);
	CGContextAddRect(context, rect);
	CGContextAddPath(context, path.CGPath);
	CGContextClip(context);
	
	CGContextAddPath(context, path.CGPath);
	CGContextSetFillColorWithColor(context, self.color.CGColor);
	CGContextFillPath(context);
	CGContextRestoreGState(context);
	
	// Gradient
	CGContextSaveGState(context);
    if (self.isHighlighted) {
        linearGradient(context, rect, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4].CGColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor, NO);
    }
    else {
        linearGradient(context, rect, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.0].CGColor, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4].CGColor, NO);
    }
	CGContextRestoreGState(context);
	
	// Drop Shadow and Top Inner Glow
	CGContextSaveGState(context);
	CGRect shadowRect = CGRectOffset(frame, 0, 1);
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRoundedRect:shadowRect cornerRadius:CornerRadius];
	CGContextAddRect(context, rect);
	CGContextAddPath(context, shadowPath.CGPath);
	CGContextEOClip(context);
	
	CGContextAddPath(context, shadowPath.CGPath);
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.3].CGColor);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	
	// Stroke
	CGContextSaveGState(context);
	CGRect strokeRect = CGContextGetClipBoundingBox(context);
	CGContextAddRect(context, strokeRect);
	CGContextAddPath(context, path.CGPath);
	CGContextEOClip(context);
	
	CGContextAddPath(context, path.CGPath);
	CGContextSetLineWidth(context, 1.0);
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0].CGColor);
	CGContextStrokePath(context);
	CGContextRestoreGState(context);
	
	// Text
	UIFont *font = [UIFont fontWithName:@"Helvetica-Bold" size:16];
	CGSize size = [text sizeWithFont:font constrainedToSize:CGSizeMake(rect.size.width, rect.size.height) lineBreakMode:UILineBreakModeTailTruncation];
	CGRect textBox = CGRectMake((rect.size.width - size.width)/2, (rect.size.height - size.height)/2, size.width, size.height);
	
	// Shadow Text
	[[UIColor blackColor] set];
	[text drawInRect:CGRectOffset(textBox, 0.0, 1.0) withFont:font];
	
	// Regular Text
	[[UIColor whiteColor] set];
	[text drawInRect:textBox withFont:font];
}


@end
