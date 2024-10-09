part of 'setting_bloc.dart';

@immutable
sealed class SettingEvent {}

class ZoomInButtonClickedEvent extends SettingEvent {}

class ZoomOutButtonClickedEvent extends SettingEvent {}

class BrowseImageActionEvent extends SettingEvent {}

class BrowseVideoActionEvent extends SettingEvent {}

class FilterEditedActionEvent extends SettingEvent {}

class FetchSimilarImagesActionEvent extends SettingEvent {}
