clc;
clear;
tic;

FileInfo = imfinfo('img/house.jpg');
origpicgray=imread('img/house.jpg');
if(strcmp('truecolor',FileInfo.ColorType)==1)
  origpicgray=rgb2gray(origpicgray);    %RGBͼ��ת�Ҷ�ͼ��
end
imshow(origpicgray)
%%  ����ͼ�񳤿�����ֵm,n��
[m,n]=size(origpicgray);   %��m����n
%%  ���ò�����ӣ����أ�c,r�������������ĸ�����ĻҶȲ�־���ֵ����ȡ��ѡ�㡣
g=double(origpicgray);
T=100;               %��ֵ
Initpointcoord=[];   %��ѡ������
for i=2:m-1
    for j=2:n-1
        dg1=abs(g(i,j)-g(i-1,j));   %�ϲ�
        dg2=abs(g(i,j)-g(i+1,j));   %�²�
        dg3=abs(g(i,j)-g(i,j-1));   %���
        dg4=abs(g(i,j)-g(i,j+1));   %�Ҳ�
        dg=[dg1 dg2 dg3 dg4];
        temp=sort(dg);
        if temp(3)>T
            Initpointcoord=[Initpointcoord;i j];
        end
    end
end

%%  �Գ�ѡ�㣨c,r��Ϊ���ĵ�w*w�����У�����Э�������N�������Բ��Բ��q,ȷ����ѡ�㡣
w=5;                          %���ڿ��ֵ
Initlen=length(Initpointcoord);   %��ѡ�����
k=floor(w/2);
Tq=0.32;                       %��ֵTq=0.32~0.5
candidatepoint=[];             %��ѡ��
for no=1:Initlen
    Initpoint=Initpointcoord(no,:);
    c=Initpoint(1);
    r=Initpoint(2);
    h=c-k;
    l=c+k-1;
    p=r-k;
    w=r+k-1;
    gu2=0;gv2=0;guv=0;
    %���㴰�ڻҶ�Э�������
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

%%  ��ȨֵΪ���ݣ�ѡȡһ�ʵ����ڣ�w2*w2���е�Ȩֵ����ߵ�Ϊ�����㡣
clear h p q j c r
w2=5;
cadipotlen=length(candidatepoint);
k2=floor(5/w2);
featurepoint=[];
h=floor(m/w2);   %��������
d=floor(n/w2);   %��������
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
title('������')
imshow(origpicgray);
hold on;
plot(featurepoint(:,2),featurepoint(:,1),'r+');
t=toc










