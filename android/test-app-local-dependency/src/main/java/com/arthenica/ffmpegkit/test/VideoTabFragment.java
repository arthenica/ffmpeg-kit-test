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

import static com.arthenica.ffmpegkit.test.MainActivity.TAG;
import static com.arthenica.ffmpegkit.test.MainActivity.notNull;

import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.MediaController;
import android.widget.Spinner;
import android.widget.TextView;
import android.widget.VideoView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AlertDialog;
import androidx.fragment.app.Fragment;

import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFmpegSessionCompleteCallback;
import com.arthenica.ffmpegkit.LogCallback;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.Statistics;
import com.arthenica.ffmpegkit.StatisticsCallback;
import com.arthenica.ffmpegkit.util.DialogUtil;
import com.arthenica.ffmpegkit.util.ResourcesUtil;
import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.IOException;
import java.math.BigDecimal;

public class VideoTabFragment extends Fragment implements AdapterView.OnItemSelectedListener {
    private VideoView videoView;
    private AlertDialog progressDialog;
    private String selectedCodec;
    private Statistics statistics;

    public VideoTabFragment() {
        super(R.layout.fragment_video_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Spinner videoCodecSpinner = view.findViewById(R.id.videoCodecSpinner);
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(requireContext(),
                R.array.video_codec, R.layout.spinner_item);
        adapter.setDropDownViewResource(R.layout.spinner_dropdown_item);
        videoCodecSpinner.setAdapter(adapter);
        videoCodecSpinner.setOnItemSelectedListener(this);

        View encodeButton = view.findViewById(R.id.encodeButton);
        if (encodeButton != null) {
            encodeButton.setOnClickListener(new View.OnClickListener() {

                @Override
                public void onClick(View v) {
                    encodeVideo();
                }
            });
        }

        videoView = view.findViewById(R.id.videoPlayerFrame);

        progressDialog = DialogUtil.createProgressDialog(requireContext(), "Encoding video");

        selectedCodec = getResources().getStringArray(R.array.video_codec)[0];
    }

    @Override
    public void onResume() {
        super.onResume();
        setActive();
    }

    public static VideoTabFragment newInstance() {
        return new VideoTabFragment();
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        selectedCodec = parent.getItemAtPosition(position).toString();
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
        // DO NOTHING
    }

    public void encodeVideo() {
        final File image1File = new File(requireContext().getCacheDir(), "machupicchu.jpg");
        final File image2File = new File(requireContext().getCacheDir(), "pyramid.jpg");
        final File image3File = new File(requireContext().getCacheDir(), "stonehenge.jpg");
        final File videoFile = getVideoFile();

        try {

            // IF VIDEO IS PLAYING STOP PLAYBACK
            videoView.stopPlayback();

            if (videoFile.exists()) {
                videoFile.delete();
            }

            final String videoCodec = selectedCodec;

            Log.d(TAG, String.format("Testing VIDEO encoding with '%s' codec", videoCodec));

            showProgressDialog();

            ResourcesUtil.resourceToFile(getResources(), R.drawable.machupicchu, image1File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.pyramid, image2File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.stonehenge, image3File);

            final String ffmpegCommand = Video.generateEncodeVideoScript(image1File.getAbsolutePath(), image2File.getAbsolutePath(), image3File.getAbsolutePath(), videoFile.getAbsolutePath(), getSelectedVideoCodec(), getPixelFormat(), getCustomOptions());

            Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", ffmpegCommand));

            final FFmpegSession session = FFmpegKit.executeAsync(ffmpegCommand, new FFmpegSessionCompleteCallback() {

                @Override
                public void apply(final FFmpegSession session) {
                    final ReturnCode returnCode = session.getReturnCode();

                    hideProgressDialog();

                    MainActivity.addUIAction(new Runnable() {

                        @Override
                        public void run() {
                            if (ReturnCode.isSuccess(returnCode)) {
                                Log.d(TAG, String.format("Encode completed successfully in %d milliseconds; playing video.", session.getDuration()));
                                playVideo();
                            } else {
                                Popup.show(requireContext(), "Encode failed. Please check logs for the details.");
                                Log.d(TAG, String.format("Encode failed with state %s and rc %s.%s", session.getState(), returnCode, notNull(session.getFailStackTrace(), "\n")));
                            }
                        }
                    });
                }
            }, new LogCallback() {

                @Override
                public void apply(com.arthenica.ffmpegkit.Log log) {
                    android.util.Log.d(MainActivity.TAG, log.getMessage());
                }
            }, new StatisticsCallback() {

                @Override
                public void apply(Statistics statistics) {
                    VideoTabFragment.this.statistics = statistics;
                    MainActivity.addUIAction(new Runnable() {

                        @Override
                        public void run() {
                            updateProgressDialog();
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

    protected void playVideo() {
        MediaController mediaController = new MediaController(requireContext());
        mediaController.setAnchorView(videoView);
        videoView.setVideoURI(Uri.parse("file://" + getVideoFile().getAbsolutePath()));
        videoView.setMediaController(mediaController);
        videoView.requestFocus();
        videoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {

            @Override
            public void onPrepared(MediaPlayer mp) {
                videoView.setBackgroundColor(0x00000000);
            }
        });
        videoView.setOnErrorListener(new MediaPlayer.OnErrorListener() {

            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                videoView.stopPlayback();
                return false;
            }
        });
        videoView.start();
    }

    public String getPixelFormat() {
        String videoCodec = selectedCodec;

        final String pixelFormat;
        if ("x265".equals(videoCodec)) {
            pixelFormat = "yuv420p10le";
        } else {
            pixelFormat = "yuv420p";
        }

        return pixelFormat;
    }

    public String getSelectedVideoCodec() {
        String videoCodec = selectedCodec;

        // VIDEO CODEC SPINNER HAS BASIC NAMES, FFMPEG NEEDS LONGER AND EXACT CODEC NAMES.
        // APPLYING NECESSARY TRANSFORMATION HERE
        switch (videoCodec) {
            case "x264":
                videoCodec = "libx264";
                break;
            case "openh264":
                videoCodec = "libopenh264";
                break;
            case "x265":
                videoCodec = "libx265";
                break;
            case "xvid":
                videoCodec = "libxvid";
                break;
            case "vp8":
                videoCodec = "libvpx";
                break;
            case "vp9":
                videoCodec = "libvpx-vp9";
                break;
            case "aom":
                videoCodec = "libaom-av1";
                break;
            case "kvazaar":
                videoCodec = "libkvazaar";
                break;
            case "theora":
                videoCodec = "libtheora";
                break;
        }

        return videoCodec;
    }

    public File getVideoFile() {
        String videoCodec = selectedCodec;

        final String extension;
        switch (videoCodec) {
            case "vp8":
            case "vp9":
                extension = "webm";
                break;
            case "aom":
                extension = "mkv";
                break;
            case "theora":
                extension = "ogv";
                break;
            case "hap":
                extension = "mov";
                break;
            default:

                // mpeg4, x264, x265, xvid, kvazaar
                extension = "mp4";
                break;
        }

        final String video = "video." + extension;
        return new File(requireContext().getFilesDir(), video);
    }

    public String getCustomOptions() {
        String videoCodec = selectedCodec;

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

    public void setActive() {
        Log.i(MainActivity.TAG, "Video Tab Activated");
        FFmpegKitConfig.enableLogCallback(null);
        FFmpegKitConfig.enableStatisticsCallback(null);
        Popup.show(requireContext(), getString(R.string.video_test_tooltip_text));
    }

    protected void showProgressDialog() {

        // CLEAN STATISTICS
        statistics = null;

        progressDialog.show();
    }

    protected void updateProgressDialog() {
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

    protected void hideProgressDialog() {
        progressDialog.dismiss();

        MainActivity.addUIAction(new Runnable() {

            @Override
            public void run() {
                VideoTabFragment.this.progressDialog = DialogUtil.createProgressDialog(requireContext(), "Encoding video");
            }
        });
    }

}
