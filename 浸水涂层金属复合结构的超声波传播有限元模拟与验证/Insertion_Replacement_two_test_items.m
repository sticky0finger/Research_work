clc, clear
close all;

%% 参数
d1 = 10;           % 厚样品厚度 (mm)
d2 = 7.5;           % 薄样品厚度 (mm)

%% 读取CSV文件 - 插入样品1
data1 = readtable('7.5mm钢块透射波3.CSV');  
y1 = data1{1:end, 5};           % 读取幅度数据
x_sample1 = (0:length(y1)-1)';   % 生成采样点序号（0~2499）

% 插入样品1接收脉冲波形图
figure(1);
plot(x_sample1, y1, 'b', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('7.5mm钢块脉冲波');
grid on;

%% 读取CSV文件 - 插入样品2
data2 = readtable('10mm钢块透射波3.CSV');  
y2 = data2{1:end, 5};           % 读取幅度数据
x_sample2 = (0:length(y2)-1)';   % 生成采样点序号（0~2499）

% 插入样品2接收脉冲波形图
figure(2);
plot(x_sample2, y2, 'r', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('10mm钢块脉冲波');
grid on;

%% 计算声衰减系数
% 1. 提取最大幅值
A1 = max(abs(y2));  % 插入厚样品接收脉冲幅值
A2 = max(abs(y1));   % 插入薄样品后接收脉冲幅值

% 2. 计算声衰减系数 (dB/m)
d_m1 = d1 / 1000;  % 将厚度从mm转换为m
d_m2 = d2 / 1000;
alpha_dB = 20 / (d_m1-d_m2) * (log10(A2 / A1));

% 3. 将声衰减系数转换为奈培单位 (Np/m)
alpha_Np = alpha_dB / (20 * log10(exp(1)));  % 1 dB = 1/(20*log10(e)) Np

%% 显示计算结果
fprintf('================= 声衰减系数计算结果 =================\n');
fprintf('插入厚样品脉冲最大幅值 (A1): %.6f V\n', A1);
fprintf('插入薄样品脉冲最大幅值 (A2): %.6f V\n', A2);
fprintf('\n声衰减系数 (α):\n');
fprintf('  以分贝为单位: %.6f dB/m\n', alpha_dB);
fprintf('  以奈培为单位: %.6f Np/m\n', alpha_Np);