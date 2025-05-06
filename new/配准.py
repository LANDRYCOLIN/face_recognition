# 配准人脸图像
import cv2
import dlib
import numpy as np
import os

# 配置路径
base_img_path = "new/codetest/3.jpg"  # 基准图片路径
input_folder = "new/all"  # 已处理图片目录
output_folder = "new/output2"  # 输出目录

# 初始化dlib组件
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor("new/shape_predictor_68_face_landmarks.dat")  # 需提前下载模型文件

def get_landmarks(img):
    """获取人脸68个关键点坐标"""
    dets = detector(img, 1)
    if len(dets) == 0:
        return None
    shape = predictor(img, dets[0])
    return np.array([[p.x, p.y] for p in shape.parts()])

def align_image_with_rotation(img, landmarks):
    """旋转、裁剪图像为正方形并缩放到353x353像素"""
    # 选择两眼的关键点
    left_eye = landmarks[36:42].mean(axis=0)
    right_eye = landmarks[42:48].mean(axis=0)
    
    # 计算两眼连线的角度
    dy = right_eye[1] - left_eye[1]
    dx = right_eye[0] - left_eye[0]
    angle = np.degrees(np.arctan2(dy, dx))
    
    # 计算旋转矩阵
    center = tuple(np.mean([left_eye, right_eye], axis=0).astype(float))  # 转换为浮点数元组
    M = cv2.getRotationMatrix2D(center, angle, scale=1.0)
    
    # 旋转图像
    rotated_img = cv2.warpAffine(img, M, (img.shape[1], img.shape[0]))
    
    # 更新关键点坐标
    ones = np.ones((landmarks.shape[0], 1))
    landmarks_homogeneous = np.hstack([landmarks, ones])
    rotated_landmarks = np.dot(M, landmarks_homogeneous.T).T
    
    # 裁剪图像为正方形并缩放到353x353像素
    # 添加眉毛的关键点(17, 19, 21为左眉毛, 22, 24, 26为右眉毛)
    points = [27, 30, 8, 45, 36, 48, 54, 17, 19, 21, 22, 24, 26]  # 添加眉毛点
    selected_points = rotated_landmarks[points]
    x_min, y_min = np.min(selected_points, axis=0)
    x_max, y_max = np.max(selected_points, axis=0)
    width = x_max - x_min
    height = y_max - y_min
    max_side = max(width, height)
    
    # 稍微扩大一点裁剪区域，确保眉毛上方有足够空间
    center_x = (x_min + x_max) // 2
    center_y = (y_min + y_max) // 2
    margin = int(max_side * 0.1)  # 添加10%的边距
    max_side_with_margin = max_side + 2 * margin
    
    x_min = max(0, center_x - max_side_with_margin // 2)
    y_min = max(0, center_y - max_side_with_margin // 2)
    x_max = min(rotated_img.shape[1], center_x + max_side_with_margin // 2)
    y_max = min(rotated_img.shape[0], center_y + max_side_with_margin // 2)
    cropped_img = rotated_img[int(y_min):int(y_max), int(x_min):int(x_max)]
    resized_img = cv2.resize(cropped_img, (353, 353), interpolation=cv2.INTER_LINEAR)
    return resized_img

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
            # 执行旋转、裁剪和缩放
            aligned_img = align_image_with_rotation(img, landmarks)
            
            # 保存结果
            output_path = os.path.join(output_folder, filename)
            cv2.imwrite(output_path, aligned_img)
            print(f"Processed: {filename}")
        else:
            print(f"Skipped: {filename} (No face detected)")

print("配准完成！")
