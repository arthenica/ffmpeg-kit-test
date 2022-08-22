import {FFmpegKit, FFmpegKitConfig, FFprobeKit, Level} from "ffmpeg-kit-react-native";
import RNFS from 'react-native-fs';

export function today() {
    let now = new Date();
    return `${now.getFullYear()}-${now.getMonth()}-${now.getDate()}`;
}

export function now() {
    let now = new Date();
    return `${now.getFullYear()}-${now.getMonth()}-${now.getDate()} ${now.getHours()}:${now.getMinutes()}:${now.getSeconds()}.${now.getMilliseconds()}`;
}

export function ffprint(text) {
    console.log(text.endsWith('\n') ? text.replace('\n', '') : text);
}

export function notNull(string, valuePrefix) {
    return (string === undefined || string == null) ? "" : valuePrefix.concat(string);
}

export function listFFprobeSessions() {
    FFprobeKit.listFFprobeSessions().then(sessionList => {
        ffprint(`Listing ${sessionList.length} FFprobe sessions asynchronously.`);

        let count = 0;
        sessionList.forEach(async session => {
            const sessionId = session.getSessionId();
            const startTime = session.getStartTime();
            const duration = await session.getDuration();
            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
            const returnCode = await session.getReturnCode();

            ffprint(`Session ${count++} = id:${sessionId}, startTime:${startTime}, duration:${duration}, state:${state}, returnCode:${returnCode}.`);
        });
    });
}

export function listFFmpegSessions() {
    FFmpegKit.listSessions().then(sessionList => {
        ffprint(`Listing ${sessionList.length} FFmpeg sessions asynchronously.`);

        let count = 0;
        sessionList.forEach(async session => {
            const sessionId = session.getSessionId();
            const startTime = session.getStartTime();
            const duration = await session.getDuration();
            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
            const returnCode = await session.getReturnCode();

            ffprint(`Session ${count++} = id:${sessionId}, startTime:${startTime}, duration:${duration}, state:${state}, returnCode:${returnCode}.`);
        });
    });
}

export async function registerApplicationFonts() {
    let fontNameMapping = new Map();
    fontNameMapping["MyFontName"] = "Doppio One";
    await FFmpegKitConfig.setFontDirectoryList([RNFS.CachesDirectoryPath, "/system/fonts", "/System/Library/Fonts"], fontNameMapping);
    await FFmpegKitConfig.setEnvironmentVariable("FFREPORT", "file=" +
        RNFS.CachesDirectoryPath + "/" + today() + "-ffreport.txt");
}

export async function deleteFile(videoFile) {
    return RNFS.unlink(videoFile).catch(_ => _);
}

export async function listAllLogs(session) {
    ffprint(`Listing log entries for session: ${session.getSessionId()}`);
    let allLogs = await session.getAllLogs();
    allLogs.forEach((element) => {
        ffprint(
            `${Level.levelToString(element.getLevel())}:${element.getMessage()}`);
    });
    ffprint(`Listed log entries for session: ${session.getSessionId()}`);
}

export async function listAllStatistics(session) {
    ffprint(`Listing statistics entries for session: ${session.getSessionId()}`);
    let allStatistics = await session.getAllStatistics();

    allStatistics.forEach((s) => {
        ffprint(
            `${s.getVideoFrameNumber()}:${s.getVideoFps()}:${s.getVideoQuality()}:${s.getSize()}:${s.getTime()}:${s.getBitrate()}:${s.getSpeed()}`);
    });
    ffprint(`Listed statistics entries for session: ${session.getSessionId()}`);
}
