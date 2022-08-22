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

#include "AudioTab.h"
#include "Application.h"
#include "Constants.h"
#include "Popup.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>

using namespace ffmpegkit;

static gboolean showEncodeSuccessPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_INFO, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean showEncodeFailedPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::AudioTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::AudioTab* audioTab = parameters->first;
    auto log = parameters->second;
    audioTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

ffmpegkittest::AudioTab::AudioTab() : selectedCodec(-1) {
    audioCodecModel = Gtk::ListStore::create(audioCodecModelColumn);
    audioCodec.set_model(audioCodecModel);
    audioCodec.set_size_request(240, 30);
    audioCodec.signal_changed().connect(sigc::mem_fun(*this, &AudioTab::onAudioCodecChanged));
    Util::applyComboBoxStyle(audioCodec);

    initAudioCodecData();

    encodeButton.set_label("ENCODE");
    encodeButton.set_size_request(120, 30);
    encodeButton.set_tooltip_text(Constants::AudioTestTooltipText);
    encodeButton.signal_clicked().connect(sigc::mem_fun(*this, &AudioTab::encodeAudio));
    encodeButton.set_sensitive(false);
    Util::applyButtonStyle(encodeButton);
    encodeButtonBox.pack_start(encodeButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(audioCodecBox, Gtk::PACK_SHRINK);
    pack_start(encodeButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::AudioTab::setActive() {
    std::cout << "Audio Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback(nullptr);
    FFmpegKitConfig::enableStatisticsCallback(nullptr);
    createAudioSample();
    FFmpegKitConfig::enableLogCallback([this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<AudioTab*,const std::shared_ptr<Log>>(this, log));
    });
}

void ffmpegkittest::AudioTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::AudioTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::AudioTab::createAudioSample() {
    std::cout << "Creating AUDIO sample before the test." << std::endl;

    auto audioSampleFile = getAudioSampleFile();
    std::remove(audioSampleFile.c_str());

    std::string ffmpegCommand = "-hide_banner -y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le " + audioSampleFile;

    std::cout << "Creating audio sample with '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::execute(ffmpegCommand);
    if (ReturnCode::isSuccess(session->getReturnCode())) {
        encodeButton.set_sensitive(true);
        std::cout << "AUDIO sample created." << std::endl;
    } else {
        std::cout << "Creating AUDIO sample failed with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;
        g_idle_add((GSourceFunc)showEncodeFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Creating AUDIO sample failed. Please check logs for the details."));
    }
}

void ffmpegkittest::AudioTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::AudioTab::initAudioCodecData() {
    auto row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "1";
    row[audioCodecModelColumn.columnName] = "mp2 (twolame)";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "2";
    row[audioCodecModelColumn.columnName] = "mp3 (liblame)";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "3";
    row[audioCodecModelColumn.columnName] = "mp3 (libshine)";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "4";
    row[audioCodecModelColumn.columnName] = "vorbis";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "5";
    row[audioCodecModelColumn.columnName] = "opus";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "6";
    row[audioCodecModelColumn.columnName] = "amr-nb";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "7";
    row[audioCodecModelColumn.columnName] = "amr-wb";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "8";
    row[audioCodecModelColumn.columnName] = "ilbc";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "9";
    row[audioCodecModelColumn.columnName] = "soxr";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "10";
    row[audioCodecModelColumn.columnName] = "speex";

    row = *(audioCodecModel->append());
    row[audioCodecModelColumn.columnId] = "11";
    row[audioCodecModelColumn.columnName] = "wavpack";

    audioCodec.pack_start(audioCodecModelColumn.columnName);
    audioCodec.set_entry_text_column(audioCodecModelColumn.columnId);
    audioCodec.set_active(0);

    audioCodecBox.pack_start(audioCodec, Gtk::PACK_EXPAND_PADDING);
}

void ffmpegkittest::AudioTab::onAudioCodecChanged() {
    int rowNumber = audioCodec.get_active_row_number();
    if (rowNumber != -1) {
        selectedCodec = rowNumber;
    }
}

std::string ffmpegkittest::AudioTab::getSelectedAudioCodec() {
    switch(selectedCodec) {
        case 0: return "mp2 (twolame)";
        case 1: return "mp3 (liblame)";
        case 2: return "mp3 (libshine)";
        case 3: return "vorbis";
        case 4: return "opus";
        case 5: return "amr-nb";
        case 6: return "amr-wb";
        case 7: return "ilbc";
        case 8: return "soxr";
        case 9: return "speex";
        case 10: return "wavpack";
        default: return "";
    }
}

void ffmpegkittest::AudioTab::encodeAudio() {
    auto audioOutputFile = getAudioOutputFile();
    std::remove(audioOutputFile.c_str());

    auto audioCodec = getSelectedAudioCodec();

    std::cout << "Testing AUDIO encoding with '" << audioCodec << "' codec." << std::endl;

    auto ffmpegCommand = generateAudioEncodeScript();

    showProgressDialog();

    clearOutput();

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::executeAsync(ffmpegCommand, [this](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();

        this->hideProgressDialog();

        if (ReturnCode::isSuccess(returnCode)) {
            g_idle_add((GSourceFunc)showEncodeSuccessPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Encode completed successfully."));
            std::cout << "Encode completed successfully." << std::endl;
        } else {
            g_idle_add((GSourceFunc)showEncodeFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Encode failed. Please check logs for the details."));
            std::cout << "Encode failed with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;
        }
    });
}

std::string ffmpegkittest::AudioTab::getAudioOutputFile() {
    std::string audioCodec = getSelectedAudioCodec();

    std::string extension;
    if (audioCodec.compare("mp2 (twolame)") == 0) {
        extension = "mpg";
    } else if (audioCodec.compare("mp3 (liblame)") == 0 || audioCodec.compare("mp3 (libshine)") == 0) {
        extension = "mp3";
    } else if (audioCodec.compare("vorbis") == 0) {
        extension = "ogg";
    } else if (audioCodec.compare("opus") == 0) {
        extension = "opus";
    } else if (audioCodec.compare("amr-nb") == 0 || audioCodec.compare("amr-wb") == 0) {
        extension = "amr";
    } else if (audioCodec.compare("ilbc") == 0) {
        extension = "lbc";
    } else if (audioCodec.compare("speex") == 0) {
        extension = "spx";
    } else if (audioCodec.compare("wavpack") == 0) {
        extension = "wv";
    } else {

        // soxr
        extension = "wav";
    }

    return Application::getApplicationCacheDirectory() + "/audio." + extension;
}

std::string ffmpegkittest::AudioTab::getAudioSampleFile() {
    return Application::getApplicationCacheDirectory() + "/audio-sample.wav";
}

void ffmpegkittest::AudioTab::showProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::AudioTab::hideProgressDialog() {
    // progressDialog.hide();
}

std::string ffmpegkittest::AudioTab::generateAudioEncodeScript() {
    auto audioCodec = getSelectedAudioCodec();
    auto audioSampleFile = getAudioSampleFile();
    auto audioOutputFile = getAudioOutputFile();

    if (audioCodec.compare("mp2 (twolame)") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a mp2 -b:a 192k " + audioOutputFile;
    } else if (audioCodec.compare("mp3 (liblame)") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a libmp3lame -qscale:a 2 " + audioOutputFile;
    } else if (audioCodec.compare("mp3 (libshine)") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a libshine -qscale:a 2 " + audioOutputFile;
    } else if (audioCodec.compare("vorbis") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a libvorbis -b:a 64k " + audioOutputFile;
    } else if (audioCodec.compare("opus") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a libopus -b:a 64k -vbr on -compression_level 10 " + audioOutputFile;
    } else if (audioCodec.compare("amr-nb") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -ar 8000 -ab 12.2k -c:a libopencore_amrnb " + audioOutputFile;
    } else if (audioCodec.compare("amr-wb") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -ar 8000 -ab 12.2k -c:a libvo_amrwbenc -strict experimental " + audioOutputFile;
    } else if (audioCodec.compare("ilbc") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a ilbc -ar 8000 -b:a 15200 " + audioOutputFile;
    } else if (audioCodec.compare("speex") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a libspeex -ar 16000 " + audioOutputFile;
    } else if (audioCodec.compare("wavpack") == 0) {
        return "-hide_banner -y -i " + audioSampleFile + " -c:a wavpack -b:a 64k " + audioOutputFile;
    } else {

        // soxr
        return "-hide_banner -y -i " + audioSampleFile + " -af aresample=resampler=soxr -ar 44100 " + audioOutputFile;
    }
}
