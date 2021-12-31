/*
 * Copyright (c) 2021 Taner Sener
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

#import "Video.h"

@implementation Video

+ (NSString*)generateCreateVideoWithPipesScript:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile {
    return [NSString stringWithFormat:
@"-hide_banner -y -i %@ \
-i %@ \
-i %@ \
-filter_complex \"\
[0:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];\
[1:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];\
[2:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];\
[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];\
[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),fade=t=out:s=0:n=30[stream1fadeout];\
[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];\
[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];\
[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];\
[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),fade=t=in:s=0:n=30[stream3fadein];\
[stream2starting]fade=t=in:s=0:n=30[stream2fadein];\
[stream2ending]fade=t=out:s=0:n=30[stream2fadeout];\
[stream2fadein][stream1fadeout]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2,trim=duration=1,select=lte(n\\,30)[stream2blended];\
[stream3fadein][stream2fadeout]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2,trim=duration=1,select=lte(n\\,30)[stream3blended];\
[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=yuv420p[video]\" \
-map [video] -vsync 2 -async 1 -c:v mpeg4 -r 30 %@", image1, image2, image3, videoFile];
}

+ (NSString*)generateVideoEncodeScript:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile :(NSString *)videoCodec :(NSString *)customOptions {
    return [Video generateVideoEncodeScriptWithCustomPixelFormat:image1:image2:image3:videoFile:videoCodec:@"yuv420p":customOptions];
}

+ (NSString*)generateVideoEncodeScriptWithCustomPixelFormat:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile :(NSString *)videoCodec :(NSString *)pixelFormat :(NSString *)customOptions {
    return [NSString stringWithFormat:
@"-hide_banner -y -loop 1 -i %@ \
-loop 1 -i %@ \
-loop 1 -i %@ \
-filter_complex \"\
[0:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];\
[1:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];\
[2:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];\
[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];\
[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),fade=t=out:s=0:n=30[stream1fadeout];\
[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];\
[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];\
[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];\
[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),fade=t=in:s=0:n=30[stream3fadein];\
[stream2starting]fade=t=in:s=0:n=30[stream2fadein];\
[stream2ending]fade=t=out:s=0:n=30[stream2fadeout];\
[stream2fadein][stream1fadeout]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2,trim=duration=1,select=lte(n\\,30)[stream2blended];\
[stream3fadein][stream2fadeout]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2,trim=duration=1,select=lte(n\\,30)[stream3blended];\
[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=%@[video]\" \
-map [video] -vsync 2 -async 1 %@-c:v %@ -r 30 %@", image1, image2, image3, pixelFormat, customOptions, videoCodec, videoFile];
}

+ (NSString*)generateShakingVideoScript:(NSString *)image1 :(NSString *)image2 :(NSString *)image3 :(NSString *)videoFile {
    return [NSString stringWithFormat:
@"-hide_banner -y -loop 1 -i %@ \
-loop 1 -i %@ \
-loop 1 -i %@ \
-f lavfi -i color=black:s=640x427 \
-filter_complex \"\
[0:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream1out];\
[1:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream2out];\
[2:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream3out];\
[stream1out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream1overlaid];\
[stream2out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream2overlaid];\
[stream3out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream3overlaid];\
[3:v][stream1overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream1shaking];\
[3:v][stream2overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream2shaking];\
[3:v][stream3overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream3shaking];\
[stream1shaking][stream2shaking][stream3shaking]concat=n=3:v=1:a=0,scale=w=640:h=424,format=yuv420p[video]\" \
-map [video] -vsync 2 -async 1 -c:v mpeg4 -r 30 %@", image1, image2, image3, videoFile];
}

+ (NSString*)generateZscaleVideoScript:(NSString *)inputVideoFilePath :(NSString *)outputVideoFilePath {
    return [NSString stringWithFormat:@"-y -i %@ -vf zscale=tin=smpte2084:min=bt2020nc:pin=bt2020:rin=tv:t=smpte2084:m=bt2020nc:p=bt2020:r=tv,zscale=t=linear,tonemap=tonemap=clip,zscale=t=bt709,format=yuv420p %@", inputVideoFilePath, outputVideoFilePath];
}

@end
