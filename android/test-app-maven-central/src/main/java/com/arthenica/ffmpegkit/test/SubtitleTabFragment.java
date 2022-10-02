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
import android.widget.MediaController;
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

public class SubtitleTabFragment extends Fragment {

    private enum State {
        IDLE,
        CREATING,
        BURNING
    }

    private VideoView videoView;
    private AlertDialog createProgressDialog;
    private AlertDialog burnProgressDialog;
    private Statistics statistics;
    private State state;
    private Long sessionId;

    public SubtitleTabFragment() {
        super(R.layout.fragment_subtitle_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        View burnSubtitlesButton = view.findViewById(R.id.burnSubtitlesButton);
        burnSubtitlesButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                burnSubtitles();
            }
        });

        videoView = view.findViewById(R.id.videoPlayerFrame);

        state = State.IDLE;
    }

    @Override
    public void onResume() {
        super.onResume();
        setActive();
    }

    public static SubtitleTabFragment newInstance() {
        return new SubtitleTabFragment();
    }

    public void enableLogCallback() {
        FFmpegKitConfig.enableLogCallback(new LogCallback() {

            @Override
            public void apply(final com.arthenica.ffmpegkit.Log log) {
                Log.d(MainActivity.TAG, log.getMessage());
            }
        });
    }

    public void enableStatisticsCallback() {
        FFmpegKitConfig.enableStatisticsCallback(new StatisticsCallback() {

            @Override
            public void apply(final Statistics newStatistics) {
                MainActivity.addUIAction(new Runnable() {

                    @Override
                    public void run() {
                        SubtitleTabFragment.this.statistics = newStatistics;
                        updateProgressDialog();
                    }
                });
            }
        });
    }

    public void burnSubtitles() {
        final File image1File = new File(requireContext().getCacheDir(), "machupicchu.jpg");
        final File image2File = new File(requireContext().getCacheDir(), "pyramid.jpg");
        final File image3File = new File(requireContext().getCacheDir(), "stonehenge.jpg");
        final File videoFile = getVideoFile();
        final File videoWithSubtitlesFile = getVideoWithSubtitlesFile();

        try {

            // IF VIDEO IS PLAYING STOP PLAYBACK
            videoView.stopPlayback();

            Log.d(TAG, "Testing SUBTITLE burning");

            showCreateProgressDialog();

            ResourcesUtil.resourceToFile(getResources(), R.drawable.machupicchu, image1File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.pyramid, image2File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.stonehenge, image3File);
            ResourcesUtil.rawResourceToFile(getResources(), R.raw.subtitle, getSubtitleFile());

            final String ffmpegCommand = Video.generateEncodeVideoScript(image1File.getAbsolutePath(), image2File.getAbsolutePath(), image3File.getAbsolutePath(), videoFile.getAbsolutePath(), "mpeg4", "");

            Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", ffmpegCommand));

            state = State.CREATING;

            sessionId = FFmpegKit.executeAsync(ffmpegCommand, new FFmpegSessionCompleteCallback() {

                @Override
                public void apply(final FFmpegSession session) {
                    Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", session.getState(), session.getReturnCode(), notNull(session.getFailStackTrace(), "\n")));

                    hideCreateProgressDialog();

                    if (ReturnCode.isSuccess(session.getReturnCode())) {

                        MainActivity.addUIAction(new Runnable() {

                            @Override
                            public void run() {

                                Log.d(TAG, "Create completed successfully; burning subtitles.");

                                String burnSubtitlesCommand = String.format("-y -i %s -vf subtitles=%s:force_style='FontName=MyFontName' -c:v mpeg4 %s", videoFile.getAbsolutePath(), getSubtitleFile().getAbsolutePath(), videoWithSubtitlesFile.getAbsolutePath());

                                showBurnProgressDialog();

                                Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", burnSubtitlesCommand));

                                state = State.BURNING;

                                FFmpegKit.executeAsync(burnSubtitlesCommand, new FFmpegSessionCompleteCallback() {

                                    @Override
                                    public void apply(final FFmpegSession secondSession) {

                                        hideBurnProgressDialog();

                                        MainActivity.addUIAction(new Runnable() {

                                            @Override
                                            public void run() {
                                                if (ReturnCode.isSuccess(secondSession.getReturnCode())) {
                                                    Log.d(TAG, "Burn subtitles completed successfully; playing video.");
                                                    playVideo();
                                                } else if (ReturnCode.isCancel(secondSession.getReturnCode())) {
                                                    Popup.show(requireContext(), "Burn subtitles operation cancelled.");
                                                    Log.e(TAG, "Burn subtitles operation cancelled");
                                                } else {
                                                    Popup.show(requireContext(), "Burn subtitles failed. Please check logs for the details.");
                                                    Log.d(TAG, String.format("Burn subtitles failed with state %s and rc %s.%s", secondSession.getState(), secondSession.getReturnCode(), notNull(secondSession.getFailStackTrace(), "\n")));
                                                }
                                            }
                                        });
                                    }
                                });
                            }
                        });
                    }
                }
            }).getSessionId();

            Log.d(TAG, String.format("Async FFmpeg process started with sessionId %d.", sessionId));

        } catch (IOException e) {
            Log.e(TAG, String.format("Burn subtitles failed %s.", Exceptions.getStackTraceString(e)));
            Popup.show(requireContext(), "Burn subtitles failed");
        }
    }

    protected void playVideo() {
        MediaController mediaController = new MediaController(requireContext());
        mediaController.setAnchorView(videoView);
        videoView.setVideoURI(Uri.parse("file://" + getVideoWithSubtitlesFile().getAbsolutePath()));
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

    public File getSubtitleFile() {
        return new File(requireContext().getCacheDir(), "subtitle.srt");
    }

    public File getVideoFile() {
        return new File(requireContext().getFilesDir(), "video.mp4");
    }

    public File getVideoWithSubtitlesFile() {
        return new File(requireContext().getFilesDir(), "video-with-subtitles.mp4");
    }

    public void setActive() {
        Log.i(MainActivity.TAG, "Subtitle Tab Activated");
        enableLogCallback();
        enableStatisticsCallback();
        Popup.show(requireContext(), getString(R.string.subtitle_test_tooltip_text));
    }

    protected void showCreateProgressDialog() {

        // CLEAN STATISTICS
        statistics = null;

        createProgressDialog = DialogUtil.createCancellableProgressDialog(requireContext(), "Creating video", new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                if (sessionId != null) {
                    Log.d(TAG, String.format("Cancelling FFmpeg execution with sessionId %d.", sessionId));
                    FFmpegKit.cancel(sessionId);
                }
            }
        });
        createProgressDialog.show();
    }

    protected void updateProgressDialog() {
        if (statistics == null || statistics.getTime() < 0) {
            return;
        }

        int timeInMilliseconds = this.statistics.getTime();
        int totalVideoDuration = 9000;

        String completePercentage = new BigDecimal(timeInMilliseconds).multiply(new BigDecimal(100)).divide(new BigDecimal(totalVideoDuration), 0, BigDecimal.ROUND_HALF_UP).toString();

        if (state == State.CREATING) {
            TextView textView = createProgressDialog.findViewById(R.id.progressDialogText);
            if (textView != null) {
                textView.setText(String.format("Creating video: %% %s.", completePercentage));
            }
        } else if (state == State.BURNING) {
            TextView textView = burnProgressDialog.findViewById(R.id.progressDialogText);
            if (textView != null) {
                textView.setText(String.format("Burning subtitles: %% %s.", completePercentage));
            }
        }

    }

    protected void hideCreateProgressDialog() {
        createProgressDialog.dismiss();
    }

    protected void showBurnProgressDialog() {

        // CLEAN STATISTICS
        statistics = null;

        burnProgressDialog = DialogUtil.createCancellableProgressDialog(requireContext(), "Burning subtitles", new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                FFmpegKit.cancel();
            }
        });
        burnProgressDialog.show();
    }

    protected void hideBurnProgressDialog() {
        burnProgressDialog.dismiss();
    }

}
