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

#include <ffmpegkit/FFmpegKitConfig.h>
#include "AppDelegate.h"

void uncaughtExceptionHandler(NSException *exception) {
    NSLog(@"Uncaught exception detected: %@.", exception);
    NSLog(@"%@", [exception callStackSymbols]);
}

@interface AppDelegate ()

@end

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

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);

    // UPDATE TAB BAR STYLE
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UITabBar *tabBar = tabBarController.tabBar;
    UITabBarItem *tabBarItem1 = [tabBar.items objectAtIndex:0];
    UITabBarItem *tabBarItem2 = [tabBar.items objectAtIndex:1];
    UITabBarItem *tabBarItem3 = [tabBar.items objectAtIndex:2];
    UITabBarItem *tabBarItem4 = [tabBar.items objectAtIndex:3];
    UITabBarItem *tabBarItem5 = [tabBar.items objectAtIndex:4];
    UITabBarItem *tabBarItem6 = [tabBar.items objectAtIndex:5];
    UITabBarItem *tabBarItem7 = [tabBar.items objectAtIndex:6];
    UITabBarItem *tabBarItem8 = [tabBar.items objectAtIndex:7];
    UITabBarItem *tabBarItem9 = [tabBar.items objectAtIndex:8];
    tabBarItem1.title = @"COMMAND";
    tabBarItem2.title = @"VIDEO";
    tabBarItem3.title = @"HTTPS";
    tabBarItem4.title = @"AUDIO";
    tabBarItem5.title = @"SUBTITLE";
    tabBarItem6.title = @"VID.STAB";
    tabBarItem7.title = @"PIPE";
    tabBarItem8.title = @"CONCURRENT";
    tabBarItem9.title = @"OTHER";

    // SELECTED BAR ITEM
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor colorWithRed:244.0/255.0 green:104.0/255.0 blue:66.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                       [UIFont boldSystemFontOfSize:14], NSFontAttributeName,
                                                       nil] forState:UIControlStateSelected];

    // NOT SELECTED BAR ITEMS
    [[UITabBarItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                       [UIColor colorWithRed:189.0/255.0 green:195.0/255.0 blue:199.0/255.0 alpha:1.0], NSForegroundColorAttributeName,
                                                       [UIFont boldSystemFontOfSize:12], NSFontAttributeName,
                                                       nil] forState:UIControlStateNormal];
    
    NSString *resourceFolder = [[NSBundle mainBundle] resourcePath];
    NSDictionary *fontNameMapping = @{@"MyFontName" : @"Doppio One"};

    [FFmpegKitConfig setFontDirectory:resourceFolder with:fontNameMapping];
    [FFmpegKitConfig setFontDirectory:resourceFolder with:nil];

    [FFmpegKitConfig ignoreSignal:SIGXCPU];
    [FFmpegKitConfig setLogLevel:LevelAVLogInfo];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
