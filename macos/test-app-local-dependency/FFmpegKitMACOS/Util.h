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
