/*
 * Copyright (c) 2018-2021 Taner Sener
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "Util.h"

NSString* notNull(NSString* string, NSString* valuePrefix) {
    return (string == nil) ? @"" : [NSString stringWithFormat:@"%@%@", valuePrefix, string];
}

void addUIAction(AsyncUpdateUIBlock asyncUpdateUIBlock) {
    dispatch_async(dispatch_get_main_queue(), ^{
        asyncUpdateUIBlock();
    });
}

@implementation Util

+ (void)applyButtonStyle: (UIButton*) button {
    button.tintColor = [UIColor whiteColor];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.layer.backgroundColor = [UIColor colorWithDisplayP3Red:46.0/256 green:204.0/256 blue:113.0/256 alpha:1.0].CGColor;
    button.layer.borderWidth = 1.0f;
    button.layer.borderColor = [UIColor colorWithDisplayP3Red:39.0/256 green:174.0/256 blue:96.0/256 alpha:1.0].CGColor;
    button.layer.cornerRadius = 5.0f;
}

+ (void)applyEditTextStyle: (UITextField*) textField {
    textField.layer.borderWidth = 1.0f;
    textField.layer.borderColor = [UIColor colorWithDisplayP3Red:52.0/256 green:152.0/256 blue:219.0/256 alpha:1.0].CGColor;
    textField.layer.cornerRadius = 5.0f;
}

+ (void)applyHeaderStyle: (UILabel*) label {
    label.layer.borderWidth = 1.0f;
    label.layer.borderColor = [UIColor colorWithDisplayP3Red:231.0/256 green:76.0/256 blue:60.0/256 alpha:1.0].CGColor;
    label.layer.cornerRadius = 5.0f;
}

+ (void)applyOutputTextStyle: (UITextView*) textView {
    textView.layer.backgroundColor = [UIColor colorWithDisplayP3Red:241.0/256 green:196.0/256 blue:15.0/256 alpha:1.0].CGColor;
    textView.layer.borderWidth = 1.0f;
    textView.layer.borderColor = [UIColor colorWithDisplayP3Red:243.0/256 green:156.0/256 blue:18.0/256 alpha:1.0].CGColor;
    textView.layer.cornerRadius = 5.0f;
}

+ (void)applyVideoPlayerFrameStyle: (UILabel*) playerFrame {
    playerFrame.layer.backgroundColor = [UIColor colorWithDisplayP3Red:236.0/256 green:240.0/256 blue:241.0/256 alpha:1.0].CGColor;
    playerFrame.layer.borderWidth = 1.0f;
    playerFrame.layer.borderColor = [UIColor colorWithDisplayP3Red:185.0/256 green:195.0/256 blue:199.0/256 alpha:1.0].CGColor;
    playerFrame.layer.cornerRadius = 5.0f;
}

+ (void)alert: (UIViewController*)controller withTitle:(NSString*)title message:(NSString*)message andButtonText:(NSString*)buttonText {
    UIAlertController* alert = [UIAlertController
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction
                                    actionWithTitle:buttonText style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [controller presentViewController:alert animated:YES completion:nil];
}

@end
