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

import android.os.Bundle;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.Spinner;
import android.widget.TextView;

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
import com.arthenica.ffmpegkit.SessionState;
import com.arthenica.ffmpegkit.util.DialogUtil;

import java.io.File;

public class AudioTabFragment extends Fragment implements AdapterView.OnItemSelectedListener {
    private AlertDialog progressDialog;
    private Button encodeButton;
    private TextView outputText;
    private String selectedCodec;

    public AudioTabFragment() {
        super(R.layout.fragment_audio_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Spinner audioCodecSpinner = view.findViewById(R.id.audioCodecSpinner);
        ArrayAdapter<CharSequence> adapter = ArrayAdapter.createFromResource(requireContext(), R.array.audio_codec, R.layout.spinner_item);
        adapter.setDropDownViewResource(R.layout.spinner_dropdown_item);
        audioCodecSpinner.setAdapter(adapter);
        audioCodecSpinner.setOnItemSelectedListener(this);

        encodeButton = view.findViewById(R.id.encodeButton);
        encodeButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                encodeAudio();
            }
        });
        encodeButton.setEnabled(false);

        outputText = view.findViewById(R.id.outputText);
        outputText.setMovementMethod(new ScrollingMovementMethod());

        progressDialog = DialogUtil.createProgressDialog(requireContext(), "Encoding audio");

        selectedCodec = getResources().getStringArray(R.array.audio_codec)[0];
    }

    @Override
    public void onResume() {
        super.onResume();
        setActive();
    }

    public static AudioTabFragment newInstance() {
        return new AudioTabFragment();
    }

    public void enableLogCallback() {
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

    public void disableLogCallback() {
        FFmpegKitConfig.enableLogCallback(null);
    }

    public void disableStatisticsCallback() {
        FFmpegKitConfig.enableStatisticsCallback(null);
    }

    @Override
    public void onItemSelected(AdapterView<?> parent, View view, int position, long id) {
        selectedCodec = parent.getItemAtPosition(position).toString();
    }

    @Override
    public void onNothingSelected(AdapterView<?> parent) {
        // DO NOTHING
    }

    public void encodeAudio() {
        File audioOutputFile = getAudioOutputFile();
        if (audioOutputFile.exists()) {
            audioOutputFile.delete();
        }

        final String audioCodec = selectedCodec;

        android.util.Log.d(TAG, String.format("Testing AUDIO encoding with '%s' codec.", audioCodec));

        final String ffmpegCommand = generateAudioEncodeScript();

        showProgressDialog();

        clearOutput();

        android.util.Log.d(TAG, String.format("FFmpeg process started with arguments: '%s'.", ffmpegCommand));

        FFmpegKit.executeAsync(ffmpegCommand, new FFmpegSessionCompleteCallback() {

            @Override
            public void apply(final FFmpegSession session) {
                final SessionState state = session.getState();
                final ReturnCode returnCode = session.getReturnCode();

                hideProgressDialog();

                MainActivity.addUIAction(new Runnable() {

                    @Override
                    public void run() {
                        if (ReturnCode.isSuccess(returnCode)) {
                            Popup.show(requireContext(), "Encode completed successfully.");
                            android.util.Log.d(TAG, "Encode completed successfully.");
                        } else {
                            Popup.show(requireContext(), "Encode failed. Please check logs for the details.");
                            android.util.Log.d(TAG, String.format("Encode failed with state %s and rc %s.%s", state, returnCode, notNull(session.getFailStackTrace(), "\n")));
                        }
                    }
                });
            }
        });
    }

    public void createAudioSample() {
        android.util.Log.d(TAG, "Creating AUDIO sample before the test.");

        File audioSampleFile = getAudioSampleFile();
        if (audioSampleFile.exists()) {
            audioSampleFile.delete();
        }

        String ffmpegCommand = String.format("-hide_banner -y -f lavfi -i sine=frequency=1000:duration=5 -c:a pcm_s16le %s", audioSampleFile.getAbsolutePath());

        android.util.Log.d(TAG, String.format("Creating audio sample with '%s'.", ffmpegCommand));

        final FFmpegSession session = FFmpegKit.execute(ffmpegCommand);
        if (ReturnCode.isSuccess(session.getReturnCode())) {
            encodeButton.setEnabled(true);
            android.util.Log.d(TAG, "AUDIO sample created");
        } else {
            android.util.Log.d(TAG, String.format("Creating AUDIO sample failed with state %s and rc %s.%s", session.getState(), session.getReturnCode(), notNull(session.getFailStackTrace(), "\n")));
            Popup.show(requireContext(), "Creating AUDIO sample failed. Please check logs for the details.");
        }
    }

    public File getAudioOutputFile() {
        String audioCodec = selectedCodec;

        String extension;
        switch (audioCodec) {
            case "mp2 (twolame)":
                extension = "mpg";
                break;
            case "mp3 (liblame)":
            case "mp3 (libshine)":
                extension = "mp3";
                break;
            case "vorbis":
                extension = "ogg";
                break;
            case "opus":
                extension = "opus";
                break;
            case "amr-nb":
            case "amr-wb":
                extension = "amr";
                break;
            case "ilbc":
                extension = "lbc";
                break;
            case "speex":
                extension = "spx";
                break;
            case "wavpack":
                extension = "wv";
                break;
            default:

                // soxr
                extension = "wav";
                break;
        }

        final String audio = "audio." + extension;
        return new File(requireContext().getFilesDir(), audio);
    }

    public File getAudioSampleFile() {
        return new File(requireContext().getFilesDir(), "audio-sample.wav");
    }

    public void setActive() {
        android.util.Log.i(MainActivity.TAG, "Audio Tab Activated");
        disableStatisticsCallback();
        disableLogCallback();
        createAudioSample();
        enableLogCallback();
        Popup.show(requireContext(), getString(R.string.audio_test_tooltip_text));
    }

    public void appendOutput(final String logMessage) {
        outputText.append(logMessage);
    }

    public void clearOutput() {
        outputText.setText("");
    }

    protected void showProgressDialog() {
        progressDialog.show();
    }

    protected void hideProgressDialog() {
        progressDialog.dismiss();
    }

    public String generateAudioEncodeScript() {
        String audioCodec = selectedCodec;
        String audioSampleFile = getAudioSampleFile().getAbsolutePath();
        String audioOutputFile = getAudioOutputFile().getAbsolutePath();

        switch (audioCodec) {
            case "mp2 (twolame)":
                return String.format("-hide_banner -y -i %s -c:a mp2 -b:a 192k %s", audioSampleFile, audioOutputFile);
            case "mp3 (liblame)":
                return String.format("-hide_banner -y -i %s -c:a libmp3lame -qscale:a 2 %s", audioSampleFile, audioOutputFile);
            case "mp3 (libshine)":
                return String.format("-hide_banner -y -i %s -c:a libshine -qscale:a 2 %s", audioSampleFile, audioOutputFile);
            case "vorbis":
                return String.format("-hide_banner -y -i %s -c:a libvorbis -b:a 64k %s", audioSampleFile, audioOutputFile);
            case "opus":
                return String.format("-hide_banner -y -i %s -c:a libopus -b:a 64k -vbr on -compression_level 10 %s", audioSampleFile, audioOutputFile);
            case "amr-nb":
                return String.format("-hide_banner -y -i %s -ar 8000 -ab 12.2k -c:a libopencore_amrnb %s", audioSampleFile, audioOutputFile);
            case "amr-wb":
                return String.format("-hide_banner -y -i %s -ar 8000 -ab 12.2k -c:a libvo_amrwbenc -strict experimental %s", audioSampleFile, audioOutputFile);
            case "ilbc":
                return String.format("-hide_banner -y -i %s -c:a ilbc -ar 8000 -b:a 15200 %s", audioSampleFile, audioOutputFile);
            case "speex":
                return String.format("-hide_banner -y -i %s -c:a libspeex -ar 16000 %s", audioSampleFile, audioOutputFile);
            case "wavpack":
                return String.format("-hide_banner -y -i %s -c:a wavpack -b:a 64k %s", audioSampleFile, audioOutputFile);
            default:

                // soxr
                return String.format("-hide_banner -y -i %s -af aresample=resampler=soxr -ar 44100 %s", audioSampleFile, audioOutputFile);
        }
    }

}
