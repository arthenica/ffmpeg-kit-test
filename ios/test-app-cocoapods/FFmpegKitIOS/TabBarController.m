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

#include "TabBarController.h"
#include "CommandViewController.h"
#include "VideoViewController.h"
#include "HttpsViewController.h"
#include "AudioViewController.h"
#include "SubtitleViewController.h"
#include "VidStabViewController.h"
#include "PipeViewController.h"
#include "ConcurrentExecutionViewController.h"
#include "OtherViewController.h"

@interface TabBarController () <UITabBarControllerDelegate>

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)tabBarController: (UITabBarController *)tabBarController didSelectViewController: (UIViewController *)viewController {
    
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
