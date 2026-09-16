clc
clear all
%% 读取CSV文件
data1 = readtable('中心偏移40us（垫高）.CSV');
y = data1{1:1900, 5};           % 第5列是幅度数据
data2 = readtable('回波.csv');
t_blue = data2{1:end, 1};      % 第1列是时间数据（单位：微秒）
y1 = data2{1:end, 2};          % 第2列是幅度数据

%% 设置实验采集波形参数
fs_red = 25;  % 采样频率 MHz (对应采样间隔 0.04us)
dt_red = 1/fs_red;  % 采样间隔 us (0.04us)
n_red = length(y);  % 采样点数
t_red = (0:n_red-1) * dt_red;  % 创建时间轴 us

% 对仿真波形进行等比例放大
red_peak = max(abs(y));
blue_peak = max(abs(y1));
scale_factor = red_peak / blue_peak;
y1_scaled = y1 * scale_factor;

%% 对实验采集信号进行左移处理
shift_amount = 250;
time_shift = shift_amount * dt_red;
if shift_amount >= n_red
    error('左移点数超过波形长度，无法处理！');
end
y_shifted = y(shift_amount+1:end);
t_red_shifted = (0:n_red-1-shift_amount) * dt_red;

%% 绘制上下两个子图（原始波形对比）
figure(1);
set(gcf, 'Position', [100, 100, 800, 600]);

subplot(2, 1, 1);
plot(t_red_shifted, y_shifted, 'r', 'LineWidth', 1.2);
xlabel('Time (μs)');
ylabel('Signal Amplitude');
title(sprintf('Actual Collected Signal (fs=%.0f MHz)', fs_red));
grid on;

subplot(2, 1, 2);
plot(t_blue, y1_scaled, 'b', 'LineWidth', 1.5);
xlabel('Time (μs)');
ylabel('Signal Amplitude');
title("Simulation Signal");
grid on;

%% =====================================================
%  红色波形频谱分析（汉明窗加窗）
%  区间1: 31.48us - 34.28us
%  区间2: 52.5us  - 54.64us
%% =====================================================

% 亚克力上表面一次回波：31.48us - 34.28us
red_t1_start = 31.48;
red_t1_end   = 34.28;
idx_red1 = find(t_red_shifted >= red_t1_start & t_red_shifted <= red_t1_end);
t_red_seg1 = t_red_shifted(idx_red1);
y_red_seg1 = y_shifted(idx_red1);

% 汉明窗加窗
win_red1 = hamming(length(y_red_seg1))';
y_red_seg1_win = y_red_seg1(:)' .* win_red1;

% FFT
N_red1 = length(y_red_seg1_win);
NFFT_red1 = 2^nextpow2(N_red1) * 4;  
Y_red1 = fft(y_red_seg1_win, NFFT_red1);
f_red1 = fs_red * (0:NFFT_red1/2-1) / NFFT_red1;  % 频率轴 (MHz)
mag_red1 = 2 * abs(Y_red1(1:NFFT_red1/2)) / N_red1;

% 钢下表面一次回波：52.5us - 54.64us 
red_t2_start = 52.5;
red_t2_end   = 54.64;
idx_red2 = find(t_red_shifted >= red_t2_start & t_red_shifted <= red_t2_end);
t_red_seg2 = t_red_shifted(idx_red2);
y_red_seg2 = y_shifted(idx_red2);

% 汉明窗加窗 
win_red2 = hamming(length(y_red_seg2))';
y_red_seg2_win = y_red_seg2(:)' .* win_red2;

% FFT
N_red2 = length(y_red_seg2_win);
NFFT_red2 = 2^nextpow2(N_red2) * 4;
Y_red2 = fft(y_red_seg2_win, NFFT_red2);
f_red2 = fs_red * (0:NFFT_red2/2-1) / NFFT_red2;
mag_red2 = 2 * abs(Y_red2(1:NFFT_red2/2)) / N_red2;

%% 加窗时域 + 频谱图
figure(2);
set(gcf, 'Position', [100, 100, 1000, 800]);
sgtitle('Experimental signal acquisition', 'FontSize', 14, 'FontWeight', 'bold');

% 亚克力上表面一次回波：加窗后时域
subplot(2, 2, 1);
%plot(t_red_seg1, y_red_seg1, 'r--', 'LineWidth', 1.0); hold on;
plot(t_red_seg1, y_red_seg1_win, 'r', 'LineWidth', 1.5); hold off;
xlabel('Time (μs)');
ylabel('Amplitude');
title(sprintf('Acrylic Top Surface First Echo: %.2f-%.2f μs', red_t1_start, red_t1_end));
%legend('原始', '加窗后');
grid on;

% 亚克力上表面一次回波：频谱
subplot(2, 2, 2);
plot(f_red1, mag_red1, 'r', 'LineWidth', 1.5);
xlabel('Frequency (MHz)');
ylabel('Magnitude');
title('Acrylic Top Surface First Echo Spectrum');
xlim([0, fs_red/2]);
grid on;

% 钢下表面一次回波：加窗后时域
subplot(2, 2, 3);
%plot(t_red_seg2, y_red_seg2, 'r--', 'LineWidth', 1.0); hold on;
plot(t_red_seg2, y_red_seg2_win, 'r', 'LineWidth', 1.5); hold off;
xlabel('Time (μs)');
ylabel('Amplitude');
title(sprintf('Steel Bottom Surface First Echo: %.2f-%.2f μs', red_t2_start, red_t2_end));
%legend('原始', '加窗后');
grid on;

% 钢下表面一次回波：频谱
subplot(2, 2, 4);
plot(f_red2, mag_red2, 'r', 'LineWidth', 1.5);
xlabel('Frequency (MHz)');
ylabel('Magnitude');
title('Steel Bottom Surface First Echo Spectrum');
xlim([0, fs_red/2]);
grid on;

%% =====================================================
%  蓝色波形频谱分析
%  区间1: 33us - 35us
%  区间2: 47.5us - 49us
%% =====================================================

% 蓝色波形采样间隔
dt_blue = t_blue(2) - t_blue(1);
fs_blue = 1 / dt_blue;  % 采样频率 MHz

% 亚克力上表面一次回波: 33us - 35us
blue_t1_start = 33;
blue_t1_end   = 35.5;
idx_blue1 = find(t_blue >= blue_t1_start & t_blue <= blue_t1_end);
t_blue_seg1 = t_blue(idx_blue1);
y_blue_seg1 = y1_scaled(idx_blue1);

%汉明窗加窗
win_blue1 = hamming(length(y_blue_seg1))';
y_blue_seg1_win = y_blue_seg1(:)' .* win_blue1;

% FFT
N_blue1 = length(y_blue_seg1);
NFFT_blue1 = 2^nextpow2(N_blue1) * 4;
Y_blue1 = fft(y_blue_seg1_win(:)', NFFT_blue1);
f_blue1 = fs_blue * (0:NFFT_blue1/2-1) / NFFT_blue1;
mag_blue1 = 2 * abs(Y_blue1(1:NFFT_blue1/2)) / N_blue1;

% 钢下表面一次回波： 47.5us - 49us 
blue_t2_start = 47.82;
blue_t2_end   = 49.7;
idx_blue2 = find(t_blue >= blue_t2_start & t_blue <= blue_t2_end);
t_blue_seg2 = t_blue(idx_blue2);
y_blue_seg2 = y1_scaled(idx_blue2);

%汉明窗加窗
win_blue2 = hamming(length(y_blue_seg2))';
y_blue_seg2_win = y_blue_seg2(:)' .* win_blue2;

% FFT
N_blue2 = length(y_blue_seg2);
NFFT_blue2 = 2^nextpow2(N_blue2) * 4;
Y_blue2 = fft(y_blue_seg2_win(:)', NFFT_blue2);
f_blue2 = fs_blue * (0:NFFT_blue2/2-1) / NFFT_blue2;
mag_blue2 = 2 * abs(Y_blue2(1:NFFT_blue2/2)) / N_blue2;

%% 绘制蓝色波形的时域 + 频谱图
figure(3);
set(gcf, 'Position', [100, 100, 1000, 800]);
sgtitle('Simulated Echo Signal', 'FontSize', 14, 'FontWeight', 'bold');

% 亚克力上表面一次回波：时域
subplot(2, 2, 1);
plot(t_blue_seg1, y_blue_seg1, 'b', 'LineWidth', 1.5);
xlabel('Time (μs)');
ylabel('Amplitude');
title(sprintf('Acrylic Top Surface First Echo: %.1f-%.1f μs', blue_t1_start, blue_t1_end));
grid on;

% 亚克力上表面一次回波：频谱
subplot(2, 2, 2);
plot(f_blue1, mag_blue1, 'b', 'LineWidth', 1.5);
xlabel('Frequency (MHz)');
ylabel('Magnitude');
title('Acrylic Top Surface First Echo Spectrum');
xlim([0, min(fs_blue/2, 10)]);  % 限制显示到10MHz或奈奎斯特频率
grid on;

% 钢下表面一次回波： 时域
subplot(2, 2, 3);
plot(t_blue_seg2, y_blue_seg2, 'b', 'LineWidth', 1.5);
xlabel('Time (μs)');
ylabel('Amplitude');
title(sprintf('Steel Bottom Surface First Echo: %.2f-%.2f μs', blue_t2_start, blue_t2_end));
grid on;

% 钢下表面一次回波： 频谱
subplot(2, 2, 4);
plot(f_blue2, mag_blue2, 'b', 'LineWidth', 1.5);
xlabel('Frequency (MHz)');
ylabel('Magnitude');
title('Steel Bottom Surface First Echo Spectrum');
xlim([0, min(fs_blue/2, 10)]);
grid on;