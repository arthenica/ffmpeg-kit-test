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

#include <UIKit/UIKit.h>
#include <Foundation/Foundation.h>

extern NSString* notNull(NSString* string, NSString* valuePrefix);

typedef void (^AsyncUpdateUIBlock)(void);

extern void addUIAction(AsyncUpdateUIBlock asyncUpdateUIBlock);

@interface Util : NSObject

+ (void)applyButtonStyle: (UIButton*) button;
+ (void)applyEditTextStyle: (UITextField*) textField;
+ (void)applyHeaderStyle: (UILabel*) label;
+ (void)applyOutputTextStyle: (UITextView*) textView;
+ (void)applyVideoPlayerFrameStyle: (UILabel*) playerFrame;
+ (void)alert: (UIViewController*)controller withTitle:(NSString*)title message:(NSString*)message andButtonText:(NSString*)buttonText;

@end

#endif  /* FFMPEG_KIT_TEST_UTIL */
