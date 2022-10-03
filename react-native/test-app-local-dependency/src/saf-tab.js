import React from 'react';
import {ScrollView, Text, TouchableOpacity, View} from 'react-native';
import {styles} from './style';
import {FFmpegKit, FFmpegKitConfig, FFprobeKit, ReturnCode} from 'ffmpeg-kit-react-native';
import {ffprint, notNull} from './util';
import VideoUtil from "./video-util";
import {ProgressModal} from "./progress_modal";

export default class SafTab extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            outputText: ''
        };

        this.progressModalReference = React.createRef();
    }

    componentDidMount() {
        this.props.navigation.addListener('focus', (_) => {
            this.clearOutput();
            this.setActive();
        });
    }

    setActive() {
        ffprint("SAF Tab Activated");
        FFmpegKitConfig.enableLogCallback(this.logCallback);
        FFmpegKitConfig.enableStatisticsCallback(this.statisticsCallback);
    }

    logCallback = (log) => {
        this.appendOutput(log.getMessage());
    }

    statisticsCallback = (statistics) => {
        this.setState({statistics: statistics});
        this.updateProgressDialog();
    }

    appendOutput(logMessage) {
        this.setState({outputText: this.state.outputText + logMessage});
    };

    clearOutput() {
        this.setState({outputText: ''});
    }

    runFFprobe = () => {
        FFmpegKitConfig.selectDocumentForRead('*/*', ['image/*', 'video/*', 'audio/*'])
            .then(uri => {
                FFmpegKitConfig.getSafParameterForRead(uri)
                    .then(safUrl => {
                        this.clearOutput();

                        let ffprobeCommand = `-hide_banner -print_format json -show_format -show_streams ${safUrl}`;

                        ffprint('Testing FFprobe COMMAND synchronously.');

                        ffprint(`FFprobe process started with arguments: \'${ffprobeCommand}\'.`);

                        FFprobeKit.execute(ffprobeCommand).then(async (session) => {
                            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                            const returnCode = await session.getReturnCode();
                            const failStackTrace = await session.getFailStackTrace();

                            ffprint(`FFprobe process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

                            if (!ReturnCode.isSuccess(returnCode)) {
                                ffprint("Command failed. Please check output for the details.");
                            }
                        });
                    });
            })
            .catch(err => ffprint('Select file failed: ' + err));
    };

    encodeVideo = () => {
        FFmpegKitConfig.selectDocumentForWrite('video.mp4', 'video/*')
            .then(uri => {
                FFmpegKitConfig.getSafParameter(uri, "rw")
                    .then(safUrl => {
                        let image1Path = VideoUtil.assetPath(VideoUtil.ASSET_1);
                        let image2Path = VideoUtil.assetPath(VideoUtil.ASSET_2);
                        let image3Path = VideoUtil.assetPath(VideoUtil.ASSET_3);
                        let videoFile = safUrl;

                        let videoCodec = 'mpeg4';

                        ffprint(`Testing VIDEO encoding with '${videoCodec}' codec`);

                        this.hideProgressDialog();
                        this.showProgressDialog();

                        let ffmpegCommand = VideoUtil.generateEncodeVideoScript(image1Path, image2Path, image3Path, videoFile, videoCodec, '');

                        ffprint(`FFmpeg process started with arguments: \'${ffmpegCommand}\'.`);

                        FFmpegKit.executeAsync(ffmpegCommand, async (session) => {
                            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                            const returnCode = await session.getReturnCode();
                            const failStackTrace = await session.getFailStackTrace();

                            ffprint(`FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

                            this.hideProgressDialog();

                            if (ReturnCode.isSuccess(returnCode)) {
                                ffprint(`Encode completed successfully.`);
                            } else {
                                ffprint("Encode failed. Please check log for the details.");
                            }
                        }).then(session => ffprint(`Async FFmpeg process started with sessionId ${session.getSessionId()}.`));
                    });
            })
            .catch(err => ffprint('Select file failed: ' + err));
    }

    showProgressDialog() {
        // CLEAN STATISTICS
        this.setState({statistics: undefined});
        this.progressModalReference.current.show(`Encoding video`);
    }

    updateProgressDialog() {
        let statistics = this.state.statistics;
        if (statistics === undefined || statistics.getTime() < 0) {
            return;
        }

        let timeInMilliseconds = statistics.getTime();
        let totalVideoDuration = 9000;
        let completePercentage = Math.round((timeInMilliseconds * 100) / totalVideoDuration);
        this.progressModalReference.current.update(`Encoding video % ${completePercentage}`);
    }

    hideProgressDialog() {
        this.progressModalReference.current.hide();
    }

    render() {
        return (<View style={styles.screenStyle}>
                <View style={styles.headerViewStyle}>
                    <Text style={styles.headerTextStyle}>
                        FFmpegKit ReactNative
                    </Text>
                </View>
                <View style={[styles.buttonViewStyle, {paddingTop: 30}]}>
                    <TouchableOpacity
                        style={styles.buttonStyle}
                        onPress={this.encodeVideo}>
                        <Text style={styles.buttonTextStyle}>RUN FFMPEG</Text>
                    </TouchableOpacity>
                </View>
                <ProgressModal
                    visible={false}
                    ref={this.progressModalReference}/>
                <View style={[styles.buttonViewStyle, {paddingBottom: 10}]}>
                    <TouchableOpacity
                        style={styles.buttonStyle}
                        onPress={this.runFFprobe}>
                        <Text style={styles.buttonTextStyle}>RUN FFPROBE</Text>
                    </TouchableOpacity>
                </View>
                <View style={styles.outputViewStyle}>
                    <ScrollView
                        ref={(view) => {
                            this.scrollViewReference = view;
                        }}
                        onContentSizeChange={(width, height) => this.scrollViewReference.scrollTo({y: height})}
                        style={styles.outputScrollViewStyle}>
                        <Text style={styles.outputTextStyle}>{this.state.outputText}</Text>
                    </ScrollView>
                </View>
            </View>);
    };

}
