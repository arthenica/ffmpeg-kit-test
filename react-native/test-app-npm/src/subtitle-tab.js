import React from 'react';
import {Text, TouchableOpacity, View} from 'react-native';
import RNFS from 'react-native-fs';
import VideoUtil from './video-util';
import {FFmpegKit, FFmpegKitConfig, ReturnCode} from 'ffmpeg-kit-react-native';
import {styles} from './style';
import {ProgressModal} from "./progress_modal";
import Video from 'react-native-video';
import {deleteFile, ffprint, notNull} from './util';

export default class SubtitleTab extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            state: 'IDLE',
            statistics: undefined,
            sessionId: 0
        };

        this.progressModalReference = React.createRef();
    }

    componentDidMount() {
        this.props.navigation.addListener('focus', (_) => {
            this.pause();
            this.setActive();
        });
    }

    setActive() {
        ffprint("Subtitle Tab Activated");
        FFmpegKitConfig.enableLogCallback(this.logCallback);
        FFmpegKitConfig.enableStatisticsCallback(this.statisticsCallback);
    }

    logCallback = (log) => {
        ffprint(log.getMessage());
    }

    statisticsCallback = (statistics) => {
        this.setState({statistics: statistics});
        this.updateProgressDialog();
    }

    burnSubtitles = () => {
        let image1Path = VideoUtil.assetPath(VideoUtil.ASSET_1);
        let image2Path = VideoUtil.assetPath(VideoUtil.ASSET_2);
        let image3Path = VideoUtil.assetPath(VideoUtil.ASSET_3);
        let subtitlePath = VideoUtil.assetPath(VideoUtil.SUBTITLE_ASSET);
        let videoFile = this.getVideoFile();
        let videoWithSubtitlesFile = this.getVideoWithSubtitlesFile();

        // IF VIDEO IS PLAYING STOP PLAYBACK
        this.pause();

        deleteFile(videoFile);
        deleteFile(videoWithSubtitlesFile);

        ffprint("Testing SUBTITLE burning");

        this.hideProgressDialog();
        this.showCreateProgressDialog();

        let ffmpegCommand = VideoUtil.generateEncodeVideoScript(image1Path, image2Path, image3Path, videoFile, "mpeg4", "");

        this.setState({state: 'CREATING'});

        FFmpegKit.executeAsync(ffmpegCommand, async (session) => {
                const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                const returnCode = await session.getReturnCode();
                const failStackTrace = await session.getFailStackTrace();

                ffprint(`FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

                if (ReturnCode.isSuccess(returnCode)) {
                    ffprint("Create completed successfully; burning subtitles.");

                    let burnSubtitlesCommand = `-y -i ${videoFile} -vf subtitles=${subtitlePath}:force_style='FontName=MyFontName' -c:v mpeg4 ${videoWithSubtitlesFile}`;

                    this.showBurnProgressDialog();

                    ffprint(`FFmpeg process started with arguments\n\'${burnSubtitlesCommand}\'.`);

                    this.setState({state: 'BURNING'});

                    FFmpegKit.executeAsync(burnSubtitlesCommand, async (secondSession) => {
                        this.hideProgressDialog();

                        const secondState = FFmpegKitConfig.sessionStateToString(await secondSession.getState());
                        const secondReturnCode = await secondSession.getReturnCode();
                        const secondFailStackTrace = await secondSession.getFailStackTrace();

                        if (ReturnCode.isSuccess(secondReturnCode)) {
                            ffprint("Burn subtitles completed successfully; playing video.");
                            this.playVideo();
                        } else if (ReturnCode.isCancel(secondReturnCode)) {
                            ffprint("Burn subtitles operation cancelled.");
                            ffprint("Burn subtitles operation cancelled");
                        } else {
                            ffprint("Burn subtitles failed. Please check log for the details.");
                            ffprint(`Burn subtitles failed with state ${secondState} and rc ${secondReturnCode}.${notNull(secondFailStackTrace, "\\n")}`);
                        }
                    }).then(session => {
                        this.setState({sessionId: session.getSessionId()});
                    });
                } else {
                    this.hideProgressDialog();
                }
            }
        ).then(session => {
            this.setState({sessionId: session.getSessionId()});
            ffprint(`Async FFmpeg process started with sessionId ${session.getSessionId()}.`)
        });
    }

    playVideo() {
        let player = this.player;
        if (player !== undefined) {
            player.seek(0);
        }
        this.setState({paused: false});
    }

    pause() {
        this.setState({paused: true});
    }

    getVideoFile() {
        return `${RNFS.CachesDirectoryPath}/video.mp4`;
    }

    getVideoWithSubtitlesFile() {
        return `${RNFS.CachesDirectoryPath}/video-with-subtitles.mp4`;
    }

    showCreateProgressDialog() {
        // CLEAN STATISTICS
        this.setState({statistics: undefined});
        this.progressModalReference.current.show(`Creating video`, () => FFmpegKit.cancel(this.state.sessionId));
    }

    showBurnProgressDialog() {
        // CLEAN STATISTICS
        this.setState({statistics: undefined});
        this.progressModalReference.current.show(`Burning subtitles`, () => FFmpegKit.cancel(this.state.sessionId));
    }

    updateProgressDialog() {
        let statistics = this.state.statistics;
        if (statistics === undefined || statistics.getTime() < 0) {
            return;
        }

        let timeInMilliseconds = statistics.getTime();
        let totalVideoDuration = 9000;
        let completePercentage = Math.round((timeInMilliseconds * 100) / totalVideoDuration);

        if (this.state.state === 'CREATING') {
            this.progressModalReference.current.update(`Creating video % ${completePercentage}`);
        } else if (this.state.state === 'BURNING') {
            this.progressModalReference.current.update(`Burning subtitles % ${completePercentage}`);
        }
    }

    hideProgressDialog() {
        this.progressModalReference.current.hide();
    }

    onPlayError = (err) => {
        ffprint('Play error: ' + JSON.stringify(err));
    }

    render() {
        return (
            <View style={styles.screenStyle}>
                <View style={styles.headerViewStyle}>
                    <Text
                        style={styles.headerTextStyle}>
                        FFmpegKit ReactNative
                    </Text>
                </View>
                <View style={[styles.buttonViewStyle, {paddingTop: 50, paddingBottom: 50}]}>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 160}]}
                        onPress={this.burnSubtitles}>
                        <Text style={styles.buttonTextStyle}>BURN SUBTITLES</Text>
                    </TouchableOpacity>
                </View>
                <ProgressModal
                    visible={false}
                    ref={this.progressModalReference}/>
                <Video source={{uri: this.getVideoWithSubtitlesFile()}}
                       ref={(ref) => {
                           this.player = ref
                       }}
                       hideShutterView={true}
                       paused={this.state.paused}
                    // onError={this.onPlayError}
                       resizeMode={"stretch"}
                       style={styles.videoPlayerViewStyle}/>
            </View>
        );
    }

}
