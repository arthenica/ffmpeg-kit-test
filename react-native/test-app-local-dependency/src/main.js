import React from 'react';
import {Platform} from 'react-native';
import {NavigationContainer} from '@react-navigation/native';
import CommandTab from './command-tab'
import VideoTab from './video-tab'
import VideoUtil from "./video-util";
import Test from "./test-api";
import HttpsTab from "./https-tab";
import AudioTab from "./audio-tab";
import SubtitleTab from "./subtitle-tab";
import PipeTab from "./pipe-tab";
import VidStabTab from "./vid-stab-tab";
import ConcurrentExecutionTab from "./concurrent-execution-tab";
import SafTab from "./saf-tab";
import OtherTab from "./other-tab";

import {createMaterialTopTabNavigator} from '@react-navigation/material-top-tabs';
import {registerAppFont} from "./util";
import {FFmpegKitConfig} from "ffmpeg-kit-react-native";

const Tab = createMaterialTopTabNavigator();

function BottomTabs() {
    return (
        <Tab.Navigator
            initialRouteName="COMMAND"
            lazy={false}
            tabBarPosition='bottom'
            tabBarOptions={{
                activeTintColor: 'dodgerblue',
                inactiveTintColor: 'gray',
                showIcon: false,
                scrollEnabled: true,
                labelStyle: {
                    fontSize: 14,
                    fontWeight: '600',
                    textAlign: 'center',
                    flex: 1,
                    height: 20
                }
            }}>

            <Tab.Screen
                name="COMMAND"
                component={CommandTab}
                options={{
                    tabBarLabel: 'COMMAND'
                }}
            />
            <Tab.Screen
                name="VIDEO"
                component={VideoTab}
                options={{
                    tabBarLabel: 'VIDEO'
                }}
            />
            <Tab.Screen
                name="HTTPS"
                component={HttpsTab}
                options={{
                    tabBarLabel: 'HTTPS'
                }}
            />
            <Tab.Screen
                name="AUDIO"
                component={AudioTab}
                options={{
                    tabBarLabel: 'AUDIO'
                }}
            />
            <Tab.Screen
                name="SUBTITLE"
                component={SubtitleTab}
                options={{
                    tabBarLabel: 'SUBTITLE'
                }}
            />
            <Tab.Screen
                name="VID.STAB"
                component={VidStabTab}
                options={{
                    tabBarLabel: 'VID.STAB'
                }}
            />
            <Tab.Screen
                name="PIPE"
                component={PipeTab}
                options={{
                    tabBarLabel: 'PIPE'
                }}
            />
            <Tab.Screen
                name="CONCURRENT EXECUTION"
                component={ConcurrentExecutionTab}
                options={{
                    tabBarLabel: 'CONCURRENT EXECUTION'
                }}
            />
            {
                Platform.OS === 'android'
                    ?
                    <Tab.Screen
                        name="SAF"
                        component={SafTab}
                        options={{
                            tabBarLabel: 'SAF'
                        }}
                    />
                    :
                    <React.Fragment/>
            }
            <Tab.Screen
                name="OTHER"
                component={OtherTab}
                options={{
                    tabBarLabel: 'OTHER'
                }}
            />
        </Tab.Navigator>
    );
}

export default class Main extends React.Component {
    constructor(props) {
        super(props);

        FFmpegKitConfig.init().then(() => {
            VideoUtil.prepareAssets();
            registerAppFont();

            Test.testCommonApiMethods();
            Test.testParseArguments();
        });
    }

    render() {
        return (
            <NavigationContainer>
                <BottomTabs/>
            </NavigationContainer>
        );
    }
}
