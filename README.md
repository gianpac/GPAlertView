GPAlertView
===========

Reverse engineered `UIAlertView`
Useful when control is needed over the alertview.
Supports iOS 4.3 for the new `UIAlertViewStyle` introduce in iOS 5.0

Uses CoreGraphics to do all the drawing needed.

**Usage**

    GPAlertView *alertView = [[GPAlertView alloc] initWithTitle:@"Lorem Ipsum" 
                                                        message:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit. "
                                                       delegate:self cancelButtonTitle:@"Cancel"       
                                              otherButtonTitles:@"Continue", @"one", @"two", nil] autorelease];         
    [alert setAlertViewStyle:GPAlertViewStyleLoginAndPasswordInput];        
    [alert show];

**MIT License**

Copyright © 2012 Giancarlo Pacheco

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.