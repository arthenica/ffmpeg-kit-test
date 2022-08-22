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

#include "PipeTab.h"
#include "Application.h"
#include "Constants.h"
#include "Log.h"
#include "Popup.h"
#include "Statistics.h"
#include "Video.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>
#include <thread>

using namespace ffmpegkit;

static gboolean showCreateFailedPopup(Gtk::Window* window) {
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, "Create failed. Please check logs for the details.");
    return FALSE;
}

static gboolean saveStatistics(const std::pair<ffmpegkittest::PipeTab*,const std::shared_ptr<Statistics>>* parameters) {
    ffmpegkittest::PipeTab* videoTab = parameters->first;
    auto statistics = parameters->second;
    videoTab->updateProgressDialog(statistics);
    delete parameters;
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::PipeTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::PipeTab* videoTab = parameters->first;
    auto log = parameters->second;
    videoTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

static void startAsyncCatImageProcess(std::string imagePath, std::shared_ptr<std::string> namedPipePath) {
    auto thread = std::thread([imagePath,namedPipePath]() {
        std::string asyncCommand = "cat " + imagePath + " > " + *namedPipePath;

        std::cout << "Starting async cat image command: " << asyncCommand << std::endl;

        int rc = system(asyncCommand.c_str());

        std::cout << "Async cat image command: " << asyncCommand << " exited with " << rc << "." << std::endl;
    });
    thread.detach();
}

ffmpegkittest::PipeTab::PipeTab() : statistics(nullptr) {
    createButton.set_label("CREATE");
    createButton.set_size_request(120, 30);
    createButton.set_tooltip_text(Constants::PipeTestTooltipText);
    createButton.signal_clicked().connect(sigc::mem_fun(*this, &PipeTab::createVideo));
    Util::applyButtonStyle(createButton);
    createButtonBox.pack_start(createButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(createButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::PipeTab::setActive() {
    std::cout << "Pipe Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback([this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<PipeTab*,const std::shared_ptr<Log>>(this, log));
    });
    FFmpegKitConfig::enableStatisticsCallback([this](auto statistics) {
        g_idle_add((GSourceFunc)saveStatistics, new std::pair<PipeTab*,const std::shared_ptr<Statistics>>(this, statistics));
    });
}

void ffmpegkittest::PipeTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::PipeTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::PipeTab::updateProgressDialog(const std::shared_ptr<ffmpegkit::Statistics> statistics) {
    if (statistics == nullptr || statistics->getTime() < 0) {
        return;
    }

    this->statistics = statistics;
    int timeInMilliseconds = this->statistics->getTime();
    int totalVideoDuration = 9000;
    double completePercentage = timeInMilliseconds*100/totalVideoDuration;
    // progressDialog.update(completePercentage);
    std::cout << "Creating video: " << completePercentage << "%" << std::endl;
}

void ffmpegkittest::PipeTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::PipeTab::createVideo() {
    clearOutput();

    std::string image1File = Application::getApplicationInstallDirectory() + "/share/images/machupicchu.jpg";
    std::string image2File = Application::getApplicationInstallDirectory() + "/share/images/pyramid.jpg";
    std::string image3File = Application::getApplicationInstallDirectory() + "/share/images/stonehenge.jpg";
    std::string videoFile = getVideoFile();

    auto pipe1 = FFmpegKitConfig::registerNewFFmpegPipe();
    auto pipe2 = FFmpegKitConfig::registerNewFFmpegPipe();
    auto pipe3 = FFmpegKitConfig::registerNewFFmpegPipe();

    std::remove(videoFile.c_str());

    std::cout << "Testing PIPE with 'mpeg4' codec" << std::endl;

    showProgressDialog();

    std::string ffmpegCommand = Video::generateCreateVideoWithPipesScript(*pipe1, *pipe2, *pipe3, videoFile);

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::executeAsync(ffmpegCommand, [this,pipe1,pipe2,pipe3](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();

        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;

        this->hideProgressDialog();

        // CLOSE PIPES
        FFmpegKitConfig::closeFFmpegPipe(pipe1->c_str());
        FFmpegKitConfig::closeFFmpegPipe(pipe2->c_str());
        FFmpegKitConfig::closeFFmpegPipe(pipe3->c_str());

        if (ReturnCode::isSuccess(returnCode)) {
            std::cout << "Create completed successfully." << std::endl;
        } else {
            g_idle_add((GSourceFunc)showCreateFailedPopup, this->parentWindow);
        }
    }, [this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<PipeTab*,const std::shared_ptr<Log>>(this, log));
    }, [this](auto statistics) {
        g_idle_add((GSourceFunc)saveStatistics, new std::pair<PipeTab*,const std::shared_ptr<Statistics>>(this, statistics));
    });

    // START ASYNC PROCESSES AFTER INITIATING FFMPEG COMMAND
    startAsyncCatImageProcess(image1File, pipe1);
    startAsyncCatImageProcess(image2File, pipe2);
    startAsyncCatImageProcess(image3File, pipe3);
}

std::string ffmpegkittest::PipeTab::getVideoFile() {
    return Application::getApplicationCacheDirectory() + "/video.mp4";
}

void ffmpegkittest::PipeTab::showProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::PipeTab::hideProgressDialog() {
    // progressDialog.hide();
}
