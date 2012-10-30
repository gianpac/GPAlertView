//
//  ViewController.m
//  GPAlertViewDemo
//
//  Created by Giancarlo Pacheco on 2012-10-29.
//  Copyright (c) 2012 Giancarlo Pacheco. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.view addGestureRecognizer:tapRecognizer];
    [tapRecognizer release];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    GPAlertView *alert = [[[GPAlertView alloc] initWithTitle:@"What is your phone number?"
                                                     message:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                                                    delegate:self
                                           cancelButtonTitle:@"Cancel"
                                           otherButtonTitles:@"Continue",
                           //@"one",
                           //@"two",
                           nil] autorelease];
    [alert setAlertViewStyle:GPAlertViewStyleLoginAndPasswordInput];
    [alert show];
}

#pragma mark -
#pragma mark GPAlertView Delegate Methods

- (void)alertView:(GPAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"Clicked : %@", [alertView buttonTitleAtIndex:buttonIndex]);
}

- (void)willPresentAlertView:(GPAlertView *)alertView {
    NSLog(@"will present alertview");
}

- (void)didPresentAlertView:(GPAlertView *)alertView {
    NSLog(@"did present alertview");
}

- (void)alertView:(GPAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"will dissmiss with button : %@", [alertView buttonTitleAtIndex:buttonIndex]);
}

- (void)alertView:(GPAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    NSLog(@"did dismiss with button : %@", [alertView buttonTitleAtIndex:buttonIndex]);
}

- (void)alertViewCancel:(GPAlertView *)alertView {
    NSLog(@"cancelled");
}

@end
