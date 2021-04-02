import React from 'react';
import {Dimensions, Platform, StyleSheet} from 'react-native';

const window = Dimensions.get('window');

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

export {styles}
