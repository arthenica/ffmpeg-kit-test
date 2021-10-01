//
// MIT License
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

//     react-native-loading-spinner-overlay
//     Copyright (c) 2016- Nick Baugh <niftylettuce@gmail.com>
//     MIT Licensed

// * Author: [@niftylettuce](https://twitter.com/#!/niftylettuce)
// * Source:
// <https://github.com/niftylettuce/react-native-loading-spinner-overlay>

// # react-native-loading-spinner-overlay
//
// <https://github.com/facebook/react-native/issues/2501>
// <https://rnplay.org/apps/1YkBCQ>
// <https://github.com/facebook/react-native/issues/2501>
// <https://github.com/brentvatne/react-native-overlay>
//

import React from 'react';
import PropTypes from 'prop-types';
import {ActivityIndicator, Dimensions, Modal, StyleSheet, Text, TouchableOpacity, View} from 'react-native';
import {styles as sharedStyles} from "./style";

const window = Dimensions.get('window');
const transparent = 'transparent';
const ANIMATION = ['none', 'slide', 'fade'];

export class ProgressModal extends React.PureComponent {
    constructor(props) {
        super(props);
        this.state = {
            visible: this.props.visible
        };
    }

    static propTypes = {
        cancelable: PropTypes.bool,
        color: PropTypes.string,
        animation: PropTypes.oneOf(ANIMATION),
        overlayColor: PropTypes.string,
        textContent: PropTypes.string,
        textStyle: PropTypes.object,
        visible: PropTypes.bool,
        indicatorStyle: PropTypes.object,
        children: PropTypes.element,
        spinnerKey: PropTypes.string
    };

    static defaultProps = {
        visible: false,
        cancelable: false,
        textContent: '',
        animation: 'fade',
        color: 'black',
        overlayColor: 'rgba(0, 0, 0, 0.4)'
    };

    show(message, cancelFunction) {
        this.setState({visible: true, textContent: message, cancelFunction: cancelFunction});
    }

    update(message) {
        this.setState({textContent: message});
    }

    hide() {
        this.setState({visible: false});
    }

    cancelFunction = () => {
        this.state.cancelFunction();
        this.hide();
    }

    render() {
        return (
            <Modal
                animationType={this.props.animation}
                supportedOrientations={['landscape', 'portrait']}
                transparent
                visible={this.state.visible}>
                <View style={[styles.container, {backgroundColor: this.props.overlayColor}]}>
                    <View style={[styles.panel, this.state.cancelFunction ? styles.largePanel : styles.smallPanel]}>
                        <View style={styles.loadingPanel}>
                            <View style={styles.activityIndicator}>
                                <ActivityIndicator
                                    color={spinnerStyle.color}
                                    size={spinnerStyle.size}/>
                            </View>
                            <View style={styles.textContainer}>
                                <Text style={styles.textContent}>
                                    {this.state.textContent}
                                </Text>
                            </View>
                        </View>
                        {
                            this.state.cancelFunction ?
                                (<View style={styles.buttonPanel}>
                                    <View style={sharedStyles.buttonViewStyle}>
                                        <TouchableOpacity
                                            style={sharedStyles.cancelButtonStyle}
                                            onPress={this.cancelFunction}>
                                            <Text style={sharedStyles.buttonTextStyle}>CANCEL</Text>
                                        </TouchableOpacity>
                                    </View>
                                </View>)
                                :
                                <React.Fragment/>
                        }
                    </View>
                </View>
            </Modal>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: transparent,
        bottom: 0,
        left: 0,
        position: 'absolute',
        right: 0,
        top: 0
    },
    panel: {
        flexDirection: 'column',
        alignItems: 'stretch',
        justifyContent: 'flex-start',
        alignSelf: 'flex-start',
        backgroundColor: 'white',
        borderRadius: 5,
        position: 'absolute',
        width: Math.round(window.width - 80),
        left: 40,
        top: Math.round((window.height - 120) / 2)
    },
    smallPanel: {
        height: 100
    },
    largePanel: {
        height: 140,
        paddingBottom: 30
    },
    loadingPanel: {
        flex: 1,
        flexDirection: 'row',
        position: 'relative',
        height: 80,
        left: 0,
        top: 0,
        paddingLeft: 0,
        paddingRight: 0,
        paddingTop: 40,
        paddingBottom: 40
    },
    buttonPanel: {
        flex: 1,
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative',
        width: Math.round(window.width - 80),
        left: 0,
        top: 10,
        marginTop: -5
    },
    activityIndicator: {
        alignItems: 'baseline',
        justifyContent: 'center',
        flex: 1,
        paddingLeft: 30
    },
    textContainer: {
        alignItems: 'baseline',
        flex: 4,
        justifyContent: 'center',
        position: 'relative',
        left: 0
    },
    textContent: {
        color: 'black',
        fontSize: 16,
        fontWeight: 'bold',
        paddingLeft: 20
    }
});

const spinnerStyle = {
    color: 'dodgerblue',
    size: 50
}
