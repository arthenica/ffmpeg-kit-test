/*
 * Copyright (c) 2018-2021 Taner Sener
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

import android.os.AsyncTask;
import android.util.Log;

import com.arthenica.smartexception.java.Exceptions;

import java.io.IOException;

import static com.arthenica.ffmpegkit.test.MainActivity.TAG;

public class AsyncCatImageTask extends AsyncTask<String, Integer, Integer> {

    @Override
    protected Integer doInBackground(String... inputs) {
        try {
            final String asyncCommand = "cat " + inputs[0] + " > " + inputs[1];
            Log.d(TAG, String.format("Starting async cat image command: %s", asyncCommand));

            final Process process = Runtime.getRuntime().exec(new String[]{"sh", "-c", asyncCommand});
            int rc = process.waitFor();

            Log.d(TAG, String.format("Async cat image command: %s exited with %d.", asyncCommand, rc));

            return rc;
        } catch (final IOException | InterruptedException e) {
            Log.e(TAG, String.format("Async cat image command failed for %s.%s", inputs[0], Exceptions.getStackTraceString(e)));
            return -1;
        }
    }

}
