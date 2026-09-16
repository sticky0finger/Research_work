clc,close all;
%% 参数设置
d = 4.2e-3;      % 钢块厚度 (转换为米)
T = 25.0;        % 水温 (摄氏度) - 根据实际实验设置
Fs = 1e7;        % 采样频率 (Hz) - 根据实际示波器设置调整

%% 水中的声速 (根据温度)
c_w = 1402.9 + 4.835*T - 0.047016*T^2 + 0.00012725*T^3;

%% 读取CSV文件 - 插入样品前
data1 = readtable('未插入样品前脉冲.CSV');  
y1 = data1{1:end, 5};           % 读取幅度数据
x_sample1 = (0:length(y1)-1)';   % 生成采样点序号

% 插入样品前接收脉冲波形图
figure(1);
plot(x_sample1, y1, 'b', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('未插入样品前脉冲');
grid on;

%% 读取CSV文件 - 插入样品后
data2 = readtable('插入胶皮脉冲1.CSV');  
y2 = data2{1:end, 5};           % 读取幅度数据
x_sample2 = (0:length(y2)-1)';   % 生成采样点序号

% 插入样品后接收脉冲波形图
figure(2);
plot(x_sample2, y2, 'b', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('插入钢块后脉冲');
grid on;

%% 计算声速 - 通过时间差
% 找到最大幅值对应的采样点
[~, idx1] = max(abs(y1));  % 插入前最大幅值位置
[~, idx2] = max(abs(y2));  % 插入后最大幅值位置

% 计算时间差 (秒)
delta_n = idx2-idx1;  % 采样点差
delta_t = delta_n / Fs;      % 时间差

% 计算样品中的声速
c_s = d / (d/c_w + delta_t);

fprintf('==================================================\n');
fprintf('声速计算结果:\n');
fprintf('水中的声速 (%.1f°C): %.2f m/s\n', T, c_w);
fprintf('时间差: %.2f ns (对应 %d 个采样点)\n', delta_t*1e9, delta_n);
fprintf('亚克力块的声速: %.2f m/s\n', c_s);
fprintf('==================================================\n');

%% 计算声衰减系数 - 通过频谱分析
% 计算FFT
N = length(y1);  % FFT点数
frequencies = (0:N-1)*(Fs/N);  % 频率轴

% 计算幅度谱
A0 = abs(fft(y1));  % 未插入样品的幅度谱
As = abs(fft(y2));  % 插入样品后的幅度谱

% 计算衰减系数 (dB/m)
alpha_dB = (20*log10(A0) - 20*log10(As)) / d;

%% 选择对应于2.25MHz的衰减系数
target_freq = 2.25e6;  % 2.25MHz
[~, idx] = min(abs(frequencies - target_freq));  % 找到最接近的频率索引
result_alpha_dB = alpha_dB(idx);  % 提取对应值

% 输出结果
fprintf('声衰减系数 (在 %.2f MHz): %.2f dB/m\n', frequencies(idx)/1e6, result_alpha_dB);

% 可选：绘制衰减系数随频率的变化图
figure(3);
plot(frequencies/1e6, alpha_dB, 'b', 'LineWidth', 1.5);
xlabel('频率 (MHz)');
ylabel('声衰减系数 (dB/m)');
title('声衰减系数随频率变化');
grid on;
hold on;
plot(frequencies(idx)/1e6, result_alpha_dB, 'ro', 'MarkerSize', 8, 'LineWidth', 2);  % 标记选择点
legend('衰减系数', '选择点');