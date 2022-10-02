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

#ifndef FFMPEG_KIT_TEST_CONCURRENT_EXECUTION_TAB_H
#define FFMPEG_KIT_TEST_CONCURRENT_EXECUTION_TAB_H

#include "Util.h"
#include <gtkmm.h>

namespace ffmpegkittest {

    class ConcurrentExecutionTab: public Gtk::VBox {
        public:
            ConcurrentExecutionTab();
            void setActive();
            void setParentWindow(Gtk::Window* parentWindow);
            void appendOutput(const std::string& string);

        private:
            void clearOutput();
            void encodeVideo(const int buttonNumber);
            void cancel(const int buttonNumber);

            Gtk::Button encodeButton1;
            Gtk::Button encodeButton2;
            Gtk::Button encodeButton3;
            Gtk::HBox encodeButtonBox;
            Gtk::Button cancelButton1;
            Gtk::Button cancelButton2;
            Gtk::Button cancelButton3;
            Gtk::Button cancelButton4;
            Gtk::HBox cancelButtonBox;
            Gtk::TextView outputText;
            Gtk::ScrolledWindow outputTextWindow;
            Gtk::Window* parentWindow;
    };

}

#endif // FFMPEG_KIT_TEST_CONCURRENT_EXECUTION_TAB_H
