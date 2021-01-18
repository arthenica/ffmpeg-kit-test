/*
 * Copyright (c) 2018-2021 Taner Sener
 *
 * This file is part of FFmpegKitTest.
 *
 * FFmpegKitTest is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * FFmpegKitTest is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with FFmpegKitTest.  If not, see <http://www.gnu.org/licenses/>.
 */

package com.arthenica.ffmpegkit.test;

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

import com.arthenica.ffmpegkit.ExecuteCallback;
import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFprobeKit;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.LogCallback;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.Session;
import com.arthenica.ffmpegkit.SessionState;
import com.arthenica.ffmpegkit.Statistics;
import com.arthenica.ffmpegkit.StatisticsCallback;
import com.arthenica.ffmpegkit.util.DialogUtil;
import com.arthenica.ffmpegkit.util.ResourcesUtil;
import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.concurrent.Callable;

import static android.app.Activity.RESULT_OK;
import static com.arthenica.ffmpegkit.test.MainActivity.TAG;
import static com.arthenica.ffmpegkit.test.MainActivity.notNull;

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
                MainActivity.addUIAction(new Callable() {

                    @Override
                    public Object call() {
                        appendOutput(log.getMessage());
                        return null;
                    }
                });
            }
        });
    }

    private void runFFprobe() {
        clearOutput();

        final String ffprobeCommand = "-hide_banner -print_format json -show_format -show_streams " + FFmpegKitConfig.getSafParameterForRead(getContext(), inUri);

        Log.d(TAG, "Testing FFprobe COMMAND synchronously.");

        Log.d(TAG, String.format("FFprobe process started with arguments\n'%s'", ffprobeCommand));

        final FFprobeSession session = FFprobeKit.execute(ffprobeCommand);

        Log.d(TAG, String.format("FFprobe process exited with state %s and rc %s.%s", session.getState(), session.getReturnCode(), notNull(session.getFailStackTrace(), "\n")));

        if (ReturnCode.isSuccess(session.getReturnCode())) {
            Popup.show(requireContext(), "Command failed. Please check output for the details.");
        }
        inUri = null;
    }

    private void encodeVideo() {
        final File image1File = new File(requireContext().getCacheDir(), "machupicchu.jpg");
        final File image2File = new File(requireContext().getCacheDir(), "pyramid.jpg");
        final File image3File = new File(requireContext().getCacheDir(), "stonehenge.jpg");
        final String videoPath = FFmpegKitConfig.getSafParameterForWrite(requireContext(), outUri);

        try {
            String selectedCodec = getCodec(videoPath);
            Log.d(TAG, String.format("Testing VIDEO encoding with '%s' codec", selectedCodec));

            showProgressDialog();

            ResourcesUtil.resourceToFile(getResources(), R.drawable.machupicchu, image1File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.pyramid, image2File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.stonehenge, image3File);

            final String ffmpegCommand = Video.generateEncodeVideoScript(image1File.getAbsolutePath(), image2File.getAbsolutePath(), image3File.getAbsolutePath(), videoPath, selectedCodec, getCustomOptions(selectedCodec));

            Log.d(TAG, String.format("FFmpeg process started with arguments\n'%s'.", ffmpegCommand));

            FFmpegSession session = FFmpegKit.executeAsync(ffmpegCommand, new ExecuteCallback() {

                @Override
                public void apply(final Session session) {
                    final SessionState state = session.getState();
                    final ReturnCode returnCode = session.getReturnCode();

                    Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", state, returnCode, notNull(session.getFailStackTrace(), "\n")));

                    hideProgressDialog();

                    MainActivity.addUIAction(new Callable<Object>() {

                        @Override
                        public Object call() {
                            if (ReturnCode.isSuccess(session.getReturnCode())) {
                                Log.d(TAG, "Encode completed successfully.");
                            } else {
                                Popup.show(requireContext(), "Encode failed. Please check logs for the details.");
                            }

                            return null;
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
                return "";
        }
    }

    private void enableStatisticsCallback() {
        FFmpegKitConfig.enableStatisticsCallback(new StatisticsCallback() {

            @Override
            public void apply(final Statistics newStatistics) {
                MainActivity.addUIAction(new Callable<Object>() {

                    @Override
                    public Object call() {
                        statistics = newStatistics;
                        updateProgressDialog();
                        return null;
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
        if (statistics == null) {
            return;
        }

        int timeInMilliseconds = this.statistics.getTime();
        if (timeInMilliseconds > 0) {
            int totalVideoDuration = 9000;

            String completePercentage = new BigDecimal(timeInMilliseconds).multiply(new BigDecimal(100)).divide(new BigDecimal(totalVideoDuration), 0, BigDecimal.ROUND_HALF_UP).toString();

            TextView textView = progressDialog.findViewById(R.id.progressDialogText);
            if (textView != null) {
                textView.setText(String.format("Encoding video: %% %s.", completePercentage));
            }
        }
    }

    private void hideProgressDialog() {
        progressDialog.dismiss();

        MainActivity.addUIAction(new Callable<Object>() {

            @Override
            public Object call() {
                progressDialog = DialogUtil.createProgressDialog(requireContext(), "Encoding video");
                return null;
            }
        });
    }

}
