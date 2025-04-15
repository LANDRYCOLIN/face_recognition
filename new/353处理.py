from PIL import Image
import os

# 设置路径和目标尺寸
input_folder = "all"
output_size = (353, 353)

# 遍历文件夹中的所有文件
for filename in os.listdir(input_folder):
    if filename.lower().endswith(('.png', '.jpg', '.jpeg', '.bmp', '.gif')):
        filepath = os.path.join(input_folder, filename)

        try:
            # 打开图像并调整大小
            with Image.open(filepath) as img:
                resized_img = img.resize(output_size, Image.ANTIALIAS)
                resized_img.save(filepath)  # 覆盖保存

                print(f"已处理：{filename}")
        except Exception as e:
            print(f"处理 {filename} 时出错：{e}")

print("所有图片已调整为 353x353 尺寸。")
