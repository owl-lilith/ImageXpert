import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_processing_basic/business/bloc/setting_bloc.dart';
import 'package:image_processing_basic/data/editing_image.dart';
//  import 'package:media_kit/media_kit.dart';          
// import 'package:media_kit_video/media_kit_video.dart';
class HomePage extends StatefulWidget {
  static const routeName = "/home-page";

  @override
  State<HomePage> createState() => _HomePageState();
}

enum Filter { smoothing, threshold, morphology, edgeDetector, contours }

class _HomePageState extends State<HomePage> {
  SettingBloc settingBloc = SettingBloc();
  File selectedFolderImage = inputImage;
  Filter selectedFilter = Filter.smoothing;
  bool DarkTheme = true;
  bool activeFilter = true;
  bool anotherImage = false;
  bool similarImagesAppear = false;

  @override
  void dispose() {
    // videoController?.dispose();
    // player.dispose();
    super.dispose();
  }

  Future<void> pickVideo() async {}

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: DarkTheme ? Colors.black : Colors.white,
      body: Container(
        child: BlocConsumer<SettingBloc, SettingState>(
          bloc: settingBloc,
          listener: (context, state) async {
            switch (state.runtimeType) {
              case VideoErrorActionState s:
                // state as BrowseErrorActionState;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s.message)));
                break;
              case ImageErrorActionState s:
                // state as BrowseErrorActionState;
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s.message)));
                break;
              default:
            }
          },
          builder: (context, state) {
            Widget visualizeWidget() {
              if (state.runtimeType == ImageLoadingActionState ||
                  state.runtimeType == VideoLoadingActionState) {
                return const Center(
                    child: CircularProgressIndicator.adaptive());
              } else if (state.runtimeType ==
                  ImageSuccessfullyLoadedActionState) {
                state as ImageSuccessfullyLoadedActionState;

                return state.processedImage;
              } else if (state.runtimeType ==
                      SimilarImagesSuccessfullyLoadedActionState ||
                  state.runtimeType == SimilarImagesLoadingActionState) {
                return Image.file(inputImage);
              } 
              // else if (state.runtimeType ==
                  // VideoSuccessfullyLoadedActionState) {
                // state as VideoSuccessfullyLoadedActionState;
                // return state.processedVideo;
              // } 
              
              else {
                return Center(
                    child: Text(
                  'Load to Process',
                  style:
                      TextStyle(color: DarkTheme ? Colors.white : Colors.black),
                ));
              }
            }

            return SizedBox(
              height: height,
              width: width,
              child: Row(
                children: [
                  Expanded(
                      flex: 5,
                      child: Column(children: [
                        Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: categoriesFilter,
                            )),
                        Expanded(
                          flex: 9,
                          child: Column(
                            children: [
                              Expanded(
                                  flex: similarImagesAppear ? 3 : 1,
                                  child: activeFilter
                                      ? visualizeWidget()
                                      : Image.file(inputImage)),
                              similarImagesAppear
                                  ? Expanded(
                                      flex: 1,
                                      child: state.runtimeType ==
                                              SimilarImagesLoadingActionState
                                          ? Center(
                                              child:
                                                  CircularProgressIndicator())
                                          : ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemBuilder: (context, index) =>
                                                  Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: InkWell(
                                                    onTap: () {
                                                      setState(() async {
                                                        anotherImage =
                                                            !anotherImage;
                                                        inputImage = File(
                                                            similarImages[
                                                                index]);
                                                        File sourceFile = File(
                                                            'assets/images/input.jpg');
                                                        await inputImage.copy(
                                                            sourceFile.path);
                                                        settingBloc.add(
                                                            FilterEditedActionEvent());
                                                      });
                                                    },
                                                    child: Image.file(File(
                                                        similarImages[index]))),
                                              ),
                                              itemCount: similarImages.length,
                                            ))
                                  : SizedBox(),
                            ],
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Switch(
                                      value: !DarkTheme,
                                      activeTrackColor:
                                          const Color.fromRGBO(64, 196, 255, 1),
                                      inactiveTrackColor: Colors.black,
                                      activeColor: Colors.amberAccent,
                                      thumbIcon:
                                          MaterialStatePropertyAll(DarkTheme
                                              ? Icon(Icons.dark_mode)
                                              : Icon(
                                                  Icons.light_mode,
                                                  color: Colors.white,
                                                )),
                                      onChanged: (newValue) => setState(() {
                                            DarkTheme = !DarkTheme;
                                          })),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    color: activeFilter
                                        ? Colors.blueAccent.withOpacity(0.5)
                                        : Colors.transparent,
                                  ),
                                  child: IconButton(
                                      tooltip: 'Compare',
                                      onPressed: () => setState(() {
                                            activeFilter = !activeFilter;
                                          }),
                                      icon: Icon(
                                        Icons.compare,
                                        color: DarkTheme == true
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          if (hough == Hough.line)
                                            hough = Hough.none;
                                          else
                                            hough = Hough.line;
                                        });
                                        settingBloc
                                            .add(FilterEditedActionEvent());
                                      },
                                      color: hough == Hough.line
                                          ? Colors.blueAccent.withOpacity(0.5)
                                          : Colors.transparent,
                                      elevation: 0,
                                      padding: EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      // padding: EdgeInsets.all(20),
                                      child: Text('Detect Line',
                                          style: TextStyle(
                                              color: DarkTheme == true
                                                  ? Colors.white
                                                  : Colors.black))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          if (hough == Hough.circle)
                                            hough = Hough.none;
                                          else
                                            hough = Hough.circle;
                                        });
                                        settingBloc
                                            .add(FilterEditedActionEvent());
                                      },
                                      color: hough == Hough.circle
                                          ? Colors.blueAccent.withOpacity(0.5)
                                          : Colors.transparent,
                                      elevation: 0,
                                      padding: EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      // padding: EdgeInsets.all(20),
                                      child: Text('Detect Circle',
                                          style: TextStyle(
                                              color: DarkTheme == true
                                                  ? Colors.white
                                                  : Colors.black))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          similarImagesAppear = true;
                                        });
                                        settingBloc.add(
                                            FetchSimilarImagesActionEvent());
                                      },
                                      elevation: 0,
                                      padding: EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      // padding: EdgeInsets.all(20),
                                      child: Text('Fetch Similar',
                                          style: TextStyle(
                                              color: DarkTheme == true
                                                  ? Colors.white
                                                  : Colors.black))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          backProjection = !backProjection;
                                        });
                                        settingBloc
                                            .add(FilterEditedActionEvent());
                                      },
                                      elevation: 0,
                                      padding: EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      // padding: EdgeInsets.all(20),
                                      child: Text('Back Projection',
                                          style: TextStyle(
                                              color: DarkTheme == true
                                                  ? Colors.white
                                                  : Colors.black))),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: MaterialButton(
                                      onPressed: () {
                                        setState(() {
                                          corner = !corner;
                                        });
                                        settingBloc
                                            .add(FilterEditedActionEvent());
                                      },
                                      elevation: 0,
                                      padding: EdgeInsets.all(20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      // padding: EdgeInsets.all(20),
                                      child: Text('Cornor Detector',
                                          style: TextStyle(
                                              color: DarkTheme == true
                                                  ? Colors.white
                                                  : Colors.black))),
                                ),
                              ],
                            ))
                      ])),
                  Expanded(
                      flex: 2,
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15)),
                            gradient: LinearGradient(
                                colors: [
                                  Colors.blueAccent.withOpacity(0.5),
                                  Colors.deepPurpleAccent
                                      .withOpacity(0.5)
                                      .withOpacity(0.5),
                                ],
                                begin: Alignment.bottomRight,
                                end: Alignment.topLeft)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  ElevatedButton(
                                      onPressed: () => settingBloc
                                          .add(BrowseImageActionEvent()),
                                      child: Text('Image')),
                                  ElevatedButton(
                                      onPressed: () async {
                                        settingBloc
                                            .add(BrowseVideoActionEvent());
                                        // videoController!..initialize().then((value) => videoController!.play());
                                        //videoController!.play();
                                      },
                                      child: Text('Video')),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      IconButton(
                                          tooltip: 'Zoom In',
                                          onPressed: () {
                                            setState(() {
                                              selectedZoom = Zoom.zoom_in;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                selectedZoom == Zoom.zoom_in
                                                    ? MaterialStatePropertyAll(
                                                        Colors.lightBlueAccent
                                                            .withOpacity(0.5))
                                                    : MaterialStatePropertyAll(
                                                        Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: Icon(Icons.zoom_in,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'Zoom Out',
                                          onPressed: () {
                                            setState(() {
                                              selectedZoom = Zoom.zoom_out;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                selectedZoom == Zoom.zoom_out
                                                    ? MaterialStatePropertyAll(
                                                        Colors.lightBlueAccent
                                                            .withOpacity(0.5))
                                                    : MaterialStatePropertyAll(
                                                        Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: const Icon(Icons.zoom_out,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'Stretch',
                                          onPressed: () {
                                            setState(() {
                                              if (stretch == Stretch.none)
                                                stretch = Stretch.linear;
                                              else
                                                stretch = Stretch.none;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: stretch !=
                                                    Stretch.none
                                                ? MaterialStatePropertyAll(
                                                    Colors.lightBlueAccent
                                                        .withOpacity(0.5))
                                                : MaterialStatePropertyAll(
                                                    Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: const Icon(Icons.zoom_out_map,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'Contrast',
                                          onPressed: () {
                                            setState(() {
                                              histogram = !histogram;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: histogram
                                                ? MaterialStatePropertyAll(
                                                    Colors.lightBlueAccent
                                                        .withOpacity(0.5))
                                                : MaterialStatePropertyAll(
                                                    Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: Icon(Icons.contrast,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'K-Mean',
                                          onPressed: () {
                                            setState(() {
                                              kMeanCluster = !kMeanCluster;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: kMeanCluster
                                                ? MaterialStatePropertyAll(
                                                    Colors.lightBlueAccent
                                                        .withOpacity(0.5))
                                                : MaterialStatePropertyAll(
                                                    Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: Icon(Icons.filter_b_and_w,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'Rotate',
                                          onPressed: () {
                                            setState(() {
                                              rotate += 1;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: rotate != 0
                                                ? MaterialStatePropertyAll(
                                                    Colors.lightBlueAccent
                                                        .withOpacity(0.5))
                                                : MaterialStatePropertyAll(
                                                    Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: Icon(Icons.rotate_right,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'Flip',
                                          onPressed: () {
                                            setState(() {
                                              flip = !flip;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: flip
                                                ? MaterialStatePropertyAll(
                                                    Colors.lightBlueAccent
                                                        .withOpacity(0.5))
                                                : MaterialStatePropertyAll(
                                                    Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: Icon(Icons.flip,
                                              color: Colors.white)),
                                      IconButton(
                                          tooltip: 'Transform',
                                          onPressed: () {
                                            setState(() {
                                              transform = !transform;
                                            });
                                            settingBloc
                                                .add(FilterEditedActionEvent());
                                          },
                                          style: ButtonStyle(
                                            backgroundColor: transform
                                                ? MaterialStatePropertyAll(
                                                    Colors.lightBlueAccent
                                                        .withOpacity(0.5))
                                                : MaterialStatePropertyAll(
                                                    Colors.transparent),
                                          ),
                                          hoverColor: Colors.lightBlueAccent
                                              .withOpacity(0.4),
                                          icon: Icon(Icons.transform,
                                              color: Colors.white)),
                                    ])),
                            Expanded(
                              flex: 6,
                              child: Row(
                                children: [
                                  stretch != Stretch.none
                                      ? Expanded(
                                          flex: 1,
                                          child: FittedBox(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Stretch',
                                                  style: TextStyle(
                                                      color: DarkTheme
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (stretch ==
                                                                Stretch.cubic) {
                                                              stretch =
                                                                  Stretch.none;
                                                            } else {
                                                              stretch =
                                                                  Stretch.cubic;
                                                            }
                                                            settingBloc.add(
                                                                FilterEditedActionEvent());
                                                          });
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Card(
                                                            color: stretch ==
                                                                    Stretch
                                                                        .cubic
                                                                ? Colors
                                                                    .deepPurpleAccent
                                                                    .withOpacity(
                                                                        0.5)
                                                                : Colors.white,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child:
                                                                  Text('Cubic'),
                                                            ))),
                                                    InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (stretch ==
                                                                Stretch
                                                                    .nearest) {
                                                              stretch =
                                                                  Stretch.none;
                                                            } else {
                                                              stretch = Stretch
                                                                  .nearest;
                                                            }
                                                            settingBloc.add(
                                                                FilterEditedActionEvent());
                                                          });
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Card(
                                                            color: stretch ==
                                                                    Stretch
                                                                        .nearest
                                                                ? Colors
                                                                    .deepPurpleAccent
                                                                    .withOpacity(
                                                                        0.5)
                                                                : Colors.white,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'Nearest'),
                                                            ))),
                                                    InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            if (stretch ==
                                                                Stretch
                                                                    .linear) {
                                                              stretch =
                                                                  Stretch.none;
                                                            } else {
                                                              stretch = Stretch
                                                                  .linear;
                                                            }
                                                            settingBloc.add(
                                                                FilterEditedActionEvent());
                                                          });
                                                        },
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        child: Card(
                                                            color: stretch ==
                                                                    Stretch
                                                                        .linear
                                                                ? Colors
                                                                    .deepPurpleAccent
                                                                    .withOpacity(
                                                                        0.5)
                                                                : Colors.white,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'Linear'),
                                                            ))),
                                                  ],
                                                ),
                                                Slider(
                                                  value: stretchWidth,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    stretchWidth = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 4,
                                                  divisions: 4,
                                                  label: stretchWidth
                                                      .round()
                                                      .toString(),
                                                ),
                                                Slider(
                                                  value: stretchHeight,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    stretchHeight = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 4,
                                                  divisions: 4,
                                                  label: stretchHeight
                                                      .round()
                                                      .toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Expanded(flex: 1, child: SizedBox()),
                                  kMeanCluster
                                      ? Expanded(
                                          flex: 1,
                                          child: FittedBox(
                                              child: Column(
                                            children: [
                                              Text(
                                                'K-Mean Cluster',
                                                style: TextStyle(
                                                    color: DarkTheme
                                                        ? Colors.white
                                                        : Colors.black),
                                              ),
                                              Slider(
                                                value: kMeanClusterBinsSlider,
                                                onChanged: (value) =>
                                                    setState(() {
                                                  kMeanClusterBinsSlider =
                                                      value;
                                                  settingBloc.add(
                                                      FilterEditedActionEvent());
                                                }),
                                                min: 1,
                                                max: 20,
                                                divisions: 20,
                                                label: kMeanClusterBinsSlider
                                                    .round()
                                                    .toString(),
                                              ),
                                            ],
                                          )),
                                        )
                                      : Expanded(flex: 1, child: SizedBox()),
                                  transform
                                      ? Expanded(
                                          flex: 1,
                                          child: FittedBox(
                                            child: Column(
                                              children: [
                                                Text(
                                                  'Transform',
                                                  style: TextStyle(
                                                      color: DarkTheme
                                                          ? Colors.white
                                                          : Colors.black),
                                                ),
                                                Slider(
                                                  value: affineSlider1,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    affineSlider1 = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 100,
                                                  divisions: 100,
                                                  label: affineSlider1
                                                      .round()
                                                      .toString(),
                                                ),
                                                Slider(
                                                  value: affineSlider2,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    affineSlider2 = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 100,
                                                  divisions: 100,
                                                  label: affineSlider2
                                                      .round()
                                                      .toString(),
                                                ),
                                                Slider(
                                                  value: affineSlider3,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    affineSlider3 = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 100,
                                                  divisions: 100,
                                                  label: affineSlider3
                                                      .round()
                                                      .toString(),
                                                ),
                                                Slider(
                                                  value: affineSlider4,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    affineSlider4 = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 100,
                                                  divisions: 100,
                                                  label: affineSlider4
                                                      .round()
                                                      .toString(),
                                                ),
                                                Slider(
                                                  value: affineSlider5,
                                                  onChanged: (value) =>
                                                      setState(() {
                                                    affineSlider5 = value;
                                                    settingBloc.add(
                                                        FilterEditedActionEvent());
                                                  }),
                                                  min: 1,
                                                  max: 100,
                                                  divisions: 100,
                                                  label: affineSlider5
                                                      .round()
                                                      .toString(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : Expanded(flex: 1, child: SizedBox()),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 10,
                              child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: selectedFilter == Filter.morphology
                                      ? morphologyElements
                                      : selectedFilter == Filter.threshold
                                          ? thresholdElements
                                          : selectedFilter ==
                                                  Filter.edgeDetector
                                              ? edgeDetectorElements
                                              : selectedFilter ==
                                                      Filter.contours
                                                  ? contoursElements
                                                  : smoothingElements),
                            ),
                            Expanded(
                              flex: 1,
                              child: ElevatedButton(
                                  onPressed: () async {
                                    String? selectedFolderPath =
                                        (await FilePicker.platform
                                                .getDirectoryPath())! +
                                            '/output.jpg';
                                    File sourceFile =
                                        File('assets/images/output.jpg');
                                    final destinationFile =
                                        File(selectedFolderPath);
                                    await sourceFile.copy(destinationFile.path);
                                  },
                                  child: Text('save image')),
                            )
                          ],
                        ),
                      ))
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  List<Widget> get categoriesFilter {
    return [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
            onPressed: () => setState(() {
                  selectedFilter = Filter.smoothing;
                }),
            color: selectedFilter == Filter.smoothing
                ? Colors.blueAccent.withOpacity(0.5)
                : Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(20),
            child: Text('Smoothing',
                style: TextStyle(
                    color: DarkTheme == true ? Colors.white : Colors.black))),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
            onPressed: () => setState(() {
                  selectedFilter = Filter.threshold;
                }),
            color: selectedFilter == Filter.threshold
                ? Colors.blueAccent.withOpacity(0.5)
                : Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(20),
            child: Text('Threshold',
                style: TextStyle(
                    color: DarkTheme == true ? Colors.white : Colors.black))),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
            onPressed: () => setState(() {
                  selectedFilter = Filter.morphology;
                }),
            color: selectedFilter == Filter.morphology
                ? Colors.blueAccent.withOpacity(0.5)
                : Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(20),
            child: Text('Morphology',
                style: TextStyle(
                    color: DarkTheme == true ? Colors.white : Colors.black))),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
            onPressed: () => setState(() {
                  selectedFilter = Filter.edgeDetector;
                }),
            color: selectedFilter == Filter.edgeDetector
                ? Colors.blueAccent.withOpacity(0.5)
                : Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(20),
            child: Text('Edge Detector',
                style: TextStyle(
                    color: DarkTheme == true ? Colors.white : Colors.black))),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: MaterialButton(
            onPressed: () => setState(() {
                  selectedFilter = Filter.contours;
                }),
            color: selectedFilter == Filter.contours
                ? Colors.blueAccent.withOpacity(0.5)
                : Colors.transparent,
            elevation: 0,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            padding: EdgeInsets.all(20),
            child: Text('Contours',
                style: TextStyle(
                    color: DarkTheme == true ? Colors.white : Colors.black))),
      ),
    ];
  }

  List<Widget> get smoothingElements {
    return [
      InkWell(
          onTap: () {
            setState(() {
              if (selectedSmoothingFilter == SmoothingFilter.normal) {
                selectedSmoothingFilter = SmoothingFilter.none;
              } else {
                selectedSmoothingFilter = SmoothingFilter.normal;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedSmoothingFilter == SmoothingFilter.normal
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Normal'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedSmoothingFilter == SmoothingFilter.gaussian) {
                selectedSmoothingFilter = SmoothingFilter.none;
              } else {
                selectedSmoothingFilter = SmoothingFilter.gaussian;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedSmoothingFilter == SmoothingFilter.gaussian
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Gaussian'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedSmoothingFilter == SmoothingFilter.median) {
                selectedSmoothingFilter = SmoothingFilter.none;
              } else {
                selectedSmoothingFilter = SmoothingFilter.median;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedSmoothingFilter == SmoothingFilter.median
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Median'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedSmoothingFilter == SmoothingFilter.bilateral) {
                selectedSmoothingFilter = SmoothingFilter.none;
              } else {
                selectedSmoothingFilter = SmoothingFilter.bilateral;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedSmoothingFilter == SmoothingFilter.bilateral
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Bilateral filter'),
              ))),
      Slider(
        value: selectedSmoothingSlider,
        onChanged: (value) => setState(() {
          selectedSmoothingSlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 1,
        max: 31,
        divisions: 31,
        label: selectedSmoothingSlider.round().toString(),
      )
    ];
  }

  List<Widget> get thresholdElements {
    return [
      InkWell(
          onTap: () {
            setState(() {
              if (selectedThresholdFilter == ThresholdFilter.binary) {
                selectedThresholdFilter = ThresholdFilter.none;
              } else {
                selectedThresholdFilter = ThresholdFilter.binary;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedThresholdFilter == ThresholdFilter.binary
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Binary'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedThresholdFilter == ThresholdFilter.binaryInverted) {
                selectedThresholdFilter = ThresholdFilter.none;
              } else {
                selectedThresholdFilter = ThresholdFilter.binaryInverted;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedThresholdFilter == ThresholdFilter.binaryInverted
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Binary Inverted'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedThresholdFilter == ThresholdFilter.truncate) {
                selectedThresholdFilter = ThresholdFilter.none;
              } else {
                selectedThresholdFilter = ThresholdFilter.truncate;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedThresholdFilter == ThresholdFilter.truncate
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Truncate'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedThresholdFilter == ThresholdFilter.toZero) {
                selectedThresholdFilter = ThresholdFilter.none;
              } else {
                selectedThresholdFilter = ThresholdFilter.toZero;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedThresholdFilter == ThresholdFilter.toZero
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('To Zero'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedThresholdFilter == ThresholdFilter.toZeroInverted) {
                selectedThresholdFilter = ThresholdFilter.none;
              } else {
                selectedThresholdFilter = ThresholdFilter.toZeroInverted;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedThresholdFilter == ThresholdFilter.toZeroInverted
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('To Zero Inverted'),
              ))),
      Slider(
        value: selectedThresholdSlider,
        onChanged: (value) => setState(() {
          selectedThresholdSlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 0,
        max: 255,
        divisions: 255,
        label: selectedThresholdSlider.round().toString(),
      ),
      Divider(),
      Center(
          child: Text(
        'Adaptive',
        style: TextStyle(color: DarkTheme ? Colors.white : Colors.black),
      )),
      InkWell(
          onTap: () {
            setState(() {
              if (adaptiveThresholdFilter == AdaptiveThresholdFilter.mean) {
                adaptiveThresholdFilter = AdaptiveThresholdFilter.none;
              } else {
                adaptiveThresholdFilter = AdaptiveThresholdFilter.mean;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: adaptiveThresholdFilter == AdaptiveThresholdFilter.mean
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Mean'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (adaptiveThresholdFilter == AdaptiveThresholdFilter.gaussian) {
                adaptiveThresholdFilter = AdaptiveThresholdFilter.none;
              } else {
                adaptiveThresholdFilter = AdaptiveThresholdFilter.gaussian;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: adaptiveThresholdFilter == AdaptiveThresholdFilter.gaussian
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Gaussian'),
              ))),
      Slider(
        value: selectedAdaptiveThresholdIntensitySlider,
        onChanged: (value) => setState(() {
          selectedAdaptiveThresholdIntensitySlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 1,
        max: 100,
        divisions: 99,
        label: selectedAdaptiveThresholdIntensitySlider.round().toString(),
      ),
      Slider(
        value: selectedAdaptiveThresholdSizeSlider,
        onChanged: (value) => setState(() {
          selectedAdaptiveThresholdSizeSlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 0,
        max: 30,
        divisions: 30,
        label: selectedAdaptiveThresholdSizeSlider.round().toString(),
      )
    ];
  }

  List<Widget> get contoursElements {
    return [
      InkWell(
          onTap: () {
            setState(() {
              if (selectedContoursFilter == ContoursFilter.contours) {
                selectedContoursFilter = ContoursFilter.none;
              } else {
                selectedContoursFilter = ContoursFilter.contours;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedContoursFilter == ContoursFilter.contours
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Contours'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedContoursFilter == ContoursFilter.convexHull) {
                selectedContoursFilter = ContoursFilter.none;
              } else {
                selectedContoursFilter = ContoursFilter.convexHull;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedContoursFilter == ContoursFilter.convexHull
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Convex Hull'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedContoursFilter ==
                  ContoursFilter.rotatedRectanglesEllipses) {
                selectedContoursFilter = ContoursFilter.none;
              } else {
                selectedContoursFilter =
                    ContoursFilter.rotatedRectanglesEllipses;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedContoursFilter ==
                      ContoursFilter.rotatedRectanglesEllipses
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('rotated and Rectangles Ellipses'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedContoursFilter == ContoursFilter.moments) {
                selectedContoursFilter = ContoursFilter.none;
              } else {
                selectedContoursFilter = ContoursFilter.moments;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedContoursFilter == ContoursFilter.moments
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Moments'),
              ))),
      Slider(
        value: selectedContoursSlider,
        onChanged: (value) => setState(() {
          selectedContoursSlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 1,
        max: 100,
        divisions: 100,
        label: selectedContoursSlider.round().toString(),
      )
    ];
  }

  List<Widget> get morphologyElements {
    return [
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.dilation) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.dilation;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.dilation
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Dilation'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.erosion) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.erosion;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.erosion
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Erosion'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.opening) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.opening;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.opening
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Opening'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.closing) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.closing;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.closing
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Closing'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter ==
                  MorphologyFilter.morphologicalGradient) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter =
                    MorphologyFilter.morphologicalGradient;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter ==
                      MorphologyFilter.morphologicalGradient
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Morphological Gradient'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.topHat) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.topHat;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.topHat
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Top Hat'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.blackHat) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.blackHat;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.blackHat
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Black Hat'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.horizontalEdge) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.horizontalEdge;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.horizontalEdge
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Horizontal Edge'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedMorphologyFilter == MorphologyFilter.verticalEdge) {
                selectedMorphologyFilter = MorphologyFilter.none;
              } else {
                selectedMorphologyFilter = MorphologyFilter.verticalEdge;
              }
              settingBloc.add(FilterEditedActionEvent());
            });
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedMorphologyFilter == MorphologyFilter.verticalEdge
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Vertical Edge'),
              ))),
      Slider(
        value: selectedMorphologySlider,
        onChanged: (value) => setState(() {
          selectedMorphologySlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 1,
        max: 30,
        divisions: 29,
        label: selectedMorphologySlider.round().toString(),
      )
    ];
  }

  List<Widget> get edgeDetectorElements {
    return [
      InkWell(
          onTap: () {
            setState(() {
              if (selectedEdgeDetectorFilter == EdgeDetectorFilter.sobel) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.none;
              } else if (selectedEdgeDetectorFilter ==
                  EdgeDetectorFilter.canny) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.sobel;
                selectedEdgeDetectorSlider = 15;
              } else {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.sobel;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedEdgeDetectorFilter == EdgeDetectorFilter.sobel
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('sobel'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedEdgeDetectorFilter == EdgeDetectorFilter.scharr) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.none;
              } else if (selectedEdgeDetectorFilter ==
                  EdgeDetectorFilter.canny) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.scharr;
                selectedEdgeDetectorSlider = 15;
              } else {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.scharr;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedEdgeDetectorFilter == EdgeDetectorFilter.scharr
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('scharr'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedEdgeDetectorFilter == EdgeDetectorFilter.laplacian) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.none;
              } else if (selectedEdgeDetectorFilter ==
                  EdgeDetectorFilter.canny) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.laplacian;
                selectedEdgeDetectorSlider = 15;
              } else {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.laplacian;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedEdgeDetectorFilter == EdgeDetectorFilter.laplacian
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('laplacian'),
              ))),
      InkWell(
          onTap: () {
            setState(() {
              if (selectedEdgeDetectorFilter == EdgeDetectorFilter.canny) {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.none;
              } else {
                selectedEdgeDetectorFilter = EdgeDetectorFilter.canny;
              }
            });
            settingBloc.add(FilterEditedActionEvent());
          },
          borderRadius: BorderRadius.circular(15),
          child: Card(
              color: selectedEdgeDetectorFilter == EdgeDetectorFilter.canny
                  ? Colors.deepPurpleAccent.withOpacity(0.5)
                  : Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('canny filter'),
              ))),
      Slider(
        value: selectedEdgeDetectorSlider,
        onChanged: (value) => setState(() {
          selectedEdgeDetectorSlider = value;
          settingBloc.add(FilterEditedActionEvent());
        }),
        min: 1,
        max: selectedEdgeDetectorFilter == EdgeDetectorFilter.canny ? 100 : 15,
        divisions:
            selectedEdgeDetectorFilter == EdgeDetectorFilter.canny ? 100 : 15,
        label: selectedEdgeDetectorSlider.round().toString(),
      )
    ];
  }
}
