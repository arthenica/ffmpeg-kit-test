import React from 'react';
import {Text, TouchableOpacity, View} from 'react-native';
import RNFS from 'react-native-fs';
import VideoUtil from './video-util';
import {FFmpegKit, FFmpegKitConfig, ReturnCode} from 'ffmpeg-kit-react-native';
import {styles} from './style';
import {ProgressModal} from "./progress_modal";
import Video from 'react-native-video';
import {deleteFile, ffprint, notNull} from './util';

export default class VidStabTab extends React.Component {
    constructor(props) {
        super(props);

        this.state = {};

        this.progressModalReference = React.createRef();
    }

    componentDidMount() {
        this.props.navigation.addListener('focus', (_) => {
            this.pauseVideo();
            this.pauseStabilizedVideo();
            this.setActive();
        });
    }

    setActive() {
        ffprint("VidStab Tab Activated");
        FFmpegKitConfig.enableLogCallback(this.logCallback);
        FFmpegKitConfig.enableStatisticsCallback(undefined);
    }

    logCallback = (log) => {
        ffprint(log.getMessage());
    }

    stabilizeVideo = () => {
        let image1Path = VideoUtil.assetPath(VideoUtil.ASSET_1);
        let image2Path = VideoUtil.assetPath(VideoUtil.ASSET_2);
        let image3Path = VideoUtil.assetPath(VideoUtil.ASSET_3);
        let shakeResultsFile = this.getShakeResultsFile();
        let videoFile = this.getVideoFile();
        let stabilizedVideoFile = this.getStabilizedVideoFile();

        // IF VIDEO IS PLAYING STOP PLAYBACK
        this.pauseVideo();
        this.pauseStabilizedVideo();

        deleteFile(shakeResultsFile);
        deleteFile(videoFile);
        deleteFile(stabilizedVideoFile);

        ffprint("Testing VID.STAB");

        this.hideProgressDialog();
        this.showCreateProgressDialog();

        let ffmpegCommand = VideoUtil.generateShakingVideoScript(image1Path, image2Path, image3Path, videoFile);

        ffprint(`FFmpeg process started with arguments: \'${ffmpegCommand}\'.`);

        FFmpegKit.executeAsync(ffmpegCommand, async (session) => {
                const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                const returnCode = await session.getReturnCode();
                const failStackTrace = await session.getFailStackTrace();

                ffprint(`FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

                this.hideProgressDialog();

                if (ReturnCode.isSuccess(returnCode)) {

                    ffprint("Create completed successfully; stabilizing video.");

                    let analyzeVideoCommand = `-y -i ${videoFile} -vf vidstabdetect=shakiness=10:accuracy=15:result=${shakeResultsFile} -f null -`;

                    this.showStabilizeProgressDialog();

                    ffprint(`FFmpeg process started with arguments: \'${analyzeVideoCommand}\'.`);

                    FFmpegKit.executeAsync(analyzeVideoCommand, async (secondSession) => {
                        const secondState = FFmpegKitConfig.sessionStateToString(await secondSession.getState());
                        const secondReturnCode = await secondSession.getReturnCode();
                        const secondFailStackTrace = await secondSession.getFailStackTrace();

                        ffprint(`FFmpeg process exited with state ${secondState} and rc ${secondReturnCode}.${notNull(secondFailStackTrace, "\\n")}`);

                        if (ReturnCode.isSuccess(secondReturnCode)) {

                            let stabilizeVideoCommand = `-y -i ${videoFile} -vf vidstabtransform=smoothing=30:input=${shakeResultsFile} -c:v mpeg4 ${stabilizedVideoFile}`;

                            ffprint(`FFmpeg process started with arguments: \'${stabilizeVideoCommand}\'.`);

                            FFmpegKit.executeAsync(stabilizeVideoCommand, async (thirdSession) => {
                                const thirdState = FFmpegKitConfig.sessionStateToString(await thirdSession.getState());
                                const thirdReturnCode = await thirdSession.getReturnCode();
                                const thirdFailStackTrace = await thirdSession.getFailStackTrace();

                                ffprint(`FFmpeg process exited with state ${thirdState} and rc ${thirdReturnCode}.${notNull(thirdFailStackTrace, "\\n")}`);

                                this.hideProgressDialog();

                                if (ReturnCode.isSuccess(thirdReturnCode)) {
                                    ffprint("Stabilize video completed successfully; playing videos.");
                                    this.playVideo();
                                    this.playStabilizedVideo();
                                } else {
                                    ffprint("Stabilize video failed. Please check log for the details.");
                                }
                            });
                        } else {
                            this.hideProgressDialog();
                            ffprint("Stabilize video failed. Please check log for the details.");
                        }
                    });
                } else {
                    ffprint("Create video failed. Please check log for the details.");
                }
            }
        );
    }

    playVideo() {
        let player = this.videoPlayer;
        if (player !== undefined) {
            player.seek(0);
        }
        this.setState({videoPaused: false});
    }

    pauseVideo() {
        this.setState({videoPaused: true});
    }

    playStabilizedVideo() {
        let player = this.stabilizedVideoPlayer;
        if (player !== undefined) {
            player.seek(0);
        }
        this.setState({stabilizedVideoPaused: false});
    }

    pauseStabilizedVideo() {
        this.setState({stabilizedVideoPaused: true});
    }

    getShakeResultsFile() {
        return `${RNFS.CachesDirectoryPath}/transforms.trf`;
    }

    getVideoFile() {
        return `${RNFS.CachesDirectoryPath}/video-shaking.mp4`;
    }

    getStabilizedVideoFile() {
        return `${RNFS.CachesDirectoryPath}/video-stabilized.mp4`;
    }

    showCreateProgressDialog() {
        this.progressModalReference.current.show(`Creating video`);
    }

    showStabilizeProgressDialog() {
        this.progressModalReference.current.update(`Stabilizing video`);
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
                <Video source={{uri: this.getVideoFile()}}
                       ref={(ref) => {
                           this.videoPlayer = ref
                       }}
                       hideShutterView={true}
                       paused={this.state.videoPaused}
                    // onError={this.onPlayError}
                       resizeMode={"stretch"}
                       style={styles.halfSizeVideoPlayerViewStyle}/>

                <View style={[styles.buttonViewStyle, {paddingTop: 0, paddingBottom: 0}]}>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 160}]}
                        onPress={this.stabilizeVideo}>
                        <Text style={styles.buttonTextStyle}>STABILIZE VIDEO</Text>
                    </TouchableOpacity>
                </View>
                <ProgressModal
                    visible={false}
                    ref={this.progressModalReference}/>
                <Video source={{uri: this.getStabilizedVideoFile()}}
                       ref={(ref) => {
                           this.stabilizedVideoPlayer = ref
                       }}
                       hideShutterView={true}
                       paused={this.state.stabilizedVideoPaused}
                    // onError={this.onPlayError}
                       resizeMode={"stretch"}
                       style={styles.halfSizeVideoPlayerViewStyle}/>
            </View>
        );
    }

}
