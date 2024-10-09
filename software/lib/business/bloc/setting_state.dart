part of 'setting_bloc.dart';

@immutable
sealed class SettingState {}

final class SettingInitial extends SettingState {}

class ImageLoadingActionState extends SettingState {}

class ImageSuccessfullyLoadedActionState extends SettingState {
  final Image processedImage;
  ImageSuccessfullyLoadedActionState(this.processedImage);
}

class ImageErrorActionState extends SettingState {
  final String message;
  ImageErrorActionState(this.message);
}

class VideoLoadingActionState extends SettingState {}

class VideoSuccessfullyLoadedActionState extends SettingState {
  // final Video processedVideo;
  // VideoSuccessfullyLoadedActionState(this.processedVideo);
}

class VideoErrorActionState extends SettingState {
  final String message;
  VideoErrorActionState(this.message);
}

class SimilarImagesLoadingActionState extends SettingState {}

class SimilarImagesSuccessfullyLoadedActionState extends SettingState {
  final List<String> similarImages;
  SimilarImagesSuccessfullyLoadedActionState(this.similarImages);
}

class SimilarImagesErrorActionState extends SettingState {
  final String message;
  SimilarImagesErrorActionState(this.message);
}
