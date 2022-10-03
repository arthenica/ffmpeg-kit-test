import React from 'react';
import {styles} from './style';
import {ffprint, notNull} from './util';
import {ScrollView, Text, TextInput, TouchableOpacity, View} from 'react-native';
import {FFmpegKitConfig, FFprobeKit} from "ffmpeg-kit-react-native";

const HTTPS_TEST_DEFAULT_URL = "https://download.blender.org/peach/trailer/trailer_1080p.ogg";

const HTTPS_TEST_FAIL_URL = "https://download2.blender.org/peach/trailer/trailer_1080p.ogg";

const HTTPS_TEST_RANDOM_URL_1 = "https://filesamples.com/samples/video/mov/sample_640x360.mov";

const HTTPS_TEST_RANDOM_URL_2 = "https://filesamples.com/samples/audio/mp3/sample3.mp3";

const HTTPS_TEST_RANDOM_URL_3 = "https://filesamples.com/samples/image/webp/sample1.webp";

export default class HttpsTab extends React.Component {

    constructor(props) {
        super(props);

        this.state = {
            urlText: '',
            outputText: ''
        };
    }

    componentDidMount() {
        this.props.navigation.addListener('focus', (_) => {
            this.clearOutput();
            this.setActive();
        });
    }

    setActive() {
        ffprint("Https Tab Activated");
        FFmpegKitConfig.enableLogCallback(undefined);
        FFmpegKitConfig.enableStatisticsCallback(undefined);
    }

    appendOutput(logMessage) {
        this.setState({outputText: this.state.outputText + logMessage});
    };

    clearOutput() {
        this.setState({outputText: ''});
    }

    getRandomTestUrl() {
        switch (Math.floor(Math.random() * 3)) {
            case 0:
                return HTTPS_TEST_RANDOM_URL_1;
            case 1:
                return HTTPS_TEST_RANDOM_URL_2;
            default:
                return HTTPS_TEST_RANDOM_URL_3;
        }
    }

    runGetMediaInformation = (buttonNumber) => {

        // SELECT TEST URL
        let testUrl = "";
        switch (buttonNumber) {
            case 1: {
                testUrl = this.state.urlText;
                if (testUrl === undefined || testUrl.trim().length <= 0) {
                    testUrl = HTTPS_TEST_DEFAULT_URL;
                    this.setState({urlText: testUrl});
                }
                break;
            }
            case 2:
            case 3: {
                testUrl = this.getRandomTestUrl();
                break;
            }
            case 4:
            default: {
                testUrl = HTTPS_TEST_FAIL_URL;
                this.setState({urlText: testUrl});
            }
        }

        ffprint(`Testing HTTPS with for button ${buttonNumber} using url ${testUrl}.`);

        if (buttonNumber === 4) {

            // ONLY THIS BUTTON CLEARS THE TEXT VIEW
            this.clearOutput();
        }

        // EXECUTE
        FFprobeKit.getMediaInformation(testUrl).then(async (session) => {
            const information = await session.getMediaInformation();

            if (information === undefined) {
                const state = FFmpegKitConfig.sessionStateToString(await session.getState());
                const returnCode = await session.getReturnCode();
                const failStackTrace = await session.getFailStackTrace();
                const duration = await session.getDuration();
                const output = await session.getOutput();

                this.appendOutput(`Get media information failed\n`);
                this.appendOutput(`State: ${state}\n`);
                this.appendOutput(`Duration: ${duration}\n`);
                this.appendOutput(`Return Code: ${returnCode}\n`);
                this.appendOutput(`Fail stack trace: ${notNull(failStackTrace, "\\n")}\n`);
                this.appendOutput(`Output: ${output}\n`);
            } else {
                this.appendOutput(`Media information for ${information.getFilename()}\n`);

                if (information.getFormat() !== undefined) {
                    this.appendOutput(`Format: ${information.getFormat()}\n`);
                }
                if (information.getBitrate() !== undefined) {
                    this.appendOutput(`Bitrate: ${information.getBitrate()}\n`);
                }
                if (information.getDuration() !== undefined) {
                    this.appendOutput(`Duration: ${information.getDuration()}\n`);
                }
                if (information.getStartTime() !== undefined) {
                    this.appendOutput(`Start time: ${information.getStartTime()}\n`);
                }
                if (information.getTags() !== undefined) {
                    let tags = information.getTags();
                    Object.keys(tags).forEach((key) => {
                        this.appendOutput(`Tag: ${key}:${tags[key]}\n`);
                    });
                }

                let streams = information.getStreams();
                if (streams !== undefined) {
                    for (let i = 0; i < streams.length; ++i) {
                        let stream = streams[i];
                        if (stream.getIndex() != null) {
                            this.appendOutput(`Stream index: ${stream.getIndex()}\n`);
                        }
                        if (stream.getType() != null) {
                            this.appendOutput(`Stream type: ${stream.getType()}\n`);
                        }
                        if (stream.getCodec() != null) {
                            this.appendOutput(`Stream codec: ${stream.getCodec()}\n`);
                        }
                        if (stream.getCodecLong() != null) {
                            this.appendOutput(`Stream codec long: ${stream.getCodecLong()}\n`);
                        }
                        if (stream.getFormat() != null) {
                            this.appendOutput(`Stream format: ${stream.getFormat()}\n`);
                        }
                        if (stream.getWidth() != null) {
                            this.appendOutput(`Stream width: ${stream.getWidth()}\n`);
                        }
                        if (stream.getHeight() != null) {
                            this.appendOutput(`Stream height: ${stream.getHeight()}\n`);
                        }
                        if (stream.getBitrate() != null) {
                            this.appendOutput(`Stream bitrate: ${stream.getBitrate()}\n`);
                        }
                        if (stream.getSampleRate() != null) {
                            this.appendOutput(`Stream sample rate: ${stream.getSampleRate()}\n`);
                        }
                        if (stream.getSampleFormat() != null) {
                            this.appendOutput(`Stream sample format: ${stream.getSampleFormat()}\n`);
                        }
                        if (stream.getChannelLayout() != null) {
                            this.appendOutput(`Stream channel layout: ${stream.getChannelLayout()}\n`);
                        }
                        if (stream.getSampleAspectRatio() != null) {
                            this.appendOutput(`Stream sample aspect ratio: ${stream.getSampleAspectRatio()}\n`);
                        }
                        if (stream.getDisplayAspectRatio() != null) {
                            this.appendOutput(`Stream display ascpect ratio: ${stream.getDisplayAspectRatio()}\n`);
                        }
                        if (stream.getAverageFrameRate() != null) {
                            this.appendOutput(`Stream average frame rate: ${stream.getAverageFrameRate()}\n`);
                        }
                        if (stream.getRealFrameRate() != null) {
                            this.appendOutput(`Stream real frame rate: ${stream.getRealFrameRate()}\n`);
                        }
                        if (stream.getTimeBase() != null) {
                            this.appendOutput(`Stream time base: ${stream.getTimeBase()}\n`);
                        }
                        if (stream.getCodecTimeBase() != null) {
                            this.appendOutput(`Stream codec time base: ${stream.getCodecTimeBase()}\n`);
                        }
                        if (stream.getTags() !== undefined) {
                            let tags = stream.getTags();
                            Object.keys(tags).forEach((key) => {
                                this.appendOutput(`Stream tag: ${key}:${tags[key]}\n`);
                            });
                        }
                    }
                }

                let chapters = information.getChapters();
                if (chapters !== undefined) {
                    for (let i = 0; i < chapters.length; ++i) {
                        let chapter = chapters[i];
                        if (chapter.getId() != null) {
                            this.appendOutput(`Chapter id: ${chapter.getId()}\n`);
                        }
                        if (chapter.getTimeBase() != null) {
                            this.appendOutput(`Chapter time base: ${chapter.getTimeBase()}\n`);
                        }
                        if (chapter.getStart() != null) {
                            this.appendOutput(`Chapter start: ${chapter.getStart()}\n`);
                        }
                        if (chapter.getStartTime() != null) {
                            this.appendOutput(`Chapter start time: ${chapter.getStartTime()}\n`);
                        }
                        if (chapter.getEnd() != null) {
                            this.appendOutput(`Chapter end: ${chapter.getEnd()}\n`);
                        }
                        if (chapter.getEndTime() != null) {
                            this.appendOutput(`Chapter end time: ${chapter.getEndTime()}\n`);
                        }
                        if (chapter.getTags() !== undefined) {
                            let tags = chapter.getTags();
                            Object.keys(tags).forEach((key) => {
                                this.appendOutput(`Chapter tag: ${key}:${tags[key]}\n`);
                            });
                        }
                    }
                }
            }
        });
    };

    render() {
        return (
            <View style={styles.screenStyle}>
                <View style={styles.headerViewStyle}>
                    <Text style={styles.headerTextStyle}>
                        FFmpegKit ReactNative
                    </Text>
                </View>
                <View style={[styles.textInputViewStyle, {paddingTop: 24, paddingBottom: 14}]}>
                    <TextInput
                        style={styles.textInputStyle}
                        autoCapitalize='none'
                        autoCorrect={false}
                        placeholder="Enter https url"
                        underlineColorAndroid="transparent"
                        onChangeText={(urlText) => this.setState({urlText})}
                        value={this.state.urlText}
                    />
                </View>
                <View style={[styles.buttonViewStyle, {paddingBottom: 0}]}>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 180, marginVertical: 10}]}
                        onPress={() => this.runGetMediaInformation(1)}>
                        <Text style={styles.buttonTextStyle}>GET INFO FROM URL</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 180, marginVertical: 10}]}
                        onPress={() => this.runGetMediaInformation(2)}>
                        <Text style={styles.buttonTextStyle}>GET RANDOM INFO</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 180, marginVertical: 10}]}
                        onPress={() => this.runGetMediaInformation(3)}>
                        <Text style={styles.buttonTextStyle}>GET RANDOM INFO</Text>
                    </TouchableOpacity>
                    <TouchableOpacity
                        style={[styles.buttonStyle, {width: 160, marginVertical: 10}]}
                        onPress={() => this.runGetMediaInformation(4)}>
                        <Text style={styles.buttonTextStyle}>GET INFO AND FAIL</Text>
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
            </View>
        );
    };

}
