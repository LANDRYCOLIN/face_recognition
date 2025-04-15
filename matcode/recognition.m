%% 1. 设置文件夹路径
mainImageFilePath = "E:\Code\face_recogniton\face";  % 原始图像存放路径
mainImageSavePath = "E:\Code\face_recogniton\face_result";  % 目标存储路径

% 获取所有子文件夹（不同类别）
dirList = dir(mainImageFilePath);
dirList = dirList([dirList.isdir]);  % 仅保留文件夹
dirList = dirList(~ismember({dirList.name}, {'.', '..'}));  % 移除 '.' 和 '..'

%% 2. 初始化人脸检测器
faceDetector = vision.CascadeObjectDetector();
faceDetector.MergeThreshold = 4;  % 设置合并阈值，提高检测准确率

%% 3. 遍历每个类别文件夹
for n = 1:length(dirList)
    categoryName = dirList(n).name;
    stImageFilePath = fullfile(mainImageFilePath, categoryName);  % 读取路径
    stImageSavePath = fullfile(mainImageSavePath, categoryName);  % 存储路径
    
    % 创建存储文件夹（如果不存在）
    if ~exist(stImageSavePath, 'dir')
        mkdir(stImageSavePath);
        fprintf('已创建文件夹: %s\n', stImageSavePath);
    end

    % 获取所有 .jpg 图片
    imageFiles = dir(fullfile(stImageFilePath, '*.jpg'));
    
    if isempty(imageFiles)
        fprintf('文件夹 %s 中没有图片\n', stImageFilePath);
        continue;
    end
    
    %% 4. 处理每张图片
    for i = 1:length(imageFiles)
        try
            % 读取图片
            imgPath = fullfile(stImageFilePath, imageFiles(i).name);
            img = imread(imgPath);
            
            % 人脸检测
            bbox = step(faceDetector, img);
            
            if isempty(bbox)
                fprintf('未检测到人脸: %s\n', imageFiles(i).name);
                continue;
            end
            
            % 取第一个检测到的人脸区域
            faceBox = bbox(1, :);  
            x = faceBox(1);
            y = faceBox(2);
            w = faceBox(3);
            h = faceBox(4);
            
            % 扩展人脸区域（可调节，防止裁剪过小）
            expandRatio = 0.2;
            x = max(1, x - round(w * expandRatio / 2));
            y = max(1, y - round(h * expandRatio / 2));
            w = min(size(img, 2) - x, round(w * (1 + expandRatio)));
            h = min(size(img, 1) - y, round(h * (1 + expandRatio)));
            
            % 裁剪人脸区域
            faceImg = imcrop(img, [x, y, w, h]);
            
            % 存储裁剪后的人脸
            savePath = fullfile(stImageSavePath, sprintf('%d.jpg', i));
            imwrite(faceImg, savePath);
            
            fprintf('处理成功: %s -> %s\n', imageFiles(i).name, savePath);
        
        catch ME
            fprintf('处理失败: %s | 错误信息: %s\n', imageFiles(i).name, ME.message);
        end
    end
end
