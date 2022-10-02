/*
 * Copyright (c) 2018-2022 Taner Sener
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */

#include "MediaInformationParserTest.h"
#include <MediaInformationJsonParser.h>

using namespace ffmpegkit;

const std::string MEDIA_INFORMATION_MP3 =     "{\n"
                                              "     \"streams\": [\n"
                                              "         {\n"
                                              "             \"index\": 0,\n"
                                              "             \"codec_name\": \"mp3\",\n"
                                              "             \"codec_long_name\": \"MP3 (MPEG audio layer 3)\",\n"
                                              "             \"codec_type\": \"audio\",\n"
                                              "             \"codec_time_base\": \"1/44100\",\n"
                                              "             \"codec_tag_string\": \"[0][0][0][0]\",\n"
                                              "             \"codec_tag\": \"0x0000\",\n"
                                              "             \"sample_fmt\": \"fltp\",\n"
                                              "             \"sample_rate\": \"44100\",\n"
                                              "             \"channels\": 2,\n"
                                              "             \"channel_layout\": \"stereo\",\n"
                                              "             \"bits_per_sample\": 0,\n"
                                              "             \"r_frame_rate\": \"0/0\",\n"
                                              "             \"avg_frame_rate\": \"0/0\",\n"
                                              "             \"time_base\": \"1/14112000\",\n"
                                              "             \"start_pts\": 169280,\n"
                                              "             \"start_time\": \"0.011995\",\n"
                                              "             \"duration_ts\": 4622376960,\n"
                                              "             \"duration\": \"327.549388\",\n"
                                              "             \"bit_rate\": \"320000\",\n"
                                              "             \"disposition\": {\n"
                                              "                 \"default\": 0,\n"
                                              "                 \"dub\": 0,\n"
                                              "                 \"original\": 0,\n"
                                              "                 \"comment\": 0,\n"
                                              "                 \"lyrics\": 0,\n"
                                              "                 \"karaoke\": 0,\n"
                                              "                 \"forced\": 0,\n"
                                              "                 \"hearing_impaired\": 0,\n"
                                              "                 \"visual_impaired\": 0,\n"
                                              "                 \"clean_effects\": 0,\n"
                                              "                 \"attached_pic\": 0,\n"
                                              "                 \"timed_thumbnails\": 0\n"
                                              "             },\n"
                                              "             \"tags\": {\n"
                                              "                 \"encoder\": \"Lavf\"\n"
                                              "             }\n"
                                              "         }\n"
                                              "     ],\n"
                                              "     \"chapters\": [\n"
                                              "         {\n"
                                              "             \"id\": 0,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 0,\n"
                                              "             \"start_time\": \"0.000000\",\n"
                                              "             \"end\": 11158238,\n"
                                              "             \"end_time\": \"506.042540\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"1 Laying Plans - 2 Waging War\"\n"
                                              "            }\n"
                                              "         },\n"
                                              "         {\n"
                                              "             \"id\": 1,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 11158238,\n"
                                              "             \"start_time\": \"506.042540\",\n"
                                              "             \"end\": 21433051,\n"
                                              "             \"end_time\": \"972.020454\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"3 Attack By Stratagem - 4 Tactical Dispositions\"\n"
                                              "            }\n"
                                              "         },\n"
                                              "         {\n"
                                              "             \"id\": 2,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 21433051,\n"
                                              "             \"start_time\": \"972.020454\",\n"
                                              "             \"end\": 35478685,\n"
                                              "             \"end_time\": \"1609.010658\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"5 Energy - 6 Weak Points and Strong\"\n"
                                              "            }\n"
                                              "         },\n"
                                              "         {\n"
                                              "             \"id\": 3,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 35478685,\n"
                                              "             \"start_time\": \"1609.010658\",\n"
                                              "             \"end\": 47187043,\n"
                                              "             \"end_time\": \"2140.001950\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"7 Maneuvering - 8 Variation in Tactics\"\n"
                                              "            }\n"
                                              "         },\n"
                                              "         {\n"
                                              "             \"id\": 4,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 47187043,\n"
                                              "             \"start_time\": \"2140.001950\",\n"
                                              "             \"end\": 66635594,\n"
                                              "             \"end_time\": \"3022.022404\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"9 The Army on the March - 10 Terrain\"\n"
                                              "            }\n"
                                              "         },\n"
                                              "         {\n"
                                              "             \"id\": 5,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 66635594,\n"
                                              "             \"start_time\": \"3022.022404\",\n"
                                              "             \"end\": 83768105,\n"
                                              "             \"end_time\": \"3799.007029\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"11 The Nine Situations\"\n"
                                              "            }\n"
                                              "         },\n"
                                              "         {\n"
                                              "             \"id\": 6,\n"
                                              "             \"time_base\": \"1/22050\",\n"
                                              "             \"start\": 83768105,\n"
                                              "             \"start_time\": \"3799.007029\",\n"
                                              "             \"end\": 95659008,\n"
                                              "             \"end_time\": \"4338.277007\",\n"
                                              "             \"tags\": {\n"
                                              "                \"title\": \"12 The Attack By Fire - 13 The Use of Spies\"\n"
                                              "            }\n"
                                              "         }\n"
                                              "     ],\n"
                                              "     \"format\": {\n"
                                              "         \"filename\": \"sample.mp3\",\n"
                                              "         \"nb_streams\": 1,\n"
                                              "         \"nb_programs\": 0,\n"
                                              "         \"format_name\": \"mp3\",\n"
                                              "         \"format_long_name\": \"MP2/3 (MPEG audio layer 2/3)\",\n"
                                              "         \"start_time\": \"0.011995\",\n"
                                              "         \"duration\": \"327.549388\",\n"
                                              "         \"size\": \"13103064\",\n"
                                              "         \"bit_rate\": \"320026\",\n"
                                              "         \"probe_score\": 51,\n"
                                              "         \"tags\": {\n"
                                              "             \"encoder\": \"Lavf58.20.100\",\n"
                                              "             \"album\": \"Impact\",\n"
                                              "             \"artist\": \"Kevin MacLeod\",\n"
                                              "             \"comment\": \"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit finito.\",\n"
                                              "             \"genre\": \"Cinematic\",\n"
                                              "             \"title\": \"Impact Moderato\"\n"
                                              "         }\n"
                                              "     }\n"
                                              "}";

const std::string MEDIA_INFORMATION_JPG =     "{\n"
                                              "     \"streams\": [\n"
                                              "         {\n"
                                              "             \"index\": 0,\n"
                                              "             \"codec_name\": \"mjpeg\",\n"
                                              "             \"codec_long_name\": \"Motion JPEG\",\n"
                                              "             \"profile\": \"Baseline\",\n"
                                              "             \"codec_type\": \"video\",\n"
                                              "             \"codec_time_base\": \"0/1\",\n"
                                              "             \"codec_tag_string\": \"[0][0][0][0]\",\n"
                                              "             \"codec_tag\": \"0x0000\",\n"
                                              "             \"width\": 1496,\n"
                                              "             \"height\": 1729,\n"
                                              "             \"coded_width\": 1496,\n"
                                              "             \"coded_height\": 1729,\n"
                                              "             \"has_b_frames\": 0,\n"
                                              "             \"sample_aspect_ratio\": \"1:1\",\n"
                                              "             \"display_aspect_ratio\": \"1496:1729\",\n"
                                              "             \"pix_fmt\": \"yuvj444p\",\n"
                                              "             \"level\": -99,\n"
                                              "             \"color_range\": \"pc\",\n"
                                              "             \"color_space\": \"bt470bg\",\n"
                                              "             \"chroma_location\": \"center\",\n"
                                              "             \"refs\": 1,\n"
                                              "             \"r_frame_rate\": \"25/1\",\n"
                                              "             \"avg_frame_rate\": \"0/0\",\n"
                                              "             \"time_base\": \"1/25\",\n"
                                              "             \"start_pts\": 0,\n"
                                              "             \"start_time\": \"0.000000\",\n"
                                              "             \"duration_ts\": 1,\n"
                                              "             \"duration\": \"0.040000\",\n"
                                              "             \"bits_per_raw_sample\": \"8\",\n"
                                              "             \"disposition\": {\n"
                                              "                 \"default\": 0,\n"
                                              "                 \"dub\": 0,\n"
                                              "                 \"original\": 0,\n"
                                              "                 \"comment\": 0,\n"
                                              "                 \"lyrics\": 0,\n"
                                              "                 \"karaoke\": 0,\n"
                                              "                 \"forced\": 0,\n"
                                              "                 \"hearing_impaired\": 0,\n"
                                              "                 \"visual_impaired\": 0,\n"
                                              "                 \"clean_effects\": 0,\n"
                                              "                 \"attached_pic\": 0,\n"
                                              "                 \"timed_thumbnails\": 0\n"
                                              "             }\n"
                                              "         }\n"
                                              "     ],\n"
                                              "     \"format\": {\n"
                                              "         \"filename\": \"sample.jpg\",\n"
                                              "         \"nb_streams\": 1,\n"
                                              "         \"nb_programs\": 0,\n"
                                              "         \"format_name\": \"image2\",\n"
                                              "         \"format_long_name\": \"image2 sequence\",\n"
                                              "         \"start_time\": \"0.000000\",\n"
                                              "         \"duration\": \"0.040000\",\n"
                                              "         \"size\": \"1659050\",\n"
                                              "         \"bit_rate\": \"331810000\",\n"
                                              "         \"probe_score\": 50\n"
                                              "     }\n"
                                              "}";

const std::string MEDIA_INFORMATION_GIF =     "{\n"
                                              "     \"streams\": [\n"
                                              "         {\n"
                                              "             \"index\": 0,\n"
                                              "             \"codec_name\": \"gif\",\n"
                                              "             \"codec_long_name\": \"CompuServe GIF (Graphics Interchange Format)\",\n"
                                              "             \"codec_type\": \"video\",\n"
                                              "             \"codec_time_base\": \"12/133\",\n"
                                              "             \"codec_tag_string\": \"[0][0][0][0]\",\n"
                                              "             \"codec_tag\": \"0x0000\",\n"
                                              "             \"width\": 400,\n"
                                              "             \"height\": 400,\n"
                                              "             \"coded_width\": 400,\n"
                                              "             \"coded_height\": 400,\n"
                                              "             \"has_b_frames\": 0,\n"
                                              "             \"pix_fmt\": \"bgra\",\n"
                                              "             \"level\": -99,\n"
                                              "             \"refs\": 1,\n"
                                              "             \"r_frame_rate\": \"100/9\",\n"
                                              "             \"avg_frame_rate\": \"133/12\",\n"
                                              "             \"time_base\": \"1/100\",\n"
                                              "             \"start_pts\": 0,\n"
                                              "             \"start_time\": \"0.000000\",\n"
                                              "             \"duration_ts\": 396,\n"
                                              "             \"duration\": \"3.960000\",\n"
                                              "             \"nb_frames\": \"44\",\n"
                                              "             \"disposition\": {\n"
                                              "                 \"default\": 0,\n"
                                              "                 \"dub\": 0,\n"
                                              "                 \"original\": 0,\n"
                                              "                 \"comment\": 0,\n"
                                              "                 \"lyrics\": 0,\n"
                                              "                 \"karaoke\": 0,\n"
                                              "                 \"forced\": 0,\n"
                                              "                 \"hearing_impaired\": 0,\n"
                                              "                 \"visual_impaired\": 0,\n"
                                              "                 \"clean_effects\": 0,\n"
                                              "                 \"attached_pic\": 0,\n"
                                              "                 \"timed_thumbnails\": 0\n"
                                              "             }\n"
                                              "         }\n"
                                              "     ],\n"
                                              "     \"format\": {\n"
                                              "         \"filename\": \"sample.gif\",\n"
                                              "         \"nb_streams\": 1,\n"
                                              "         \"nb_programs\": 0,\n"
                                              "         \"format_name\": \"gif\",\n"
                                              "         \"format_long_name\": \"CompuServe Graphics Interchange Format (GIF)\",\n"
                                              "         \"start_time\": \"0.000000\",\n"
                                              "         \"duration\": \"3.960000\",\n"
                                              "         \"size\": \"1001718\",\n"
                                              "         \"bit_rate\": \"2023672\",\n"
                                              "         \"probe_score\": 100\n"
                                              "     }\n"
                                              "}";

const std::string MEDIA_INFORMATION_MP4 =     "{\n"
                                              " \"streams\": [\n"
                                              "      {\n"
                                              "          \"index\": 0,\n"
                                              "          \"codec_name\": \"h264\",\n"
                                              "          \"codec_long_name\": \"H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10\",\n"
                                              "          \"profile\": \"Main\",\n"
                                              "          \"codec_type\": \"video\",\n"
                                              "          \"codec_time_base\": \"1/60\",\n"
                                              "          \"codec_tag_string\": \"avc1\",\n"
                                              "          \"codec_tag\": \"0x31637661\",\n"
                                              "          \"width\": 1280,\n"
                                              "          \"height\": 720,\n"
                                              "          \"coded_width\": 1280,\n"
                                              "          \"coded_height\": 720,\n"
                                              "          \"has_b_frames\": 0,\n"
                                              "          \"sample_aspect_ratio\": \"1:1\",\n"
                                              "          \"display_aspect_ratio\": \"16:9\",\n"
                                              "          \"pix_fmt\": \"yuv420p\",\n"
                                              "          \"level\": 42,\n"
                                              "          \"chroma_location\": \"left\",\n"
                                              "          \"refs\": 1,\n"
                                              "          \"is_avc\": \"true\",\n"
                                              "          \"nal_length_size\": \"4\",\n"
                                              "          \"r_frame_rate\": \"30/1\",\n"
                                              "          \"avg_frame_rate\": \"30/1\",\n"
                                              "          \"time_base\": \"1/15360\",\n"
                                              "          \"start_pts\": 0,\n"
                                              "          \"start_time\": \"0.000000\",\n"
                                              "          \"duration_ts\": 215040,\n"
                                              "          \"duration\": \"14.000000\",\n"
                                              "          \"bit_rate\": \"9166570\",\n"
                                              "          \"bits_per_raw_sample\": \"8\",\n"
                                              "          \"nb_frames\": \"420\",\n"
                                              "          \"disposition\": {\n"
                                              "              \"default\": 1,\n"
                                              "              \"dub\": 0,\n"
                                              "              \"original\": 0,\n"
                                              "              \"comment\": 0,\n"
                                              "              \"lyrics\": 0,\n"
                                              "              \"karaoke\": 0,\n"
                                              "              \"forced\": 0,\n"
                                              "              \"hearing_impaired\": 0,\n"
                                              "              \"visual_impaired\": 0,\n"
                                              "              \"clean_effects\": 0,\n"
                                              "              \"attached_pic\": 0,\n"
                                              "              \"timed_thumbnails\": 0\n"
                                              "          },\n"
                                              "          \"tags\": {\n"
                                              "              \"language\": \"und\",\n"
                                              "              \"handler_name\": \"VideoHandler\"\n"
                                              "          }\n"
                                              "      }\n"
                                              "  ],\n"
                                              "  \"format\": {\n"
                                              "      \"filename\": \"sample.mp4\",\n"
                                              "      \"nb_streams\": 1,\n"
                                              "      \"nb_programs\": 0,\n"
                                              "      \"format_name\": \"mov,mp4,m4a,3gp,3g2,mj2\",\n"
                                              "      \"format_long_name\": \"QuickTime / MOV\",\n"
                                              "      \"start_time\": \"0.000000\",\n"
                                              "      \"duration\": \"14.000000\",\n"
                                              "      \"size\": \"16044159\",\n"
                                              "      \"bit_rate\": \"9168090\",\n"
                                              "      \"probe_score\": 100,\n"
                                              "      \"tags\": {\n"
                                              "          \"major_brand\": \"isom\",\n"
                                              "          \"minor_version\": \"512\",\n"
                                              "          \"compatible_brands\": \"isomiso2avc1mp41\",\n"
                                              "          \"encoder\": \"Lavf58.33.100\"\n"
                                              "      }\n"
                                              "  }\n"
                                              "}";

const std::string MEDIA_INFORMATION_PNG =     "{\n"
                                              "     \"streams\": [\n"
                                              "         {\n"
                                              "             \"index\": 0,\n"
                                              "             \"codec_name\": \"png\",\n"
                                              "             \"codec_long_name\": \"PNG (Portable Network Graphics) image\",\n"
                                              "             \"codec_type\": \"video\",\n"
                                              "             \"codec_time_base\": \"0/1\",\n"
                                              "             \"codec_tag_string\": \"[0][0][0][0]\",\n"
                                              "             \"codec_tag\": \"0x0000\",\n"
                                              "             \"width\": 1198,\n"
                                              "             \"height\": 1198,\n"
                                              "             \"coded_width\": 1198,\n"
                                              "             \"coded_height\": 1198,\n"
                                              "             \"has_b_frames\": 0,\n"
                                              "             \"sample_aspect_ratio\": \"1:1\",\n"
                                              "             \"display_aspect_ratio\": \"1:1\",\n"
                                              "             \"pix_fmt\": \"pal8\",\n"
                                              "             \"level\": -99,\n"
                                              "             \"color_range\": \"pc\",\n"
                                              "             \"refs\": 1,\n"
                                              "             \"r_frame_rate\": \"25/1\",\n"
                                              "             \"avg_frame_rate\": \"0/0\",\n"
                                              "             \"time_base\": \"1/25\",\n"
                                              "             \"disposition\": {\n"
                                              "                 \"default\": 0,\n"
                                              "                 \"dub\": 0,\n"
                                              "                 \"original\": 0,\n"
                                              "                 \"comment\": 0,\n"
                                              "                 \"lyrics\": 0,\n"
                                              "                 \"karaoke\": 0,\n"
                                              "                 \"forced\": 0,\n"
                                              "                 \"hearing_impaired\": 0,\n"
                                              "                 \"visual_impaired\": 0,\n"
                                              "                 \"clean_effects\": 0,\n"
                                              "                 \"attached_pic\": 0,\n"
                                              "                 \"timed_thumbnails\": 0\n"
                                              "             }\n"
                                              "         }\n"
                                              "     ],\n"
                                              "     \"format\": {\n"
                                              "         \"filename\": \"sample.png\",\n"
                                              "         \"nb_streams\": 1,\n"
                                              "         \"nb_programs\": 0,\n"
                                              "         \"format_name\": \"png_pipe\",\n"
                                              "         \"format_long_name\": \"piped png sequence\",\n"
                                              "         \"size\": \"31533\",\n"
                                              "         \"probe_score\": 99\n"
                                              "     }\n"
                                              "}";

const std::string MEDIA_INFORMATION_OGG =  "{\n"
                                           "    \"streams\": [\n"
                                           "        {\n"
                                           "            \"index\": 0,\n"
                                           "            \"codec_name\": \"theora\",\n"
                                           "            \"codec_long_name\": \"Theora\",\n"
                                           "            \"codec_type\": \"video\",\n"
                                           "            \"codec_time_base\": \"1/25\",\n"
                                           "            \"codec_tag_string\": \"[0][0][0][0]\",\n"
                                           "            \"codec_tag\": \"0x0000\",\n"
                                           "            \"width\": 1920,\n"
                                           "            \"height\": 1080,\n"
                                           "            \"coded_width\": 1920,\n"
                                           "            \"coded_height\": 1088,\n"
                                           "            \"has_b_frames\": 0,\n"
                                           "            \"pix_fmt\": \"yuv420p\",\n"
                                           "            \"level\": -99,\n"
                                           "            \"color_space\": \"bt470bg\",\n"
                                           "            \"color_transfer\": \"bt709\",\n"
                                           "            \"color_primaries\": \"bt470bg\",\n"
                                           "            \"chroma_location\": \"center\",\n"
                                           "            \"refs\": 1,\n"
                                           "            \"r_frame_rate\": \"25/1\",\n"
                                           "            \"avg_frame_rate\": \"25/1\",\n"
                                           "            \"time_base\": \"1/25\",\n"
                                           "            \"start_pts\": 0,\n"
                                           "            \"start_time\": \"0.000000\",\n"
                                           "            \"duration_ts\": 813,\n"
                                           "            \"duration\": \"32.520000\",\n"
                                           "            \"disposition\": {\n"
                                           "                \"default\": 0,\n"
                                           "                \"dub\": 0,\n"
                                           "                \"original\": 0,\n"
                                           "                \"comment\": 0,\n"
                                           "                \"lyrics\": 0,\n"
                                           "                \"karaoke\": 0,\n"
                                           "                \"forced\": 0,\n"
                                           "                \"hearing_impaired\": 0,\n"
                                           "                \"visual_impaired\": 0,\n"
                                           "                \"clean_effects\": 0,\n"
                                           "                \"attached_pic\": 0,\n"
                                           "                \"timed_thumbnails\": 0\n"
                                           "            },\n"
                                           "            \"tags\": {\n"
                                           "                \"ENCODER\": \"ffmpeg2theora 0.19\"\n"
                                           "            }\n"
                                           "        },\n"
                                           "        {\n"
                                           "            \"index\": 1,\n"
                                           "            \"codec_name\": \"vorbis\",\n"
                                           "            \"codec_long_name\": \"Vorbis\",\n"
                                           "            \"codec_type\": \"audio\",\n"
                                           "            \"codec_time_base\": \"1/48000\",\n"
                                           "            \"codec_tag_string\": \"[0][0][0][0]\",\n"
                                           "            \"codec_tag\": \"0x0000\",\n"
                                           "            \"sample_fmt\": \"fltp\",\n"
                                           "            \"sample_rate\": \"48000\",\n"
                                           "            \"channels\": 2,\n"
                                           "            \"channel_layout\": \"stereo\",\n"
                                           "            \"bits_per_sample\": 0,\n"
                                           "            \"r_frame_rate\": \"0/0\",\n"
                                           "            \"avg_frame_rate\": \"0/0\",\n"
                                           "            \"time_base\": \"1/48000\",\n"
                                           "            \"start_pts\": 0,\n"
                                           "            \"start_time\": \"0.000000\",\n"
                                           "            \"duration_ts\": 1583850,\n"
                                           "            \"duration\": \"32.996875\",\n"
                                           "            \"bit_rate\": \"80000\",\n"
                                           "            \"disposition\": {\n"
                                           "                \"default\": 0,\n"
                                           "                \"dub\": 0,\n"
                                           "                \"original\": 0,\n"
                                           "                \"comment\": 0,\n"
                                           "                \"lyrics\": 0,\n"
                                           "                \"karaoke\": 0,\n"
                                           "                \"forced\": 0,\n"
                                           "                \"hearing_impaired\": 0,\n"
                                           "                \"visual_impaired\": 0,\n"
                                           "                \"clean_effects\": 0,\n"
                                           "                \"attached_pic\": 0,\n"
                                           "                \"timed_thumbnails\": 0\n"
                                           "            },\n"
                                           "            \"tags\": {\n"
                                           "                \"ENCODER\": \"ffmpeg2theora 0.19\"\n"
                                           "            }\n"
                                           "        }\n"
                                           "    ],\n"
                                           "    \"format\": {\n"
                                           "        \"filename\": \"sample.ogg\",\n"
                                           "        \"nb_streams\": 2,\n"
                                           "        \"nb_programs\": 0,\n"
                                           "        \"format_name\": \"ogg\",\n"
                                           "        \"format_long_name\": \"Ogg\",\n"
                                           "        \"start_time\": \"0.000000\",\n"
                                           "        \"duration\": \"32.996875\",\n"
                                           "        \"size\": \"27873937\",\n"
                                           "        \"bit_rate\": \"6757958\",\n"
                                           "        \"probe_score\": 100\n"
                                           "    }\n"
                                           "}";

void assertNumber(long expected, std::shared_ptr<int64_t> real) {
    if (real == nullptr) {
        assert(expected == -1);
    } else {
        assert(expected == *real);
    }
}

void assertString(std::string expected, std::shared_ptr<std::string> real) {
    if (real == nullptr) {
        assert(expected == "");
    } else {
        assert(expected == *real);
    }
}

void assertString(std::string expected, std::string real) {
    assert(expected == real);
}

void assertVideoStream(std::shared_ptr<StreamInformation> stream, long index, std::string codec, std::string fullCodec, std::string format, long width, long height, std::string sampleAspectRatio, std::string displayAspectRatio, std::string bitrate, std::string averageFrameRate, std::string realFrameRate, std::string timeBase, std::string codecTimeBase) {
    assert(stream != nullptr);
    assertNumber(index, stream->getIndex());
    assertString("video", stream->getType());

    assertString(codec, stream->getCodec());
    assertString(fullCodec, stream->getCodecLong());

    assertString(format, stream->getFormat());

    assertNumber(width, stream->getWidth());
    assertNumber(height, stream->getHeight());
    assertString(sampleAspectRatio, stream->getSampleAspectRatio());
    assertString(displayAspectRatio, stream->getDisplayAspectRatio());

    assertString(bitrate, stream->getBitrate());

    assertString(averageFrameRate, stream->getAverageFrameRate());
    assertString(realFrameRate, stream->getRealFrameRate());
    assertString(timeBase, stream->getTimeBase());
    assertString(codecTimeBase, stream->getCodecTimeBase());
}

void assertAudioStream(std::shared_ptr<StreamInformation> stream, long index, std::string codec, std::string fullCodec, std::string sampleRate, std::string channelLayout, std::string sampleFormat, std::string bitrate) {
    assert(stream != nullptr);
    assertNumber(index, stream->getIndex());
    assertString("audio", stream->getType());

    assertString(codec, stream->getCodec());
    assertString(fullCodec, stream->getCodecLong());

    assertString(sampleRate, stream->getSampleRate());
    assertString(channelLayout, stream->getChannelLayout());
    assertString(sampleFormat, stream->getSampleFormat());
    assertString(bitrate, stream->getBitrate());
}

void assertChapter(std::shared_ptr<Chapter> chapter, long id, std::string timeBase, long start, std::string  startTime, long end, std::string endTime) {
    assert(chapter != nullptr);
    assertNumber(id, chapter->getId());
    assertString(timeBase, chapter->getTimeBase());

    assertNumber(start, chapter->getStart());
    assertString(startTime, chapter->getStartTime());

    assertNumber(end, chapter->getEnd());
    assertString(endTime, chapter->getEndTime());

    std::shared_ptr<rapidjson::Value> tags = chapter->getTags();
    assert(tags);

    assert(1 == tags->MemberCount());
}

void assertMediaInput(std::shared_ptr<MediaInformation> mediaInformation, std::string expectedFormat, std::string expectedFilename) {
    std::shared_ptr<std::string> format = mediaInformation->getFormat();
    std::shared_ptr<std::string> filename = mediaInformation->getFilename();
    if (format == nullptr) {
        assert(expectedFormat == "");
    } else {
        assert(*format == expectedFormat);
    }
    if (filename == nullptr) {
        assert(expectedFilename == "");
    } else {
        assert(*filename == expectedFilename);
    }
}

void assertMediaDuration(std::shared_ptr<MediaInformation> mediaInformation, std::string expectedDuration, std::string expectedStartTime, std::string expectedBitrate) {
    std::shared_ptr<std::string> duration = mediaInformation->getDuration();
    std::shared_ptr<std::string> startTime = mediaInformation->getStartTime();
    std::shared_ptr<std::string> bitrate = mediaInformation->getBitrate();

    assertString(expectedDuration, duration);
    assertString(expectedStartTime, startTime);
    assertString(expectedBitrate, bitrate);
}

void assertTag(std::shared_ptr<MediaInformation> mediaInformation, std::string expectedKey, std::string expectedValue) {
    std::shared_ptr<rapidjson::Value> tags = mediaInformation->getTags();
    assert(tags);

    auto value = (*tags)[expectedKey.c_str()].GetString();
    assert(value);

    assert(value == expectedValue);
}

void assertStreamTag(std::shared_ptr<StreamInformation> streamInformation, std::string expectedKey, std::string expectedValue) {
    std::shared_ptr<rapidjson::Value> tags = streamInformation->getTags();
    assert(tags);
    
    auto value = (*tags)[expectedKey.c_str()].GetString();
    assert(value);
    
    assert(value == expectedValue);
}

void testMediaInformationMp3() {
    std::shared_ptr<MediaInformation> mediaInformation = MediaInformationJsonParser::from(MEDIA_INFORMATION_MP3);
    
    assert(mediaInformation);
    assertMediaInput(mediaInformation, "mp3", "sample.mp3");
    assertMediaDuration(mediaInformation, "327.549388", "0.011995", "320026");
    
    assertTag(mediaInformation, "comment", "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Lorem ipsum dolor sit amet, consectetur adipiscing elit finito.");
    assertTag(mediaInformation, "album", "Impact");
    assertTag(mediaInformation, "title", "Impact Moderato");
    assertTag(mediaInformation, "artist", "Kevin MacLeod");
    
    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = mediaInformation->getStreams();
    assert(streams);
    assert(1 == streams->size());

    assertAudioStream((*streams)[0], 0, "mp3", "MP3 (MPEG audio layer 3)", "44100", "stereo", "fltp", "320000");

    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::Chapter>>> chapters = mediaInformation->getChapters();
    assert(chapters);
    assert(7 == chapters->size());

    assertChapter((*chapters)[0], 0, "1/22050", 0, "0.000000", 11158238, "506.042540");
    assertChapter((*chapters)[1], 1, "1/22050", 11158238, "506.042540", 21433051, "972.020454");
}

void testMediaInformationJpg() {
    std::shared_ptr<MediaInformation> mediaInformation = MediaInformationJsonParser::from(MEDIA_INFORMATION_JPG);

    assert(mediaInformation);
    assertMediaInput(mediaInformation, "image2", "sample.jpg");
    assertMediaDuration(mediaInformation, "0.040000", "0.000000", "331810000");

    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = mediaInformation->getStreams();
    assert(streams);
    assert(1 == streams->size());

    assertVideoStream((*streams)[0], 0, "mjpeg", "Motion JPEG", "yuvj444p", 1496, 1729, "1:1", "1496:1729", "", "0/0", "25/1", "1/25", "0/1");
}

void testMediaInformationGif() {
    std::shared_ptr<MediaInformation> mediaInformation = MediaInformationJsonParser::from(MEDIA_INFORMATION_GIF);
    
    assert(mediaInformation);
    assertMediaInput(mediaInformation, "gif", "sample.gif");
    assertMediaDuration(mediaInformation, "3.960000", "0.000000", "2023672");

    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = mediaInformation->getStreams();
    assert(streams);
    assert(1 == streams->size());

    assertVideoStream((*streams)[0], 0, "gif", "CompuServe GIF (Graphics Interchange Format)", "bgra", 400, 400, "", "", "", "133/12", "100/9", "1/100", "12/133");
}

void testMediaInformationMp4() {
    std::shared_ptr<MediaInformation> mediaInformation = MediaInformationJsonParser::from(MEDIA_INFORMATION_MP4);
    
    assert(mediaInformation);
    assertMediaInput(mediaInformation, "mov,mp4,m4a,3gp,3g2,mj2", "sample.mp4");
    assertMediaDuration(mediaInformation, "14.000000", "0.000000", "9168090");

    assertTag(mediaInformation, "major_brand", "isom");
    assertTag(mediaInformation, "minor_version", "512");
    assertTag(mediaInformation, "compatible_brands", "isomiso2avc1mp41");
    assertTag(mediaInformation, "encoder", "Lavf58.33.100");

    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = mediaInformation->getStreams();
    assert(streams);
    assert(1 == streams->size());

    assertVideoStream((*streams)[0], 0, "h264", "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10", "yuv420p", 1280, 720, "1:1", "16:9", "9166570", "30/1", "30/1", "1/15360", "1/60");
    
    assertStreamTag((*streams)[0], "language", "und");
    assertStreamTag((*streams)[0], "handler_name", "VideoHandler");
}

void testMediaInformationPng() {
    std::shared_ptr<MediaInformation> mediaInformation = MediaInformationJsonParser::from(MEDIA_INFORMATION_PNG);
    
    assert(mediaInformation);
    assertMediaInput(mediaInformation, "png_pipe", "sample.png");
    assertMediaDuration(mediaInformation, "", "", "");

    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = mediaInformation->getStreams();
    assert(streams);
    assert(1 == streams->size());

    assertVideoStream((*streams)[0], 0, "png", "PNG (Portable Network Graphics) image", "pal8", 1198, 1198, "1:1", "1:1", "", "0/0", "25/1", "1/25", "0/1");
}

void testMediaInformationOgg() {
    std::shared_ptr<MediaInformation> mediaInformation = MediaInformationJsonParser::from(MEDIA_INFORMATION_OGG);
    
    assert(mediaInformation);
    assertMediaInput(mediaInformation, "ogg", "sample.ogg");
    assertMediaDuration(mediaInformation, "32.996875", "0.000000", "6757958");

    std::shared_ptr<std::vector<std::shared_ptr<ffmpegkit::StreamInformation>>> streams = mediaInformation->getStreams();
    assert(streams);
    assert(2 == streams->size());

    assertVideoStream((*streams)[0], 0, "theora", "Theora", "yuv420p", 1920, 1080, "", "", "", "25/1", "25/1", "1/25", "1/25");
    assertAudioStream((*streams)[1], 1, "vorbis", "Vorbis", "48000", "stereo", "fltp", "80000");

    assertStreamTag((*streams)[0], "ENCODER", "ffmpeg2theora 0.19");
    assertStreamTag((*streams)[1], "ENCODER", "ffmpeg2theora 0.19");
}

void testMediaInformationJsonParser(void) {
    testMediaInformationMp3();
    testMediaInformationJpg();
    testMediaInformationGif();
    testMediaInformationMp4();
    testMediaInformationPng();
    testMediaInformationOgg();

    std::cout << "MediaInformationJsonParserTest passed." << std::endl;
}
