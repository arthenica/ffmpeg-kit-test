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

import com.arthenica.ffmpegkit.ExecuteCallback;
import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.LogCallback;
import com.arthenica.ffmpegkit.LogRedirectionStrategy;
import com.arthenica.ffmpegkit.ReturnCode;
import com.arthenica.ffmpegkit.Session;
import com.arthenica.ffmpegkit.SessionState;

import java.util.concurrent.Callable;

import static com.arthenica.ffmpegkit.test.MainActivity.notNull;

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

        android.util.Log.d(MainActivity.TAG, String.format("FFmpeg process started with arguments:\n'%s'", ffmpegCommand));

        FFmpegKit.executeAsync(ffmpegCommand, new ExecuteCallback() {

            @Override
            public void apply(final Session session) {
                final SessionState state = session.getState();
                final ReturnCode returnCode = session.getReturnCode();

                android.util.Log.d(MainActivity.TAG, String.format("FFmpeg process exited with state %s and rc %s.%s", state, returnCode, notNull(session.getFailStackTrace(), "\n")));

                if (state == SessionState.FAILED || !returnCode.isSuccess()) {
                    MainActivity.addUIAction(new Callable<Object>() {

                        @Override
                        public Object call() {
                            Popup.show(requireContext(), "Command failed. Please check output for the details.");
                            return null;
                        }
                    });
                }
            }
        }, new LogCallback() {

            @Override
            public void apply(final com.arthenica.ffmpegkit.Log log) {
                MainActivity.addUIAction(new Callable<Object>() {

                    @Override
                    public Object call() {
                        appendOutput(log.getMessage());
                        return null;
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

        android.util.Log.d(MainActivity.TAG, String.format("FFprobe process started with arguments:\n'%s'", ffprobeCommand));

        FFprobeSession session = new FFprobeSession(FFmpegKit.parseArguments(ffprobeCommand), new ExecuteCallback() {

            @Override
            public void apply(final Session session) {
                final SessionState state = session.getState();
                final ReturnCode returnCode = session.getReturnCode();

                MainActivity.addUIAction(new Callable<Object>() {

                    @Override
                    public Object call() {
                        appendOutput(session.getOutput());
                        return null;
                    }
                });

                android.util.Log.d(MainActivity.TAG, String.format("FFprobe process exited with state %s and rc %s.%s", state, returnCode, notNull(session.getFailStackTrace(), "\n")));

                if (state == SessionState.FAILED || !session.getReturnCode().isSuccess()) {
                    MainActivity.addUIAction(new Callable<Object>() {

                        @Override
                        public Object call() {
                            Popup.show(requireContext(), "Command failed. Please check output for the details.");
                            return null;
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
