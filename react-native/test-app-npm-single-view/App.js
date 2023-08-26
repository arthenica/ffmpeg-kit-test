import React, { Component } from 'react'
import {
    Platform,
    ScrollView,
    StyleSheet,
    Text, TextInput, TouchableOpacity,
    View,
} from 'react-native';
import {
    FFmpegKit,
    FFmpegKitConfig, FFprobeSession, Level, LogRedirectionStrategy, SessionState
} from "ffmpeg-kit-react-native";

function notNull(string, valuePrefix) {
    return (string === undefined || string == null) ? "" : valuePrefix.concat(string);
}

class App extends Component {
    constructor(props) {
        super(props);

        this.state = {
            commandText: '', outputText: ''
        };
    }

    componentDidMount() {
        this.clearOutput();
        this.setActive();
    }

    setActive() {
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

        console.log(`Current log level is ${Level.levelToString(FFmpegKitConfig.getLogLevel())}.`);

        console.log('Testing FFmpeg COMMAND asynchronously.');

        console.log(`FFmpeg process started with arguments: \'${ffmpegCommand}\'.`);

        FFmpegKit.execute(ffmpegCommand).then(async (session) => {
            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
            const returnCode = await session.getReturnCode();
            const failStackTrace = await session.getFailStackTrace();
            const output = await session.getOutput();

            console.log(`FFmpeg process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

            this.appendOutput(output);

            if (state === SessionState.FAILED || !returnCode.isValueSuccess()) {
                console.log("Command failed. Please check output for the details.");
            }
        });
    };

    runFFprobe = () => {
        this.clearOutput();

        let ffprobeCommand = this.state.commandText;

        console.log('Testing FFprobe COMMAND asynchronously.');

        console.log(`FFprobe process started with arguments: \'${ffprobeCommand}\'.`);

        FFprobeSession.create(FFmpegKitConfig.parseArguments(ffprobeCommand), async (session) => {
            const state = FFmpegKitConfig.sessionStateToString(await session.getState());
            const returnCode = await session.getReturnCode();
            const failStackTrace = await session.getFailStackTrace();
            session.getOutput().then(output => this.appendOutput(output));

            console.log(`FFprobe process exited with state ${state} and rc ${returnCode}.${notNull(failStackTrace, "\\n")}`);

            if (state === SessionState.FAILED || !returnCode.isValueSuccess()) {
                console.log("Command failed. Please check output for the details.");
            }

        }, undefined, LogRedirectionStrategy.NEVER_PRINT_LOGS).then(session => {
            FFmpegKitConfig.asyncFFprobeExecute(session);
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
    }
}

const styles = StyleSheet.create({
    screenStyle: {
        flex: 1,
        justifyContent: 'flex-start',
        alignItems: 'stretch',
        marginTop: Platform.select({ios: 20, android: 0})
    },
    headerViewStyle: {
        paddingTop: 16,
        paddingBottom: 10,
        backgroundColor: '#F46842'
    },
    headerTextStyle: {
        alignSelf: 'center',
        height: 32,
        fontSize: 18,
        fontWeight: 'bold',
        color: '#fff',
        borderColor: 'lightgray',
        borderRadius: 5,
        borderWidth: 0
    },
    buttonViewStyle: {
        alignSelf: 'center',
        paddingBottom: 20
    },
    buttonStyle: {
        justifyContent: 'center',
        alignSelf: 'center',
        width: 120,
        height: 38,
        backgroundColor: '#2ecc71',
        borderColor: '#27AE60',
        borderRadius: 5,
        paddingLeft: 10,
        paddingRight: 10
    },
    cancelButtonStyle: {
        justifyContent: 'center',
        width: 100,
        height: 38,
        backgroundColor: '#c5c5c5',
        borderRadius: 5
    },
    buttonTextStyle: {
        textAlign: 'center',
        fontSize: 14,
        fontWeight: 'bold',
        color: '#fff'
    },
    videoPlayerViewStyle: {
        backgroundColor: '#ECF0F1',
        borderColor: '#B9C3C7',
        borderRadius: 5,
        borderWidth: 1,
        height: window.height - 310,
        width: window.width - 40,
        marginVertical: 20,
        marginHorizontal: 20
    },
    halfSizeVideoPlayerViewStyle: {
        backgroundColor: '#ECF0F1',
        borderColor: '#B9C3C7',
        borderRadius: 5,
        borderWidth: 1,
        height: (window.height - 250) / 2,
        width: window.width - 40,
        marginVertical: 20,
        marginHorizontal: 20
    },
    outputViewStyle: {
        padding: 20,
        flex: 1,
        justifyContent: 'flex-start',
        alignItems: 'stretch'
    },
    outputScrollViewStyle: {
        padding: 4,
        backgroundColor: '#f1c40f',
        borderColor: '#f39c12',
        borderRadius: 5,
        borderWidth: 1
    },
    outputTextStyle: {
        color: 'black'
    },
    textInputViewStyle: {
        paddingTop: 40,
        paddingBottom: 40,
        paddingRight: 20,
        paddingLeft: 20
    },
    textInputStyle: {
        height: 36,
        fontSize: 12,
        borderColor: '#3498db',
        borderRadius: 5,
        borderWidth: 1
    }
});

export default App;
