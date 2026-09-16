clc
clear all

%% 读取CSV文件
% 读取红色波形数据
data1 = readtable('中心偏移40us（垫高）.CSV');  
y = data1{1:1900, 5};           % 第5列是幅度数据

% 读取蓝色波形数据
data2 = readtable('回波.csv');  
t_blue = data2{1:end, 1};      % 第1列是时间数据（单位：微秒）
y1 = data2{1:end, 2};          % 第2列是幅度数据

%% 设置红色波形参数
% 红色波形参数

fs_red = 25;  % 采样频率 MHz (对应采样间隔 0.04us)
dt_red = 1/fs_red;  % 采样间隔 us (0.04us)
n_red = length(y);  % 采样点数
t_red = (0:n_red-1) * dt_red;  % 创建红色波形时间轴 us

% 对蓝色波形进行等比例放大
% 找到红色波形和蓝色波形的峰值
red_peak = max(abs(y));          % 红色波形峰值
blue_peak = max(abs(y1));        % 蓝色波形峰值

% 计算放大比例因子
scale_factor = red_peak / blue_peak;

% 对蓝色波形进行等比例放大
y1_scaled = y1 * scale_factor;

%% 对红色波形进行左移处理，并补零
shift_amount = 250;  % 左移点数
time_shift = shift_amount * dt_red;  % 左移时间 us

% 执行左移并补零
if shift_amount >= n_red
    error('左移点数超过波形长度，无法处理！');
end

y_shifted = y(shift_amount+1:end);
t_red_shifted = (0:n_red-1-shift_amount) * dt_red;

%% 绘制上下两个子图
figure(1);
set(gcf, 'Position', [100, 100, 800, 600]); % 设置图形窗口大小

% 第一个子图：左移并补零后的红色波形
subplot(2, 1, 1);
plot(t_red_shifted, y_shifted, 'r', 'LineWidth', 1.2);
xlabel('Time (μs)'); 
ylabel('Signal Amplitude');
title(sprintf('Actual Collected Signal (fs=%.0f MHz)', fs_red));
grid on;

% 第二个子图：放大后的蓝色波形
subplot(2, 1, 2);
plot(t_blue, y1_scaled, 'b', 'LineWidth', 1.5);
xlabel('时间 (μs)'); 
ylabel('信号波形');
title(sprintf('仿真信号 (已缩放%.2f倍)', scale_factor));
grid on;

% 添加总标题
sgtitle('信号波形对比', 'FontSize', 14, 'FontWeight', 'bold');

%% 调整子图间距和坐标轴范围
% 设置红色波形的显示范围
% subplot(2, 1, 1);
xlim([0, max(t_red_shifted)]);
y_red_min = min(y_shifted);
y_red_max = max(y_shifted);
y_red_margin = (y_red_max - y_red_min) * 0.06;
ylim([y_red_min - y_red_margin, y_red_max + y_red_margin]);

% 设置蓝色波形的显示范围
subplot(2, 1, 2);
% 根据蓝色波形实际时间范围设置x轴
if t_blue(end) > 100
    % 如果总时间超过100μs，显示前100μs，便于观察
    xlim([t_blue(1), min(t_blue(1)+100, t_blue(end))]);
else
    xlim([t_blue(1), t_blue(end)]);
end
y_blue_min = min(y1_scaled);
y_blue_max = max(y1_scaled);
y_blue_margin = (y_blue_max - y_blue_min) * 0.1;
ylim([y_blue_min - y_blue_margin, y_blue_max + y_blue_margin]);
% 添加网格和美化
grid minor;
