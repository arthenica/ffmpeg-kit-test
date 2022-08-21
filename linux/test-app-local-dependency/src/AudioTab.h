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

#ifndef FFMPEG_KIT_TEST_AUDIO_TAB_H
#define FFMPEG_KIT_TEST_AUDIO_TAB_H

#include "ProgressDialog.h"
#include "Util.h"
#include <gtkmm.h>

namespace ffmpegkittest {

    class AudioTab: public Gtk::VBox {
        public:
            AudioTab();
            void setActive();
            void setParentWindow(Gtk::Window* parentWindow);
            void appendOutput(const std::string& string);

        private:
            void createAudioSample();
            void clearOutput();
            void initAudioCodecData();
            void onAudioCodecChanged();
            std::string getSelectedAudioCodec();
            void encodeAudio();
            std::string getAudioOutputFile();
            std::string getAudioSampleFile();
            void showProgressDialog();
            void hideProgressDialog();
            std::string generateAudioEncodeScript();

            Glib::RefPtr<Gtk::ListStore> audioCodecModel;
            ComboBoxModelColumn audioCodecModelColumn;
            Gtk::ComboBox audioCodec;
            Gtk::HBox audioCodecBox;
            int selectedCodec;
            Gtk::Button encodeButton;
            Gtk::HBox encodeButtonBox;
            Gtk::TextView outputText;
            Gtk::ScrolledWindow outputTextWindow;
            ffmpegkittest::ProgressDialog progressDialog;
            Gtk::Window* parentWindow;
    };

}

#endif // FFMPEG_KIT_TEST_AUDIO_TAB_H
