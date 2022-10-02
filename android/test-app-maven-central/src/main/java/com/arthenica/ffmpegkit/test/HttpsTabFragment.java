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

import static com.arthenica.ffmpegkit.test.MainActivity.notNull;

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.arthenica.ffmpegkit.Chapter;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFprobeKit;
import com.arthenica.ffmpegkit.MediaInformation;
import com.arthenica.ffmpegkit.MediaInformationSession;
import com.arthenica.ffmpegkit.MediaInformationSessionCompleteCallback;
import com.arthenica.ffmpegkit.StreamInformation;

import org.json.JSONObject;

import java.util.Iterator;
import java.util.Random;

public class HttpsTabFragment extends Fragment {

    public static final String HTTPS_TEST_DEFAULT_URL = "https://download.blender.org/peach/trailer/trailer_1080p.ogg";

    public static final String HTTPS_TEST_FAIL_URL = "https://download2.blender.org/peach/trailer/trailer_1080p.ogg";

    public static final String HTTPS_TEST_RANDOM_URL_1 = "https://filesamples.com/samples/video/mov/sample_640x360.mov";

    public static final String HTTPS_TEST_RANDOM_URL_2 = "https://filesamples.com/samples/audio/mp3/sample3.mp3";

    public static final String HTTPS_TEST_RANDOM_URL_3 = "https://filesamples.com/samples/image/webp/sample1.webp";

    private static final Random testUrlRandom = new Random();
    private static final Object outputLock = new Object();

    private EditText urlText;
    private TextView outputText;

    public HttpsTabFragment() {
        super(R.layout.fragment_https_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        urlText = view.findViewById(R.id.urlText);

        View getInfoFromUrlButton = view.findViewById(R.id.getInfoFromUrlButton);
        getInfoFromUrlButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                runGetMediaInformation(1);
            }
        });

        View getRandomInfoButton1 = view.findViewById(R.id.getRandomInfoButton1);
        getRandomInfoButton1.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                runGetMediaInformation(2);
            }
        });

        View getRandomInfoButton2 = view.findViewById(R.id.getRandomInfoButton2);
        getRandomInfoButton2.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                runGetMediaInformation(3);
            }
        });

        View getInfoAndFailButton = view.findViewById(R.id.getInfoAndFailButton);
        getInfoAndFailButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                runGetMediaInformation(4);
            }
        });

        outputText = view.findViewById(R.id.outputText);
        outputText.setMovementMethod(new ScrollingMovementMethod());
    }

    @Override
    public void onResume() {
        super.onResume();
        setActive();
    }

    public static HttpsTabFragment newInstance() {
        return new HttpsTabFragment();
    }

    public void enableLogCallback() {
        FFmpegKitConfig.enableLogCallback(null);
        FFmpegKitConfig.enableStatisticsCallback(null);
    }

    public void runGetMediaInformation(final int buttonNumber) {

        // SELECT TEST URL
        String testUrl;
        switch (buttonNumber) {
            case 1: {
                testUrl = urlText.getText().toString();
                if (testUrl.isEmpty()) {
                    testUrl = HTTPS_TEST_DEFAULT_URL;
                    urlText.setText(testUrl);
                }
            }
            break;
            case 2:
            case 3: {
                testUrl = getRandomTestUrl();
            }
            break;
            case 4:
            default: {
                testUrl = HTTPS_TEST_FAIL_URL;
                urlText.setText(testUrl);
            }
        }

        android.util.Log.d(MainActivity.TAG, String.format("Testing HTTPS with for button %d using url %s.", buttonNumber, testUrl));

        if (buttonNumber == 4) {

            // ONLY THIS BUTTON CLEARS THE TEXT VIEW
            clearOutput();
        }

        // EXECUTE
        FFprobeKit.getMediaInformationAsync(testUrl, createNewCompleteCallback());
    }

    public void setActive() {
        Log.i(MainActivity.TAG, "Https Tab Activated");
        enableLogCallback();
        Popup.show(requireContext(), getString(R.string.https_test_tooltip_text));
    }

    public void appendOutput(final String logMessage) {
        MainActivity.handler.post(new Runnable() {

            @Override
            public void run() {
                outputText.append(logMessage);
            }
        });
    }

    public void clearOutput() {
        outputText.setText("");
    }

    private String getRandomTestUrl() {
        switch (testUrlRandom.nextInt(3)) {
            case 0:
                return HTTPS_TEST_RANDOM_URL_1;
            case 1:
                return HTTPS_TEST_RANDOM_URL_2;
            default:
                return HTTPS_TEST_RANDOM_URL_3;
        }
    }

    private MediaInformationSessionCompleteCallback createNewCompleteCallback() {
        return new MediaInformationSessionCompleteCallback() {

            @Override
            public void apply(MediaInformationSession session) {

                // SYNC THE OUTPUT SO WE CAN IDENTIFY THE FILES
                synchronized (outputLock) {
                    final MediaInformation information = session.getMediaInformation();
                    if (information == null) {
                        appendOutput("Get media information failed\n");
                        appendOutput(String.format("State: %s\n", session.getState()));
                        appendOutput(String.format("Duration: %s\n", session.getDuration()));
                        appendOutput(String.format("Return Code: %s\n", session.getReturnCode()));
                        appendOutput(String.format("Fail stack trace: %s\n", notNull(session.getFailStackTrace(), "\n")));
                        appendOutput(String.format("Output: %s\n", session.getOutput()));
                    } else {
                        appendOutput("Media information for " + information.getFilename() + "\n");

                        if (information.getFormat() != null) {
                            appendOutput("Format: " + information.getFormat() + "\n");
                        }
                        if (information.getBitrate() != null) {
                            appendOutput("Bitrate: " + information.getBitrate() + "\n");
                        }
                        if (information.getDuration() != null) {
                            appendOutput("Duration: " + information.getDuration() + "\n");
                        }
                        if (information.getStartTime() != null) {
                            appendOutput("Start time: " + information.getStartTime() + "\n");
                        }
                        if (information.getTags() != null) {
                            JSONObject tags = information.getTags();
                            Iterator<String> keys = tags.keys();
                            while (keys.hasNext()) {
                                String next = keys.next();
                                appendOutput("Tag: " + next + ":" + tags.optString(next) + "\n");
                            }
                        }
                        if (information.getStreams() != null) {
                            for (StreamInformation stream : information.getStreams()) {
                                if (stream.getIndex() != null) {
                                    appendOutput("Stream index: " + stream.getIndex() + "\n");
                                }
                                if (stream.getType() != null) {
                                    appendOutput("Stream type: " + stream.getType() + "\n");
                                }
                                if (stream.getCodec() != null) {
                                    appendOutput("Stream codec: " + stream.getCodec() + "\n");
                                }
                                if (stream.getCodecLong() != null) {
                                    appendOutput("Stream codec long: " + stream.getCodecLong() + "\n");
                                }
                                if (stream.getFormat() != null) {
                                    appendOutput("Stream format: " + stream.getFormat() + "\n");
                                }

                                if (stream.getWidth() != null) {
                                    appendOutput("Stream width: " + stream.getWidth() + "\n");
                                }
                                if (stream.getHeight() != null) {
                                    appendOutput("Stream height: " + stream.getHeight() + "\n");
                                }

                                if (stream.getBitrate() != null) {
                                    appendOutput("Stream bitrate: " + stream.getBitrate() + "\n");
                                }
                                if (stream.getSampleRate() != null) {
                                    appendOutput("Stream sample rate: " + stream.getSampleRate() + "\n");
                                }
                                if (stream.getSampleFormat() != null) {
                                    appendOutput("Stream sample format: " + stream.getSampleFormat() + "\n");
                                }
                                if (stream.getChannelLayout() != null) {
                                    appendOutput("Stream channel layout: " + stream.getChannelLayout() + "\n");
                                }

                                if (stream.getSampleAspectRatio() != null) {
                                    appendOutput("Stream sample aspect ratio: " + stream.getSampleAspectRatio() + "\n");
                                }
                                if (stream.getDisplayAspectRatio() != null) {
                                    appendOutput("Stream display ascpect ratio: " + stream.getDisplayAspectRatio() + "\n");
                                }
                                if (stream.getAverageFrameRate() != null) {
                                    appendOutput("Stream average frame rate: " + stream.getAverageFrameRate() + "\n");
                                }
                                if (stream.getRealFrameRate() != null) {
                                    appendOutput("Stream real frame rate: " + stream.getRealFrameRate() + "\n");
                                }
                                if (stream.getTimeBase() != null) {
                                    appendOutput("Stream time base: " + stream.getTimeBase() + "\n");
                                }
                                if (stream.getCodecTimeBase() != null) {
                                    appendOutput("Stream codec time base: " + stream.getCodecTimeBase() + "\n");
                                }

                                if (stream.getTags() != null) {
                                    JSONObject tags = stream.getTags();
                                    Iterator<String> keys = tags.keys();
                                    while (keys.hasNext()) {
                                        String next = keys.next();
                                        appendOutput(String.format("Stream tag: %s:%s\n", next, tags.optString(next)));
                                    }
                                }
                            }
                        }
                        if (information.getChapters() != null) {
                            for (Chapter chapter : information.getChapters()) {
                                if (chapter.getId() != null) {
                                    appendOutput("Chapter id: " + chapter.getId() + "\n");
                                }
                                if (chapter.getTimeBase() != null) {
                                    appendOutput("Chapter time base: " + chapter.getTimeBase() + "\n");
                                }
                                if (chapter.getStart() != null) {
                                    appendOutput("Chapter start: " + chapter.getStart() + "\n");
                                }
                                if (chapter.getStartTime() != null) {
                                    appendOutput("Chapter start time: " + chapter.getStartTime() + "\n");
                                }
                                if (chapter.getEnd() != null) {
                                    appendOutput("Chapter end: " + chapter.getEnd() + "\n");
                                }
                                if (chapter.getEndTime() != null) {
                                    appendOutput("Chapter end time: " + chapter.getEndTime() + "\n");
                                }
                                if (chapter.getTags() != null) {
                                    JSONObject tags = chapter.getTags();
                                    if (tags != null) {
                                        Iterator<String> keys = tags.keys();
                                        while (keys.hasNext()) {
                                            String next = keys.next();
                                            appendOutput(String.format("Chapter tag: %s:%s\n", next, tags.optString(next)));
                                        }
                                    }
                                }

                            }
                        }
                    }
                }
            }
        };
    }

}
