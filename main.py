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
   

# Run the FastAPI server using: uvicorn app:app --reload
