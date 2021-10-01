//
// MIT License
//
// Copyright (c) 2016 Jia PengHui
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

/**
 * react-native-easy-toast
 * https://github.com/crazycodeboy/react-native-easy-toast
 * Email:crazycodeboy@gmail.com
 * Blog:http://jiapenghui.com
 * @flow
 */

import React, {Component} from 'react';
import {Animated, Dimensions, StyleSheet, Text, View, ViewPropTypes as RNViewPropTypes,} from 'react-native'
import PropTypes from 'prop-types';
import {ffprint} from './util';

const ViewPropTypes = RNViewPropTypes || View.propTypes;
const DURATION = {
    LENGTH_SHORT: 1000,
    FOREVER: 0,
};

const window = Dimensions.get('window');

export function showPopup(reference, text) {
    if (reference.current !== null && reference.current !== undefined) {
        reference.current.show(text, DURATION.LENGTH_SHORT);
    } else {
        ffprint('Popup reference is empty.');
    }
}

export class Toast extends Component {

    constructor(props) {
        super(props);
        this.state = {
            isShow: false,
            text: '',
            opacityValue: new Animated.Value(this.props.opacity),
        }
    }

    show(text, duration, callback) {
        this.duration = typeof duration === 'number' ? duration : DURATION.LENGTH_SHORT;
        this.callback = callback;
        this.setState({
            isShow: true,
            text: text,
        });

        this.animation = Animated.timing(
            this.state.opacityValue,
            {
                toValue: this.props.opacity,
                duration: this.props.fadeInDuration,
                useNativeDriver: true
            }
        )
        this.animation.start(() => {
            this.isShow = true;
            if (duration !== DURATION.FOREVER) this.close();
        });
    }

    close(duration) {
        let delay = typeof duration === 'undefined' ? this.duration : duration;

        if (delay === DURATION.FOREVER) delay = this.props.defaultCloseDelay || 250;

        if (!this.isShow && !this.state.isShow) return;
        this.timer && clearTimeout(this.timer);
        this.timer = setTimeout(() => {
            this.animation = Animated.timing(
                this.state.opacityValue,
                {
                    toValue: 0.0,
                    duration: this.props.fadeOutDuration,
                    useNativeDriver: true
                }
            )
            this.animation.start(() => {
                this.setState({
                    isShow: false,
                });
                this.isShow = false;
                if (typeof this.callback === 'function') {
                    this.callback();
                }
            });
        }, delay);
    }

    componentWillUnmount() {
        this.animation && this.animation.stop()
        this.timer && clearTimeout(this.timer);
    }

    render() {
        let vPos;
        switch (this.props.position) {
            case 'top':
                vPos = this.props.positionValue;
                break;
            case 'center':
                vPos = window.height / 2;
                break;
            case 'bottom':
                vPos = window.height - this.props.positionValue;
                break;
        }
        let hPos = 50;

        return this.state.isShow ?
            <View
                style={[styles.container, {left: hPos, width: (window.width - 100), top: (vPos - 50)}]}
                pointerEvents="none">
                <Animated.View style={[styles.content, {opacity: this.state.opacityValue}, this.props.style]}>
                    {React.isValidElement(this.state.text) ? this.state.text :
                        <Text style={this.props.textStyle}>{this.state.text}</Text>}
                </Animated.View>
            </View> : null;
    }
}

const styles = StyleSheet.create({
    container: {
        position: 'absolute',
        left: 0,
        right: 0,
        elevation: 999,
        alignItems: 'center',
        zIndex: 10000,
    },
    content: {
        backgroundColor: 'rgba(250, 250, 250, 0.7)',
        borderRadius: 5,
        padding: 10,
    },
    text: {
        color: 'black'
    }
});

Toast.propTypes = {
    style: ViewPropTypes.style,
    position: PropTypes.oneOf([
        'top',
        'center',
        'bottom',
    ]),
    textStyle: Text.propTypes.style,
    positionValue: PropTypes.number,
    fadeInDuration: PropTypes.number,
    fadeOutDuration: PropTypes.number,
    opacity: PropTypes.number
}

Toast.defaultProps = {
    position: 'bottom',
    textStyle: styles.text,
    positionValue: 120,
    fadeInDuration: 500,
    fadeOutDuration: 500,
    opacity: 1
}
