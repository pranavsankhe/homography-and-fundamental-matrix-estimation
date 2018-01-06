%load image and convert the image to double and grey scale

img_1=imread('/Users/pranavsankhe/Desktop/SCHOOL/CSE CVIP/HW3/hw3/data/part1/uttower/left.jpg');
img_2=imread('/Users/pranavsankhe/Desktop/SCHOOL/CSE CVIP/HW3/hw3/data/part1/uttower/right.jpg');
img__1=img_1;
img__2=img_2;
img_1=padarray(img_1,[5,5],'replicate');
img_2=padarray(img_2,[5,5],'replicate');
img_1=im2double(rgb2gray(img_1));
img_2=im2double(rgb2gray(img_2));

thre=0.02;
[cim1,r1,c1]=harris(img_1, 2, thre, 6, 0); %---- (0.2 otherwise )
[cim2,r2,c2]=harris(img_2, 2, thre, 2, 0);

% calculating neighourhood byfeeding to find_sift
%%creating a find_sift ready inoput matrix
size_r1=size(r1);
size_r2=size(r2);
sift_input1=[c1, r1, ones(size_r1)*10 ];
sift_input2=[c2, r2, ones(size_r2)*10 ];

disc_1=find_sift(img_1,sift_input1);  
disc_2=find_sift(img_2,sift_input2);

%selecting points below a threshold

distance_matrix = dist2(disc_1, disc_2);
threshold=0.08;
[a,b]=find(distance_matrix<threshold);

% points to perform homography upon 

p1 = sift_input1(a,1:2); %-----(y,x) 
p1(:,[1 2])= p1(:,[2 1]);%------(x,y)
p2 = sift_input2(b,1:2);
p2(:,[1 2])= p2(:,[2 1]);%------(x,y)

% variable declaration

inliers=[];
H={};
dist={};

% creating 2000 homograhpy matrix from 4 random points and obtaining a projection for each point.Later categorizing on the basis of 
% distance from the P2 as inliers or outliers 
size_p1=size(p1);
for itr = (1:2000)
   rand_array = randi([1,size_p1(1)],1,4);
   x1=[round(p1(rand_array(1),1)),round(p1(rand_array(2),1)),round(p1(rand_array(3),1)),round(p1(rand_array(4),1))];  %------(x,y)
   y1=[round(p1(rand_array(1),2)),round(p1(rand_array(2),2)),round(p1(rand_array(3),2)),round(p1(rand_array(4),2))];

   x2=[round(p2(rand_array(1),1)),round(p2(rand_array(2),1)),round(p2(rand_array(3),1)),round(p2(rand_array(4),1))];
   y2=[round(p2(rand_array(1),2)),round(p2(rand_array(2),2)),round(p2(rand_array(3),2)),round(p2(rand_array(4),2))];
   
   h=[];
   for i=(1:4)
       p{i}=[-x1(i), -y1(i), -1, 0, 0, 0, x1(i)*x2(i), y1(i)*x2(i), x2(i); 0, 0, 0, -x1(i), -y1(i), -1, x1(i)*y2(i), y1(i)*y2(i), y2(i)];
       h=[h;p{i}];
   end 
   [U,S,V]=svd(h); 
   h=reshape(V(:,9),[3,3]);
   h=h./h(3,3);
   H{itr}=h';
   
   proj=[];
   point={};
   
   for j=(1:size_p1(1))
       point{j}=p1(j,:);   %-----(x,y)
       point{j}=[point{j}';1]; %-------(x;y;1)
       answer=H{itr}*point{j};
       proj=[proj;answer(1)/answer(3),answer(2)/answer(3)];%-----(x,y)
   end
   
   distance=(sum((p2-proj).^2,2)).^(0.5);
   threshold2=2;
   inliers(itr)=sum(distance<threshold2);
   dist{itr}=distance;
end
[INLIERS index]=max(inliers)
Homography=H{1,index};
Residual=(1/INLIERS)*sum(dist{index}(dist{index}<2))



% finding the op proj 
proj=[];
for i=(1:size_p1(1))
    point=[p1(i,:)';1];
    an=Homography*point;
    proj=[proj;an(1)/an(3),an(2)/an(3)];
end

dis=(sum((p2-proj).^2,2)).^(0.5);
threshold2=2 ;
ind=find(dis<threshold2);

y1=p1(ind,1);
x1=p1(ind,2);
y2=proj(ind,1);
x2=proj(ind,2);

%plotting the putative points

figure(1), imshow(img_1);
hold on, plot(x1,y1,'oy', 'LineWidth', 5, 'MarkerSize', 10);
figure(2); imshow(img_2);
hold on, plot(x2,y2,'oy', 'LineWidth', 5, 'MarkerSize', 10);

% stiching the images together
T=maketform('projective',[x2(1:4,:) y2(1:4,:)],[x1(1:4,:) y1(1:4,:)]);
T.tdata.T;
[im2t,xdataim2t,ydataim2t]=imtransform(img_2,T);
xdataout=[min(1,xdataim2t(1)) max(size(img_1,2),xdataim2t(2))];
ydataout=[min(1,ydataim2t(1)) max(size(img_1,1),ydataim2t(2))];

%reassigning the images so that we obtain color images.
img_2=img__2;
img_1=img__1;
im2t=imtransform(img_2,T,'XData',xdataout,'YData',ydataout);
im1t=imtransform(img_1,maketform('affine',eye(3)),'XData',xdataout,'YData',ydataout);
ims=max(im1t,im2t);
figure, imshow(ims);









