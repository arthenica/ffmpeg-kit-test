import React from 'react';
import {ScrollView, Text, TextInput, TouchableOpacity, View} from 'react-native';
import {styles} from './style';
import {ffprint, listFFprobeSessions, notNull} from './util';
import {
    FFmpegKit,
    FFmpegKitConfig,
    FFprobeSession,
    Level,
    LogRedirectionStrategy,
    SessionState
} from "ffmpeg-kit-react-native";

export default class CommandTab extends React.Component {
    constructor(props) {
        super(props);

        this.state = {
            commandText: '', outputText: ''
        };
    }

    componentDidMount() {
        this.props.navigation.addListener('focus', (_) => {
            this.clearOutput();
            this.setActive();
        });
    }

    setActive() {
        ffprint("Command Tab Activated");
        FFmpegKitConfig.enableLogCallback(undefined);
        FFmpegKitConfig.enableStatisticsCallback(undefined);
    }

    appendOutput(logMessage) {
        this.setState({outputText: this.state.outputText + logMessage});
    };

    clearOutput() {
        this.setState({outputText: ''});
    }

    runFFmpeg = () => {
        this.clearOutput();

        let ffmpegCommand = this.state.commandText;

        ffprint(`Current log level is ${Level.levelToString(FFmpegKitConfig.getLogLevel())}.`);

        ffprint('Testing FFmpeg COMMAND asynchronously.');

        ffprint(`FFmpeg process started with arguments: \'${ffmpegCommand}\'.`);

        FFmpegKit.execute(ffmpegCommand).then(async (session) => {
            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
            const returnCode = await session.getReturnCode();
            const failStackTrace = await session.getFailStackTrace();
            const output = await session.getOutput();

            ffprint(`FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

            this.appendOutput(output);

            if (state === SessionState.FAILED || !returnCode.isValueSuccess()) {
                ffprint("Command failed. Please check output for the details.");
            }
        });
    };

    runFFprobe = () => {
        this.clearOutput();

        let ffprobeCommand = this.state.commandText;

        ffprint('Testing FFprobe COMMAND asynchronously.');

        ffprint(`FFprobe process started with arguments: \'${ffprobeCommand}\'.`);

        FFprobeSession.create(FFmpegKitConfig.parseArguments(ffprobeCommand), async (session) => {
            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
            const returnCode = await session.getReturnCode();
            const failStackTrace = await session.getFailStackTrace();
            session.getOutput().then(output => this.appendOutput(output));

            ffprint(`FFprobe process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

            if (state === SessionState.FAILED || !returnCode.isValueSuccess()) {
                ffprint("Command failed. Please check output for the details.");
            }

        }, undefined, LogRedirectionStrategy.NEVER_PRINT_LOGS).then(session => {
            FFmpegKitConfig.asyncFFprobeExecute(session);

            listFFprobeSessions();
        });
    };

    render() {
        return (<View style={styles.screenStyle}>
            <View style={styles.headerViewStyle}>
                <Text style={styles.headerTextStyle}>
                    FFmpegKit ReactNative
                </Text>
            </View>
            <View style={styles.textInputViewStyle}>
                <TextInput
                    style={styles.textInputStyle}
                    autoCapitalize='none'
                    autoCorrect={false}
                    placeholder="Enter command"
                    underlineColorAndroid="transparent"
                    onChangeText={(commandText) => this.setState({commandText})}
                    value={this.state.commandText}
                />
            </View>
            <View style={styles.buttonViewStyle}>
                <TouchableOpacity
                    style={styles.buttonStyle}
                    onPress={this.runFFmpeg}>
                    <Text style={styles.buttonTextStyle}>RUN FFMPEG</Text>
                </TouchableOpacity>
            </View>
            <View style={styles.buttonViewStyle}>
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
