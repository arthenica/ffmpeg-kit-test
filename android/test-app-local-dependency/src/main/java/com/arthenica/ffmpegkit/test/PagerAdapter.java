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

import android.content.Context;

import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentPagerAdapter;

public class PagerAdapter extends FragmentPagerAdapter {
    private static final int NUMBER_OF_TABS = 10;

    private final Context context;

    PagerAdapter(FragmentManager fragmentManager, Context context) {
        super(fragmentManager, BEHAVIOR_RESUME_ONLY_CURRENT_FRAGMENT);
        this.context = context;
    }

    @Override
    public Fragment getItem(final int position) {
        switch (position) {
            case 0: {
                return CommandTabFragment.newInstance();
            }
            case 1: {
                return VideoTabFragment.newInstance();
            }
            case 2: {
                return HttpsTabFragment.newInstance();
            }
            case 3: {
                return AudioTabFragment.newInstance();
            }
            case 4: {
                return SubtitleTabFragment.newInstance();
            }
            case 5: {
                return VidStabTabFragment.newInstance();
            }
            case 6: {
                return PipeTabFragment.newInstance();
            }
            case 7: {
                return ConcurrentExecutionTabFragment.newInstance();
            }
            case 8: {
                return SafTabFragment.newInstance();
            }
            case 9: {
                return OtherTabFragment.newInstance();
            }
            default: {
                return null;
            }
        }
    }

    @Override
    public int getCount() {
        return NUMBER_OF_TABS;
    }

    @Override
    public CharSequence getPageTitle(final int position) {
        switch (position) {
            case 0: {
                return context.getString(R.string.command_tab);
            }
            case 1: {
                return context.getString(R.string.video_tab);
            }
            case 2: {
                return context.getString(R.string.https_tab);
            }
            case 3: {
                return context.getString(R.string.audio_tab);
            }
            case 4: {
                return context.getString(R.string.subtitle_tab);
            }
            case 5: {
                return context.getString(R.string.vidstab_tab);
            }
            case 6: {
                return context.getString(R.string.pipe_tab);
            }
            case 7: {
                return context.getString(R.string.concurrent_tab);
            }
            case 8: {
                return context.getString(R.string.saf_tab);
            }
            case 9: {
                return context.getString(R.string.other_tab);
            }
            default: {
                return null;
            }
        }
    }

}
