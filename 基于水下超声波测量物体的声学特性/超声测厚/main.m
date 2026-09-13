clc;clear;close all;fclose all;
c=5900;   % 钢块声速（假定值）
load data.mat;
figure(1);plot(rf); 
xlabel('采样点');ylabel('信号波形');

%%%%%%%%%%%%%%%%%%%%
% 用户手动选择
% n1=1685;            % 基准信号起点
% n2=1740;            % 基准信号终点
% m1=1860;            % 搜索测信号最佳位置估计点
% r_search=30;        % 搜索半径

n1=1860;            % 基准信号起点
n2=1905;            % 基准信号终点
m1=2035;            % 搜索测信号最佳位置估计点
r_search=30;        % 搜索半径


% 参考信号
L=n2-n1+1;          % 信号长度L
ind1=n1:n2;         % 参考窗下标
sig1=rf(n1:n2);   	% 上表面反射信号

% 对比信号
mid=m1:m1+L-1;                  % 中心窗下标
shift=-r_search:r_search;       % 偏移
coef=zeros(1,2*r_search+1);     % 互相关系数
for i=1:length(shift)
    ind2=mid+shift(i);          % 参考窗下标
    sig2=rf(ind2);
    coef(i)=sum(sig1.*sig2)/sqrt(sum(sig1.*sig1))/sqrt(sum(sig2.*sig2)); % 相关系数
end

figure(2);
plot(m1+shift,coef); hold on;
xlabel('搜索位置');ylabel('归一化相关系数');
idmax=find(abs(coef)==max(abs(coef))); 
m=m1+shift(idmax);
scatter([m-1:m+1],coef(idmax-1:idmax+1),'r*');
fprintf('与%d对应的最值匹配位置为%d,最大互相关系数: %.3f\n',n1,m1+shift(idmax),coef(idmax));

% 配准波形
figure(3); 
plot(sig1,'r'); hold on; 
sig2=rf(mid+shift(idmax));
plot(sig2,'g'); 
title('配准波形');

% 厚度计算
N=m1+shift(idmax)-n1;
depth=N/fs*c/2*1000;
fprintf('厚度为%.3fmm\n', depth);



