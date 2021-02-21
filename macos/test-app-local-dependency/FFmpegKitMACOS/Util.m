/*
 * Copyright (c) 2018-2021 Taner Sener
 *
 * This file is part of FFmpegKitTest.
 *
 * FFmpegKitTest is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKitTest is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKitTest.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Util.h"

NSString* notNull(NSString* string, NSString* valuePrefix) {
    return (string == nil) ? @"" : [NSString stringWithFormat:@"%@%@", valuePrefix, string];
}

void addUIAction(AsyncBlock asyncUpdateUIBlock) {
    dispatch_async(dispatch_get_main_queue(), ^{
        asyncUpdateUIBlock();
    });
}

@implementation Util

+ (void)applyButtonStyle: (NSButton*) button {
    button.layer.borderWidth = 1.0f;
    button.layer.cornerRadius = 5.0f;
}

+ (void)applyEditTextStyle: (NSTextField*) textField {
    textField.wantsLayer = true;
    textField.textColor = [NSColor blackColor];
    textField.layer.borderWidth = 1.0f;
    textField.layer.cornerRadius = 5.0f;
    textField.layer.borderColor = CGColorCreateGenericRGB(52.0/256, 152.0/256, 219.0/256, 1.0/1.0);
    textField.layer.backgroundColor = CGColorCreateGenericRGB(255.0/256, 255.0/256, 255.0/256, 1.0/1.0);
}

+ (void)applyOutputTextStyle: (NSTextView*) textView {
    textView.wantsLayer = true;
    textView.layer.borderWidth = 1.0f;
    textView.layer.cornerRadius = 5.0f;
    textView.textColor = [NSColor blackColor];
    textView.backgroundColor = [NSColor colorWithRed:241.0/256 green:196.0/256 blue:15.0/256 alpha:1.0];
    textView.layer.borderColor = CGColorCreateGenericRGB(243.0/256, 156.0/256, 18.0/256, 1.0/1.0);
}

+ (void)applyComboBoxStyle: (NSComboBox*) comboBox {
    comboBox.wantsLayer = false;
    comboBox.textColor = [NSColor whiteColor];
    comboBox.layer.borderWidth = 1.0f;
    comboBox.layer.cornerRadius = 5.0f;
}

+ (void)applyVideoPlayerFrameStyle: (NSView*) playerFrame {
    playerFrame.wantsLayer = true;
    playerFrame.layer.borderWidth = 1.0f;
    playerFrame.layer.cornerRadius = 5.0f;
    playerFrame.layer.borderColor = CGColorCreateGenericRGB(185.0/256, 195.0/256, 199.0/256, 1.0/1.0);
    playerFrame.layer.backgroundColor = CGColorCreateGenericRGB(236.0/256, 240.0/256, 241.0/256, 1.0/1.0);
}

+ (NSAlert*)alert:(NSWindow*)window withTitle:(NSString*)title message:(NSString*)message buttonText:(NSString*)buttonText andHandler:(void (^)(NSModalResponse result))handler {
    NSAlert *alert = [[NSAlert alloc] init];

    [alert setAlertStyle:NSAlertStyleInformational];
    [alert setMessageText:title];
    [alert setInformativeText:message];
    [alert addButtonWithTitle:buttonText];
    if (handler != nil) {
        [alert addButtonWithTitle:@"Cancel"];
    }
    [alert beginSheetModalForWindow:window completionHandler:handler];
    
    return alert;
}
    
/*+ (void)alert: (NSViewController*)controller withTitle:(NSString*)title message:(NSString*)message andButtonText:(NSString*)buttonText {
    NSAlert* alert = [NSAlert
                                alertControllerWithTitle:title
                                message:message
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* defaultAction = [UIAlertAction
                                    actionWithTitle:buttonText style:UIAlertActionStyleDefault
                                    handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [controller presentViewController:alert animated:YES completion:nil];
}
*/
@end
