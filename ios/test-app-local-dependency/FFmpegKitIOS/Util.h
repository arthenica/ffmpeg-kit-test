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
+ (void)applyPickerViewStyle: (UIPickerView*) pickerView;
+ (void)applyVideoPlayerFrameStyle: (UILabel*) playerFrame;
+ (void)alert: (UIViewController*)controller withTitle:(NSString*)title message:(NSString*)message andButtonText:(NSString*)buttonText;

@end

#endif  /* FFMPEG_KIT_TEST_UTIL */
