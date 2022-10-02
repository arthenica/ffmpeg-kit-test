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

#include "Constants.h"

// COMMAND TEST
NSString *const COMMAND_TEST_TOOLTIP_TEXT = @"Enter a command without ffmpeg/ffprobe at the beginning and click one of the RUN buttons";
NSTimeInterval const COMMAND_TEST_TOOLTIP_DURATION = 4.0;

// VIDEO TEST
NSString *const VIDEO_TEST_TOOLTIP_TEXT = @"Select a video codec and press the ENCODE button";
NSTimeInterval const VIDEO_TEST_TOOLTIP_DURATION = 4.0;

// HTTPS TEST
NSString *const HTTPS_TEST_DEFAULT_URL = @"https://download.blender.org/peach/trailer/trailer_1080p.ogg";
NSString *const HTTPS_TEST_FAIL_URL = @"https://download2.blender.org/peach/trailer/trailer_1080p.ogg";
NSString *const HTTPS_TEST_RANDOM_URL_1 = @"https://filesamples.com/samples/video/mov/sample_640x360.mov";
NSString *const HTTPS_TEST_RANDOM_URL_2 = @"https://filesamples.com/samples/audio/mp3/sample3.mp3";
NSString *const HTTPS_TEST_RANDOM_URL_3 = @"https://filesamples.com/samples/image/webp/sample1.webp";
NSString *const HTTPS_TEST_TOOLTIP_TEXT = @"Enter the https url of a media file and click the button";
NSTimeInterval const HTTPS_TEST_TOOLTIP_DURATION = 4.0;

// AUDIO TEST
NSString *const AUDIO_TEST_TOOLTIP_TEXT = @"Select an audio codec and press the ENCODE button";
NSTimeInterval const AUDIO_TEST_TOOLTIP_DURATION = 4.0;

// SUBTITLE TEST
NSString *const SUBTITLE_TEST_TOOLTIP_TEXT = @"Click the button to burn subtitles. Created video will play inside the frame below";
NSTimeInterval const SUBTITLE_TEST_TOOLTIP_DURATION = 4.0;

// VID.STAB TEST
NSString *const VIDSTAB_TEST_TOOLTIP_TEXT = @"Click the button to stabilize video. Original video will play above and stabilized video will play below";
NSTimeInterval const VIDSTAB_TEST_TOOLTIP_DURATION = 4.0;

// PIPE TEST
NSString *const PIPE_TEST_TOOLTIP_TEXT = @"Click the button to create a video using pipe redirection. Created video will play inside the frame below";
NSTimeInterval const PIPE_TEST_TOOLTIP_DURATION = 4.0;

// OTHER TEST
NSString *const DAV1D_TEST_DEFAULT_URL = @"http://download.opencontent.netflix.com.s3.amazonaws.com/AV1/Sparks/Sparks-5994fps-AV1-10bit-960x540-film-grain-synthesis-854kbps.obu";
