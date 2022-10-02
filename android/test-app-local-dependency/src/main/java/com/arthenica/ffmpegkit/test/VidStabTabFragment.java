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
import com.arthenica.ffmpegkit.util.DialogUtil;
import com.arthenica.ffmpegkit.util.ResourcesUtil;
import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.IOException;

public class VidStabTabFragment extends Fragment {
    private VideoView videoView;
    private VideoView stabilizedVideoView;
    private AlertDialog createProgressDialog;
    private AlertDialog stabilizeProgressDialog;

    public VidStabTabFragment() {
        super(R.layout.fragment_vidstab_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        View stabilizeVideoButton = view.findViewById(R.id.stabilizeVideoButton);
        stabilizeVideoButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                stabilizeVideo();
            }
        });

        videoView = view.findViewById(R.id.videoPlayerFrame);
        stabilizedVideoView = view.findViewById(R.id.stabilizedVideoPlayerFrame);

        createProgressDialog = DialogUtil.createProgressDialog(requireContext(), "Creating video");
        stabilizeProgressDialog = DialogUtil.createProgressDialog(requireContext(), "Stabilizing video");
    }

    @Override
    public void onResume() {
        super.onResume();
        setActive();
    }

    public static VidStabTabFragment newInstance() {
        return new VidStabTabFragment();
    }

    public void enableLogCallback() {
        FFmpegKitConfig.enableLogCallback(new LogCallback() {

            @Override
            public void apply(final com.arthenica.ffmpegkit.Log log) {
                Log.d(MainActivity.TAG, log.getMessage());
            }
        });
    }

    public void disableStatisticsCallback() {
        FFmpegKitConfig.enableStatisticsCallback(null);
    }

    public void stabilizeVideo() {
        final File image1File = new File(requireContext().getCacheDir(), "machupicchu.jpg");
        final File image2File = new File(requireContext().getCacheDir(), "pyramid.jpg");
        final File image3File = new File(requireContext().getCacheDir(), "stonehenge.jpg");
        final File shakeResultsFile = getShakeResultsFile();
        final File videoFile = getVideoFile();
        final File stabilizedVideoFile = getStabilizedVideoFile();

        try {

            // IF VIDEO IS PLAYING STOP PLAYBACK
            videoView.stopPlayback();
            stabilizedVideoView.stopPlayback();

            if (shakeResultsFile.exists()) {
                shakeResultsFile.delete();
            }
            if (videoFile.exists()) {
                videoFile.delete();
            }
            if (stabilizedVideoFile.exists()) {
                stabilizedVideoFile.delete();
            }

            Log.d(TAG, "Testing VID.STAB");

            showCreateProgressDialog();

            ResourcesUtil.resourceToFile(getResources(), R.drawable.machupicchu, image1File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.pyramid, image2File);
            ResourcesUtil.resourceToFile(getResources(), R.drawable.stonehenge, image3File);

            final String ffmpegCommand = Video.generateShakingVideoScript(image1File.getAbsolutePath(), image2File.getAbsolutePath(), image3File.getAbsolutePath(), videoFile.getAbsolutePath());

            Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", ffmpegCommand));

            FFmpegKit.executeAsync(ffmpegCommand, new FFmpegSessionCompleteCallback() {

                @Override
                public void apply(final FFmpegSession session) {
                    Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", session.getState(), session.getReturnCode(), notNull(session.getFailStackTrace(), "\n")));

                    hideCreateProgressDialog();

                    MainActivity.addUIAction(new Runnable() {

                        @Override
                        public void run() {
                            if (ReturnCode.isSuccess(session.getReturnCode())) {

                                Log.d(TAG, "Create completed successfully; stabilizing video.");

                                final String analyzeVideoCommand = String.format("-y -i %s -vf vidstabdetect=shakiness=10:accuracy=15:result=%s -f null -", videoFile.getAbsolutePath(), shakeResultsFile.getAbsolutePath());

                                showStabilizeProgressDialog();

                                Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", analyzeVideoCommand));

                                FFmpegKit.executeAsync(analyzeVideoCommand, new FFmpegSessionCompleteCallback() {

                                    @Override
                                    public void apply(final FFmpegSession secondSession) {
                                        Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", secondSession.getState(), secondSession.getReturnCode(), notNull(secondSession.getFailStackTrace(), "\n")));

                                        if (ReturnCode.isSuccess(secondSession.getReturnCode())) {
                                            final String stabilizeVideoCommand = String.format("-y -i %s -vf vidstabtransform=smoothing=30:input=%s -c:v mpeg4 %s", videoFile.getAbsolutePath(), shakeResultsFile.getAbsolutePath(), stabilizedVideoFile.getAbsolutePath());

                                            Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", stabilizeVideoCommand));

                                            FFmpegKit.executeAsync(stabilizeVideoCommand, new FFmpegSessionCompleteCallback() {

                                                @Override
                                                public void apply(final FFmpegSession thirdSession) {
                                                    Log.d(TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", thirdSession.getState(), thirdSession.getReturnCode(), notNull(thirdSession.getFailStackTrace(), "\n")));

                                                    hideStabilizeProgressDialog();

                                                    MainActivity.addUIAction(new Runnable() {

                                                        @Override
                                                        public void run() {
                                                            if (ReturnCode.isSuccess(thirdSession.getReturnCode())) {
                                                                Log.d(TAG, "Stabilize video completed successfully; playing videos.");
                                                                playVideo();
                                                                playStabilizedVideo();
                                                            } else {
                                                                Popup.show(requireContext(), "Stabilize video failed. Please check logs for the details.");
                                                            }
                                                        }
                                                    });
                                                }
                                            });

                                        } else {
                                            MainActivity.addUIAction(() -> {
                                                hideStabilizeProgressDialog();
                                                Popup.show(requireContext(), "Stabilize video failed. Please check logs for the details.");
                                            });
                                        }
                                    }
                                });

                            } else {
                                Popup.show(requireContext(), "Create video failed. Please check logs for the details.");
                            }
                        }
                    });
                }
            });

        } catch (IOException e) {
            Log.e(TAG, String.format("Stabilize video failed %s.", Exceptions.getStackTraceString(e)));
            Popup.show(requireContext(), "Stabilize video failed");
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

    protected void playStabilizedVideo() {
        MediaController mediaController = new MediaController(requireContext());
        mediaController.setAnchorView(stabilizedVideoView);
        stabilizedVideoView.setVideoURI(Uri.parse("file://" + getStabilizedVideoFile().getAbsolutePath()));
        stabilizedVideoView.setMediaController(mediaController);
        stabilizedVideoView.requestFocus();
        stabilizedVideoView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {

            @Override
            public void onPrepared(MediaPlayer mp) {
                stabilizedVideoView.setBackgroundColor(0x00000000);
            }
        });
        stabilizedVideoView.setOnErrorListener(new MediaPlayer.OnErrorListener() {

            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                stabilizedVideoView.stopPlayback();
                return false;
            }
        });
        stabilizedVideoView.start();
    }

    public File getShakeResultsFile() {
        return new File(requireContext().getCacheDir(), "transforms.trf");
    }

    public File getVideoFile() {
        return new File(requireContext().getFilesDir(), "video.mp4");
    }

    public File getStabilizedVideoFile() {
        return new File(requireContext().getFilesDir(), "video-stabilized.mp4");
    }

    public void setActive() {
        Log.i(MainActivity.TAG, "VidStab Tab Activated");
        enableLogCallback();
        disableStatisticsCallback();
        Popup.show(requireContext(), getString(R.string.vidstab_test_tooltip_text));
    }

    protected void showCreateProgressDialog() {
        createProgressDialog.show();
    }

    protected void hideCreateProgressDialog() {
        createProgressDialog.dismiss();
    }

    protected void showStabilizeProgressDialog() {
        stabilizeProgressDialog.show();
    }

    protected void hideStabilizeProgressDialog() {
        stabilizeProgressDialog.dismiss();
    }

}
