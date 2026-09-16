clc, clear

%% 读取CSV文件
data = readtable('旧防腐层1.CSV');  %防腐层厚度2.1mm,钢板厚度8.6mm
y = data{1:end, 5};           % 读取幅度数据
x_sample = 0:length(y)-1;     % 生成采样点序号（0~2499）


%% 原波形图：标注红绿区间
figure(1);
plot(x_sample, y);       % 绘制全部波形
xlabel('采样点');ylabel('信号波形');

d = 4.3;   % 厚度（测量值mm）
fs = 25;
%%%%%%%%%%%%%%%%%%%%
% 用户手动选择
n1=1224;            % 基准信号起点 
n2=1267;            % 基准信号终点      
m1=1313;            % 搜索测信号最佳位置估计点
r_search=30;        % 搜索半径

% 参考信号
L=n2-n1+1;          % 信号长度L
ind1=n1:n2;         % 参考窗下标
sig1=y(n1:n2);   	% 上表面反射信号

% 对比信号
mid=m1:m1+L-1;                  % 中心窗下标
shift=-r_search:r_search;       % 偏移
coef=zeros(1,2*r_search+1);     % 互相关系数
for i=1:length(shift)
    ind2=mid+shift(i);          % 参考窗下标
    sig2=y(ind2);
    coef(i)=sum(sig1.*sig2)/sqrt(sum(sig1.*sig1))/sqrt(sum(sig2.*sig2)); % 相关系数
end

figure(2);
plot(m1+shift,coef); hold on;
xlabel('搜索位置');ylabel('归一化相关系数');
idmax=find(abs(coef)==max(abs(coef))); 
m=m1+shift(idmax);
scatter([m-1:m+1],coef(idmax-1:idmax+1),'r*');
fprintf('与%d对应的最值匹配位置为%d,最大互相关系数: %.3f\n',n1,m1+shift(idmax),coef(idmax));

figure(3);
plot(x_sample, y); hold on; 
% 下表面回波1
plot(n1:n2, sig1, 'b', 'LineWidth', 1.5);
% 下表面回波2
plot(m:m+L-1,y(m:m+L-1), 'g', 'LineWidth', 1.5);
hold off;


% 配准波形
figure(4); 
plot(sig1,'r'); hold on; 
sig2=y(mid+shift(idmax));
plot(sig2,'g'); 
title('配准波形');

% 声速计算
N=m1+shift(idmax)-n1;
velocity=2*d*fs/N*1000;
fprintf('声速为%.3fm/s\n', velocity);


