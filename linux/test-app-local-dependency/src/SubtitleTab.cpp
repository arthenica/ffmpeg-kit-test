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

#include "SubtitleTab.h"
#include "Application.h"
#include "Constants.h"
#include "Log.h"
#include "Popup.h"
#include "Statistics.h"
#include "Video.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>

using namespace ffmpegkit;

enum State {
    StateIdle,
    StateCreating,
    StateBurning
};

static State state = StateIdle;

static long sessionId = -1;

static gboolean showBurningCancelledPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_INFO, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean showBurningFailedPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean saveStatistics(const std::pair<ffmpegkittest::SubtitleTab*,const std::shared_ptr<Statistics>>* parameters) {
    ffmpegkittest::SubtitleTab* subtitleTab = parameters->first;
    auto statistics = parameters->second;
    subtitleTab->updateProgressDialog(statistics);
    delete parameters;
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::SubtitleTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::SubtitleTab* videoTab = parameters->first;
    auto log = parameters->second;
    videoTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

ffmpegkittest::SubtitleTab::SubtitleTab() : statistics(nullptr) {
    encodeButton.set_label("BURN SUBTITLES");
    encodeButton.set_size_request(120, 30);
    encodeButton.set_tooltip_text(Constants::SubtitleTestEncodeTooltipText);
    encodeButton.signal_clicked().connect(sigc::mem_fun(*this, &SubtitleTab::burnSubtitles));
    Util::applyButtonStyle(encodeButton);
    cancelButton.set_label("CANCEL");
    cancelButton.set_size_request(120, 30);
    cancelButton.set_tooltip_text(Constants::SubtitleTestCancelTooltipText);
    cancelButton.signal_clicked().connect(sigc::mem_fun(*this, &SubtitleTab::cancel));
    Util::applyButtonStyle(cancelButton);
    buttonBox.pack_start(encodeButton, Gtk::PACK_EXPAND_PADDING);
    buttonBox.pack_start(cancelButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(buttonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);

    state = StateIdle;
}

void ffmpegkittest::SubtitleTab::setActive() {
    std::cout << "Subtitle Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback([this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<SubtitleTab*,const std::shared_ptr<Log>>(this, log));
    });
    FFmpegKitConfig::enableStatisticsCallback([this](auto statistics) {
        g_idle_add((GSourceFunc)saveStatistics, new std::pair<SubtitleTab*,const std::shared_ptr<Statistics>>(this, statistics));
    });
}

void ffmpegkittest::SubtitleTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::SubtitleTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::SubtitleTab::updateProgressDialog(const std::shared_ptr<ffmpegkit::Statistics> statistics) {
    if (statistics == nullptr || statistics->getTime() < 0) {
        return;
    }

    this->statistics = statistics;
    int timeInMilliseconds = this->statistics->getTime();
    int totalVideoDuration = 9000;
    double completePercentage = timeInMilliseconds*100/totalVideoDuration;
    // progressDialog.update(completePercentage);
    if (state == StateCreating) {
        std::cout << "Creating video: " << completePercentage << "%" << std::endl;
    } else if (state == StateBurning) {
        std::cout << "Burning subtitles: " << completePercentage << "%" << std::endl;
    }
}

void ffmpegkittest::SubtitleTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::SubtitleTab::burnSubtitles() {
    clearOutput();

    std::string image1File = Application::getApplicationInstallDirectory() + "/share/images/machupicchu.jpg";
    std::string image2File = Application::getApplicationInstallDirectory() + "/share/images/pyramid.jpg";
    std::string image3File = Application::getApplicationInstallDirectory() + "/share/images/stonehenge.jpg";
    std::string videoFile = getVideoFile();
    std::string videoWithSubtitlesFile = getVideoWithSubtitlesFile();

    std::cout << "Testing SUBTITLE burning." << std::endl;

    showCreateProgressDialog();

    std::string ffmpegCommand = Video::generateEncodeVideoScript(image1File, image2File, image3File, videoFile, "mpeg4", "");

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    state = StateCreating;

    sessionId = FFmpegKit::executeAsync(ffmpegCommand, [this, videoFile, videoWithSubtitlesFile](auto session) {
        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;

        this->hideCreateProgressDialog();

        if (ReturnCode::isSuccess(session->getReturnCode())) {
            std::cout << "Create completed successfully; burning subtitles." << std::endl;

            std::string burnSubtitlesCommand = "-y -i " + videoFile + " -vf subtitles=" + getSubtitleFile() + ":force_style='FontName=MyFontName' -c:v mpeg4 " + videoWithSubtitlesFile;

            this->showBurnProgressDialog();

            std::cout << "FFmpeg process started with arguments: '" << burnSubtitlesCommand << "'." << std::endl;

            state = StateBurning;

            FFmpegKit::executeAsync(burnSubtitlesCommand, [this](auto secondSession) {

                hideBurnProgressDialog();

                if (ReturnCode::isSuccess(secondSession->getReturnCode())) {
                    std::cout << "Burn subtitles completed successfully." << std::endl;
                } else if (ReturnCode::isCancel(secondSession->getReturnCode())) {
                    g_idle_add((GSourceFunc)showBurningCancelledPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Burn subtitles operation cancelled."));
                    std::cout << "Burn subtitles operation cancelled." << std::endl;
                } else {
                    g_idle_add((GSourceFunc)showBurningFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Burn subtitles failed. Please check logs for the details."));
                    std::cout << "Burn subtitles failed with state " << FFmpegKitConfig::sessionStateToString(secondSession->getState()) << " and rc " << secondSession->getReturnCode() << "." << secondSession->getFailStackTrace() << std::endl;
                }
            });
        }
    })->getSessionId();

    std::cout << "Async FFmpeg process started with sessionId " << sessionId << "." << std::endl;
}

void ffmpegkittest::SubtitleTab::cancel() {
    if (sessionId > -1) {
        std::cout << "Cancelling FFmpeg execution with sessionId " << sessionId << "." << std::endl;
        FFmpegKit::cancel(sessionId);
    }
}

std::string ffmpegkittest::SubtitleTab::getSubtitleFile() {
    return Application::getApplicationInstallDirectory() + "/share/subtitles/subtitle.srt";
}

std::string ffmpegkittest::SubtitleTab::getVideoFile() {
    return Application::getApplicationCacheDirectory() + "/video.mp4";
}

std::string ffmpegkittest::SubtitleTab::getVideoWithSubtitlesFile() {
    return Application::getApplicationCacheDirectory() + "/video-with-subtitles.mp4";
}

void ffmpegkittest::SubtitleTab::showCreateProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::SubtitleTab::hideCreateProgressDialog() {
    // progressDialog.hide();
}

void ffmpegkittest::SubtitleTab::showBurnProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::SubtitleTab::hideBurnProgressDialog() {
    // progressDialog.hide();
}
