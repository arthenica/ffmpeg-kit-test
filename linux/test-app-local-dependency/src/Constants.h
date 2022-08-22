/*
 * Copyright (c) 2022 Taner Sener
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

#ifndef FFMPEG_KIT_TEST_CONSTANTS_H
#define FFMPEG_KIT_TEST_CONSTANTS_H

#include <gtkmm.h>
#include <iostream>

namespace ffmpegkittest {

    class Constants {
        public:

            static constexpr const char* CommandTestFFmpegTooltipText = "Enter an FFmpeg command without 'ffmpeg' at the beginning and click the RUN button";

            static constexpr const char* CommandTestFFprobeTooltipText = "Enter an FFprobe command without 'ffprobe' at the beginning and click the RUN button";

            static constexpr const char* VideoTestTooltipText = "Select a video codec and press the ENCODE button";

            static constexpr const char* HttpsTestTooltipText = "Enter the https url of a media file and click the button";

            static constexpr const char* AudioTestTooltipText = "Select an audio codec and press the ENCODE button";

            static constexpr const char* SubtitleTestEncodeTooltipText = "Click the button to burn subtitles";

            static constexpr const char* SubtitleTestCancelTooltipText = "Click cancel to stop";

            static constexpr const char* VidStabTestTooltipText = "Click the button to stabilize video";

            static constexpr const char* PipeTestTooltipText = "Click the button to create a video using pipe redirection";

            static constexpr const char* ConcurrentExecutionTestTooltipText = "Use ENCODE and CANCEL buttons to start/stop multiple executions";

            static constexpr const char* OtherTestTooltipText = "Select a test and press the RUN button";

    };

}

#endif // FFMPEG_KIT_TEST_CONSTANTS_H
