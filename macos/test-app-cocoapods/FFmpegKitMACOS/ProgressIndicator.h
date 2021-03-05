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

#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>
#include "Util.h"

@interface ProgressIndicator : NSObject

- (void)show:(NSView*)view message:(NSString*)message indeterminate:(BOOL)indeterminate asyncBlock:(AsyncBlock)asyncBlock;

- (void)updateMessage:(NSString*)message;

- (void)updateMessage:(NSString*)message percentage:(int)percentage;

- (void)updatePercentage:(int)percentage;

- (void)hide;

@end
