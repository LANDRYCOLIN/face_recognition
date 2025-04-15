# 配准人脸图像
import cv2
import dlib
import numpy as np
import os
from skimage import io

# 配置路径
base_img_path = "E:/Code/face_recogniton/Face registration/10_10.jpg"  # 基准图片路径
input_folder = "E:/Code/face_recogniton/Face registration/2_output"  # 已处理图片目录
output_folder = "E:/Code/face_recogniton/Face registration/result"  # 输出目录

# 初始化dlib组件
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("shape_predictor_68_face_landmarks.dat")  # 需提前下载模型文件

def get_landmarks(img):
    """获取人脸68个关键点坐标"""
    dets = detector(img, 1)
    if len(dets) == 0:
        return None
    shape = predictor(img, dets[0])
    return np.array([[p.x, p.y] for p in shape.parts()])

def align_image(img, landmarks, ref_landmarks):
    """使用相似变换进行图像对齐"""
    # 选择用于对齐的关键点（眼、鼻、嘴）
    points = [27, 30, 8, 45, 36, 48, 54]  # 鼻尖、下巴、左右眼尾、嘴角
    src_points = landmarks[points].astype(np.float32)
    dst_points = ref_landmarks[points].astype(np.float32)
    
    # 计算变换矩阵（相似变换）
    M, _ = cv2.estimateAffinePartial2D(src_points, dst_points)
    
    # 应用变换
    aligned = cv2.warpAffine(img, M, (353, 353), flags=cv2.INTER_LINEAR)
    return aligned

# 处理基准图像
base_img = cv2.imread(base_img_path, cv2.IMREAD_GRAYSCALE)
ref_landmarks = get_landmarks(base_img)

# 创建输出目录
os.makedirs(output_folder, exist_ok=True)

# 遍历处理所有图片
for filename in os.listdir(input_folder):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        img_path = os.path.join(input_folder, filename)
        img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
        
        # 获取关键点
        landmarks = get_landmarks(img)
        
        if landmarks is not None:
            # 执行配准
            aligned_img = align_image(img, landmarks, ref_landmarks)
            
            # 保存结果
            output_path = os.path.join(output_folder, filename)
            cv2.imwrite(output_path, aligned_img)
            print(f"Processed: {filename}")
        else:
            print(f"Skipped: {filename} (No face detected)")

print("配准完成！")