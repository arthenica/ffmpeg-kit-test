import {Platform} from 'react-native';
import RNFS from 'react-native-fs';
import {ffprint} from './util';

export default class VideoUtil {
    static get ASSET_1() {
        return "machupicchu.jpg";
    }

    static get ASSET_2() {
        return "pyramid.jpg";
    }

    static get ASSET_3() {
        return "stonehenge.jpg";
    }

    static get SUBTITLE_ASSET() {
        return "subtitle.srt";
    }

    static get FONT_ASSET_1() {
        return "doppioone_regular.ttf";
    }

    static get FONT_ASSET_2() {
        return "truenorg.otf";
    }

    static async prepareAssets() {
        await VideoUtil.assetToFile(VideoUtil.ASSET_1);
        await VideoUtil.assetToFile(VideoUtil.ASSET_2);
        await VideoUtil.assetToFile(VideoUtil.ASSET_3);
        await VideoUtil.assetToFile(VideoUtil.SUBTITLE_ASSET);
        await VideoUtil.assetToFile(VideoUtil.FONT_ASSET_1);
        await VideoUtil.assetToFile(VideoUtil.FONT_ASSET_2);
    }

    static async assetToFile(assetName) {
        let fullTemporaryPath = VideoUtil.assetPath(assetName);

        if (Platform.OS === 'android') {
            await RNFS.copyFileAssets(assetName, fullTemporaryPath)
                .then(_ => ffprint(`Asset ${assetName} saved to file at ${fullTemporaryPath}.`))
                .catch((err) => {
                    ffprint(`Failed to save asset ${assetName} to file at ${fullTemporaryPath}, err message: ${err.message}, err code: ${err.code}`);
                });
        } else {
            ffprint(`Asset ${assetName} loaded as file at ${fullTemporaryPath}.`);
        }

        return fullTemporaryPath;
    }

    static assetPath(assetName) {
        if (Platform.OS === 'ios') {
            return VideoUtil.iosAssetPath(assetName);
        } else {
            return VideoUtil.androidAssetPath(assetName);
        }
    }

    static androidAssetPath(assetName) {
        return `${RNFS.CachesDirectoryPath}/${assetName}`;
    }

    static iosAssetPath(assetName) {
        return `${RNFS.MainBundlePath}/${assetName}`;
    }

    static generateEncodeVideoScript(image1Path, image2Path, image3Path, videoFilePath, videoCodec, customOptions) {
        return VideoUtil.generateEncodeVideoScriptWithCustomPixelFormat(image1Path, image2Path, image3Path, videoFilePath, videoCodec, "yuv420p", customOptions);
    }

    static generateEncodeVideoScriptWithCustomPixelFormat(image1Path, image2Path, image3Path, videoFilePath, videoCodec, pixelFormat, customOptions) {
        return "-hide_banner -y -loop 1 -i '" + image1Path + "'   " +
            "-loop 1 -i   \"" + image2Path + "\" " +
            "-loop 1 -i  \"" + image3Path + "\" " +
            "-filter_complex " +
            "\"[0:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream1out1][stream1out2];" +
            "[1:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream2out1][stream2out2];" +
            "[2:v]setpts=PTS-STARTPTS,scale=w=\'if(gte(iw/ih,640/427),min(iw,640),-1)\':h=\'if(gte(iw/ih,640/427),-1,min(ih,427))\',scale=trunc(iw/2)*2:trunc(ih/2)*2,setsar=sar=1/1,split=2[stream3out1][stream3out2];" +
            "[stream1out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=3,select=lte(n\\,90)[stream1overlaid];" +
            "[stream1out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream1ending];" +
            "[stream2out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream2overlaid];" +
            "[stream2out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30),split=2[stream2starting][stream2ending];" +
            "[stream3out1]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=2,select=lte(n\\,60)[stream3overlaid];" +
            "[stream3out2]pad=width=640:height=427:x=(640-iw)/2:y=(427-ih)/2:color=#00000000,trim=duration=1,select=lte(n\\,30)[stream3starting];" +
            "[stream2starting][stream1ending]blend=all_expr=\'if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)\':shortest=1[stream2blended];" +
            "[stream3starting][stream2ending]blend=all_expr=\'if(gte(X,(W/2)*T/1)*lte(X,W-(W/2)*T/1),B,A)\':shortest=1[stream3blended];" +
            "[stream1overlaid][stream2blended][stream2overlaid][stream3blended][stream3overlaid]concat=n=5:v=1:a=0,scale=w=640:h=424,format=" + pixelFormat + "[video]\"" +
            " -map [video] -vsync 2 -async 1 " + customOptions + "-c:v " + videoCodec.toLowerCase() + " -r 30 " + videoFilePath;
    }

    static generateShakingVideoScript(image1Path, image2Path, image3Path, videoFilePath) {
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
            " -map [video] -vsync 2 -async 1 -c:v mpeg4 -r 30 " + videoFilePath;
    }

    static generateCreateVideoWithPipesScript(image1Pipe, image2Pipe, image3Pipe, videoFilePath) {
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
            " -map [video] -vsync 2 -async 1 -c:v mpeg4 -r 30 " + videoFilePath;
    }

    static generateZscaleVideoScript(inputVideoFilePath, outputVideoFilePath) {
        return "-y -i " +
            inputVideoFilePath +
            " -vf zscale=tin=smpte2084:min=bt2020nc:pin=bt2020:rin=tv:t=smpte2084:m=bt2020nc:p=bt2020:r=tv,zscale=t=linear,tonemap=tonemap=clip,zscale=t=bt709,format=yuv420p " +
            outputVideoFilePath;
    }

}
