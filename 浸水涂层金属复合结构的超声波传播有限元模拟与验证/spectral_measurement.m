clc,clear
%% CSV
% 1. 读取CSV文件为表格格式  
data = readtable('F0000CH1.CSV');  

x = data{1:end, 1} * 1e6;  % 转换为微秒单位（秒 → 微秒）
y = data{1:end, 2};

figure(1);
plot(x, y);
title('回波波形图');
xlabel('时间 (µs)');   % 修改单位标注
ylabel('幅度增益');

%% 定义时间范围参数
time_ranges = [17,  19;      % 每组时间范围的起止点
              24,  25.5;
              31,  32.5;
              35,  37];
num_ranges = size(time_ranges,1);  % 获取范围数量

%% 循环处理每个时间范围
for i = 1:num_ranges
    % 提取当前时间范围
    t_start = time_ranges(i,1);
    t_end = time_ranges(i,2);
    
    % 获取时间范围内的数据索引
    idx = (x >= t_start) & (x <= t_end);
    x_segment = x(idx);
    y_segment = y(idx);
    
    % 去直流分量
    y_centered = y_segment - mean(y_segment);
    
    % 计算FFT参数
    N = length(y_centered);            % 数据点数
    Fs = 1/(mean(diff(x_segment))*1e-6); % 采样频率（Hz），注意单位转换
    
    % 执行FFT
    fft_result = fft(y_centered);
    fft_magnitude = abs(fft_result/N);  % 幅度归一化
    fft_magnitude = fft_magnitude(1:floor(N/2)+1); % 取单边频谱
    
    % 生成频率轴
    freq_axis = (0:floor(N/2)) * Fs/N / 1e6; % 频率转换为MHz单位
    
    % 绘制频谱图
    figure(i+1)  % 避免覆盖原始波形图
    plot(freq_axis, fft_magnitude) 
    title(sprintf('[%.1f-%.1fµs] 频谱分析', t_start, t_end))
    xlabel('频率 (MHz)')
    ylabel('幅度')
    grid on
    
    % 标注主要频率成分（可选）
    [max_amp, max_idx] = max(fft_magnitude);
    text(freq_axis(max_idx), max_amp,...
        sprintf('%.2f MHz', freq_axis(max_idx)),...
        'VerticalAlignment','bottom')
end