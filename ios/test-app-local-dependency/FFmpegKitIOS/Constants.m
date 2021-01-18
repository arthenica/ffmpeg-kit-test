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

#include "Constants.h"

// COMMAND TEST
NSString *const COMMAND_TEST_TOOLTIP_TEXT = @"Enter an FFmpeg command without 'ffmpeg' at the beginning and click one of the RUN buttons";
NSTimeInterval const COMMAND_TEST_TOOLTIP_DURATION = 4.0;

// VIDEO TEST
NSString *const VIDEO_TEST_TOOLTIP_TEXT = @"Select a video codec and press ENCODE button";
NSTimeInterval const VIDEO_TEST_TOOLTIP_DURATION = 4.0;

// HTTPS TEST
NSString *const HTTPS_TEST_DEFAULT_URL = @"https://download.blender.org/peach/trailer/trailer_1080p.ogg";
NSString *const HTTPS_TEST_FAIL_URL = @"https://download2.blender.org/peach/trailer/trailer_1080p.ogg";
NSString *const HTTPS_TEST_RANDOM_URL_1 = @"https://file-examples-com.github.io/uploads/2018/04/file_example_MOV_640_800kB.mov";
NSString *const HTTPS_TEST_RANDOM_URL_2 = @"https://file-examples-com.github.io/uploads/2017/11/file_example_MP3_700KB.mp3";
NSString *const HTTPS_TEST_RANDOM_URL_3 = @"https://file-examples-com.github.io/uploads/2020/03/file_example_WEBP_50kB.webp";
NSString *const HTTPS_TEST_TOOLTIP_TEXT = @"Enter the https url of a media file and click the button";
NSTimeInterval const HTTPS_TEST_TOOLTIP_DURATION = 4.0;

// AUDIO TEST
NSString *const AUDIO_TEST_TOOLTIP_TEXT = @"Select an audio codec and press ENCODE button";
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
