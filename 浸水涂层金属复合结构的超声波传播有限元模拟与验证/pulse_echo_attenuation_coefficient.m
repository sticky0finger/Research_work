clc, clear

%% 读取CSV文件
data1 = readtable('最新弧形钢板放大.CSV');  
y = data1{1:end, 5};           % 读取幅度数据
x_sample = 0:length(y)-1;     % 生成采样点序号（0~2499）

%% 原波形图：标注红绿区间
figure(1);
plot(x_sample, y);       % 绘制全部波形
xlabel('采样点');ylabel('信号波形');

d = 8.6;   % 厚度（测量值mm）
fs = 100;
%%%%%%%%%%%%%%%%%%%%
% 用户手动选择
n1=1131;            % 基准信号起点 
n2=1290;            % 基准信号终点      
m1=1398;            % 搜索测信号最佳位置估计点
r_search=30;        % 搜索半径


% 参考信号
L=n2-n1+1;          % 信号长度L
ind1=n1:n2;         % 参考窗下标
sig1=y(n1:n2);   	% 第二次下表面反射信号

% 对比信号
mid=m1:m1+L-1;                  % 中心窗下标
shift=-r_search:r_search;       % 偏移
coef=zeros(1,2*r_search+1);     % 互相关系数
for i=1:length(shift)
    ind2=mid+shift(i);          % 参考窗下标
    sig2_temp=y(ind2);
    coef(i)=sum(sig1.*sig2_temp)/sqrt(sum(sig1.^2)*sum(sig2_temp.^2));
end

figure(2);
plot(m1+shift,coef); hold on;
xlabel('搜索位置');ylabel('归一化相关系数');
[~, idmax]=max(abs(coef)); % 更鲁棒的峰值查找
m=m1+shift(idmax);
scatter(m, coef(idmax), 'r*');
fprintf('一次下表面信号位置:%d，二次下表面信号位置:%d, 最大互相关系数: %.3f\n',n1,m,coef(idmax));

figure(3);
plot(x_sample, y, 'DisplayName', '原始信号'); 
hold on; 
% 一次下表面回波
plot(n1:n2, sig1, 'r', 'LineWidth', 1.5, 'DisplayName', '一次上表面回波');
% 二次下表面回波
sig2 = y(m:m+L-1);
plot(m:m+L-1, sig2, 'g', 'LineWidth', 1.5, 'DisplayName', '一次下表面回波');
xlabel('采样点');
ylabel('信号波形');
% 添加图例
legend('show', 'Location', 'best'); % 'best' 会自动选择最佳位置放置图例
% 添加标题
title('下表面回波信号对比');
hold off;

% ======================================================================
% 声衰减系数计算 (新增关键部分)
% ======================================================================

% 1. 计算峰值幅度 (使用绝对值的最大值)
A1 = max(abs(sig1));    % 第一个下表面信号峰值幅度 
A2 = max(abs(sig2));    % 第二个下表面信号峰值幅度

% 2. 计算幅度比
amplitude_ratio = A1/A2;

% 3. 将厚度转换为米 (mm -> m)
d_m = d * 1e-3; 

% 4. 计算声衰减系数 (自然对数)
alpha = (1/(2*d_m)) * log(amplitude_ratio); % 单位: Np/m

% 5. 转换为dB/m (可选：1 Np = 8.6859 dB)
alpha_dB = alpha * 20 * log10(exp(1)); % 单位转换: Np/m -> dB/m

%% 结果输出
fprintf('===== 声衰减系数计算结果 =====\n');
fprintf('声衰减系数(α): %.3f Np/m\n', alpha);
fprintf('声衰减系数(α): %.3f dB/m\n', alpha_dB);