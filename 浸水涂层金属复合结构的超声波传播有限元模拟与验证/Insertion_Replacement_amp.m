clc, clear
close all;

%% 用户提供的参数
d = 4.2;           % 样品厚度 (mm)
rho_sample = 7340; % 样品密度 (kg/m³)，将g/cm³转换为kg/m³
c_sample = 5736;   % 样品声速 (m/s)
rho_water = 997.416;   % 水密度 (kg/m³)
c_water = 1492.895;    % 水声速 (m/s)

%% 读取CSV文件 - 插入样品前
data1 = readtable('未插入钢块前脉冲1.CSV');  
y1 = data1{1:end, 5};           % 读取幅度数据
x_sample1 = (0:length(y1)-1)';   % 生成采样点序号（0~2499）

% 插入样品前接收脉冲波形图
figure(1);
plot(x_sample1, y1, 'b', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('未插入钢块前脉冲');
grid on;

%% 读取CSV文件 - 插入样品后
data2 = readtable('插入钢块后脉冲1.CSV');  
y2 = data2{1:end, 5};           % 读取幅度数据
x_sample2 = (0:length(y2)-1)';   % 生成采样点序号（0~2499）

% 插入样品后接收脉冲波形图
figure(2);
plot(x_sample2, y2, 'r', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('插入钢块后脉冲');
grid on;

%% 计算声衰减系数
% 1. 提取最大幅值
A0 = max(abs(y1));  % 插入样品前接收脉冲幅值
A = max(abs(y2));   % 插入样品后接收脉冲幅值

% 2. 计算声阻抗
Z_sample = rho_sample * c_sample;  % 样品声阻抗
Z_water = rho_water * c_water;     % 水声阻抗

% 3. 计算公式中的修正项
transmission_term = (Z_sample + Z_water)^2 / (4 * Z_sample * Z_water);

% 4. 计算声衰减系数 (dB/m)
d_m = d / 1000;  % 将厚度从mm转换为m
alpha_dB = abs((20 / d_m) * (log10(A0 / A) - log10(transmission_term)));

% 5. 将声衰减系数转换为奈培单位 (Np/m)
alpha_Np = alpha_dB / (20 * log10(exp(1)));  % 1 dB = 1/(20*log10(e)) Np

%% 显示计算结果
fprintf('================= 声衰减系数计算结果 =================\n');
fprintf('样品厚度 (d): %.3f mm = %.6f m\n', d, d_m);
fprintf('插入样品前最大幅值 (A0): %.6f V\n', A0);
fprintf('插入样品后最大幅值 (A): %.6f V\n', A);
fprintf('幅值比 (A0/A): %.6f\n', A0/A);
fprintf('样品声阻抗 (Z_sample): %.3f rayl\n', Z_sample);
fprintf('水声阻抗 (Z_water): %.3f rayl\n', Z_water);
fprintf('\n声衰减系数 (α):\n');
fprintf('  以分贝为单位: %.6f dB/m\n', alpha_dB);
fprintf('  以奈培为单位: %.6f Np/m\n', alpha_Np);