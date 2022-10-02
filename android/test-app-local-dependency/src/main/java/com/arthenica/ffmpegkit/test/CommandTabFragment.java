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
import android.util.AndroidRuntimeException;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFmpegSessionCompleteCallback;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.FFprobeSessionCompleteCallback;
import com.arthenica.ffmpegkit.LogCallback;
import com.arthenica.ffmpegkit.LogRedirectionStrategy;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.SessionState;

public class CommandTabFragment extends Fragment {
    private EditText commandText;
    private TextView outputText;

    public CommandTabFragment() {
        super(R.layout.fragment_command_tab);
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        commandText = view.findViewById(R.id.commandText);

        View runFFmpegButton = view.findViewById(R.id.runFFmpegButton);
        runFFmpegButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                runFFmpeg();
            }
        });

        View runFFprobeButton = view.findViewById(R.id.runFFprobeButton);
        runFFprobeButton.setOnClickListener(new View.OnClickListener() {

            @Override
            public void onClick(View v) {
                runFFprobe();
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

    public static CommandTabFragment newInstance() {
        return new CommandTabFragment();
    }

    public void runFFmpeg() {
        clearOutput();

        final String ffmpegCommand = String.format("%s", commandText.getText().toString());

        android.util.Log.d(MainActivity.TAG, String.format("Current log level is %s.", FFmpegKitConfig.getLogLevel()));

        android.util.Log.d(MainActivity.TAG, "Testing FFmpeg COMMAND asynchronously.");

        android.util.Log.d(MainActivity.TAG, String.format("FFmpeg process started with arguments: '%s'", ffmpegCommand));

        FFmpegKit.executeAsync(ffmpegCommand, new FFmpegSessionCompleteCallback() {

            @Override
            public void apply(final FFmpegSession session) {
                final SessionState state = session.getState();
                final ReturnCode returnCode = session.getReturnCode();

                android.util.Log.d(MainActivity.TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", FFmpegKitConfig.sessionStateToString(state), returnCode, notNull(session.getFailStackTrace(), "\n")));

                if (state == SessionState.FAILED || !returnCode.isValueSuccess()) {
                    MainActivity.addUIAction(new Runnable() {

                        @Override
                        public void run() {
                            Popup.show(requireContext(), "Command failed. Please check output for the details.");
                        }
                    });
                }
            }
        }, new LogCallback() {

            @Override
            public void apply(final com.arthenica.ffmpegkit.Log log) {
                MainActivity.addUIAction(new Runnable() {

                    @Override
                    public void run() {
                        appendOutput(log.getMessage());
                    }
                });

                throw new AndroidRuntimeException("I am test exception thrown by the application");
            }
        }, null);
    }

    public void runFFprobe() {
        clearOutput();

        final String ffprobeCommand = String.format("%s", commandText.getText().toString());

        android.util.Log.d(MainActivity.TAG, "Testing FFprobe COMMAND asynchronously.");

        android.util.Log.d(MainActivity.TAG, String.format("FFprobe process started with arguments: '%s'", ffprobeCommand));

        FFprobeSession session = FFprobeSession.create(FFmpegKitConfig.parseArguments(ffprobeCommand), new FFprobeSessionCompleteCallback() {

            @Override
            public void apply(final FFprobeSession session) {
                final SessionState state = session.getState();
                final ReturnCode returnCode = session.getReturnCode();

                MainActivity.addUIAction(new Runnable() {

                    @Override
                    public void run() {
                        appendOutput(session.getOutput());
                    }
                });

                android.util.Log.d(MainActivity.TAG, String.format("FFprobe process exited with state %s and rc %s.%s", FFmpegKitConfig.sessionStateToString(state), returnCode, notNull(session.getFailStackTrace(), "\n")));

                if (state == SessionState.FAILED || !session.getReturnCode().isValueSuccess()) {
                    MainActivity.addUIAction(new Runnable() {

                        @Override
                        public void run() {
                            Popup.show(requireContext(), "Command failed. Please check output for the details.");
                        }
                    });
                }
            }
        }, null, LogRedirectionStrategy.NEVER_PRINT_LOGS);

        FFmpegKitConfig.asyncFFprobeExecute(session);

        MainActivity.listFFprobeSessions();
    }

    private void setActive() {
        Log.i(MainActivity.TAG, "Command Tab Activated");
        FFmpegKitConfig.enableLogCallback(null);
        Popup.show(requireContext(), getString(R.string.command_test_tooltip_text));
    }

    public void appendOutput(final String logMessage) {
        outputText.append(logMessage);
    }

    public void clearOutput() {
        outputText.setText("");
    }

}
