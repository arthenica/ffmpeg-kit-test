import React from 'react';
import {Text, TouchableOpacity, View} from 'react-native';
import RNFS from 'react-native-fs';
import VideoUtil from './video-util';
import {FFmpegKit, FFmpegKitConfig, ReturnCode} from 'ffmpeg-kit-react-native';
import {styles} from './style';
import {ProgressModal} from "./progress_modal";
import Video from 'react-native-video';
import {deleteFile, ffprint, listAllStatistics, notNull} from './util';

export default class PipeTab extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            statistics: undefined
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
        ffprint("Pipe Tab Activated");
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

    createVideo = () => {
        let videoFile = this.getVideoFile();
        FFmpegKitConfig.registerNewFFmpegPipe().then((pipe1) => {
            FFmpegKitConfig.registerNewFFmpegPipe().then((pipe2) => {
                FFmpegKitConfig.registerNewFFmpegPipe().then((pipe3) => {

                    // IF VIDEO IS PLAYING STOP PLAYBACK
                    this.pause();

                    deleteFile(videoFile);

                    ffprint("Testing PIPE with 'mpeg4' codec");

                    this.hideProgressDialog();
                    this.showProgressDialog();

                    let ffmpegCommand = VideoUtil.generateCreateVideoWithPipesScript(pipe1, pipe2, pipe3, videoFile);

                    ffprint(`FFmpeg process started with arguments: \'${ffmpegCommand}\'.`);

                    FFmpegKit.executeAsync(ffmpegCommand, async (session) => {
                            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                            const returnCode = await session.getReturnCode();
                            const failStackTrace = await session.getFailStackTrace();

                            ffprint(`FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

                            this.hideProgressDialog();

                            // CLOSE PIPES
                            FFmpegKitConfig.closeFFmpegPipe(pipe1);
                            FFmpegKitConfig.closeFFmpegPipe(pipe2);
                            FFmpegKitConfig.closeFFmpegPipe(pipe3);

                            if (ReturnCode.isSuccess(returnCode)) {
                                ffprint("Create completed successfully; playing video.");
                                this.playVideo();
                                listAllStatistics(session);
                            } else {
                                ffprint("Create failed. Please check log for the details.");
                            }
                        }
                    );

                    FFmpegKitConfig.writeToPipe(VideoUtil.assetPath(VideoUtil.ASSET_1), pipe1);
                    FFmpegKitConfig.writeToPipe(VideoUtil.assetPath(VideoUtil.ASSET_2), pipe2);
                    FFmpegKitConfig.writeToPipe(VideoUtil.assetPath(VideoUtil.ASSET_3), pipe3);
                });
            });
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

    showProgressDialog() {
        // CLEAN STATISTICS
        this.setState({statistics: undefined});
        this.progressModalReference.current.show(`Creating video`);
    }

    updateProgressDialog() {
        let statistics = this.state.statistics;
        if (statistics === undefined || statistics.getTime() < 0) {
            return;
        }

        let timeInMilliseconds = statistics.getTime();
        let totalVideoDuration = 9000;
        let completePercentage = Math.round((timeInMilliseconds * 100) / totalVideoDuration);
        this.progressModalReference.current.update(`Creating video % ${completePercentage}`);
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
                        style={styles.buttonStyle}
                        onPress={this.createVideo}>
                        <Text style={styles.buttonTextStyle}>CREATE</Text>
                    </TouchableOpacity>
                </View>
                <ProgressModal
                    visible={false}
                    ref={this.progressModalReference}/>
                <Video source={{uri: this.getVideoFile()}}
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
