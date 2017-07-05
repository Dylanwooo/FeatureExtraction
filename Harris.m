clc,clear;

harris_result = [];
FileInfo = imfinfo('img/house.jpg');
Image = imread('img/house.jpg');
imshow(Image);
%彩色转换成灰度值图像
if(strcmp('truecolor',FileInfo.ColorType)==1)
    Image = im2uint8(rgb2gray(Image));
end
%prewitt模板
dx=[-1 0 1;
       -1 0 1;
       -1 0 1];
%计算x，y梯度和两个方向梯度的乘积
Ix2=filter2(dx,Image).^2;                       
Iy2=filter2(dx',Image).^2;                        
Ixy=filter2(dx,Image).*filter2(dx',Image);
%计算局部自相关矩阵
h=fspecial('gaussian',9,2);              %高斯滤波模板大小为9，标准差为2
%使用高斯函数加权
A=filter2(h,Ix2);                           %x方向的差分
B=filter2(h,Iy2);                           %y方向的差分
C=filter2(h,Ixy);
%corner用于保存候选角点位置
nrow=size(Image,1);
ncol=size(Image,2);
Corner=zeros(nrow,ncol);

t=20;
boundary=8;             %---去除边界上boundary个像素
for i=boundary:1:nrow-boundary+1
    for j=boundary:1:ncol-boundary+1
        nlike=0;                     %----相似点的个数
        if Image(i-1,j-1)-Image(i,j)>-t&&Image(i-1,j-1)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i-1,j)-Image(i,j)>-t&&Image(i-1,j)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i-1,j+1)-Image(i,j)>-t&&Image(i-1,j+1)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i,j-1)-Image(i,j)>-t&&Image(i,j-1)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i,j+1)-Image(i,j)>-t&&Image(i,j+1)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i+1,j-1)-Image(i,j)>-t&&Image(i+1,j-1)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i+1,j)-Image(i,j)>-t&&Image(i+1,j)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if Image(i+1,j+1)-Image(i,j)>-t&&Image(i+1,j+1)-Image(i,j)<t
            nlike=nlike+1;
        end
        
        if nlike>=2&&nlike<=6
            Corner(i,j)=1;
        end
        
    end
end
%计算角点响应函数值
CRF=zeros(nrow,ncol);
CRFmax=0;   %----图像中角点响应函数的最大值，作阈值用
k=0.05;         %参数k
for i=boundary:1:nrow-boundary+1
    for j=boundary:1:ncol-boundary+1
        if Corner(i,j)==1
            M=[A(i,j) C(i,j);
                C(i,j) B(i,j)];
            CRF(i,j)=det(M)-k*(trace(M))^2;              %角点响应值
            if CRF(i,j)>CRFmax
                CRFmax=CRF(i,j);
            end
        end
    end
end
%判断当前位置是否为角点
count=0;%----角点个数
t=0.01;                   %系数取0.01效果较好

%阈值化，对于小于阈值0.01的响应值设为0
for i=boundary:1:nrow-boundary+1
    for j=boundary:1:ncol-boundary+1
        if Corner(i,j)==1
            if CRF(i,j)>t*CRFmax&&CRF(i,j)>CRF(i-1,j-1)...
                    &&CRF(i,j)>CRF(i-1,j)&&CRF(i,j)>CRF(i-1,j+1)...
                    &&CRF(i,j)>CRF(i,j-1)&&CRF(i,j)>CRF(i,j+1)...
                    &&CRF(i,j)>CRF(i+1,j-1)&&CRF(i,j)>CRF(i+1,j)...
                    &&CRF(i,j)>CRF(i+1,j+1)
                count=count+1;
            else
                Corner(i,j)=0;
            end
        end
    end
end

figure,imshow(Image);
hold on;
for i=boundary:1:nrow-boundary+1
    for j=boundary:1:ncol-boundary+1
        column_ave=0;
        row_ave=0;
        k=0;
        if Corner(i,j)==1
            for x=i-3:1:i+3
                for y=j-3:1:j+3
                    if Corner(x,y)==1
                        row_ave=row_ave+x;
                        column_ave=column_ave+y;
                        k=k+1;
                    end
                end
            end
        end
        if k>0
            harris_result=[harris_result;round(row_ave/k) round(column_ave/k)];
            plot(column_ave/k,row_ave/k,'r+');
        end
    end
end