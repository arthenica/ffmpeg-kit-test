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

#include "ProgressIndicator.h"

@implementation ProgressIndicator {
    NSView *_progressView;
    NSProgressIndicator *_progressIndicator;
    NSTextField *_progressText;
    AsyncBlock _cancelAction;
}

- (void)show:(NSView*)view message:(NSString*)message indeterminate:(BOOL)indeterminate asyncBlock:(AsyncBlock)cancelAction {
    
    // SET SIZES
    NSInteger windowWidth = view.frame.size.width;
    NSInteger windowHeight = view.frame.size.height;
    NSInteger frameWidth = 300;
    NSInteger frameHeight = (cancelAction == nil)?80:120;
    NSInteger progressWidth = 260;
    NSInteger progressHeight = 20;
    NSInteger cancelButtonWidth = 100;
    NSInteger baseY = (cancelAction == nil)?0:40;

    // CREATE PROGRESS INDICATOR
    _progressIndicator = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect((frameWidth - progressWidth)/2, 10 + baseY, progressWidth, progressHeight)];
    _progressIndicator.indeterminate = indeterminate;
    if (!indeterminate) {
        _progressIndicator.minValue = 0;
        _progressIndicator.maxValue = 100;
    }
    [_progressIndicator startAnimation:self];

    // CREATE PROGRESS VIEW
    _progressView = [[NSView alloc] initWithFrame:NSMakeRect((windowWidth - frameWidth)/2, (windowHeight - frameHeight)/2, frameWidth, frameHeight)];
    _progressView.wantsLayer = true;
    _progressView.layer.backgroundColor = [[NSColor darkGrayColor] CGColor];
    _progressView.shadow = [[NSShadow alloc] init];
    _progressView.layer.borderColor = [[NSColor lightGrayColor] CGColor];
    _progressView.layer.borderWidth = 1.0f;
    _progressView.layer.cornerRadius = 5.0f;
    _progressView.layer.shadowOpacity = 1.0;
    _progressView.layer.shadowColor = [[NSColor darkGrayColor] CGColor];
    _progressView.layer.shadowOffset = NSMakeSize(0, 0);
    _progressView.layer.shadowRadius = 10;
    
    // CREATE PROGRESS TEXT
    _progressText = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 40 + baseY, frameWidth, 20)];
    [_progressText setFont:[NSFont systemFontOfSize:14]];
    [_progressText setTextColor:[NSColor whiteColor]];
    [_progressText setBackgroundColor:[NSColor darkGrayColor]];
    [_progressText setStringValue:message];
    [_progressText setEditable:NO];
    [_progressText setSelectable:NO];
    [_progressText setBezeled:NO];
    [_progressText setAlignment:NSTextAlignmentCenter];

    // UPDATE VIEWS
    [view addSubview:_progressView];
    
    if (cancelAction != nil) {
        _cancelAction = cancelAction;

        // CREATE CANCEL BUTTON
        NSButton *button = [[NSButton alloc] initWithFrame:NSMakeRect((frameWidth - cancelButtonWidth)/2, 20, 100, 20)];
        [button setTitle:@"CANCEL"];
        [button setFont:[NSFont systemFontOfSize:14]];
        [button setAlignment:NSTextAlignmentCenter];
        [button setBezelStyle:NSRoundedBezelStyle];
        [button setAction:@selector(performAction)];
        [button setTarget:self];

        [Util applyButtonStyle: button];

        [_progressView addSubview:button];
    }

    [_progressView addSubview:_progressText];
    [_progressView addSubview:_progressIndicator];
}

- (void)updateMessage:(NSString*)message {
    [_progressText setStringValue:message];
}

- (void)updateMessage:(NSString*)message percentage:(int)percentage {
    [_progressText setStringValue:message];
    [_progressIndicator setDoubleValue:percentage];
}

- (void)updatePercentage:(int)percentage {
    [_progressIndicator setDoubleValue:percentage];
}

- (void)hide {
    [_progressView removeFromSuperview];
}

- (void)performAction {
    if (_cancelAction != nil) {
        _cancelAction();
    }
}

@end
