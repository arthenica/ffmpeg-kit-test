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

#ifndef FFMPEG_KIT_TEST_HTTPS_TAB_H
#define FFMPEG_KIT_TEST_HTTPS_TAB_H

#include <gtkmm.h>
#include "Util.h"
#include <FFprobeKit.h>

namespace ffmpegkittest {

    class HttpsTab: public Gtk::VBox {
        public:

            static constexpr const char* HttpsTestDefaultUrl = "https://download.blender.org/peach/trailer/trailer_1080p.ogg";

            static constexpr const char* HttpsTestFailUrl = "https://download2.blender.org/peach/trailer/trailer_1080p.ogg";

            static constexpr const char* HttpsTestRandomUrl1 = "https://filesamples.com/samples/video/mov/sample_640x360.mov";

            static constexpr const char* HttpsTestRandomUrl2 = "https://filesamples.com/samples/audio/mp3/sample3.mp3";

            static constexpr const char* HttpsTestRandomUrl3 = "https://filesamples.com/samples/image/webp/sample1.webp";

            HttpsTab();
            void setActive();
            void setParentWindow(Gtk::Window* parentWindow);
            void appendOutput(const std::string& string);

        private:
            void clearOutput();
            void runGetMediaInformation(const int buttonNumber);
            std::string getRandomTestUrl();
            ffmpegkit::MediaInformationSessionCompleteCallback createNewCompleteCallback();

            Gtk::Entry urlText;
            Gtk::Button getInfoFromUrlButton;
            Gtk::HBox getInfoFromUrlButtonBox;
            Gtk::Button getRandomInfoButton1;
            Gtk::HBox getRandomInfoButton1Box;
            Gtk::Button getRandomInfoButton2;
            Gtk::HBox getRandomInfoButton2Box;
            Gtk::Button getInfoAndFailButton;
            Gtk::HBox getInfoAndFailButtonBox;
            Gtk::TextView outputText;
            Gtk::ScrolledWindow outputTextWindow;
            Gtk::Window* parentWindow;
    };

}

#endif // FFMPEG_KIT_TEST_HTTPS_TAB_H
