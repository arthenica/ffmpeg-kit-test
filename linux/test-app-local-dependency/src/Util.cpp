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

#include "Util.h"
#include <iostream>

void applyCssData(Gtk::Widget& widget, const std::string& data) {
    Glib::RefPtr<Gtk::CssProvider> cssProvider = Gtk::CssProvider::create();
    cssProvider->load_from_data(data);
    widget.get_style_context()->add_provider(cssProvider, GTK_STYLE_PROVIDER_PRIORITY_USER);
}

void ffmpegkittest::Util::applyEditTextStyle(Gtk::Entry& entry) {
    entry.override_background_color(Gdk::RGBA("White"));
    entry.override_color(Gdk::RGBA("Black"));
    entry.set_margin_start(20);
    entry.set_margin_end(20);
    entry.set_margin_top(20);
    entry.set_margin_bottom(10);
    applyCssData(entry, "entry {border: 1px solid rgba(52, 152, 219, 1.0);}\
                entry {border: 1px solid rgba(52, 152, 219, 1.0);}");
}

void ffmpegkittest::Util::applyButtonStyle(Gtk::Button& button) {
    button.override_color(Gdk::RGBA("White"));
    button.set_margin_top(10);
    button.set_margin_bottom(10);
    applyCssData(button, "button {background-image: image(rgba(46, 204, 113, 1.0)); border: 1px solid rgba(39, 174, 96, 1.0);}\
                button:active {background-image: image(rgba(46, 174, 113, 1.0)); border: 1px solid rgba(39, 174, 96, 1.0);}");
}

void ffmpegkittest::Util::applyOutputTextStyle(Gtk::TextView& textView) {
    textView.set_margin_start(20);
    textView.set_margin_end(20);
    textView.set_margin_top(10);
    textView.set_margin_bottom(20);
    textView.override_color(Gdk::RGBA("White"));
    applyCssData(textView, "textview text {background-image: image(rgba(241, 196, 15, 1.0)); border-radius: 5px; border: 1px solid rgba(243, 156, 18, 1.0);}");
}

void ffmpegkittest::Util::applyComboBoxStyle(Gtk::ComboBox& comboBox) {
    comboBox.set_margin_start(20);
    comboBox.set_margin_end(20);
    comboBox.set_margin_top(20);
    comboBox.set_margin_bottom(10);
    comboBox.override_color(Gdk::RGBA("White"));
    applyCssData(comboBox, "combobox {background-image: image(rgba(155, 89, 182, 1.0)); border-radius: 5px; border: 1px solid rgba(142, 68, 173, 1.0);}");
}

void ffmpegkittest::Util::applyVideoPlayerFrameStyle(Gtk::Button& button) {
    button.set_margin_top(10);
    button.set_margin_bottom(10);
    applyCssData(button, "button {background-image: image(rgba(236, 240, 241, 1.0)); border: 1px solid rgba(185, 195, 199, 1.0);}");
}
