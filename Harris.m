clc,clear;

harris_result = [];
FileInfo = imfinfo('img/house.jpg');
Image = imread('img/house.jpg');
imshow(Image);
%��ɫת���ɻҶ�ֵͼ��
if(strcmp('truecolor',FileInfo.ColorType)==1)
    Image = im2uint8(rgb2gray(Image));
end
%prewittģ��
dx=[-1 0 1;
       -1 0 1;
       -1 0 1];
%����x��y�ݶȺ����������ݶȵĳ˻�
Ix2=filter2(dx,Image).^2;                       
Iy2=filter2(dx',Image).^2;                        
Ixy=filter2(dx,Image).*filter2(dx',Image);
%����ֲ�����ؾ���
h=fspecial('gaussian',9,2);              %��˹�˲�ģ���СΪ9����׼��Ϊ2
%ʹ�ø�˹������Ȩ
A=filter2(h,Ix2);                           %x����Ĳ��
B=filter2(h,Iy2);                           %y����Ĳ��
C=filter2(h,Ixy);
%corner���ڱ����ѡ�ǵ�λ��
nrow=size(Image,1);
ncol=size(Image,2);
Corner=zeros(nrow,ncol);

t=20;
boundary=8;             %---ȥ���߽���boundary������
for i=boundary:1:nrow-boundary+1
    for j=boundary:1:ncol-boundary+1
        nlike=0;                     %----���Ƶ�ĸ���
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
%����ǵ���Ӧ����ֵ
CRF=zeros(nrow,ncol);
CRFmax=0;   %----ͼ���нǵ���Ӧ���������ֵ������ֵ��
k=0.05;         %����k
for i=boundary:1:nrow-boundary+1
    for j=boundary:1:ncol-boundary+1
        if Corner(i,j)==1
            M=[A(i,j) C(i,j);
                C(i,j) B(i,j)];
            CRF(i,j)=det(M)-k*(trace(M))^2;              %�ǵ���Ӧֵ
            if CRF(i,j)>CRFmax
                CRFmax=CRF(i,j);
            end
        end
    end
end
%�жϵ�ǰλ���Ƿ�Ϊ�ǵ�
count=0;%----�ǵ����
t=0.01;                   %ϵ��ȡ0.01Ч���Ϻ�

%��ֵ��������С����ֵ0.01����Ӧֵ��Ϊ0
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