function face_recognition_functions(action, varargin)
    %% FACE_RECOGNITION_FUNCTIONS 人脸识别功能函数集
    % 此文件包含所有与人脸识别相关的功能函数
    %
    % 参数:
    %   action - 要执行的操作名称
    %   varargin - 可变参数，根据不同的操作需要不同的参数
    
    switch action
        case 'selectImage'
            selectImage(varargin{:});
        case 'clearImage'
            clearImage(varargin{:});
        case 'adjustCrop'
            adjustCrop(varargin{:});
        case 'adjustRotation'
            adjustRotation(varargin{:});
        case 'flipImageDirect'
            flipImageDirect(varargin{:});
        case 'applyParameters'
            applyParameters(varargin{:});
        case 'applyFlip'
            applyFlip(varargin{:});
        case 'startRecognition'
            startRecognition(varargin{:});
        case 'directInputCrop'
            directInputCrop(varargin{:});
        case 'directInputRotation'
            directInputRotation(varargin{:});
        case 'convertToGrayscale'
            convertToGrayscale(varargin{:});
        otherwise
            error('未知操作: %s', action);
    end
end

%% --- 图像选择与清除函数 ---

% 选择图像函数
% 功能：打开文件选择对话框，读取并显示选中的图像
% 参数：
%   mainFig: 主窗口句柄
%   imgAxes: 图像显示区域句柄
function selectImage(mainFig, imgAxes)
    [filename, pathname] = uigetfile({'*.jpg;*.jpeg;*.png;*.bmp', '图像文件 (*.jpg, *.jpeg, *.png, *.bmp)'}, '选择待识别图像');
    if isequal(filename, 0) || isequal(pathname, 0)
        return;
    end
    
    % 读取图像
    img = imread(fullfile(pathname, filename));
    userData = getappdata(mainFig, 'UserData');
    userData.originalImg = img;
    userData.processedImg = img;
    setappdata(mainFig, 'UserData', userData);
    
    % 显示图像
    axes(imgAxes);
    imshow(img);
    title('待识别图像', 'Color', [1, 1, 1]);
end

% 清除图像函数
% 功能：清除当前显示的图像，重置所有参数
% 参数：
%   mainFig: 主窗口句柄
%   imgAxes: 图像显示区域句柄
%   cropSlider: 裁切滑动条句柄
%   rotateSlider: 旋转滑动条句柄
%   flipNone, flipHoriz, flipVert: 翻转选项按钮句柄
function clearImage(mainFig, imgAxes, cropSlider, rotateSlider, flipNone, flipHoriz, flipVert)
    userData = getappdata(mainFig, 'UserData');
    userData.originalImg = [];
    userData.processedImg = [];
    userData.cropFactor = 1;
    userData.rotationAngle = 0;
    userData.flipDir = 'none';
    setappdata(mainFig, 'UserData', userData);
    
    % 清除图像显示
    axes(imgAxes);
    cla;
    axis off;
    text(0.5, 0.5, '请选择待识别图像', ...
         'HorizontalAlignment', 'center', ...
         'Color', [0.7, 0.7, 0.7]);
    
    % 重置参数
    set(cropSlider, 'Value', 1);
    set(rotateSlider, 'Value', 0);
    % 设置"无"翻转为选中
    set(flipNone, 'Value', 1);
    set(flipHoriz, 'Value', 0);
    set(flipVert, 'Value', 0);
end

%% --- 图像参数调整函数 ---

% 调整裁切函数
% 功能：根据滑动条值更新裁切因子
% 参数：
%   mainFig: 主窗口句柄
%   src: 事件源对象(滑动条)
%   cropValueText: 裁切值显示文本句柄
function adjustCrop(mainFig, src, cropValueText)
    userData = getappdata(mainFig, 'UserData');
    userData.cropFactor = get(src, 'Value');
    setappdata(mainFig, 'UserData', userData);
    set(cropValueText, 'String', sprintf('%.2f', userData.cropFactor)); % 更新数值显示
end

% 调整旋转函数
% 功能：根据滑动条值更新旋转角度
% 参数：
%   mainFig: 主窗口句柄
%   src: 事件源对象(滑动条)
%   rotateValueText: 旋转值显示文本句柄
function adjustRotation(mainFig, src, rotateValueText)
    userData = getappdata(mainFig, 'UserData');
    userData.rotationAngle = get(src, 'Value');
    setappdata(mainFig, 'UserData', userData);
    set(rotateValueText, 'String', sprintf('%.1f°', userData.rotationAngle)); % 更新数值显示
end

% 直接翻转函数（用于独立按钮）
% 功能：根据选择的翻转类型更新翻转方向
% 参数：
%   mainFig: 主窗口句柄
%   flipType: 翻转类型('none', 'horizontal', 'vertical')
%   flipNone, flipHoriz, flipVert: 翻转选项按钮句柄
function flipImageDirect(mainFig, flipType, flipNone, flipHoriz, flipVert)
    % 取消选中其他按钮
    if strcmp(flipType, 'none')
        set(flipHoriz, 'Value', 0);
        set(flipVert, 'Value', 0);
    elseif strcmp(flipType, 'horizontal')
        set(flipNone, 'Value', 0);
        set(flipVert, 'Value', 0);
    else % vertical
        set(flipNone, 'Value', 0);
        set(flipHoriz, 'Value', 0);
    end
    
    % 更新翻转方向
    userData = getappdata(mainFig, 'UserData');
    userData.flipDir = flipType;
    setappdata(mainFig, 'UserData', userData);
end

%% --- 图像处理函数 ---

% 应用参数函数
% 功能：将裁切、旋转和翻转参数应用到图像上
% 参数：
%   mainFig: 主窗口句柄
%   imgAxes: 图像显示区域句柄
function applyParameters(mainFig, imgAxes)
    userData = getappdata(mainFig, 'UserData');
    if isempty(userData.originalImg)
        return;
    end
    
    img = userData.originalImg;
    
    % 应用裁切
    if userData.cropFactor < 1
        [rows, cols, ~] = size(img);
        cropRows = round(rows * userData.cropFactor);
        cropCols = round(cols * userData.cropFactor);
        startRow = round((rows - cropRows) / 2);
        startCol = round((cols - cropCols) / 2);
        img = img(startRow:startRow+cropRows-1, startCol:startCol+cropCols-1, :);
    end
    
    % 应用旋转
    if userData.rotationAngle ~= 0
        img = imrotate(img, userData.rotationAngle, 'bilinear', 'crop');
    end
    
    % 应用翻转
    if strcmp(userData.flipDir, 'horizontal')
        img = fliplr(img);
    elseif strcmp(userData.flipDir, 'vertical')
        img = flipud(img);
    end
    
    userData.processedImg = img;
    setappdata(mainFig, 'UserData', userData);
    
    % 显示处理后的图像
    axes(imgAxes);
    imshow(img);
    title('处理后的图像', 'Color', [1, 1, 1]);
end

% 应用翻转函数
% 功能：单独应用翻转参数到当前处理后的图像
% 参数：
%   mainFig: 主窗口句柄
%   imgAxes: 图像显示区域句柄
function applyFlip(mainFig, imgAxes)
    userData = getappdata(mainFig, 'UserData');
    if isempty(userData.originalImg)
        return;
    end
    
    % 获取当前处理后的图像作为基础
    % 如果之前已经应用了裁切和旋转，保留这些效果
    img = userData.processedImg;
    
    % 检查当前图像是否已经应用了翻转
    % 如果已经应用了翻转，先恢复到未翻转状态
    % 这里简化处理，直接从原始图像重新应用裁切和旋转
    if ~strcmp(userData.flipDir, 'none')
        img = userData.originalImg;
        
        % 重新应用裁切
        if userData.cropFactor < 1
            [rows, cols, ~] = size(img);
            cropRows = round(rows * userData.cropFactor);
            cropCols = round(cols * userData.cropFactor);
            startRow = round((rows - cropRows) / 2);
            startCol = round((cols - cropCols) / 2);
            img = img(startRow:startRow+cropRows-1, startCol:startCol+cropCols-1, :);
        end
        
        % 重新应用旋转
        if userData.rotationAngle ~= 0
            img = imrotate(img, userData.rotationAngle, 'bilinear', 'crop');
        end
    end
    
    % 应用选择的翻转
    if strcmp(userData.flipDir, 'horizontal')
        img = fliplr(img);
    elseif strcmp(userData.flipDir, 'vertical')
        img = flipud(img);
    end
    
    userData.processedImg = img;
    setappdata(mainFig, 'UserData', userData);
    
    % 显示处理后的图像
    axes(imgAxes);
    imshow(img);
    title('处理后的图像', 'Color', [1, 1, 1]);
end

% 开始识别函数
% 功能：执行人脸识别算法并显示结果
% 参数：
%   mainFig: 主窗口句柄
%   resultText: 结果文本区域句柄
%   similarityText: 相似度显示句柄
%   matchAxes: 匹配图像显示区句柄
function startRecognition(mainFig, resultText, similarityText, matchAxes)
    userData = getappdata(mainFig, 'UserData');
    if isempty(userData.processedImg)
        msgbox('请先选择待识别图像', '提示', 'warn');
        return;
    end
    
    % 这里应该实现人脸识别算法
    % 由于人脸识别算法较为复杂，此处仅作为示例
    % 实际应用中需要替换为真实的人脸识别代码
    
    % 模拟识别过程
    set(resultText, 'String', '正在识别...');
    pause(1);
    
    % 模拟识别结果
    set(resultText, 'String', '识别完成!');
    set(similarityText, 'String', sprintf('相似度: %.2f%%', rand()*100));
    
    % 显示模拟的匹配结果
    axes(matchAxes);
    % 这里应该显示数据库中匹配到的人脸图像
    % 此处仅作为示例，显示处理后的图像
    imshow(userData.processedImg);
    title('最佳匹配', 'Color', [1, 1, 1]);
end

% 直接输入裁切值函数
% 功能：通过对话框直接输入裁切因子值
% 参数：
%   mainFig: 主窗口句柄
%   cropSlider: 裁切滑动条句柄
%   cropValueText: 裁切值显示文本句柄
function directInputCrop(mainFig, cropSlider, cropValueText)
    userData = getappdata(mainFig, 'UserData');
    currentValue = userData.cropFactor;
    
    % 创建输入对话框
    prompt = {'请输入裁切因子 (0.1-1.0):'};
    dlgtitle = '直接输入裁切值';
    dims = [1 40];
    definput = {num2str(currentValue)};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    % 检查用户是否取消了输入
    if isempty(answer)
        return;
    end
    
    % 尝试转换输入值为数值
    try
        newValue = str2double(answer{1});
        % 检查输入值是否在有效范围内
        if isnan(newValue) || newValue < 0.1 || newValue > 1.0
            errordlg('请输入0.1到1.0之间的数值', '输入错误');
            return;
        end
        
        % 更新裁切因子值
        userData.cropFactor = newValue;
        setappdata(mainFig, 'UserData', userData);
        
        % 更新滑动条和显示文本
        set(cropSlider, 'Value', newValue);
        set(cropValueText, 'String', sprintf('%.2f', newValue));
    catch
        errordlg('输入格式错误，请输入有效数值', '输入错误');
    end
end

% 直接输入旋转角度函数
% 功能：通过对话框直接输入旋转角度值
% 参数：
%   mainFig: 主窗口句柄
%   rotateSlider: 旋转滑动条句柄
%   rotateValueText: 旋转值显示文本句柄
function directInputRotation(mainFig, rotateSlider, rotateValueText)
    userData = getappdata(mainFig, 'UserData');
    currentValue = userData.rotationAngle;
    
    % 创建输入对话框
    prompt = {'请输入旋转角度 (-180° 到 180°):'};
    dlgtitle = '直接输入旋转角度';
    dims = [1 40];
    definput = {num2str(currentValue)};
    answer = inputdlg(prompt, dlgtitle, dims, definput);
    
    % 检查用户是否取消了输入
    if isempty(answer)
        return;
    end
    
    % 尝试转换输入值为数值
    try
        newValue = str2double(answer{1});
        % 检查输入值是否在有效范围内
        if isnan(newValue) || newValue < -180 || newValue > 180
            errordlg('请输入-180到180之间的数值', '输入错误');
            return;
        end
        
        % 更新旋转角度值
        userData.rotationAngle = newValue;
        setappdata(mainFig, 'UserData', userData);
        
        % 更新滑动条和显示文本
        set(rotateSlider, 'Value', newValue);
        set(rotateValueText, 'String', sprintf('%.1f°', newValue));
    catch
        errordlg('输入格式错误，请输入有效数值', '输入错误');
    end
end

% 灰度化处理函数
% 功能：将当前处理的图像转换为灰度图
% 参数：
%   mainFig: 主窗口句柄
%   imgAxes: 图像显示区域句柄
function convertToGrayscale(mainFig, imgAxes)
    userData = getappdata(mainFig, 'UserData');
    if isempty(userData.processedImg)
        msgbox('请先选择待处理的图像', '提示', 'warn');
        return;
    end
    
    % 将图像转换为灰度图
    grayImg = rgb2gray(userData.processedImg);
    userData.processedImg = grayImg;
    setappdata(mainFig, 'UserData', userData);
    
    % 显示灰度图
    axes(imgAxes);
    imshow(grayImg);
    title('灰度图像', 'Color', [1, 1, 1]);
end