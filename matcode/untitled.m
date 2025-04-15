numList = {'1', '2', '3', '4', '5', '6', '7', '8', '9', '10'...
    '11', '12', '13', '14', '15', '16', '17', '18', '19', '20'...
    '21', '22', '23', '24', '25', '26', '27', '28', '29', '30'};% 定义名字列表
mainImageFilePath="D:\原始人脸图像\"; %大文件夹的目录
% 遍历每个名字
for n = 1:length(numList)
    fileName = numList{n};
    % 设置目标文件夹路径
    folderPath = fullfile(mainImageFilePath, fileName, filesep); % 修改为你的目标文件夹路径
    % 设置新文件名的基础名字
    baseName = numList{n}; % 修改为你想要的名字
    % 获取文件夹中的文件列表
    fileList = dir(fullfile(folderPath, '*.*')); % 获取所有文件（包括扩展名）
    fileList = fileList([~fileList.isdir]); % 过滤掉子文件夹，只保留文件
    % 检查是否存在文件
    if isempty(fileList)
        disp('文件夹中没有文件。');
    else
        % 遍历文件列表，逐一更改文件名和格式
        for i = 1:length(fileList)
            % 获取原文件名和路径
            oldFileName = fileList(i).name;
            oldFilePath = fullfile(folderPath, oldFileName);
            % 生成新文件名（规则：名字+编号.jpg）
            newFileName = sprintf('%s_%02d.jpg', baseName, i); % 格式化为 "名字_编号.jpg"
            newFilePath = fullfile(folderPath, newFileName);
            % 检查文件是否为图片格式
            [~, ~, ext] = fileparts(oldFileName);
            validFormats = {'.jpg', '.jpeg', '.png', '.bmp', '.tiff', '.gif'}; % 支持的图片格式
            if ismember(lower(ext), validFormats)
                try
                    % 读取图片
                    img = imread(oldFilePath);
                    % 保存为新的jpg文件
                    imwrite(img, newFilePath, 'jpg');
                    % 删除旧文件（在文件有重名的时候选择注释）
                    delete(oldFilePath);
                    fprintf('文件重命名并格式转换成功: %s -> %s\n', oldFileName, newFileName);
                catch ME
                    fprintf('文件重命名或格式转换失败: %s -> %s\n', oldFileName, newFileName);
                    disp(ME.message);
                end
            else
                fprintf('文件格式不支持，跳过: %s\n', oldFileName);
            end
        end
    end
end