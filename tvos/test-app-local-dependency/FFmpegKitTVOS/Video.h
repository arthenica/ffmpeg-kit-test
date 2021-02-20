/*
 * Copyright (c) 2021 Taner Sener
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

#ifndef FFMPEG_KIT_TEST_VIDEO
#define FFMPEG_KIT_TEST_VIDEO

#include <Foundation/Foundation.h>

@interface Video : NSObject

+ (NSString*)generateCreateVideoWithPipesScript:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile;

+ (NSString*)generateVideoEncodeScript:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile :(NSString *)videoCodec :(NSString *)customOptions;

+ (NSString*)generateShakingVideoScript:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile;

@end

#endif /* FFMPEG_KIT_TEST_VIDEO */
