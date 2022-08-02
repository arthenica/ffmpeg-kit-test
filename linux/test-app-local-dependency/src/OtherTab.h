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

#ifndef FFMPEG_KIT_TEST_OTHER_TAB_H
#define FFMPEG_KIT_TEST_OTHER_TAB_H

#include "Util.h"
#include <gtkmm.h>

namespace ffmpegkittest {

    class OtherTab: public Gtk::VBox {
        public:

            static constexpr const char* Dav1dTestDefaultUrl = "http://download.opencontent.netflix.com.s3.amazonaws.com/AV1/Sparks/Sparks-5994fps-AV1-10bit-960x540-film-grain-synthesis-854kbps.obu";

            OtherTab();
            void setActive();
            void setParentWindow(Gtk::Window* parentWindow);
            void appendOutput(const std::string& string);

        private:
            void clearOutput();
            void initTestData();
            void onTestChanged();
            std::string getSelectedTest();
            void runTest();
            void testChromaprint();
            void testDav1d();
            void testWebp();
            void testZscale();
            std::string getChromaprintSampleFile();
            std::string getDav1dOutputFile();
            std::string getChromaprintOutputFile();

            Glib::RefPtr<Gtk::ListStore> testModel;
            ComboBoxModelColumn testModelColumn;
            Gtk::ComboBox test;
            Gtk::HBox testBox;
            int selectedTest;
            Gtk::Button runButton;
            Gtk::HBox runButtonBox;
            Gtk::TextView outputText;
            Gtk::ScrolledWindow outputTextWindow;
            Gtk::Window* parentWindow;
    };

}

#endif // FFMPEG_KIT_TEST_OTHER_TAB_H
