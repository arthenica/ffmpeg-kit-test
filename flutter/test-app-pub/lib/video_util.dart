/*
 * Copyright (c) 2018-2022 Taner Sener
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

import 'dart:async';
import 'dart:io';

import 'package:ffmpeg_kit_flutter_video/ffmpeg_kit_config.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

import 'util.dart';

class VideoUtil {
  static const String ASSET_1 = "machupicchu.jpg";
  static const String ASSET_2 = "pyramid.jpg";
  static const String ASSET_3 = "stonehenge.jpg";
  static const String SUBTITLE_ASSET = "subtitle.srt";
  static const String FONT_ASSET_1 = "doppioone_regular.ttf";
  static const String FONT_ASSET_2 = "truenorg.otf";

  static void registerApplicationFonts() {
    var fontNameMapping = Map<String, String>();
    fontNameMapping["MyFontName"] = "Doppio One";
    VideoUtil.tempDirectory.then((tempDirectory) {
      FFmpegKitConfig.setFontDirectoryList(
          [tempDirectory.path, "/system/fonts", "/System/Library/Fonts"],
          fontNameMapping);
      FFmpegKitConfig.setEnvironmentVariable(
          "FFREPORT",
          "file=" +
              new File(tempDirectory.path + "/" + today() + "-ffreport.txt")
                  .path);
    });
  }

  static void prepareAssets() async {
    await VideoUtil.assetToFile(ASSET_1);
    await VideoUtil.assetToFile(ASSET_2);
    await VideoUtil.assetToFile(ASSET_3);
    await VideoUtil.assetToFile(SUBTITLE_ASSET);
    await VideoUtil.assetToFile(FONT_ASSET_1);
    await VideoUtil.assetToFile(FONT_ASSET_2);
  }

  static Future<File> assetToFile(String assetName) async {
    final ByteData assetByteData = await rootBundle.load('assets/$assetName');

    final List<int> byteList = assetByteData.buffer
        .asUint8List(assetByteData.offsetInBytes, assetByteData.lengthInBytes);

    final String fullTemporaryPath =
        join((await tempDirectory).path, assetName);

    Future<File> fileFuture = new File(fullTemporaryPath)
        .writeAsBytes(byteList, mode: FileMode.writeOnly, flush: true);

    ffprint('assets/$assetName saved to file at $fullTemporaryPath.');

    return fileFuture;
  }

  static Future<String> assetPath(String assetName) async {
    return join((await tempDirectory).path, assetName);
  }

  static Future<Directory> get documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  static Future<Directory> get tempDirectory async {
    return await getTemporaryDirectory();
  }

  static String generateEncodeVideoScript(
      String image1Path,
      String image2Path,
      String image3Path,
      String videoFilePath,
      String videoCodec,
      String customOptions) {
    return generateEncodeVideoScriptWithCustomPixelFormat(
        image1Path,
        image2Path,
        image3Path,
        videoFilePath,
        videoCodec,
        "yuv420p",
        customOptions);
  }

  static generateEncodeVideoScriptWithCustomPixelFormat(
      String image1Path,
      String image2Path,
      String image3Path,
      String videoFilePath,
      String videoCodec,
      String pixelFormat,
      String customOptions) {
    return "-hide_banner -y -loop 1 -i '" +
        image1Path +
        "' " +
        "-loop   1 -i \"" +
        image2Path +
        "\" " +
        "-loop 1   -i \"" +
        image3Path +
        "\" " +
        "-filter_complex " +
        "\"[0:v]setpts=PTS-STARTPTS,scale=w='if(gte(iw/ih,640/427),min(iw,640),-1)':h='if(gte(iw/ih,640/427),-1,min(ih,427))',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];" +
        "[1:v]setpts=PTS-STARTPTS,scale=w='if(gte(iw/ih,640/427),min(iw,640),-1)':h='if(gte(iw/ih,640/427),-1,min(ih,427))',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];" +
        "[2:v]setpts=PTS-STARTPTS,scale=w='if(gte(iw/ih,640/427),min(iw,640),-1)':h='if(gte(iw/ih,640/427),-1,min(ih,427))',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];" +
        "[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];" +
        "[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream1ending];" +
        "[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];" +
        "[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];" +
        "[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];" +
        "[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream3starting];" +
        "[stream2starting][stream1ending]blend=all_expr='if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)':shortest=1[stream2blended];" +
        "[stream3starting][stream2ending]blend=all_expr='if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)':shortest=1[stream3blended];" +
        "[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=" +
        pixelFormat +
        "[video]\"" +
        " -map [video] -fps_mode cfr " +
        customOptions +
        "-c:v " +
        videoCodec +
        " -r 30 " +
        videoFilePath;
  }

  static String generateShakingVideoScript(
      final String image1Path,
      final String image2Path,
      final String image3Path,
      final String videoFilePath) {
    return "-hide_banner -y -loop 1 -i \"" +
        image1Path +
        "\" " +
        "-loop 1 -i '" +
        image2Path +
        "' " +
        "-loop 1 -i " +
        image3Path +
        " " +
        "-f lavfi -i color=black:s=640x427 " +
        "-filter_complex \"" +
        "[0:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream1out];" +
        "[1:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream2out];" +
        "[2:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1[stream3out];" +
        "[stream1out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream1overlaid];" +
        "[stream2out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream2overlaid];" +
        "[stream3out]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3[stream3overlaid];" +
        "[3:v][stream1overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream1shaking];" +
        "[3:v][stream2overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream2shaking];" +
        "[3:v][stream3overlaid]overlay=x=\'2*mod(n,4)\':y=\'2*mod(n,2)\',trim=duration=3[stream3shaking];" +
        "[stream1shaking][stream2shaking][stream3shaking]concat=n=3:v=1:a=0,scale=w=640:h=424,format=yuv420p[video]\"" +
        " -map [video] -fps_mode cfr -c:v mpeg4 -r 30 " +
        videoFilePath;
  }

  static String generateCreateVideoWithPipesScript(
      final String image1Pipe,
      final String image2Pipe,
      final String image3Pipe,
      final String videoFilePath) {
    return "-hide_banner -y -i \"" +
        image1Pipe +
        "\" " +
        "-i '" +
        image2Pipe +
        "' " +
        "-i " +
        image3Pipe +
        " " +
        "-filter_complex \"" +
        "[0:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];" +
        "[1:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];" +
        "[2:v]loop=loop=-1:size=1:start=0,setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];" +
        "[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];" +
        "[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream1ending];" +
        "[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];" +
        "[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];" +
        "[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];" +
        "[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream3starting];" +
        "[stream2starting][stream1ending]blend=all_expr=\'if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)\':shortest=1[stream2blended];" +
        "[stream3starting][stream2ending]blend=all_expr=\'if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)\':shortest=1[stream3blended];" +
        "[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=yuv420p[video]\"" +
        " -map [video] -fps_mode cfr -c:v mpeg4 -r 30 " +
        videoFilePath;
  }

  static generateZscaleVideoScript(inputVideoFilePath, outputVideoFilePath) {
    return "-y -i " +
        inputVideoFilePath +
        " -vf zscale=tin=smpte2084:min=bt2020nc:pin=bt2020:rin=tv:t=smpte2084:m=bt2020nc:p=bt2020:r=tv,zscale=t=linear,tonemap=tonemap=clip,zscale=t=bt709,format=yuv420p " +
        outputVideoFilePath;
  }
}
