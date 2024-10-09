import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_processing_basic/data/editing_image.dart';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';
import 'package:meta/meta.dart';

import '../../data/api.dart';

part 'setting_event.dart';
part 'setting_state.dart';

class SettingBloc extends Bloc<SettingEvent, SettingState> {
  SettingBloc() : super(SettingInitial()) {
    on<BrowseImageActionEvent>(browseImageActionEvent);
    on<BrowseVideoActionEvent>(browseVideoActionEvent);
    on<FetchSimilarImagesActionEvent>(fetchSimilarImagesActionEvent);
    on<FilterEditedActionEvent>(filterEditedActionEvent);
  }

  FutureOr<void> fetchSimilarImagesActionEvent(
      FetchSimilarImagesActionEvent event, Emitter<SettingState> emit) async {
    try {
      emit(SimilarImagesLoadingActionState());
      String? selectedFolderPath =
          (await FilePicker.platform.getDirectoryPath());
      similarImages = await fetchSimilar(inputImage, selectedFolderPath!);
      emit(SimilarImagesSuccessfullyLoadedActionState(similarImages));
    } catch (error) {
      emit(SimilarImagesErrorActionState(error.toString()));
    }
  }

  FutureOr<void> filterEditedActionEvent(
      FilterEditedActionEvent event, Emitter<SettingState> emit) async {
    try {
      emit(ImageLoadingActionState());
      Map data = {
        'smoothing': selectedSmoothingFilter.name,
        'threshold': selectedThresholdFilter.name,
        'morphology': selectedMorphologyFilter.name,
        'edgeDetector': selectedEdgeDetectorFilter.name,
        'zooming': selectedZoom.name,
        'rotate': rotate.toString(),
        'affine': transform.toString(),
        'flip': flip.toString(),
        'hough': hough.name,
        'contours': selectedContoursFilter.name,
        'histogram': histogram.toString(),
        'backProjection': backProjection.toString(),
        'adaptiveThreshold': adaptiveThresholdFilter.name,
        'kMeanCluster': kMeanCluster.toString(),
        'corner': corner.toString(),
        'stretch': stretch.name,
        'smoothing_kernel': selectedSmoothingSlider.round().toString(),
        'threshold_kernel': selectedThresholdSlider.round().toString(),
        'morphology_kernel': selectedMorphologySlider.round().toString(),
        'edgeDetector_kernel': selectedEdgeDetectorSlider.round().toString(),
        'affine_kernel1': affineSlider1.round().toString(),
        'affine_kernel2': affineSlider2.round().toString(),
        'affine_kernel3': affineSlider3.round().toString(),
        'affine_kernel4': affineSlider4.round().toString(),
        'affine_kernel5': affineSlider5.round().toString(),
        'contour_kernel': selectedContoursSlider.round().toString(),
        'adaptiveThreshold_intensity_kernel':
            selectedAdaptiveThresholdIntensitySlider.round().toString(),
        'adaptiveThreshold_size_kernel':
            selectedAdaptiveThresholdSizeSlider.round().toString(),
        'kMeanCluster_kernel': kMeanClusterBinsSlider.round().toString(),
        'stretch_width': stretchWidth.round().toString(),
        'stretch_height': stretchHeight.round().toString(),
      };

      Image processedImage = await uploadImage(inputImage, data);

      emit(ImageSuccessfullyLoadedActionState(processedImage));
    } catch (error) {
      emit(ImageErrorActionState(error.toString()));
    }
  }

  FutureOr<void> browseImageActionEvent(
      BrowseImageActionEvent event, Emitter<SettingState> emit) async {
    try {
      emit(ImageLoadingActionState());
      // awit post image
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );
      if (result != null && result.files.single.path != null) {
        inputImage = File(result.files.single.path!);
        File sourceFile1 = File('assets/images/input.jpg');
        File sourceFile2 = File('assets/images/output.jpg');
        await inputImage.copy(sourceFile1.path);
        await inputImage.copy(sourceFile2.path);
        selectedEdgeDetectorSlider = 10;
        selectedSmoothingFilter = SmoothingFilter.none;
        selectedEdgeDetectorFilter = EdgeDetectorFilter.none;
        selectedThresholdFilter = ThresholdFilter.none;
        selectedMorphologyFilter = MorphologyFilter.none;
        selectedZoom = Zoom.none;
        rotate = 0;
        transform = false;
        flip = false;
        hough = Hough.none;
        selectedContoursFilter = ContoursFilter.none;
        histogram = false;
        adaptiveThresholdFilter = AdaptiveThresholdFilter.none;
        kMeanCluster = false;
        corner = false;
        stretch = Stretch.none;
        stretchHeight = 1;
        stretchWidth = 1;
        kMeanClusterBinsSlider = 2;
      }
      emit(ImageSuccessfullyLoadedActionState(Image.file(inputImage)));
    } catch (error) {
      emit(ImageErrorActionState(error.toString()));
    }
  }

  FutureOr<void> browseVideoActionEvent(
      BrowseVideoActionEvent event, Emitter<SettingState> emit) async {
    // try {
    emit(VideoLoadingActionState());
    // awit post image

    // _videoFile = File(pickedFile.path!);
    //       _controller = VideoPlayerController.file(_videoFile!)
    //         ..initialize().then((_) {
    //           setState(() {}); // To update the UI after initialization
    //           _controller!.play();
    //         });
    //     });

    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.path != null) {
      // player.open(Media(result.files.single.path!));
      
      // print('here0');

      // String? videoPath = result.files.single.path;
      // print(videoPath);
      // videoController = VideoPlayerController.file(File(videoPath!))
      //   ;await videoController!.initialize();
    }
    // if (videoController != null) {
      // print('here1');
      // inputVideo = VideoPlayer(videoController!);
    
      // inputVideo = Video(controller: controller);
    
    // }

    // emit(VideoSuccessfullyLoadedActionState(inputVideo!));
    // } catch (error) {
    //   emit(VideoErrorActionState(error.toString()));
    // }
  }
}
