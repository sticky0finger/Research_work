clc, clear

%% 读取CSV文件
data1 = readtable('弧形钢板仿真（防腐层）.CSV');  
y = data1{6:end, 2};           % 读取幅度数据
x_sample = 0:length(y)-1;     % 生成采样点序号

%% 原波形图：标注红绿区间
figure(1);
plot(x_sample, y);       % 绘制全部波形
xlabel('采样点');ylabel('信号波形');

fs = 25;
Ts = 0.003703;
velocity = 6200;
%%%%%%%%%%%%%%%%%%%%
% 用户手动选择
n1=6801;            % 基准信号起点
n2=7182;            % 基准信号终点
m1=7625;            % 搜索测信号最佳位置估计点
r_search=200;        % 搜索半径

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
plot(n1:n2, sig1, 'b', 'LineWidth', 1.5,'DisplayName', '下表面一次回波');
% 下表面回波2
plot(m:m+L-1,y(m:m+L-1), 'g', 'LineWidth', 1.5,'DisplayName', '下表面二次回波');
hold off;
legend;

%厚度计算结果
%d = (velocity*((m-n1)/fs)*1e-3)/2;
d = (velocity*((m-n1)*Ts)*1e-3)/2;
fprintf("厚度为%.2fmm\n",d);
