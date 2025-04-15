import cv2
import dlib
import numpy as np
import os

# ====== 路径配置 ======
base_img_path = "E:/Code/face_recogniton/Face registration/10_10.jpg"
input_folder = "E:/Code/face_recogniton/Face registration/2_output"
output_folder = "E:/Code/face_recogniton/Face registration/result"
predictor_path = "shape_predictor_68_face_landmarks.dat"

# ====== 初始化人脸检测器与关键点预测器 ======
detector = dlib.get_frontal_face_detector()
predictor = dlib.shape_predictor(predictor_path)

# ====== 获取人脸关键点函数 ======
def get_landmarks(img):
    faces = detector(img, 1)
    if len(faces) == 0:
        return None
    shape = predictor(img, faces[0])
    return np.array([[p.x, p.y] for p in shape.parts()])

# ====== 对齐函数 ======
def align_image(img, landmarks, ref_landmarks):
    indices = [27, 30, 8, 45, 36, 48, 54]  # 鼻梁、眼角、嘴角等
    src = landmarks[indices].astype(np.float32)
    dst = ref_landmarks[indices].astype(np.float32)
    M, _ = cv2.estimateAffinePartial2D(src, dst)
    aligned = cv2.warpAffine(img, M, (353, 353), flags=cv2.INTER_LINEAR)
    return aligned

# ====== 人脸裁剪函数（自动补边） ======
def crop_face_no_border(aligned_img, landmarks, output_size=(353, 353), box_ratio=1.4):
    min_xy = np.min(landmarks, axis=0)
    max_xy = np.max(landmarks, axis=0)
    center = (min_xy + max_xy) / 2
    box_size = np.max(max_xy - min_xy) * box_ratio

    x1 = int(center[0] - box_size / 2)
    y1 = int(center[1] - box_size / 2)
    x2 = int(center[0] + box_size / 2)
    y2 = int(center[1] + box_size / 2)

    h, w = aligned_img.shape
    crop = np.full((y2 - y1, x2 - x1), 128, dtype=np.uint8)

    x_start = max(0, x1)
    y_start = max(0, y1)
    x_end = min(w, x2)
    y_end = min(h, y2)

    crop_x1 = x_start - x1
    crop_y1 = y_start - y1
    crop_x2 = crop_x1 + (x_end - x_start)
    crop_y2 = crop_y1 + (y_end - y_start)

    crop[crop_y1:crop_y2, crop_x1:crop_x2] = aligned_img[y_start:y_end, x_start:x_end]

    resized = cv2.resize(crop, output_size)
    return resized

# ====== 创建输出文件夹 ======
os.makedirs(output_folder, exist_ok=True)

# ====== 获取基准图关键点 ======
base_img = cv2.imread(base_img_path, cv2.IMREAD_GRAYSCALE)
ref_landmarks = get_landmarks(base_img)

if ref_landmarks is None:
    print("❌ 未检测到基准图人脸，请更换基准图！")
    exit()

# ====== 遍历所有图片进行处理 ======
for filename in os.listdir(input_folder):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg')):
        img_path = os.path.join(input_folder, filename)
        img = cv2.imread(img_path, cv2.IMREAD_GRAYSCALE)
        landmarks = get_landmarks(img)

        if landmarks is not None:
            aligned_img = align_image(img, landmarks, ref_landmarks)
            aligned_landmarks = get_landmarks(aligned_img)

            if aligned_landmarks is not None:
                cropped = crop_face_no_border(aligned_img, aligned_landmarks)
                save_path = os.path.join(output_folder, filename)
                cv2.imwrite(save_path, cropped)
                print(f"✅ Processed: {filename}")
            else:
                print(f"⚠️ Skipped (no landmarks after align): {filename}")
        else:
            print(f"⚠️ Skipped (no face): {filename}")

print("🎉 全部处理完成！")
