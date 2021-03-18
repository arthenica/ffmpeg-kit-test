/*
 * Copyright (c) 2019-2021 Alexander Berezhnoi
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

package com.arthenica.ffmpegkit.util;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.appcompat.app.AlertDialog;

import com.arthenica.ffmpegkit.test.R;

public class DialogUtil {

    public static AlertDialog createProgressDialog(Context context, final String text) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        if (inflater != null) {
            View dialogView = inflater.inflate(R.layout.progress_dialog_layout, null);
            builder.setView(dialogView);

            TextView textView = dialogView.findViewById(R.id.progressDialogText);
            if (textView != null) {
                textView.setText(text);
            }
        }
        builder.setCancelable(false);
        return builder.create();
    }

    public static AlertDialog createCancellableProgressDialog(Context context, final String text, final View.OnClickListener onClickListener) {
        AlertDialog.Builder builder = new AlertDialog.Builder(context);
        LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
        if (inflater != null) {
            View dialogView = inflater.inflate(R.layout.cancellable_progress_dialog_layout, null);
            builder.setView(dialogView);

            TextView textView = dialogView.findViewById(R.id.progressDialogText);
            if (textView != null) {
                textView.setText(text);
            }
            Button cancelButton = dialogView.findViewById(R.id.cancelButton);
            if (cancelButton != null) {
                cancelButton.setOnClickListener(onClickListener);
            }
        }
        builder.setCancelable(false);
        return builder.create();
    }

}
