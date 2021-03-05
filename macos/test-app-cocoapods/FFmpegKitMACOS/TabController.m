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

#include "TabController.h"
#include "CommandViewController.h"
#include "VideoViewController.h"
#include "HttpsViewController.h"
#include "AudioViewController.h"
#include "SubtitleViewController.h"
#include "VidStabViewController.h"
#include "PipeViewController.h"
#include "ConcurrentExecutionViewController.h"
#include "OtherViewController.h"

@implementation TabController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.selectedTabViewItemIndex = 0;
}

- (void)tabView:(NSTabView *)tabView didSelectTabViewItem:(nullable NSTabViewItem *)tabViewItem {
    [super tabView:tabView didSelectTabViewItem:tabViewItem];

    NSViewController *viewController = [tabViewItem viewController];
    if ([viewController isKindOfClass:[CommandViewController class]]) {
        CommandViewController* commandView = (CommandViewController*)viewController;
        [commandView setActive];
    } else if ([viewController isKindOfClass:[VideoViewController class]]) {
        VideoViewController* videoView = (VideoViewController*)viewController;
        [videoView setActive];
    } else if ([viewController isKindOfClass:[HttpsViewController class]]) {
        HttpsViewController* httpsView = (HttpsViewController*)viewController;
        [httpsView setActive];
    } else if ([viewController isKindOfClass:[AudioViewController class]]) {
        AudioViewController* audioView = (AudioViewController*)viewController;
        [audioView setActive];
    } else if ([viewController isKindOfClass:[SubtitleViewController class]]) {
        SubtitleViewController* subtitleView = (SubtitleViewController*)viewController;
        [subtitleView setActive];
    } else if ([viewController isKindOfClass:[VidStabViewController class]]) {
        VidStabViewController* vidStabView = (VidStabViewController*)viewController;
        [vidStabView setActive];
    } else if ([viewController isKindOfClass:[PipeViewController class]]) {
        PipeViewController* pipeView = (PipeViewController*)viewController;
        [pipeView setActive];
    } else if ([viewController isKindOfClass:[ConcurrentExecutionViewController class]]) {
        ConcurrentExecutionViewController* concurrentExecutionView = (ConcurrentExecutionViewController*)viewController;
        [concurrentExecutionView setActive];
    } else if ([viewController isKindOfClass:[OtherViewController class]]) {
        OtherViewController* otherView = (OtherViewController*)viewController;
        [otherView setActive];
    }
}

@end
