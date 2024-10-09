import 'dart:io';
// import 'package:media_kit/media_kit.dart';
// import 'package:media_kit_video/media_kit_video.dart';

enum Zoom { none, zoom_in, zoom_out }

enum Hough { none, line, circle }

enum SmoothingFilter { none, normal, gaussian, median, bilateral }

enum EdgeDetectorFilter { none, sobel, scharr, laplacian, canny }

enum AdaptiveThresholdFilter { none, gaussian, mean }

enum Stretch { none, cubic, linear, nearest }

enum ThresholdFilter {
  none,
  binary,
  binaryInverted,
  truncate,
  toZero,
  toZeroInverted
}

enum MorphologyFilter {
  none,
  dilation,
  erosion,
  opening,
  closing,
  morphologicalGradient,
  topHat,
  blackHat,
  horizontalEdge,
  verticalEdge
}

enum ContoursFilter {
  none,
  contours,
  convexHull,
  rotatedRectanglesEllipses,
  moments
}

File inputImage = File("assets/images/test.jpg");
// Video? inputVideo;
// late final player = Player();
// late final controller = VideoController(player);

List<String> similarImages = [];

double selectedSmoothingSlider = 20;
double selectedThresholdSlider = 20;
double selectedAdaptiveThresholdIntensitySlider = 3; // 99
double selectedAdaptiveThresholdSizeSlider = 2; // 30
double selectedMorphologySlider = 20;
double selectedEdgeDetectorSlider = 10;
double affineSlider1 = 33;
double affineSlider2 = 85;
double affineSlider3 = 25;
double affineSlider4 = 15;
double affineSlider5 = 70;
double selectedContoursSlider = 40;
double kMeanClusterBinsSlider = 2; // 255
double stretchWidth = 1; // 4
double stretchHeight = 1; // 4

SmoothingFilter selectedSmoothingFilter = SmoothingFilter.none;
EdgeDetectorFilter selectedEdgeDetectorFilter = EdgeDetectorFilter.none;
ThresholdFilter selectedThresholdFilter = ThresholdFilter.none;
MorphologyFilter selectedMorphologyFilter = MorphologyFilter.none;
Zoom selectedZoom = Zoom.none;
int rotate = 0;
bool transform = false;
bool flip = false;
Hough hough = Hough.none;
ContoursFilter selectedContoursFilter = ContoursFilter.none;
bool histogram = false;
bool backProjection = false;
AdaptiveThresholdFilter adaptiveThresholdFilter = AdaptiveThresholdFilter.none;
bool kMeanCluster = false;
bool corner = false;
Stretch stretch = Stretch.none;
