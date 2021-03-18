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

#import "AppDelegate.h"
#import <ffmpegkit/FFmpegKitConfig.h>

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"Uncaught exception detected: %@.", exception);
    NSLog(@"%@", [exception callStackSymbols]);
}

@implementation AppDelegate

+ (void)listFFprobeSessions {
    NSArray* ffprobeSessions = [FFprobeKit listSessions];

    NSLog(@"Listing FFprobe sessions.\n");

    for (int i = 0; i < [ffprobeSessions count]; i++) {
        FFprobeSession* session = [ffprobeSessions objectAtIndex:i];
        NSLog(@"Session %d = id: %ld, startTime: %@, duration: %ld, state:%@, returnCode:%@.\n", i, [session getSessionId], [session getStartTime], [session getDuration], [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode]);
    }

    NSLog(@"Listed FFprobe sessions.\n");
}

+ (void)listFFmpegSessions {
    NSArray* ffmpegSessions = [FFmpegKit listSessions];

    NSLog(@"Listing FFmpeg sessions.\n");

    for (int i = 0; i < [ffmpegSessions count]; i++) {
        FFmpegSession* session = [ffmpegSessions objectAtIndex:i];
        NSLog(@"Session %d = id: %ld, startTime: %@, duration: %ld, state:%@, returnCode:%@.\n", i, [session getSessionId], [session getStartTime], [session getDuration], [FFmpegKitConfig sessionStateToString:[session getState]], [session getReturnCode]);
    }

    NSLog(@"Listed FFmpeg sessions.\n");
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application

    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSDictionary *fontNameMapping = @{@"MyFontName" : @"Doppio One"};

    [FFmpegKitConfig setFontDirectory:resourceFolder with:fontNameMapping];
    [FFmpegKitConfig setFontDirectory:resourceFolder with:nil];

    [FFmpegKitConfig ignoreSignal:SIGXCPU];
    [FFmpegKitConfig setLogLevel:LevelAVLogInfo];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
