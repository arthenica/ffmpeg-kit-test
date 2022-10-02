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

#include "ProgressDialog.h"
#include <iostream>

namespace ffmpegkittest {

    gboolean runDialog(ffmpegkittest::ProgressDialog* progressDialog) {
        progressDialog->dialog.run();
        return FALSE;
    }

}

ffmpegkittest::ProgressDialog::ProgressDialog() : dialog("", Gtk::DIALOG_MODAL), alignment(0.5, 0.5, 0, 0) {
    progressBar.set_show_text(false);
    progressBar.set_fraction(0.0);
    progressBar.set_size_request(100, 20);
    alignment.add(progressBar);

    dialog.set_default_size(300, 60);
    dialog.get_content_area()->set_border_width(10);
    dialog.get_content_area()->pack_start(alignment, Gtk::PACK_EXPAND_WIDGET, 5);
    dialog.show_all_children(true);
}

void ffmpegkittest::ProgressDialog::show(const Glib::RefPtr<const Gdk::Window> parentWindow) {
    dialog.set_parent_window(parentWindow);
    g_idle_add((GSourceFunc)runDialog, this);
}

void ffmpegkittest::ProgressDialog::update(double fraction) {
    progressBar.set_fraction(fraction);
}

void ffmpegkittest::ProgressDialog::hide() {
    dialog.hide();
}
