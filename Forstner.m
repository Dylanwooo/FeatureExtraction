clc;
clear;
tic;

FileInfo = imfinfo('img/house.jpg');
origpicgray=imread('img/house.jpg');
if(strcmp('truecolor',FileInfo.ColorType)==1)
  origpicgray=rgb2gray(origpicgray);    %RGB图像转灰度图像
end
imshow(origpicgray)
%%  计算图像长宽像素值m,n。
[m,n]=size(origpicgray);   %宽m，长n
%%  利用差分算子（像素（c,r）在上下左右四个方向的灰度差分绝对值）提取初选点。
g=double(origpicgray);
T=100;               %阈值
Initpointcoord=[];   %初选点坐标
for i=2:m-1
    for j=2:n-1
        dg1=abs(g(i,j)-g(i-1,j));   %上侧
        dg2=abs(g(i,j)-g(i+1,j));   %下侧
        dg3=abs(g(i,j)-g(i,j-1));   %左侧
        dg4=abs(g(i,j)-g(i,j+1));   %右侧
        dg=[dg1 dg2 dg3 dg4];
        temp=sort(dg);
        if temp(3)>T
            Initpointcoord=[Initpointcoord;i j];
        end
    end
end

%%  以初选点（c,r）为中心的w*w窗口中，计算协方差矩阵N与误差椭圆的圆度q,确定备选点。
w=5;                          %窗口宽的值
Initlen=length(Initpointcoord);   %初选点个数
k=floor(w/2);
Tq=0.32;                       %阈值Tq=0.32~0.5
candidatepoint=[];             %候选点
for no=1:Initlen
    Initpoint=Initpointcoord(no,:);
    c=Initpoint(1);
    r=Initpoint(2);
    h=c-k;
    l=c+k-1;
    p=r-k;
    w=r+k-1;
    gu2=0;gv2=0;guv=0;
    %计算窗口灰度协方差矩阵
    for e=h:l
        for f=p:w
            gu2=gu2+(g(e+1,f+1)-g(e,f))^2;
            gv2=gv2+(g(e,f+1)-g(e+1,f))^2;
            guv=guv+(g(e+1,f+1)-g(e,f))*(g(e,f+1)-g(e+1,f));
        end
    end
    DetN=gu2*gv2-guv^2;
    trN=gu2+gv2;
    q=4*DetN/(trN*trN);
    if q>Tq
        candidatepoint=[candidatepoint;c r];
    end
end

%%  以权值为依据，选取一适当窗口（w2*w2）中的权值最大者点为特征点。
clear h p q j c r
w2=5;
cadipotlen=length(candidatepoint);
k2=floor(5/w2);
featurepoint=[];
h=floor(m/w2);   %窗口行数
d=floor(n/w2);   %窗口列数
for p=1:h
    for q=1:d
        tp=(p-1)*w2;
        tq=(q-1)*w2;
        window=zeros(cadipotlen,2);
        for j=1:cadipotlen
            cadipoint=candidatepoint(j,:);
            c=cadipoint(1);
            r=cadipoint(2);
           if (c>tp&&c<tp+w2)&&(r>tq&&r<tq+w2)
               window(j,:)=[c,r];
           end
        end
        if max(window)~=0
            num=find(window(:,1)~=0);
            pointcoord=window(num,:);
            [pointcoordlen, null]=size(pointcoord);
            weight=[];
            for ii=1:pointcoordlen
                point=pointcoord(ii,:);
                cc=point(1);
                rr=point(2);
                h=cc-k;
                l=cc+k-1;
                pp=rr-k;
                w=rr+k-1;
                gu2=0;gv2=0;guv=0;
                for e=h:l
                    for f=pp:w
                        gu2=gu2+(g(e+1,f+1)-g(e,f))^2;
                        gv2=gv2+(g(e,f+1)-g(e+1,f))^2;
                        guv=guv+(g(e+1,f+1)-g(e,f))*(g(e,f+1)-g(e+1,f));
                    end
                end
                DetN=gu2*gv2-guv^2;
                trN=gu2+gv2;
                weight=[weight;DetN/trN];
            end
            maxweightid=find(max(weight));
            featurepoint=[featurepoint;pointcoord(maxweightid,:)];
            clear weight;
        end
        clear num;
        clear window;
    end
end
figure(3);
title('特征点')
imshow(origpicgray);
hold on;
plot(featurepoint(:,2),featurepoint(:,1),'r+');
t=toc










