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

#include "OtherTab.h"
#include "Application.h"
#include "Constants.h"
#include "Popup.h"
#include "Video.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>

using namespace ffmpegkit;

static gboolean showTestSuccessPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_INFO, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean showTestFailedPopup(const std::pair<Gtk::Window*,const std::string>* parameters) {
    Gtk::Window* window = parameters->first;
    auto messageDetail = parameters->second;
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, messageDetail);
    delete parameters;
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::OtherTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::OtherTab* otherTab = parameters->first;
    auto log = parameters->second;
    otherTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

ffmpegkittest::OtherTab::OtherTab() : selectedTest(-1) {
    testModel = Gtk::ListStore::create(testModelColumn);
    test.set_model(testModel);
    test.set_size_request(240, 30);
    test.signal_changed().connect(sigc::mem_fun(*this, &OtherTab::onTestChanged));
    Util::applyComboBoxStyle(test);

    initTestData();

    runButton.set_label("RUN");
    runButton.set_size_request(120, 30);
    runButton.set_tooltip_text(Constants::OtherTestTooltipText);
    runButton.signal_clicked().connect(sigc::mem_fun(*this, &OtherTab::runTest));
    Util::applyButtonStyle(runButton);
    runButtonBox.pack_start(runButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(testBox, Gtk::PACK_SHRINK);
    pack_start(runButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::OtherTab::setActive() {
    std::cout << "Other Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback(nullptr);
    FFmpegKitConfig::enableStatisticsCallback(nullptr);
}

void ffmpegkittest::OtherTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::OtherTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::OtherTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::OtherTab::initTestData() {
    auto row = *(testModel->append());
    row[testModelColumn.columnId] = "1";
    row[testModelColumn.columnName] = "chromaprint";

    row = *(testModel->append());
    row[testModelColumn.columnId] = "2";
    row[testModelColumn.columnName] = "dav1d";

    row = *(testModel->append());
    row[testModelColumn.columnId] = "3";
    row[testModelColumn.columnName] = "webp";

    row = *(testModel->append());
    row[testModelColumn.columnId] = "4";
    row[testModelColumn.columnName] = "zscale";

    test.pack_start(testModelColumn.columnName);
    test.set_entry_text_column(testModelColumn.columnId);
    test.set_active(0);

    testBox.pack_start(test, Gtk::PACK_EXPAND_PADDING);
}

void ffmpegkittest::OtherTab::onTestChanged() {
    int rowNumber = test.get_active_row_number();
    if (rowNumber != -1) {
        selectedTest = rowNumber;
    }
}

std::string ffmpegkittest::OtherTab::getSelectedTest() {
    switch(selectedTest) {
        case 0: return "chromaprint";
        case 1: return "dav1d";
        case 2: return "webp";
        case 3: return "zscale";
        default: return "";
    }
}

void ffmpegkittest::OtherTab::runTest() {
    clearOutput();

    std::string selectedTest = this->getSelectedTest();
    if (selectedTest.compare("chromaprint") == 0) {
        testChromaprint();
    } else if (selectedTest.compare("dav1d") == 0) {
        testDav1d();
    } else if (selectedTest.compare("webp") == 0) {
        testWebp();
    } else if (selectedTest.compare("zscale") == 0) {
        testZscale();
    }
}

void ffmpegkittest::OtherTab::testChromaprint() {
    std::cout << "Testing 'chromaprint' mutex." << std::endl;

    std::string audioSampleFile = getChromaprintSampleFile();
    std::remove(audioSampleFile.c_str());

    std::string ffmpegCommand = "-hide_banner -y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le " + audioSampleFile;

    std::cout << "Creating audio sample with '" << ffmpegCommand << "'." << std::endl;

    FFmpegKit::executeAsync(ffmpegCommand, [this,audioSampleFile](auto session) {
        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;

        if (ReturnCode::isSuccess(session->getReturnCode())) {
            std::cout << "AUDIO sample created." << std::endl;

            std::string chromaprintCommand = "-hide_banner -y -i " + audioSampleFile + " -f chromaprint -fp_format 2 " + getChromaprintOutputFile();

            std::cout << "FFmpeg process started with arguments: '" << chromaprintCommand << "'." << std::endl;

            FFmpegKit::executeAsync(chromaprintCommand, [this](auto secondSession) {
                std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(secondSession->getState()) << " and rc " << secondSession->getReturnCode() << "." << secondSession->getFailStackTrace() << std::endl;
                if (ReturnCode::isSuccess(secondSession->getReturnCode())) {
                    g_idle_add((GSourceFunc)showTestSuccessPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Testing chromaprint completed successfully."));
                } else {
                    g_idle_add((GSourceFunc)showTestFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Testing chromaprint failed. Please check logs for the details."));
                }
            }, [this](auto log) {
                g_idle_add((GSourceFunc)appendLog, new std::pair<OtherTab*,const std::shared_ptr<Log>>(this, log));
            }, nullptr);

        } else {
            g_idle_add((GSourceFunc)showTestFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Creating AUDIO sample failed. Please check logs for the details."));
        }
    });
}

void ffmpegkittest::OtherTab::testDav1d() {
    std::cout << "Testing decoding 'av1' codec." << std::endl;

    std::string ffmpegCommand = std::string("-hide_banner -y -i ") + Dav1dTestDefaultUrl + " " + getDav1dOutputFile();

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    FFmpegKit::executeAsync(ffmpegCommand, [this](auto session) {
        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;
    }, [this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<OtherTab*,const std::shared_ptr<Log>>(this, log));
    }, nullptr);
}

void ffmpegkittest::OtherTab::testWebp() {
    std::string imageFile = Application::getApplicationInstallDirectory() + "/share/images/machupicchu.jpg";
    std::string outputFile = Application::getApplicationCacheDirectory() + "/video.webp";

    std::cout << "Testing 'webp' codec." << std::endl;

    std::string ffmpegCommand = "-hide_banner -y -i " + imageFile + " " + outputFile;

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::executeAsync(ffmpegCommand, [this](auto session) {
        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;

        if (ReturnCode::isSuccess(session->getReturnCode())) {
            g_idle_add((GSourceFunc)showTestSuccessPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Encode webp completed successfully."));
        } else {
            g_idle_add((GSourceFunc)showTestFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "Encode webp failed. Please check logs for the details."));
        }
    }, [this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<OtherTab*,const std::shared_ptr<Log>>(this, log));
    }, nullptr);
}

void ffmpegkittest::OtherTab::testZscale() {
    std::string videoFile = Application::getApplicationCacheDirectory() + "/video.mp4";
    std::string zscaledVideoFile = Application::getApplicationCacheDirectory() + "/video-zscaled.mp4";

    std::cout << "Testing 'zscale' filter with video file created on the Video tab." << std::endl;

    std::string ffmpegCommand = Video::generateZscaleVideoScript(videoFile, zscaledVideoFile);

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::executeAsync(ffmpegCommand, [this](auto session) {
        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(session->getState()) << " and rc " << session->getReturnCode() << "." << session->getFailStackTrace() << std::endl;

        if (ReturnCode::isSuccess(session->getReturnCode())) {
            g_idle_add((GSourceFunc)showTestSuccessPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "zscale completed successfully."));
        } else {
            g_idle_add((GSourceFunc)showTestFailedPopup, new std::pair<Gtk::Window*,const std::string>(this->parentWindow, "zscale failed. Please check logs for the details."));
        }
    }, [this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<OtherTab*,const std::shared_ptr<Log>>(this, log));
    }, nullptr);
}

std::string ffmpegkittest::OtherTab::getChromaprintSampleFile() {
    return Application::getApplicationCacheDirectory() + "/audio-sample.wav";
}

std::string ffmpegkittest::OtherTab::getDav1dOutputFile() {
    return Application::getApplicationCacheDirectory() + "/video.mp4";
}

std::string ffmpegkittest::OtherTab::getChromaprintOutputFile() {
    return Application::getApplicationCacheDirectory() + "/chromaprint.txt";
}
