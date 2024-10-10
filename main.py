from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse, StreamingResponse
from PIL import Image
import io
import os
import cv2 as cv
import numpy as np
import random as rn
import shutil

app = FastAPI()


@app.post("/get_similar/")
async def get_list(image: UploadFile = File(...),
             template_path: str = Form(...),
             folder_path: str = Form(...),
             ):
    # input_image = Image.open(io.BytesIO(await template_image.read()))
    # input_image = np.array(input_image)
    print(template_path)
    template_image = cv.imread(template_path)
    h_bins = 50
    s_bins = 60
    histSize = [h_bins, s_bins]
    h_ranges = [0, 180]
    s_ranges = [0, 256]
    ranges = h_ranges + s_ranges  # concat lists
    channels = [0, 1]
    template_hsv = cv.cvtColor(template_image, cv.COLOR_BGR2HSV)
    template_hist = cv.calcHist(
        [template_hsv], channels, None, histSize, ranges, accumulate=False)
    cv.normalize(template_hist, template_hsv, alpha=0,
                 beta=1, norm_type=cv.NORM_MINMAX)

    image_files = []
    for f in os.listdir(folder_path):
        if f.endswith(('.png', '.jpg', '.jpeg', '.bmp')):
            image_path = os.path.join(folder_path, f)
            image = cv.imread(image_path)
            if image is None:
                print(f"Error: Unable to load image {image_path}")
                continue
            image_hsv = cv.cvtColor(image, cv.COLOR_BGR2HSV)
            image_hist = cv.calcHist([image_hsv], channels, None, histSize, ranges, accumulate=False)
            cv.normalize(image_hist, image_hsv, alpha=0, beta=1, norm_type=cv.NORM_MINMAX)
            comparison_value = cv.compareHist(template_hist, image_hist,  cv.HISTCMP_CORREL)
            if comparison_value >= 0.7:
                image_files.append(image_path)

    return image_files

@app.post("/upload-image/")
async def upload_image(file: UploadFile = File(...),
                       smoothing: str = Form(...),
                       threshold: str = Form(...),
                       morphology: str = Form(...),
                       edgeDetector: str = Form(...),
                       zooming: str = Form(...),
                       rotate: int = Form(...),
                       affine: str = Form(...),
                       flip: str = Form(...),
                       hough: str = Form(...),
                       contours: str = Form(...),
                       histogram: str = Form(...),
                       backProjection: str = Form(...),
                       adaptiveThreshold: str = Form(...),
                       kMeanCluster: str = Form(...),
                       corner: str = Form(...),
                       stretch: str = Form(...),
                       smoothing_kernel: int = Form(...),
                       threshold_kernel: int = Form(...),
                       morphology_kernel: int = Form(...),
                       edgeDetector_kernel: int = Form(...),
                       affine_kernel1: int = Form(...),
                       affine_kernel2: int = Form(...),
                       affine_kernel3: int = Form(...),
                       affine_kernel4: int = Form(...),
                       affine_kernel5: int = Form(...),
                       contour_kernel: int = Form(...),
                       adaptiveThreshold_intensity_kernel: int = Form(...), # 99
                       adaptiveThreshold_size_kernel: int = Form(...), # 30
                       kMeanCluster_kernel: int = Form(...), # 255
                       stretch_width: int = Form(...),
                       stretch_height: int = Form(...),
                       ):
    # Read the uploaded image
    image = Image.open(io.BytesIO(await file.read()))
    image = np.array(image)
    rows, columns, _ = image.shape
    gray = cv.cvtColor(image, cv.COLOR_RGB2GRAY)
    
    if zooming == 'zoom_in':
        image = cv.pyrUp(image, dstsize=(columns * 2, rows * 2))
    elif zooming == 'zoom_out':
        image = cv.pyrDown(image, dstsize=(columns // 2, rows // 2))

    MAX_KERNEL_LENGTH = smoothing_kernel * 2 + 1

    if smoothing == 'normal':
        image = cv.blur(image, (MAX_KERNEL_LENGTH, MAX_KERNEL_LENGTH))
    elif smoothing == 'gaussian':
        image = cv.GaussianBlur(
            image, (MAX_KERNEL_LENGTH, MAX_KERNEL_LENGTH), 0)
    elif smoothing == 'median':
        image = cv.medianBlur(image, MAX_KERNEL_LENGTH)
    elif smoothing == 'bilateral':
        image = cv.bilateralFilter(
            image, MAX_KERNEL_LENGTH, MAX_KERNEL_LENGTH * 2, MAX_KERNEL_LENGTH / 2)

    if threshold == 'binary':
        _, image = cv.threshold(image, int(
            threshold_kernel), 255, cv.THRESH_BINARY)
    elif threshold == 'binaryInverted':
        _, image = cv.threshold(image, int(
            threshold_kernel), 255, cv.THRESH_BINARY_INV)
    elif threshold == 'truncate':
        _, image = cv.threshold(image, int(
            threshold_kernel), 255, cv.THRESH_TRUNC)
    elif threshold == 'toZero':
        _, image = cv.threshold(image, int(
            threshold_kernel), 255, cv.THRESH_TOZERO)
    elif threshold == 'toZeroInverted':
        _, image = cv.threshold(image, int(
            threshold_kernel), 255, cv.THRESH_TOZERO_INV)
    elif threshold == 'Otsu':
        _, image = cv.threshold(image, int(
            threshold_kernel), 255, cv.THRESH_OTSU)
        

    morphology_kernel_size = (morphology_kernel, morphology_kernel)
    morphology_element = cv.getStructuringElement(
        cv.MORPH_ELLIPSE, morphology_kernel_size)    
    bitwise_image = cv.adaptiveThreshold(
        cv.bitwise_not(gray), 255, cv.ADAPTIVE_THRESH_MEAN_C, cv.THRESH_BINARY, 15, -2)
    horizontal = np.copy(bitwise_image)
    vertical = np.copy(bitwise_image)
    horizontal_size = columns // 30
    vertical_size = rows // 30

    if morphology == 'dilation':
        image = cv.dilate(image, morphology_element, iterations=1)
    elif morphology == 'erosion':
        image = cv.erode(image, morphology_element, iterations=1)
    elif morphology == 'opening':
        image = cv.morphologyEx(image, cv.MORPH_OPEN, morphology_element)
    elif morphology == 'closing':
        image = cv.morphologyEx(image, cv.MORPH_CLOSE, morphology_element)
    elif morphology == 'morphologicalGradient':
        image = cv.morphologyEx(image, cv.MORPH_GRADIENT, morphology_element)
    elif morphology == 'topHat':
        image = cv.morphologyEx(image, cv.MORPH_TOPHAT, morphology_element)
    elif morphology == 'blackHat':
        image = cv.morphologyEx(image, cv.MORPH_BLACKHAT, morphology_element)
    elif morphology == 'horizontalEdge':
        horizontalStructure = cv.getStructuringElement(
            cv.MORPH_RECT, (horizontal_size, 1))
        horizontal = cv.erode(horizontal, horizontalStructure)
        image = cv.dilate(horizontal, horizontalStructure)
    elif morphology == 'verticalEdge':
        verticalStructure = cv.getStructuringElement(
            cv.MORPH_RECT, (1, vertical_size))
        vertical = cv.erode(vertical, verticalStructure)
        image = cv.dilate(vertical, verticalStructure)

    rotate = rotate % 4
    map_x = np.zeros((image.shape[0], image.shape[1]), dtype=np.float32)
    map_y = np.zeros((image.shape[0], image.shape[1]), dtype=np.float32)

    center = (image.shape[1]//2, image.shape[0]//2)

    if rotate == 1:
        image = cv.rotate(image, cv.ROTATE_90_CLOCKWISE)
    elif rotate == 2:
        image = cv.rotate(image, cv.ROTATE_180)
    elif rotate == 3:
        image = cv.rotate(image, cv.ROTATE_90_COUNTERCLOCKWISE)
    # print('parameters have to be added',affine)
    if affine == 'true':
        srcTri = np.array([[0, 0], [image.shape[1] - 1, 0],
                          [0, image.shape[0] - 1]]).astype(np.float32)
        dstTri = np.array([[0, image.shape[1] * (affine_kernel1 / 100)], [image.shape[1] * (affine_kernel2 / 100), image.shape[0] * (
            affine_kernel3 / 100)], [image.shape[1] * (affine_kernel4 / 100), image.shape[0] * (affine_kernel5 / 100)]]).astype(np.float32)

        warp_mat = cv.getAffineTransform(srcTri, dstTri)

        warp_dst = cv.warpAffine(
            image, warp_mat, (image.shape[1], image.shape[0]))

        center = (warp_dst.shape[1]//2, warp_dst.shape[0]//2)
        angle = 0
        scale = 1

        rot_mat = cv.getRotationMatrix2D(center, angle, scale)

        image = cv.warpAffine(
            warp_dst, rot_mat, (warp_dst.shape[1], warp_dst.shape[0]))
    else:
        image = image

    map_x = np.zeros((image.shape[0], image.shape[1]), dtype=np.float32)
    map_y = np.zeros((image.shape[0], image.shape[1]), dtype=np.float32)

    if flip == 'true':
        for i in range(map_x.shape[0]):
            map_x[i, :] = [map_x.shape[1]-x for x in range(map_x.shape[1])]
        for j in range(map_y.shape[1]):
            map_y[:, j] = [y for y in range(map_y.shape[0])]
        image = cv.remap(image, map_x, map_y, cv.INTER_LINEAR)

    if hough == 'line':
        canny = cv.Canny(image, 50, 200, None, 3)
        linesP = cv.HoughLinesP(canny, 1, np.pi / 180, 50, None, 50, 10)
        if linesP is not None:
            for i in range(0, len(linesP)):
                l = linesP[i][0]
                cv.line(image, (l[0], l[1]), (l[2], l[3]),
                        (0, 0, 255), 1, cv.LINE_AA)
    elif hough == 'circle':
        circles = cv.HoughCircles(
            cv.medianBlur(gray, 5), cv.HOUGH_GRADIENT, 1, rows / 8, param1=100, param2=30, minRadius=1, maxRadius=30)
        if circles is not None:
            circles = np.uint16(np.around(circles))
            for i in circles[0, :]:
                center = (i[0], i[1])
                # circle center
                cv.circle(image, center, 1, (0, 100, 100), 2)
                # circle outline
                radius = i[2]
                cv.circle(image, center, radius, (255, 0, 255), 2)
    
    rn.seed(12345)
    canny_threshold = contour_kernel
    blur = cv.blur(gray, (5, 5))

    canny_output = cv.Canny(blur, canny_threshold, canny_threshold * 2)
    contours_list, hierarchy = cv.findContours(
        canny_output, cv.RETR_TREE, cv.CHAIN_APPROX_SIMPLE)
    if contours == 'contours':
        image = np.zeros(
            (canny_output.shape[0], canny_output.shape[1], 3), dtype=np.uint8)
        for i in range(len(contours_list)):
            color = (rn.randint(0, 256), rn.randint(
                0, 256), rn.randint(0, 256))
            cv.drawContours(image, contours_list, i, color,
                            1, cv.LINE_8, hierarchy, 0)
    elif contours == 'convexHull':
        hull_list = []
        for i in range(len(contours_list)):
            hull = cv.convexHull(contours_list[i])
            hull_list.append(hull)

        # Draw contours + hull results
        image = np.zeros(
            (canny_output.shape[0], canny_output.shape[1], 3), dtype=np.uint8)
        for i in range(len(contours_list)):
            color = (rn.randint(0, 256), rn.randint(
                0, 256), rn.randint(0, 256))
            cv.drawContours(image, contours_list, i, color)
            cv.drawContours(image, hull_list, i, color)
    elif contours == 'rotatedRectanglesEllipses':
        minRect = [None]*len(contours_list)
        minEllipse = [None]*len(contours_list)
        for i, c in enumerate(contours_list):
            minRect[i] = cv.minAreaRect(c)
            if c.shape[0] > 5:
                minEllipse[i] = cv.fitEllipse(c)
        image = np.zeros(
            (canny_output.shape[0], canny_output.shape[1], 3), dtype=np.uint8)

        for i, c in enumerate(contours_list):
            color = (rn.randint(0, 256), rn.randint(
                0, 256), rn.randint(0, 256))
            cv.drawContours(image, contours_list, i, color)
            if c.shape[0] > 5:
                cv.ellipse(image, minEllipse[i], color, 2)
            box = cv.boxPoints(minRect[i])
            # np.intp: Integer used for indexing (same as C ssize_t; normally either int32 or int64)
            box = np.intp(box)
            cv.drawContours(image, [box], 0, color)
    elif contours == 'moments':
        mu = [None]*len(contours_list)
        for i in range(len(contours_list)):
            mu[i] = cv.moments(contours_list[i])

        mc = [None]*len(contours_list)
        for i in range(len(contours_list)):
            mc[i] = (mu[i]['m10'] / (mu[i]['m00'] + 1e-5),
                     mu[i]['m01'] / (mu[i]['m00'] + 1e-5))

        image = np.zeros(
            (canny_output.shape[0], canny_output.shape[1], 3), dtype=np.uint8)

        for i in range(len(contours_list)):
            color = (rn.randint(0, 256), rn.randint(
                0, 256), rn.randint(0, 256))
            cv.drawContours(image, contours_list, i, color, 2)
            cv.circle(image, (int(mc[i][0]), int(mc[i][1])), 4, color, -1)
    
    if histogram == 'true':
        ycrcb_image = cv.cvtColor(image, cv.COLOR_BGR2YCrCb)
        y_channel, cr_channel, cb_channel = cv.split(ycrcb_image)
        equalized_y_channel = cv.equalizeHist(y_channel)
        equalized_ycrcb_image = cv.merge([equalized_y_channel, cr_channel, cb_channel])
        image = cv.cvtColor(equalized_ycrcb_image, cv.COLOR_YCrCb2BGR)
        
    if backProjection == 'true':
        hsv = cv.cvtColor(image, cv.COLOR_BGR2HSV)
        ch = (0, 0)
        hue = np.empty(hsv.shape, hsv.dtype)
        cv.mixChannels([hsv], [hue], ch)
        bins = 10 # max 180
        histSize = max(bins, 2)
        ranges = [0, 180] # hue_range
        hist = cv.calcHist([hue], [0], None, [histSize], ranges, accumulate=False)
        cv.normalize(hist, hist, alpha=0, beta=255, norm_type=cv.NORM_MINMAX)
        image = cv.calcBackProject([hue], [0], hist, ranges, scale=1)
    
    scale = 1
    ddepth = cv.CV_16S
    delta = 0
    MAX_EdgeDetector_KERNEL_LENGTH = edgeDetector_kernel * 2 + 1

    ratio = 3

    if edgeDetector == 'sobel':
        gradient_x = cv.Sobel(image, ddepth, 1, 0, ksize=MAX_EdgeDetector_KERNEL_LENGTH,
                              scale=scale, delta=delta, borderType=cv.BORDER_DEFAULT)
        gradient_y = cv.Sobel(image, ddepth, 0, 1, ksize=MAX_EdgeDetector_KERNEL_LENGTH,
                              scale=scale, delta=delta, borderType=cv.BORDER_DEFAULT)
        abs_gradient_x = cv.convertScaleAbs(gradient_x)
        abs_gradient_y = cv.convertScaleAbs(gradient_y)
        image = cv.addWeighted(abs_gradient_x, 0.5, abs_gradient_y, 0.5, 0)
    elif edgeDetector == 'scharr':
        gradient_x = cv.Scharr(image, ddepth, 1, 0)
        gradient_y = cv.Scharr(image, ddepth, 0, 1)
        abs_gradient_x = cv.convertScaleAbs(gradient_x)
        abs_gradient_y = cv.convertScaleAbs(gradient_y)
        image = cv.addWeighted(abs_gradient_x, 0.5, abs_gradient_y, 0.5, 0)
    elif edgeDetector == 'laplacian':
        dst = cv.Laplacian(image, ddepth, ksize=MAX_EdgeDetector_KERNEL_LENGTH)
        image = cv.convertScaleAbs(dst)
    elif edgeDetector == 'canny':
        image = cv.Canny(image, edgeDetector_kernel,
                         edgeDetector_kernel*ratio, smoothing_kernel)
    
    
    if stretch == 'cubic':
        image = cv.resize(image,(int(columns*stretch_width),int(rows*stretch_height)),interpolation=cv.INTER_CUBIC)
    elif stretch == 'nearest':
        image = cv.resize(image,(int(columns*stretch_width),int(rows*stretch_height)),interpolation=cv.INTER_NEAREST)
    elif stretch == 'linear':
        image = cv.resize(image,(int(columns*stretch_width),int(rows*stretch_height)),interpolation=cv.INTER_LINEAR)
    
    if kMeanCluster == 'true':
        Z = image.reshape((-1,3))
        Z = np.float32(Z)
        criteria = (cv.TERM_CRITERIA_EPS +cv.TERM_CRITERIA_MAX_ITER, 10, 1.0)
        ret,label,center=cv.kmeans(Z, kMeanCluster_kernel,None,criteria,10,cv.KMEANS_RANDOM_CENTERS)
        center = np.uint8(center)
        res = center[label.flatten()]
        image = res.reshape((image.shape))

    
    if corner == 'true':
        print(image.shape)
        dst = cv.cornerHarris(np.float32(gray),2,3,0.05)
        dst = cv.dilate(dst,None)
        if len(image.shape) == 3:
            image[dst>0.01*dst.max()]=[0,0,255]
        else:
            image[dst>0.01*dst.max()]=[255]
    
    adaptiveThreshold_intensity_kernel = adaptiveThreshold_intensity_kernel * 2 + 1
    if adaptiveThreshold == 'mean':
        image = cv.adaptiveThreshold(gray, 255, cv.ADAPTIVE_THRESH_MEAN_C,cv.THRESH_BINARY, adaptiveThreshold_intensity_kernel, adaptiveThreshold_size_kernel)
    elif adaptiveThreshold == 'gaussian':
        print('here here')
        image = cv.adaptiveThreshold(gray, 255,cv.ADAPTIVE_THRESH_GAUSSIAN_C, cv.THRESH_BINARY, adaptiveThreshold_intensity_kernel, adaptiveThreshold_size_kernel)


    # Prepare image for returning
    image = Image.fromarray(image)
    img_io = io.BytesIO()
    # You can change the format if needed
    image.save(img_io, format="JPEG")
    img_io.seek(0)  # Reset the buffer's position to the beginning

    # Send the image back as a StreamingResponse
    return StreamingResponse(content=img_io, media_type="image/jpeg")
