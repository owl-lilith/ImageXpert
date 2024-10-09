# Image Processing API
Note: the applied theories in this system belong to [Computer Vision: Algorithms and Applications](http://szeliski.org/Book/), [Learning OpenCV by Bradski and Kaehler](https://www.bogotobogo.com/cplusplus/files/OReilly%20Learning%20OpenCV.pdf)

<p align="center">
  <img src="https://github.com/owl-lilith/ImageXpert/output/overview.png" alt="System Overview" width="600">
</p>


This FastAPI application provides endpoints for performing image processing operations using OpenCV and Python. It includes functionalities like image comparison, smoothing, thresholding, morphological transformations, edge detection, and more. The API allows for the upload of images and application of various transformations based on user-provided parameters, then save to the local device.

---

## Technologies Used
- **FastAPI**: creating the API.
- **OpenCV**: image processing functions.
- **NumPy**: handling arrays and matrix operations.
- **Pillow (PIL)**: image manipulation and conversion.
- **Flutter**: user interaction and output visualization 

---

## Features

Note: for fully understand the usage of the system services check [basic image processing](output/basic%20image%20processing.mp4), [transform image processing](output/transform%20image%20processing.mp4) and [fetch similar images](output/fetch%20similar%20images.mp4)

- **Fetch Similar Images**
- **Smoothing (Blur)**
    - *normal*
    - *gaussian*
    - *median*
    - *bilateral*
- **Threshold Filters**
    - *binary*
    - *binaryInverted*
    - *truncate*
    - *toZero*
    - *toZeroInverted*
    - *Otsu*
- **Adaptive Threshold Filters**
    - *gaussian*
    - *mean*
- **Morphology Filters**
    - *dilation*
    - *erosion*
    - *opening*
    - *closing*
    - *morphologicalGradient*
    - *topHat*
    - *blackHat*
    - *verticalEdge*
- **Edge Detector**
    - *sobel*
    - *scharr*
    - *laplacian*
    - *canny*
- **Zooming**
    - *zoom in*
    - *zoom out*
- **Rotate**
- **Affine**
- **Flip**
- **Hough**
    - *contrast*
    - *line detector*
    - *circle detector*
- **Contours**
    - *contours*
    - *convexHull*
    - *rotatedRectanglesEllipses*
    - *moments*
- **Histogram**
- **Back Projection**
- **K-Mean Cluster**
- **Corner Detector**
- **Stretch**
    - *cubic*
    - *nearest*
    - *linear*