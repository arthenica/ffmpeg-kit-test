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
