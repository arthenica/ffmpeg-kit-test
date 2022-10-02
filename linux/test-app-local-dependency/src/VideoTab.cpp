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

#include "VideoTab.h"
#include "Application.h"
#include "Constants.h"
#include "Log.h"
#include "Popup.h"
#include "Statistics.h"
#include "Video.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>
#include <sys/stat.h>

using namespace ffmpegkit;

static gboolean showEncodeFailedPopup(Gtk::Window* window) {
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, "Encode failed. Please check logs for the details.");
    return FALSE;
}

static gboolean saveStatistics(const std::pair<ffmpegkittest::VideoTab*,const std::shared_ptr<Statistics>>* parameters) {
    ffmpegkittest::VideoTab* videoTab = parameters->first;
    auto statistics = parameters->second;
    videoTab->updateProgressDialog(statistics);
    delete parameters;
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::VideoTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::VideoTab* videoTab = parameters->first;
    auto log = parameters->second;
    videoTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

ffmpegkittest::VideoTab::VideoTab() : selectedCodec(-1), statistics(nullptr) {
    videoCodecModel = Gtk::ListStore::create(videoCodecModelColumn);
    videoCodec.set_model(videoCodecModel);
    videoCodec.set_size_request(240, 30);
    videoCodec.signal_changed().connect(sigc::mem_fun(*this, &VideoTab::onVideoCodecChanged));
    Util::applyComboBoxStyle(videoCodec);

    initVideoCodecData();

    encodeButton.set_label("ENCODE");
    encodeButton.set_size_request(120, 30);
    encodeButton.set_tooltip_text(Constants::VideoTestTooltipText);
    encodeButton.signal_clicked().connect(sigc::mem_fun(*this, &VideoTab::encodeVideo));
    Util::applyButtonStyle(encodeButton);
    encodeButtonBox.pack_start(encodeButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(videoCodecBox, Gtk::PACK_SHRINK);
    pack_start(encodeButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::VideoTab::setActive() {
    std::cout << "Video Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback(nullptr);
    FFmpegKitConfig::enableStatisticsCallback(nullptr);
}

void ffmpegkittest::VideoTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::VideoTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::VideoTab::updateProgressDialog(const std::shared_ptr<ffmpegkit::Statistics> statistics) {
    if (statistics == nullptr || statistics->getTime() < 0) {
        return;
    }

    this->statistics = statistics;
    int timeInMilliseconds = this->statistics->getTime();
    int totalVideoDuration = 9000;
    double completePercentage = timeInMilliseconds*100/totalVideoDuration;
    // progressDialog.update(completePercentage);
    std::cout << "Encoding completed " << completePercentage << "%" << std::endl;
}

void ffmpegkittest::VideoTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::VideoTab::initVideoCodecData() {
    auto row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "1";
    row[videoCodecModelColumn.columnName] = "mpeg4";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "2";
    row[videoCodecModelColumn.columnName] = "x264";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "3";
    row[videoCodecModelColumn.columnName] = "openh264";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "4";
    row[videoCodecModelColumn.columnName] = "x265";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "5";
    row[videoCodecModelColumn.columnName] = "xvid";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "6";
    row[videoCodecModelColumn.columnName] = "vp8";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "7";
    row[videoCodecModelColumn.columnName] = "vp9";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "8";
    row[videoCodecModelColumn.columnName] = "aom";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "9";
    row[videoCodecModelColumn.columnName] = "kvazaar";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "10";
    row[videoCodecModelColumn.columnName] = "theora";

    row = *(videoCodecModel->append());
    row[videoCodecModelColumn.columnId] = "11";
    row[videoCodecModelColumn.columnName] = "hap";

    videoCodec.pack_start(videoCodecModelColumn.columnName);
    videoCodec.set_entry_text_column(videoCodecModelColumn.columnId);
    videoCodec.set_active(0);

    videoCodecBox.pack_start(videoCodec, Gtk::PACK_EXPAND_PADDING);
}

void ffmpegkittest::VideoTab::onVideoCodecChanged() {
    int rowNumber = videoCodec.get_active_row_number();
    if (rowNumber != -1) {
        selectedCodec = rowNumber;
    }
}

std::string ffmpegkittest::VideoTab::getSelectedVideoCodec() {
    switch(selectedCodec) {
        case 0: return "mpeg4";
        case 1: return "libx264";
        case 2: return "libopenh264";
        case 3: return "libx265";
        case 4: return "libxvid";
        case 5: return "vp8";
        case 6: return "vp9";
        case 7: return "libaom-av1";
        case 8: return "libkvazaar";
        case 9: return "theora";
        case 10: return "hap";
        default: return "";
    }
}

void ffmpegkittest::VideoTab::encodeVideo() {
    clearOutput();

    std::string image1File = Application::getApplicationInstallDirectory() + "/share/images/machupicchu.jpg";
    std::string image2File = Application::getApplicationInstallDirectory() + "/share/images/pyramid.jpg";
    std::string image3File = Application::getApplicationInstallDirectory() + "/share/images/stonehenge.jpg";
    std::string videoFile = getVideoFile();

    std::remove(videoFile.c_str());

    std::string videoCodec = this->getSelectedVideoCodec();

    std::cout << "Testing VIDEO encoding with '" << videoCodec << "' codec" << std::endl;

    showProgressDialog();

    std::string ffmpegCommand = Video::generateEncodeVideoScript(image1File, image2File, image3File, videoFile, getSelectedVideoCodec(), getPixelFormat(), getCustomOptions());

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::executeAsync(ffmpegCommand, [this](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();

        this->hideProgressDialog();

        if (ReturnCode::isSuccess(returnCode)) {
            std::cout << "Encode completed successfully in " << session->getDuration() << " milliseconds." << std::endl;
        } else {
            g_idle_add((GSourceFunc)showEncodeFailedPopup, this->parentWindow);
            std::cout << "Encode failed with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;
        }
    }, [this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<VideoTab*,const std::shared_ptr<Log>>(this, log));
    }, [this](auto statistics) {
        g_idle_add((GSourceFunc)saveStatistics, new std::pair<VideoTab*,const std::shared_ptr<Statistics>>(this, statistics));
    });

    std::cout << "Async FFmpeg process started with sessionId " << session->getSessionId() << "." << std::endl;
}

std::string ffmpegkittest::VideoTab::getPixelFormat() {
    std::string videoCodec = this->getSelectedVideoCodec();

    std::string pixelFormat;
    if (videoCodec.compare("libx265") == 0) {
        pixelFormat = "yuv420p10le";
    } else {
        pixelFormat = "yuv420p";
    }

    return pixelFormat;
}

std::string ffmpegkittest::VideoTab::getVideoFile() {
    std::string videoCodec = this->getSelectedVideoCodec();

    std::string extension;
    if (videoCodec.compare("vp8") == 0 || videoCodec.compare("vp9") == 0) {
        extension = "webm";
    } else if (videoCodec.compare("libaom-av1") == 0) {
        extension = "mkv";
    } else if (videoCodec.compare("theora") == 0) {
        extension = "ogv";
    } else if (videoCodec.compare("hap") == 0) {
        extension = "mov";
    } else {

        // mpeg4, libx264, libx265, libxvid, kvazaar, libopenh264
        extension = "mp4";
    }

    return Application::getApplicationCacheDirectory() + "/video." + extension;
}

std::string ffmpegkittest::VideoTab::getCustomOptions() {
    std::string videoCodec = this->getSelectedVideoCodec();

    if (videoCodec.compare("libx265") == 0) {
        return "-crf 28 -preset fast ";
    } else if (videoCodec.compare("vp8") == 0) {
        return "-b:v 1M -crf 10 ";
    } else if (videoCodec.compare("vp9") == 0) {
        return "-b:v 2M ";
    } else if (videoCodec.compare("libaom-av1") == 0) {
        return "-crf 30 -strict experimental ";
    } else if (videoCodec.compare("theora") == 0) {
        return "-qscale:v 7 ";
    } else if (videoCodec.compare("hap") == 0) {
        return "-format hap_q ";
    } else {

        // kvazaar, mpeg4, libx264, libxvid, libopenh264
        return "";
    }
}

void ffmpegkittest::VideoTab::showProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::VideoTab::hideProgressDialog() {
    // progressDialog.hide();
}
