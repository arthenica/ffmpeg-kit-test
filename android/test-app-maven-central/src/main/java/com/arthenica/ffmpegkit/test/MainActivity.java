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

import android.Manifest;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.ActionBar;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;
import androidx.viewpager.widget.PagerTabStrip;
import androidx.viewpager.widget.ViewPager;

import com.arthenica.ffmpegkit.FFmpegKit;
import com.arthenica.ffmpegkit.FFmpegKitConfig;
import com.arthenica.ffmpegkit.FFmpegSession;
import com.arthenica.ffmpegkit.FFprobeKit;
import com.arthenica.ffmpegkit.FFprobeSession;
import com.arthenica.ffmpegkit.Level;
import com.arthenica.ffmpegkit.Signal;
import com.arthenica.ffmpegkit.util.ResourcesUtil;
import com.arthenica.smartexception.java.Exceptions;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Queue;
import java.util.concurrent.Callable;
import java.util.concurrent.ConcurrentLinkedQueue;

public class MainActivity extends AppCompatActivity {

    public static final String TAG = "ffmpeg-kit-test";

    public static final int REQUEST_EXTERNAL_STORAGE = 1;
    public static String[] PERMISSIONS_ALL = {
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.CAMERA
    };

    static {
        Exceptions.registerRootPackage("com.arthenica");
    }

    protected static final Queue<Callable<Object>> actionQueue = new ConcurrentLinkedQueue<>();

    protected static final Handler handler = new Handler();

    protected static final Runnable runnable = new Runnable() {

        @Override
        public void run() {
            Callable<Object> callable;

            do {
                callable = actionQueue.poll();
                if (callable != null) {
                    try {
                        callable.call();
                    } catch (final Exception e) {
                        android.util.Log.e(TAG, String.format("Running UI action received error.%s.", Exceptions.getStackTraceString(e)));
                    }
                }
            } while (callable != null);

            handler.postDelayed(this, 250);
        }
    };

    @Override
    protected void onCreate(final Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        setContentView(R.layout.activity_main);

        /* ALIGNING ACTION BAR TITLE IS SO SIMPLE */
        final ActionBar actionBar = getSupportActionBar();
        if (actionBar != null) {
            View viewActionBar = getLayoutInflater().inflate(R.layout.action_bar_title, null);
            ActionBar.LayoutParams params = new ActionBar.LayoutParams(
                    ActionBar.LayoutParams.WRAP_CONTENT,
                    ActionBar.LayoutParams.MATCH_PARENT,
                    Gravity.CENTER);
            TextView titleText = viewActionBar.findViewById(R.id.action_bar_title_text);
            titleText.setText(R.string.app_name);
            actionBar.setCustomView(viewActionBar, params);
            actionBar.setDisplayShowCustomEnabled(true);
            actionBar.setDisplayShowTitleEnabled(false);
        }

        PagerTabStrip pagerTabStrip = findViewById(R.id.pagerTabStrip);
        if (pagerTabStrip != null) {
            pagerTabStrip.setDrawFullUnderline(false);
            pagerTabStrip.setTabIndicatorColorResource(R.color.navigationColor);
            pagerTabStrip.setTextColor(Color.parseColor("#f39c12"));
        }

        final ViewPager viewPager = findViewById(R.id.pager);
        viewPager.setAdapter(new PagerAdapter(getSupportFragmentManager(), this));

        waitForUIAction();

        // VERIFY PERMISSIONS
        int permission = ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_EXTERNAL_STORAGE);
        if (permission != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    PERMISSIONS_ALL,
                    REQUEST_EXTERNAL_STORAGE);
        }
        permission = ActivityCompat.checkSelfPermission(this, Manifest.permission.CAMERA);
        if (permission != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this,
                    PERMISSIONS_ALL,
                    REQUEST_EXTERNAL_STORAGE);
        }

        try {
            registerAppFont();
            Log.d(TAG, "Application fonts registered.");
        } catch (final IOException e) {
            Log.e(TAG, String.format("Font registration failed.%s.", Exceptions.getStackTraceString(e)));
        }

        Log.d(TAG, "Listing supported camera ids.");
        listSupportedCameraIds();

        FFmpegKitConfig.ignoreSignal(Signal.SIGXCPU);
        FFmpegKitConfig.setLogLevel(Level.AV_LOG_INFO);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        handler.removeCallbacks(runnable);
    }

    public static void listFFmpegSessions() {
        List<FFmpegSession> ffmpegSessions = FFmpegKit.listSessions();
        Log.d(TAG, "Listing FFmpeg sessions.");
        for (int i = 0; i < ffmpegSessions.size(); i++) {
            FFmpegSession session = ffmpegSessions.get(i);
            Log.d(TAG, String.format("Session %d = id:%d, startTime:%s, duration:%s, state:%s, returnCode:%s.",
                    i,
                    session.getSessionId(),
                    session.getStartTime(),
                    session.getDuration(),
                    session.getState(),
                    session.getReturnCode()));
        }
        Log.d(TAG, "Listed FFmpeg sessions.");
    }

    public static void listFFprobeSessions() {
        List<FFprobeSession> ffprobeSessions = FFprobeKit.listSessions();
        Log.d(TAG, "Listing FFprobe sessions.");
        for (int i = 0; i < ffprobeSessions.size(); i++) {
            FFprobeSession session = ffprobeSessions.get(i);
            Log.d(TAG, String.format("Session %d = id:%d, startTime:%s, duration:%s, state:%s, returnCode:%s.",
                    i,
                    session.getSessionId(),
                    session.getStartTime(),
                    session.getDuration(),
                    session.getState(),
                    session.getReturnCode()));
        }
        Log.d(TAG, "Listed FFprobe sessions.");
    }

    public static void waitForUIAction() {
        handler.postDelayed(runnable, 250);
    }

    public static void addUIAction(final Callable<Object> callable) {
        actionQueue.add(callable);
    }

    protected void registerAppFont() throws IOException {
        final File cacheDirectory = getCacheDir();
        final File fontDirectory = new File(cacheDirectory, "fonts");

        boolean fontDirectoryCreated = fontDirectory.mkdirs();
        if (!fontDirectoryCreated) {
            android.util.Log.i(TAG, String.format("Failed to create font directory: %s.", fontDirectory.getAbsolutePath()));
        }

        // SAVE FONTS
        ResourcesUtil.rawResourceToFile(getResources(), R.raw.doppioone_regular, new File(fontDirectory, "doppioone_regular.ttf"));
        ResourcesUtil.rawResourceToFile(getResources(), R.raw.truenorg, new File(fontDirectory, "truenorg.otf"));

        final HashMap<String, String> fontNameMapping = new HashMap<>();
        fontNameMapping.put("MyFontName", "Doppio One");
        FFmpegKitConfig.setFontDirectoryList(this, Arrays.asList(fontDirectory.getAbsolutePath(), "/system/fonts"), fontNameMapping);
        FFmpegKitConfig.setEnvironmentVariable("FFREPORT", String.format("file=%s", new File(cacheDirectory.getAbsolutePath(), "ffreport.txt").getAbsolutePath()));
    }

    protected void listSupportedCameraIds() {
        final List<String> supportedCameraIds = FFmpegKitConfig.getSupportedCameraIds(this);
        if (supportedCameraIds.size() == 0) {
            android.util.Log.d(MainActivity.TAG, "No supported cameras found.");
        } else {
            for (String supportedCameraId : supportedCameraIds) {
                android.util.Log.d(MainActivity.TAG, "Supported camera detected: " + supportedCameraId);
            }
        }
    }

    static String notNull(final String string, final String valuePrefix) {
        return (string == null) ? "" : String.format("%s%s", valuePrefix, string);
    }

}
