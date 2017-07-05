
clc;
clear;
tic;

FileInfo = imfinfo('img/house.jpg');
origpicgray=imread('img/house.jpg');

if(strcmp('truecolor',FileInfo.ColorType)==1)
    origpicgray = rgb2gray(origpicgray);    %RGBͼ��ת�Ҷ�ͼ��
end
imshow(origpicgray);
%% ����ͼ�񳤿�����ֵm,n
[m,n]=size(origpicgray);
%% ����������ĸ��������ȤֵIV;Ӱ�񴰿�w1*w1,��c��r��
w1=5;
k=floor(w1/2);
g=double(origpicgray);
for r=3:m-2
    for c=3:n-2
        V1=0;V2=0;V3=0;V4=0;
        for i=-k:k-1
            V1=V1+(g(r,c+i)-g(r,c+i+1))^2;       %��������
            V2=V2+(g(r+i,c+i)-g(r+i+1,c+i+1))^2; %���Ϸ���
            V3=V3+(g(r+i,c)-g(r+i+1,c))^2;       %�ϱ�����
            V4=V4+(g(r-i,c+i)-g(r-i-1,c+i+1))^2; %��������
        end
        IV(r,c)=min([V1 V2 V3 V4]);
    end
end
%% ����ֵExpThrVal������Ȥֵ���ڸ���ֵ�ĵ���Ϊ��ѡ�㡣
Threshold=3000;               %������ֵ
[a,b]=find(IV>Threshold);     %��ѡ������
%% ѡȡ��ѡ���еļ�ֵ����Ϊ������,��w2*w2�Ĵ��ڣ�ȡ��Ȥֵ�������Ϊ�����������㡣
w2=9;
height=floor(m/w2);   %��������
width=floor(n/w2);   %��������
len=length(a);
featurepoint=[];         %��ѡ��

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
        if max(window(:,1))~=0               %���window��һ�в�Ϊ0
            max_IVid=find(window(:,1)==max(window(:,1)));
            featurepoint=[featurepoint;window(max_IVid,:)];
        end
        clear window;
    end
 end

%%  ���ƽ��
figure(2);
title('Moravec������');
imshow(origpicgray);
hold on;                                                %֧�ֶ�ͼ����
plot(featurepoint(:,3),featurepoint(:,2),'r+');           
t=toc                           %��ʾ��������ʱ��

