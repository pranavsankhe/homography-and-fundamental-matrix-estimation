  %load image and convert the image to double and grey scale
  
img_1=imread('library1.jpg');
img_2=imread('library2.jpg');
%img_2=padarray(img_2,[5,5],'replicate');
img_1=im2double(rgb2gray(img_1));
img_2=im2double(rgb2gray(img_2));


%sift_input1=blob(img_1,0.9,1);      %----(y,x)
%sift_input2=blob(img_2,0.85,1);

[cim1,r1,c1]=harris(img_1, 2, 0.001, 6, 1); 
[cim2,r2,c2]=harris(img_2, 2, 0.001, 2, 1);

% calculating neighourhood and feeding to find_sift
%%creating a find_sift ready inoput matrix
size_r1=size(r1);
size_r2=size(r2);
sift_input1=[c1, r1, ones(size_r1)*10 ];
sift_input2=[c2, r2, ones(size_r2)*10 ];

disc_1=find_sift(img_1,sift_input1);  
disc_2=find_sift(img_2,sift_input2);

%selecting points below a threshold

distance_matrix = dist2(disc_1, disc_2);
threshold=0.09;
[a,b]=find(distance_matrix<threshold);

% variable declaration


matches=[c1(a),r1(a),c2(b),r2(b)];
N = size(matches,1);

for itr = (1:1000)
   rand_array = randi([1,size(a,1)],1,8);
   x1=[round(c1(rand_array(1)));round(c1(rand_array(2)));round(c1(rand_array(3)));round(c1(rand_array(4)));round(c1(rand_array(5)));round(c1(rand_array(6)));round(c1(rand_array(7)));round(c1(rand_array(8)))];  %------(x,y)
   y1=[round(r1(rand_array(1)));round(r1(rand_array(2)));round(r1(rand_array(3)));round(r1(rand_array(4)));round(r1(rand_array(5)));round(r1(rand_array(6)));round(r1(rand_array(7)));round(r1(rand_array(8)))];

   x2=[round(c2(rand_array(1)));round(c2(rand_array(2)));round(c2(rand_array(3)));round(c2(rand_array(4)));round(c2(rand_array(5)));round(c2(rand_array(6)));round(c2(rand_array(7)));round(c2(rand_array(8)))];
   y2=[round(r2(rand_array(1)));round(r2(rand_array(2)));round(r2(rand_array(3)));round(r2(rand_array(4)));round(r2(rand_array(5)));round(r2(rand_array(6)));round(r2(rand_array(7)));round(r2(rand_array(8)))];
   
  match=[x1,y1,x2,y2];
  F=fitfundamental_norm(match);
  
L = (F* [matches(:,1:2) ones(N,1)]')'; 
L = L./ repmat(sqrt(L(:,1).^2 + L(:,2).^2), 1, 3); 
pt_line_dist = sum(L .* [matches(:,3:4) ones(N,1)],2);
closest_pt = matches(:,3:4) - L(:,1:2).* repmat(pt_line_dist, 1, 2);

   res=abs(pt_line_dist);
   threshold2=25;
   inliers=sum(res<threshold2);
   
   if(itr==1)
       best=inliers
       error=sum(res(res<threshold2));
       close_pt=closest_pt;
       LD=L;
   end
   
   if(inliers>best)
       best=inliers
       error=sum(res(res<threshold2));
       close_pt=closest_pt;
       LD=L; 
   end
   
end
residual=((error)/best)

pt1 = close_pt - [LD(:,2) -LD(:,1)] * 10; 
pt2 = close_pt + [LD(:,2) -LD(:,1)] * 10;

% display points and segments of corresponding epipolar lines
clf;
imshow(img_2); hold on;
plot(matches(:,3), matches(:,4), '+r');
line([matches(:,3) close_pt(:,1)]', [matches(:,4) close_pt(:,2)]', 'Color', 'r');
line([pt1(:,1) pt2(:,1)]', [pt1(:,2) pt2(:,2)]', 'Color', 'g');

    