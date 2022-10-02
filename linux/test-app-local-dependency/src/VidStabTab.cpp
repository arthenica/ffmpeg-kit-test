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

#include "VidStabTab.h"
#include "Application.h"
#include "Constants.h"
#include "Log.h"
#include "Popup.h"
#include "Video.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>

using namespace ffmpegkit;

static gboolean showStabilizeFailedPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::VidStabTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::VidStabTab* videoTab = parameters->first;
    auto log = parameters->second;
    videoTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

ffmpegkittest::VidStabTab::VidStabTab() {
    stabilizeVideoButton.set_label("STABILIZE VIDEO");
    stabilizeVideoButton.set_size_request(120, 30);
    stabilizeVideoButton.set_tooltip_text(Constants::VidStabTestTooltipText);
    stabilizeVideoButton.signal_clicked().connect(sigc::mem_fun(*this, &VidStabTab::stabilizeVideo));
    Util::applyButtonStyle(stabilizeVideoButton);
    stabilizeVideoButtonBox.pack_start(stabilizeVideoButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(stabilizeVideoButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::VidStabTab::setActive() {
    std::cout << "VidStab Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback([this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<VidStabTab*,const std::shared_ptr<Log>>(this, log));
    });
    FFmpegKitConfig::enableStatisticsCallback(nullptr);
}

void ffmpegkittest::VidStabTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::VidStabTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::VidStabTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::VidStabTab::stabilizeVideo() {
    clearOutput();

    std::string image1File = Application::getApplicationInstallDirectory() + "/share/images/machupicchu.jpg";
    std::string image2File = Application::getApplicationInstallDirectory() + "/share/images/pyramid.jpg";
    std::string image3File = Application::getApplicationInstallDirectory() + "/share/images/stonehenge.jpg";
    std::string shakeResultsFile = getShakeResultsFile();
    std::string videoFile = getVideoFile();
    std::string stabilizedVideoFile = getStabilizedVideoFile();

    std::remove(shakeResultsFile.c_str());
    std::remove(videoFile.c_str());
    std::remove(stabilizedVideoFile.c_str());

    std::cout << "Testing VID.STAB." << std::endl;

    showCreateProgressDialog();

    std::string ffmpegCommand = Video::generateShakingVideoScript(image1File, image2File, image3File, videoFile);

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    FFmpegKit::executeAsync(ffmpegCommand, [this, videoFile, shakeResultsFile, stabilizedVideoFile](auto session) {
        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;

        this->hideCreateProgressDialog();

        if (ReturnCode::isSuccess(session->getReturnCode())) {
            std::cout << "Create completed successfully; stabilizing video." << std::endl;

            std::string analyzeVideoCommand = "-y -i " + videoFile + " -vf vidstabdetect=shakiness=10:accuracy=15:result=" + shakeResultsFile + " -f null -";

            this->showStabilizeProgressDialog();

            std::cout << "FFmpeg process started with arguments: '" << analyzeVideoCommand << "'." << std::endl;

            FFmpegKit::executeAsync(analyzeVideoCommand, [this, videoFile, shakeResultsFile, stabilizedVideoFile](auto secondSession) {
                std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(secondSession->getState()) << " and rc " << secondSession->getReturnCode() << "." << secondSession->getFailStackTrace() << std::endl;

                if (ReturnCode::isSuccess(secondSession->getReturnCode())) {
                    std::string stabilizeVideoCommand = "-y -i " + videoFile + " -vf vidstabtransform=smoothing=30:input=" + shakeResultsFile + " -c:v mpeg4 " + stabilizedVideoFile;

                    std::cout << "FFmpeg process started with arguments: '" << stabilizeVideoCommand << "'." << std::endl;

                    FFmpegKit::executeAsync(stabilizeVideoCommand, [this](auto thirdSession) {

                        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(thirdSession->getState()) << " and rc " << thirdSession->getReturnCode() << "." << thirdSession->getFailStackTrace() << std::endl;

                        this->hideStabilizeProgressDialog();

                        if (ReturnCode::isSuccess(thirdSession->getReturnCode())) {
                            std::cout << "Stabilize video completed successfully." << std::endl;
                        } else {
                            g_idle_add((GSourceFunc)showStabilizeFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Stabilize video failed. Please check logs for the details."));
                        }
                    });

                } else {
                    this->hideCreateProgressDialog();
                    g_idle_add((GSourceFunc)showStabilizeFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Stabilize video failed. Please check logs for the details."));
                }
            });
        } else {
            g_idle_add((GSourceFunc)showStabilizeFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Create video failed. Please check logs for the details."));
        }
    });
}

std::string ffmpegkittest::VidStabTab::getShakeResultsFile() {
    return Application::getApplicationCacheDirectory() + "/transforms.trf";
}

std::string ffmpegkittest::VidStabTab::getVideoFile() {
    return Application::getApplicationCacheDirectory() + "/video.mp4";
}

std::string ffmpegkittest::VidStabTab::getStabilizedVideoFile() {
    return Application::getApplicationCacheDirectory() + "/video-stabilized.mp4";
}

void ffmpegkittest::VidStabTab::showCreateProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::VidStabTab::hideCreateProgressDialog() {
    // progressDialog.hide();
}

void ffmpegkittest::VidStabTab::showStabilizeProgressDialog() {
    // progressDialog.show(this->get_parent_window());
}

void ffmpegkittest::VidStabTab::hideStabilizeProgressDialog() {
    // progressDialog.hide();
}
