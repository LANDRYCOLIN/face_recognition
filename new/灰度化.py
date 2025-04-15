import cv2
import os

input_folder = "new/all"

# 遍历文件夹
for filename in os.listdir(input_folder):
    if filename.lower().endswith(('.jpg', '.jpeg', '.png', '.bmp')):
        filepath = os.path.join(input_folder, filename)

        # 读取彩色图像
        img = cv2.imread(filepath)

        # 将其转为灰度图
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

        # 应用直方图均衡化（增强对比度）
        equalized = cv2.equalizeHist(gray)

        # 保存（覆盖原图）
        cv2.imwrite(filepath, equalized)
        print(f"已处理：{filename}")

print("灰度化并增强完成。")
