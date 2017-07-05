
clc;
clear;
tic;

FileInfo = imfinfo('img/house.jpg');
origpicgray=imread('img/house.jpg');

if(strcmp('truecolor',FileInfo.ColorType)==1)
    origpicgray = rgb2gray(origpicgray);    %RGB图像转灰度图像
end
imshow(origpicgray);
%% 计算图像长宽像素值m,n
[m,n]=size(origpicgray);
%% 计算各像素四个方向的兴趣值IV;影像窗口w1*w1,列c行r。
w1=5;
k=floor(w1/2);
g=double(origpicgray);
for r=3:m-2
    for c=3:n-2
        V1=0;V2=0;V3=0;V4=0;
        for i=-k:k-1
            V1=V1+(g(r,c+i)-g(r,c+i+1))^2;       %东西方向
            V2=V2+(g(r+i,c+i)-g(r+i+1,c+i+1))^2; %东南方向
            V3=V3+(g(r+i,c)-g(r+i+1,c))^2;       %南北方向
            V4=V4+(g(r-i,c+i)-g(r-i-1,c+i+1))^2; %东北方向
        end
        IV(r,c)=min([V1 V2 V3 V4]);
    end
end
%% 给阈值ExpThrVal，将兴趣值大于该阈值的点作为候选点。
Threshold=3000;               %设置阈值
[a,b]=find(IV>Threshold);     %候选点坐标
%% 选取候选点中的极值点作为特征点,在w2*w2的窗口，取兴趣值最大者作为该像素特征点。
w2=9;
height=floor(m/w2);   %窗口行数
width=floor(n/w2);   %窗口列数
len=length(a);
featurepoint=[];         %候选点

 for p=1:height
    for q=1:width
        tp=(p-1)*w2;
        tq=(q-1)*w2;
        window=zeros(len,3);
        for j=1:len
           if (a(j)>tp&&a(j)<tp+w2)&&(b(j)>tq&&b(j)<tq+w2)
               window(j,:)=[IV(a(j),b(j)),a(j),b(j)];
           end
        end
        if max(window(:,1))~=0               %如果window第一列不为0
            max_IVid=find(window(:,1)==max(window(:,1)));
            featurepoint=[featurepoint;window(max_IVid,:)];
        end
        clear window;
    end
 end

%%  绘制结果
figure(2);
title('Moravec特征点');
imshow(origpicgray);
hold on;                                                %支持多图绘制
plot(featurepoint(:,3),featurepoint(:,2),'r+');           
t=toc                           %显示程序运行时间

