## 项目结构

```
├── Face registration/       # 人脸图像配准模块
│   ├── main.py              # 主要配准处理脚本
│   └── 配准old.py           # 旧版配准算法
├── face_new/                # 人脸图像批处理模块
│   ├── 01-文件夹标号.bat     # 文件夹批量重命名
│   ├── 02-图片标号.bat       # 图片批量重命名
│   └── 03-移动.bat          # 图片批量移动
├── matcode/                 # MATLAB算法代码
│   ├── face_recognition.m   # 人脸检测算法
│   ├── recognition.m        # 人脸识别算法
│   └── untitled.m           # 图像批处理脚本
├── new/                     # 新版图像处理工具
│   ├── 353处理.py           # 图像尺寸标准化处理
│   ├── 灰度化.py            # 图像灰度化处理
│   └── 配准.py              # 人脸配准处理
└── 人脸识别ui/               # 人脸识别界面
    ├── face_recognition_UI.m       # 用户界面主程序
    └── face_recognition_functions.m # 识别功能实现
```

## 功能模块说明

### 1. 人脸配准（Face Registration）

人脸配准模块使用dlib库进行人脸关键点检测和图像对齐，确保所有人脸图像具有统一的尺寸和姿态，为后续识别提供标准化的输入。

关键功能：
- 人脸检测和关键点提取
- 图像对齐变换
- 人脸区域裁剪和标准化输出

### 2. 批处理工具（BAT脚本）

提供一系列批处理脚本，用于快速处理大量图像文件：
- 文件夹编号：自动为文件夹添加序号命名
- 图片编号：按照特定格式重命名图片
- 移动合并：将分散在不同文件夹的图片集中到统一文件夹

### 3. 图像预处理（Python脚本）

提供图像预处理功能：
- 353处理：将图像调整为统一的353×353像素尺寸
- 灰度化：将彩色图像转换为灰度图并增强对比度
- 配准：对齐人脸特征点，标准化人脸方向和位置

### 4. 人脸识别UI（MATLAB）

基于PCA的人脸识别实验平台，提供图形化界面：
- 图像选择与预处理
- 参数调整（裁切、旋转、翻转）
- 人脸识别结果展示

## 安装依赖

### Python依赖

```bash
pip install numpy opencv-python dlib pillow
```

### 必要文件

- 需要下载`shape_predictor_68_face_landmarks.dat`并放置在对应目录下
- MATLAB需要安装Computer Vision Toolbox

## 使用说明

### 1. 人脸配准处理

```bash
cd "Face registration"
# 修改main.py中的路径配置
python main.py
```

### 2. 批量处理图像

运行批处理脚本：
1. 双击`01-文件夹标号.bat`对文件夹进行编号
2. 双击`02-图片标号.bat`对图片进行编号
3. 双击`03-移动.bat`将图片移动到all文件夹

### 3. 图像预处理

```bash
cd new
# 处理图像尺寸为353x353
python 353处理.py
# 进行灰度化处理
python 灰度化.py
# 执行人脸配准
python 配准.py
```

### 4. 运行人脸识别UI

在MATLAB中运行：
```matlab
cd 人脸识别ui
face_recognition_UI
```

## 注意事项

1. 使用前请确保已正确配置所有路径
2. 配准处理需要下载dlib人脸关键点模型文件
3. 人脸识别UI目前为实验平台，核心识别算法需要进一步完善
4. 处理大量图片时，请确保有足够的磁盘空间和内存

git push origin main