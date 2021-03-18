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

import android.content.res.Resources;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.util.Log;

import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;

import static com.arthenica.ffmpegkit.test.MainActivity.TAG;

public class ResourcesUtil {
    public static void resourceToFile(Resources resources, final int resourceId, final File file) throws IOException {
        Bitmap bitmap = BitmapFactory.decodeResource(resources, resourceId);

        if (file.exists()) {
            file.delete();
        }

        FileOutputStream outputStream = new FileOutputStream(file);
        bitmap.compress(Bitmap.CompressFormat.JPEG, 100, outputStream);
        outputStream.flush();
        outputStream.close();
    }

    public static void rawResourceToFile(Resources resources, final int resourceId, final File file) throws IOException {
        final InputStream inputStream = resources.openRawResource(resourceId);
        if (file.exists()) {
            file.delete();
        }
        final FileOutputStream outputStream = new FileOutputStream(file);

        try {
            final byte[] buffer = new byte[1024];
            int readSize;

            while ((readSize = inputStream.read(buffer)) > 0) {
                outputStream.write(buffer, 0, readSize);
            }
        } catch (final IOException e) {
            Log.e(TAG, String.format("Saving raw resource failed.%s", Exceptions.getStackTraceString(e)));
        } finally {
            inputStream.close();
            outputStream.flush();
            outputStream.close();
        }
    }
}
