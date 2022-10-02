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

#include "ConcurrentExecutionTab.h"
#include "Application.h"
#include "Constants.h"
#include "Log.h"
#include "Popup.h"
#include "Video.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>

using namespace ffmpegkit;

static long sessionId1 = -1;
static long sessionId2 = -1;
static long sessionId3 = -1;

static gboolean appendLog(const std::pair<ffmpegkittest::ConcurrentExecutionTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::ConcurrentExecutionTab* concurrentExecutionTab = parameters->first;
    auto log = parameters->second;
    concurrentExecutionTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

ffmpegkittest::ConcurrentExecutionTab::ConcurrentExecutionTab() {
    encodeButton1.set_label("ENCODE 1");
    encodeButton1.set_size_request(120, 30);
    encodeButton1.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    encodeButton1.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::encodeVideo), 1));
    Util::applyButtonStyle(encodeButton1);
    encodeButtonBox.pack_start(encodeButton1, Gtk::PACK_EXPAND_PADDING);
    encodeButton2.set_label("ENCODE 2");
    encodeButton2.set_size_request(120, 30);
    encodeButton2.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    encodeButton2.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::encodeVideo), 2));
    Util::applyButtonStyle(encodeButton2);
    encodeButtonBox.pack_start(encodeButton2, Gtk::PACK_EXPAND_PADDING);
    encodeButton3.set_label("ENCODE 3");
    encodeButton3.set_size_request(120, 30);
    encodeButton3.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    encodeButton3.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::encodeVideo), 3));
    Util::applyButtonStyle(encodeButton3);
    encodeButtonBox.pack_start(encodeButton3, Gtk::PACK_EXPAND_PADDING);

    cancelButton1.set_label("CANCEL 1");
    cancelButton1.set_size_request(120, 30);
    cancelButton1.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    cancelButton1.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::cancel), 1));
    Util::applyButtonStyle(cancelButton1);
    cancelButtonBox.pack_start(cancelButton1, Gtk::PACK_EXPAND_PADDING);
    cancelButton2.set_label("CANCEL 2");
    cancelButton2.set_size_request(120, 30);
    cancelButton2.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    cancelButton2.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::cancel), 2));
    Util::applyButtonStyle(cancelButton2);
    cancelButtonBox.pack_start(cancelButton2, Gtk::PACK_EXPAND_PADDING);
    cancelButton3.set_label("CANCEL 3");
    cancelButton3.set_size_request(120, 30);
    cancelButton3.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    cancelButton3.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::cancel), 3));
    Util::applyButtonStyle(cancelButton3);
    cancelButtonBox.pack_start(cancelButton3, Gtk::PACK_EXPAND_PADDING);
    cancelButton4.set_label("CANCEL ALL");
    cancelButton4.set_size_request(120, 30);
    cancelButton4.set_tooltip_text(Constants::ConcurrentExecutionTestTooltipText);
    cancelButton4.signal_clicked().connect(sigc::bind(sigc::mem_fun(*this, &ConcurrentExecutionTab::cancel), 0));
    Util::applyButtonStyle(cancelButton4);
    cancelButtonBox.pack_start(cancelButton4, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(encodeButtonBox, Gtk::PACK_SHRINK);
    pack_start(cancelButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::ConcurrentExecutionTab::setActive() {
    std::cout << "Concurrent Execution Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback([this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<ConcurrentExecutionTab*,const std::shared_ptr<Log>>(this, log));
    });
}

void ffmpegkittest::ConcurrentExecutionTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::ConcurrentExecutionTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::ConcurrentExecutionTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}

void ffmpegkittest::ConcurrentExecutionTab::encodeVideo(const int buttonNumber) {
    clearOutput();

    std::string image1File = Application::getApplicationInstallDirectory() + "/share/images/machupicchu.jpg";
    std::string image2File = Application::getApplicationInstallDirectory() + "/share/images/pyramid.jpg";
    std::string image3File = Application::getApplicationInstallDirectory() + "/share/images/stonehenge.jpg";
    std::string videoFile = Application::getApplicationCacheDirectory() + "/video" + std::to_string(buttonNumber) + ".mp4";

    std::cout << "Testing CONCURRENT EXECUTION for button " << buttonNumber << "." << std::endl;

    std::string ffmpegCommand = Video::generateEncodeVideoScript(image1File, image2File, image3File, videoFile, "mpeg4", "");

    std::cout << "FFmpeg process starting for button " << buttonNumber << " with arguments: '" << ffmpegCommand << "'." << std::endl;

    auto session = FFmpegKit::executeAsync(ffmpegCommand, [this, buttonNumber](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();

        if (ReturnCode::isCancel(returnCode)) {
            std::cout << "FFmpeg process ended with cancel for button " << buttonNumber << " with sessionId " << session->getSessionId() << "." << std::endl;
        } else {
            std::cout << "FFmpeg process ended with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << " for button " << buttonNumber << " with sessionId " << session->getSessionId() << "." << session->getFailStackTrace() << std::endl;
        }
    });

    const long sessionId = session->getSessionId();

    std::cout << "Async FFmpeg process started for button " << buttonNumber << " with sessionId " << session->getSessionId() << "." << std::endl;

    switch (buttonNumber) {
        case 1: {
            sessionId1 = sessionId;
        }
        break;
        case 2: {
            sessionId2 = sessionId;
        }
        break;
        default: {
            sessionId3 = sessionId;
        }
    }

    Application::listFFmpegSessions();
}

void ffmpegkittest::ConcurrentExecutionTab::cancel(const int buttonNumber) {
    long sessionId = 0;

    switch (buttonNumber) {
        case 1: {
            sessionId = sessionId1;
        }
        break;
        case 2: {
            sessionId = sessionId2;
        }
        break;
        case 3: {
            sessionId = sessionId3;
        }
    }

    std::cout << "Cancelling FFmpeg process for button " << buttonNumber << " with sessionId " << sessionId << "." << std::endl;

    if (sessionId == 0) {
        FFmpegKit::cancel();
    } else {
        FFmpegKit::cancel(sessionId);
    }
}
