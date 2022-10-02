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

package com.arthenica.ffmpegkit.test;

import static android.app.Activity.RESULT_OK;
import static com.arthenica.ffmpegkit.test.MainActivity.TAG;
import static com.arthenica.ffmpegkit.test.MainActivity.notNull;

import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFmpegSessionCompleteCallback;
import com.arthenica.ffmpegkit.FFprobeKit;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.LogCallback;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.SessionState;
import com.arthenica.ffmpegkit.Statistics;
import com.arthenica.ffmpegkit.StatisticsCallback;
import com.arthenica.ffmpegkit.util.DialogUtil;
import com.arthenica.ffmpegkit.util.ResourcesUtil;
import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;

public class SafTabFragment extends Fragment {
    private TextView outputText;
    private Uri inUri;
    private Uri outUri;
    private static final int REQUEST_SAF_FFPROBE = 11;
    private static final int REQUEST_SAF_FFMPEG = 12;

    private boolean backFromIntent = false;

    private AlertDialog progressDialog;
    private Statistics statistics;

    private Button runFFmpegButton;
    private Button runFFprobeButton;

    public SafTabFragment() {
        super(R.layout.fragment_saf_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        runFFmpegButton = view.findViewById(R.id.runFFmpegButton);
        runFFmpegButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_CREATE_DOCUMENT)
                        .setType("video/*")
                        .putExtra(Intent.EXTRA_TITLE, "video.mp4")
                        .addCategory(Intent.CATEGORY_OPENABLE);
                startActivityForResult(intent, REQUEST_SAF_FFMPEG);
            }
        });

        runFFprobeButton = view.findViewById(R.id.runFFprobeButton);
        runFFprobeButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Intent.ACTION_GET_CONTENT)
                        .setType("*/*")
                        .putExtra(Intent.EXTRA_MIME_TYPES, new String[]{"image/*", "video/*", "audio/*"})
                        .addCategory(Intent.CATEGORY_OPENABLE);
                startActivityForResult(intent, REQUEST_SAF_FFPROBE);
            }
        });

        outputText = view.findViewById(R.id.outputText);
        outputText.setMovementMethod(new ScrollingMovementMethod());

        progressDialog = DialogUtil.createProgressDialog(requireContext(), "Encoding video");
    }

    @Override
    public void onResume() {
        super.onResume();
        setActive();
    }

    static SafTabFragment newInstance() {
        return new SafTabFragment();
    }

    private void enableLogCallback() {
        FFmpegKitConfig.enableLogCallback(new LogCallback() {

            @Override
            public void apply(final com.arthenica.ffmpegkit.Log log) {
                MainActivity.addUIAction(new Runnable() {

                    @Override
                    public void run() {
                        appendOutput(log.getMessage());
                    }
                });
            }
        });
    }

    private void runFFprobe() {
        clearOutput();

        final String ffprobeCommand = "-hide_banner -print_format json -show_format -show_streams " + FFmpegKitConfig.getSafParameterForRead(getContext(), inUri);

        Log.d(TAG, "Testing FFprobe COMMAND synchronously.");

        Log.d(TAG, String.format("FFprobe process started with arguments: '%s'", ffprobeCommand));

        final FFprobeSession session = FFprobeKit.execute(ffprobeCommand);

        Log.d(TAG, String.format("FFprobe process exited with state %s and rc %s.%s", session.getState(), session.getReturnCode(), notNull(session.getFailStackTrace(), "\n")));

        if (!ReturnCode.isSuccess(session.getReturnCode())) {
            Popup.show(requireContext(), "Command failed. Please check output for the details.");
        }
        inUri = null;
    }

    private void encodeVideo() {
        final File image1File = new File(requireContext().getCacheDir(), "machupicchu.jpg");
        final File image2File = new File(requireContext().getCacheDir(), "pyramid.jpg");
        final File image3File = new File(requireContext().getCacheDir(), "stonehenge.jpg");
        final String videoPath = FFmpegKitConfig.getSafParameter(requireContext(), outUri, "rw");

        try {
            String selectedCodec = getCodec(videoPath);
            Log.d(TAG, String.format("Testing VIDEO encoding with '%s' codec", selectedCodec));

            showProgressDialog();

            ResourcesUtil.resourceToFile(getResources(), R.drawable.machupicchu, image1File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.pyramid, image2File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.stonehenge, image3File);

            final String ffmpegCommand = Video.generateEncodeVideoScript(image1File.getAbsolutePath(), image2File.getAbsolutePath(), image3File.getAbsolutePath(), videoPath, selectedCodec, getCustomOptions(selectedCodec));

            Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", ffmpegCommand));

            FFmpegSession session = FFmpegKit.executeAsync(ffmpegCommand, new FFmpegSessionCompleteCallback() {

                @Override
                public void apply(final FFmpegSession session) {
                    final SessionState state = session.getState();
                    final ReturnCode returnCode = session.getReturnCode();

                    Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", state, returnCode, notNull(session.getFailStackTrace(), "\n")));

                    hideProgressDialog();

                    MainActivity.addUIAction(new Runnable() {

                        @Override
                        public void run() {
                            if (ReturnCode.isSuccess(session.getReturnCode())) {
                                Log.d(TAG, "Encode completed successfully.");
                            } else {
                                Popup.show(requireContext(), "Encode failed. Please check logs for the details.");
                            }
                        }
                    });
                }
            });

            Log.d(TAG, String.format("Async FFmpeg process started with sessionId %d.", session.getSessionId()));

        } catch (IOException e) {
            Log.e(TAG, String.format("Encode video failed %s.", Exceptions.getStackTraceString(e)));
            Popup.show(requireContext(), "Encode video failed");
        }
    }

    private void setActive() {
        if (backFromIntent) {
            backFromIntent = false;
            return;
        }
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.KITKAT) {
            Popup.show(requireContext(), "SAF is only available for Android 4.4 and above.");
            runFFprobeButton.setEnabled(false);
            runFFmpegButton.setEnabled(false);
            outputText.setEnabled(false);
            Log.i(TAG, "SAF Tab Dectivated");
            return;
        }
        Log.i(TAG, "SAF Tab Activated");
        enableLogCallback();
        enableStatisticsCallback();
        Popup.show(requireContext(), getString(R.string.saf_test_tooltip_text));
    }

    private void appendOutput(final String logMessage) {
        outputText.append(logMessage);
    }

    private void clearOutput() {
        outputText.setText("");
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        backFromIntent = true;
        if (requestCode == REQUEST_SAF_FFPROBE && resultCode == RESULT_OK && data != null) {
            inUri = data.getData();
            MainActivity.handler.post(new Runnable() {
                @Override
                public void run() {
                    runFFprobe();
                }
            });
        } else if (requestCode == REQUEST_SAF_FFMPEG && resultCode == MainActivity.RESULT_OK && data != null) {
            outUri = data.getData();
            MainActivity.handler.post(new Runnable() {
                @Override
                public void run() {
                    encodeVideo();
                }
            });
        } else {
            super.onActivityResult(requestCode, resultCode, data);
        }
    }

    private String getCodec(String videoPath) {
        String extension = "mp4";
        int pos = videoPath.lastIndexOf('.');
        if (pos >= 0)
            extension = videoPath.substring(pos + 1);

        switch (extension) {
            case "webm":
                return "vp8";
            case "mkv":
                return "aom";
            case "ogv":
                return "theora";
            case "mov":
                return "hap";
            case "mp4":
            default:
                return "mpeg4";
        }
    }

    private String getCustomOptions(String videoCodec) {
        switch (videoCodec) {
            case "x265":
                return "-crf 28 -preset fast ";
            case "vp8":
                return "-b:v 1M -crf 10 ";
            case "vp9":
                return "-b:v 2M ";
            case "aom":
                return "-crf 30 -strict experimental ";
            case "theora":
                return "-qscale:v 7 ";
            case "hap":
                return "-format hap_q ";
            default:

                // kvazaar, mpeg4, x264, xvid
                return "-movflags faststart ";
        }
    }

    private void enableStatisticsCallback() {
        FFmpegKitConfig.enableStatisticsCallback(new StatisticsCallback() {

            @Override
            public void apply(final Statistics newStatistics) {
                MainActivity.addUIAction(new Runnable() {

                    @Override
                    public void run() {
                        statistics = newStatistics;
                        updateProgressDialog();
                    }
                });
            }
        });
    }

    private void showProgressDialog() {

        // CLEAN STATISTICS
        statistics = null;

        progressDialog.show();
    }

    private void updateProgressDialog() {
        if (statistics == null || statistics.getTime() < 0) {
            return;
        }

        int timeInMilliseconds = this.statistics.getTime();
        int totalVideoDuration = 9000;

        String completePercentage = new BigDecimal(timeInMilliseconds).multiply(new BigDecimal(100)).divide(new BigDecimal(totalVideoDuration), 0, BigDecimal.ROUND_HALF_UP).toString();

        TextView textView = progressDialog.findViewById(R.id.progressDialogText);
        if (textView != null) {
            textView.setText(String.format("Encoding video: %% %s.", completePercentage));
        }
    }

    private void hideProgressDialog() {
        progressDialog.dismiss();

        MainActivity.addUIAction(new Runnable() {

            @Override
            public void run() {
                progressDialog = DialogUtil.createProgressDialog(requireContext(), "Encoding video");
            }
        });
    }

}
