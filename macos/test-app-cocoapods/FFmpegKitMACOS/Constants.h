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
