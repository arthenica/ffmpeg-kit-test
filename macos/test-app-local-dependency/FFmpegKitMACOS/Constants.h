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

#ifndef FFMPEG_KIT_TEST_CONSTANTS
#define FFMPEG_KIT_TEST_CONSTANTS

#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

// COMMAND TEST
extern NSString *const COMMAND_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const COMMAND_TEST_TOOLTIP_DURATION;

// VIDEO TEST
extern NSString *const VIDEO_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const VIDEO_TEST_TOOLTIP_DURATION;

// HTTPS TEST
extern NSString *const HTTPS_TEST_DEFAULT_URL;
extern NSString *const HTTPS_TEST_FAIL_URL;
extern NSString *const HTTPS_TEST_RANDOM_URL_1;
extern NSString *const HTTPS_TEST_RANDOM_URL_2;
extern NSString *const HTTPS_TEST_RANDOM_URL_3;
extern NSString *const HTTPS_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const HTTPS_TEST_TOOLTIP_DURATION;

// AUDIO TEST
extern NSString *const AUDIO_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const AUDIO_TEST_TOOLTIP_DURATION;

// SUBTITLE TEST
extern NSString *const SUBTITLE_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const SUBTITLE_TEST_TOOLTIP_DURATION;

// VID.STAB TEST
extern NSString *const VIDSTAB_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const VIDSTAB_TEST_TOOLTIP_DURATION;

// PIPE TEST
extern NSString *const PIPE_TEST_TOOLTIP_TEXT;
extern NSTimeInterval const PIPE_TEST_TOOLTIP_DURATION;

// OTHER TEST
extern NSString *const DAV1D_TEST_DEFAULT_URL;

#endif  /* FFMPEG_KIT_TEST_CONSTANTS */
