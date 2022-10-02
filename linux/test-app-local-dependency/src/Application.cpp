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

#include "Application.h"
#include <FFmpegKit.h>
#include <FFmpegKitConfig.h>
#include <FFprobeKit.h>
#include <iostream>

using namespace ffmpegkit;

static bool fs_exists(const std::string &s, const bool isFile, const bool isDirectory) {
    struct stat dir_info;

    if (stat(s.c_str(), &dir_info) == 0) {
        if (isFile && S_ISREG(dir_info.st_mode)) {
            return true;
        }
        if (isDirectory && S_ISDIR(dir_info.st_mode)) {
            return true;
        }
    }

    return false;
}

static bool fs_create_dir(const std::string& s) {
    if (!fs_exists(s, false, true)) {
        if (mkdir(s.c_str(), S_IRWXU | S_IRWXG | S_IROTH) != 0) {
            std::cout << "Failed to create directory: " << s << ". Operation failed with " << errno << "." << std::endl;
            return false;
        }
    }
    return true;
}

std::ostream& operator<<(std::ostream& out, const std::chrono::time_point<std::chrono::system_clock>& o) {
    char str[100];
    std::time_t t = std::chrono::system_clock::to_time_t(o);
    std::strftime(str, sizeof(str), "%c", std::localtime(&t));
    return out << str;
}

ffmpegkittest::Application::Application() {
    set_title("FFmpegKit Linux");
    set_default_size(800, 600);
    set_position(Gtk::WIN_POS_CENTER);

    commandTab.setParentWindow(this);
    videoTab.setParentWindow(this);
    httpsTab.setParentWindow(this);
    audioTab.setParentWindow(this);
    subtitleTab.setParentWindow(this);
    vidStabTab.setParentWindow(this);
    pipeTab.setParentWindow(this);
    concurrentExecutionTab.setParentWindow(this);
    otherTab.setParentWindow(this);
    tabs.append_page(commandTab, "Command");
    tabs.append_page(videoTab, "Video");
    tabs.append_page(httpsTab, "HTTPS");
    tabs.append_page(audioTab, "Audio");
    tabs.append_page(subtitleTab, "Subtitle");
    tabs.append_page(vidStabTab, "Vid.Stab");
    tabs.append_page(pipeTab, "Pipe");
    tabs.append_page(concurrentExecutionTab, "Concurrent Execution");
    tabs.append_page(otherTab, "Other");
    tabs.signal_switch_page().connect(sigc::mem_fun(*this, &Application::onTabSelected));

    add(tabs);

    show_all_children();

    initApplicationCacheDirectory();

    registerApplicationFonts();
    std::cout << "Application fonts registered." << std::endl;

    FFmpegKitConfig::ignoreSignal(SignalXcpu);
    FFmpegKitConfig::setLogLevel(LevelAVLogInfo);
}

void ffmpegkittest::Application::initApplicationCacheDirectory() {
    auto appCacheDir = ffmpegkittest::Application::getApplicationCacheDirectory();

    if (!fs_exists(appCacheDir, false, true)) {
        if (mkdir(appCacheDir.c_str(), S_IRWXU | S_IRWXG | S_IROTH) != 0) {
            std::cout << "Failed to create application cache directory: " << appCacheDir << ". Operation failed with " << errno << "." << std::endl;
        }
    }
}

void ffmpegkittest::Application::onTabSelected(const Widget* page, const guint page_number) {
    switch (page_number) {
    case 0:
        commandTab.setActive();
        break;
    case 1:
        videoTab.setActive();
        break;
    case 2:
        httpsTab.setActive();
        break;
    case 3:
        audioTab.setActive();
        break;
    case 4:
        subtitleTab.setActive();
        break;
    case 5:
        vidStabTab.setActive();
        break;
    case 6:
        pipeTab.setActive();
        break;
    case 7:
        concurrentExecutionTab.setActive();
        break;
    case 8:
        otherTab.setActive();
        break;        
    default:
        commandTab.setActive();
        break;
    }
}

void ffmpegkittest::Application::listFFmpegSessions() {
    auto ffmpegSessions = FFmpegKit::listSessions();
    std::cout << "Listing FFmpeg sessions." << std::endl;
    int i = 0;
    std::for_each(ffmpegSessions->begin(), ffmpegSessions->end(), [&](const std::shared_ptr<ffmpegkit::FFmpegSession> session) {
        std::cout << "Session " << i++ << " = id:" << session->getSessionId() << ", startTime:" << session->getStartTime() << ", duration:" << session-> getDuration() << ", state:" << FFmpegKitConfig::sessionStateToString(session->getState()) << ", returnCode:" << session->getReturnCode() << "." << std::endl;
    });
    std::cout << "Listed FFmpeg sessions." << std::endl;
}

void ffmpegkittest::Application::listFFprobeSessions() {
    auto ffprobeSessions = FFprobeKit::listFFprobeSessions();
    std::cout << "Listing FFprobe sessions." << std::endl;
    int i = 0;
    std::for_each(ffprobeSessions->begin(), ffprobeSessions->end(), [&](const std::shared_ptr<ffmpegkit::FFprobeSession> session) {
        std::cout << "Session " << i++ << " = id:" << session->getSessionId() << ", startTime:" << session->getStartTime() << ", duration:" << session-> getDuration() << ", state:" << FFmpegKitConfig::sessionStateToString(session->getState()) << ", returnCode:" << session->getReturnCode() << "." << std::endl;
    });
    std::cout << "Listed FFprobe sessions." << std::endl;
}

std::string ffmpegkittest::Application::getApplicationCacheDirectory() {
    return Glib::get_user_cache_dir() + "/ffmpegkittest";
}

void ffmpegkittest::Application::registerApplicationFonts() {
    auto fontDirectory = Application::getApplicationInstallDirectory() + "/share/fonts";
    auto reportFile = Application::getApplicationCacheDirectory() + "/ffreport.txt";

    FFmpegKitConfig::setFontDirectoryList(std::list<std::string>{fontDirectory, "/usr/share/fonts"}, std::map<std::string,std::string>{{"MyFontName", "Doppio One"}});
    FFmpegKitConfig::setEnvironmentVariable("FFREPORT", reportFile.c_str());
}
