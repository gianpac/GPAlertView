//
//  ViewController.m
//  GPAlertViewDemo
//
//  Created by Giancarlo Pacheco on 2012-10-29.
//  Copyright (c) 2012 Giancarlo Pacheco. All rights reserved.
//

#import "ViewController.h"
#import "GPAlertView.h"

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
    [alert setAlertViewStyle:AKAlertViewStyleLoginAndPasswordInput];
    [alert show];
}

@end
