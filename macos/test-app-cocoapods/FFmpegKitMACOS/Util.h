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

#ifndef FFMPEG_KIT_TEST_UTIL
#define FFMPEG_KIT_TEST_UTIL

#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>

extern NSString* notNull(NSString* string, NSString* valuePrefix);

typedef void (^AsyncBlock)(void);

extern void addUIAction(AsyncBlock asyncUpdateUIBlock);

@interface Util : NSObject

+ (void)applyButtonStyle: (NSButton*) button;
+ (void)applyEditTextStyle: (NSTextField*) textField;
+ (void)applyOutputTextStyle: (NSTextView*) textView;
+ (void)applyComboBoxStyle: (NSComboBox*) comboBox;
+ (void)applyVideoPlayerFrameStyle: (NSView*) playerFrame;
+ (NSAlert*)alert:(NSWindow*)window withTitle:(NSString*)title message:(NSString*)message buttonText:(NSString*)buttonText andHandler:(void (^)(NSModalResponse result))handler;

@end

#endif  /* FFMPEG_KIT_TEST_UTIL */
