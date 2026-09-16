clc,close all;
%% 参数设置
d = 4.2e-3;      % 钢块厚度 (m)
T = 24.2;        % 水温 (摄氏度) 
Fs = 1e7;        % 采样频率 (Hz) - 示波器设置
rho_sample = 877.11; % 样品密度 (kg/m³)
rho_water = 997.295;   % 水密度 (kg/m³)

%% 水中的声速 (根据温度)
c_w = 1402.9 + 4.835*T - 0.047016*T^2 + 0.00012725*T^3;

%% 读取CSV文件 - 插入样品前
data1 = readtable('未插入胶皮脉冲2.CSV');  
y1 = data1{1:end, 5};           % 读取幅度数据
x_sample1 = (0:length(y1)-1)';   % 生成采样点序号

% 插入样品前接收脉冲波形图
figure(1);
plot(x_sample1, y1, 'b', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('未插入弧形钢板前脉冲');
grid on;

%% 读取CSV文件 - 插入样品后
data2 = readtable('插入胶皮脉冲2.CSV');  
y2 = data2{1:end, 5};           % 读取幅度数据
x_sample2 = (0:length(y2)-1)';   % 生成采样点序号

% 插入样品后接收脉冲波形图
figure(2);
plot(x_sample2, y2, 'b', 'LineWidth', 1.5);
xlabel('采样点'); ylabel('信号幅度 (V)');
title('插入弧形钢板后脉冲');
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
fprintf('胶皮的声速: %.2f m/s\n', c_s);
fprintf('==================================================\n');

%% 计算声衰减系数
% 1. 提取最大幅值
A0 = max(abs(y1));  % 插入样品前接收脉冲幅值
A = max(abs(y2));   % 插入样品后接收脉冲幅值

% 2. 计算声阻抗
Z_sample = rho_sample * c_s;  % 样品声阻抗
Z_water = rho_water * c_w;     % 水声阻抗

% 3. 计算公式中的修正项
transmission_term = (Z_sample + Z_water)^2 / (4 * Z_sample * Z_water);

% 4. 计算声衰减系数 (dB/m)
alpha_dB = (20 / d) * (log10(A0 / A) - log10(transmission_term));

% 5. 将声衰减系数转换为奈培单位 (Np/m)
alpha_Np = alpha_dB / (20 * log10(exp(1)));  % 1 dB = 1/(20*log10(e)) Np

%% 显示计算结果
fprintf('================= 声衰减系数计算结果 =================\n');
fprintf('样品厚度 (d): %.3f mm = \n', d);
fprintf('插入样品前最大幅值 (A0): %.6f V\n', A0);
fprintf('插入样品后最大幅值 (A): %.6f V\n', A);
fprintf('幅值比 (A0/A): %.6f\n', A0/A);
fprintf('\n声衰减系数 (α):\n');
fprintf('  以分贝为单位: %.6f dB/m\n', alpha_dB);
fprintf('  以奈培为单位: %.6f Np/m\n', alpha_Np);