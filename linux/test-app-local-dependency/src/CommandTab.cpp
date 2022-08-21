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

#include "CommandTab.h"
#include "Application.h"
#include "Constants.h"
#include "Popup.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>
#include <FFprobeSession.h>
#include <iostream>
#include <utility>

using namespace ffmpegkit;

static gboolean showCommandFailedPopup(Gtk::Window* window) {
    ffmpegkittest::Popup::show(window, Gtk::MESSAGE_ERROR, "Command failed. Please check output for the details.");
    return FALSE;
}

static gboolean appendLog(const std::pair<ffmpegkittest::CommandTab*,const std::shared_ptr<Log>>* parameters) {
    ffmpegkittest::CommandTab* commandTab = parameters->first;
    auto log = parameters->second;
    commandTab->appendOutput(log->getMessage());
    delete parameters;
    return FALSE;
}

static gboolean appendSessionOutput(const std::pair<ffmpegkittest::CommandTab*,const std::shared_ptr<FFprobeSession>>* parameters) {
    ffmpegkittest::CommandTab* commandTab = parameters->first;
    auto session = parameters->second;
    commandTab->appendOutput(session->getOutput());
    delete parameters;
    return FALSE;
}

ffmpegkittest::CommandTab::CommandTab() : parentWindow(nullptr) {
    commandText.set_placeholder_text("Enter command");
    Util::applyEditTextStyle(commandText);

    runFFmpegButton.set_label("RUN FFMPEG");
    runFFmpegButton.set_size_request(120, 30);
    runFFmpegButton.set_tooltip_text(Constants::CommandTestFFmpegTooltipText);
    runFFmpegButton.signal_clicked().connect(sigc::mem_fun(*this, &CommandTab::runFFmpeg));
    Util::applyButtonStyle(runFFmpegButton);
    runFFmpegButtonBox.pack_start(runFFmpegButton, Gtk::PACK_EXPAND_PADDING);

    runFFprobeButton.set_label("RUN FFPROBE");
    runFFprobeButton.set_size_request(120, 30);
    runFFprobeButton.set_tooltip_text(Constants::CommandTestFFprobeTooltipText);
    runFFprobeButton.signal_clicked().connect(sigc::mem_fun(*this, &CommandTab::runFFprobe));
    Util::applyButtonStyle(runFFprobeButton);
    runFFprobeButtonBox.pack_start(runFFprobeButton, Gtk::PACK_EXPAND_PADDING);

    outputText.set_editable(false);
    Util::applyOutputTextStyle(outputText);
    outputTextWindow.add(outputText);

    pack_start(commandText, Gtk::PACK_SHRINK);
    pack_start(runFFmpegButtonBox, Gtk::PACK_SHRINK);
    pack_start(runFFprobeButtonBox, Gtk::PACK_SHRINK);
    add(outputTextWindow);
}

void ffmpegkittest::CommandTab::setParentWindow(Gtk::Window* parentWindow) {
    this->parentWindow = parentWindow;
}

void ffmpegkittest::CommandTab::runFFmpeg() {
    clearOutput();

    std::string ffmpegCommand(commandText.get_text());

    std::cout << "Current log level is " << FFmpegKitConfig::logLevelToString(FFmpegKitConfig::getLogLevel()) << "." << std::endl;

    std::cout << "Testing FFmpeg COMMAND asynchronously." << std::endl;

    std::cout << "FFmpeg process started with arguments: '" << ffmpegCommand << "'" << std::endl;

    FFmpegKit::executeAsync(ffmpegCommand, [this](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();

        std::cout << "FFmpeg process exited with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;

        if (state == SessionStateFailed || !returnCode->isValueSuccess()) {
            g_idle_add((GSourceFunc)showCommandFailedPopup, this->parentWindow);
        }
    }, [this](auto log) {
        g_idle_add((GSourceFunc)appendLog, new std::pair<CommandTab*,const std::shared_ptr<Log>>(this, log));
    }, nullptr);
}

void ffmpegkittest::CommandTab::runFFprobe() {
    clearOutput();

    std::string ffprobeCommand(commandText.get_text());

    std::cout << "Testing FFprobe COMMAND asynchronously." << std::endl;

    std::cout << "FFprobe process started with arguments: '" << ffprobeCommand << "'" << std::endl;

    auto session = FFprobeSession::create(FFmpegKitConfig::parseArguments(ffprobeCommand.c_str()), [this](auto session) {
        const auto state = session->getState();
        auto returnCode = session->getReturnCode();

        g_idle_add((GSourceFunc)appendSessionOutput, new std::pair<CommandTab*,const std::shared_ptr<FFprobeSession>>(this, session));

        std::cout << "FFprobe process exited with state " << FFmpegKitConfig::sessionStateToString(state) << " and rc " << returnCode << "." << session->getFailStackTrace() << std::endl;

        if (state == SessionStateFailed || !returnCode->isValueSuccess()) {
            g_idle_add((GSourceFunc)showCommandFailedPopup, this->parentWindow);
        }

    }, nullptr, LogRedirectionStrategyNeverPrintLogs);

    FFmpegKitConfig::asyncFFprobeExecute(session);

    ffmpegkittest::Application::listFFprobeSessions();
}

void ffmpegkittest::CommandTab::setActive() {
    std::cout << "Command Tab Activated" << std::endl;
    FFmpegKitConfig::enableLogCallback(nullptr);
}

void ffmpegkittest::CommandTab::appendOutput(const std::string& string) {
    outputText.get_buffer()->set_text(outputText.get_buffer()->get_text() + string);
    Glib::RefPtr<Gtk::Adjustment> adj = outputText.get_vadjustment();
    adj->set_value(adj->get_upper());
}

void ffmpegkittest::CommandTab::clearOutput() {
    outputText.get_buffer()->set_text("");
}
