matches = load('house_matches.txt'); 
camMatrix1=load('house1_camera.txt');
camMatrix2=load('house2_camera.txt');
x1 = matches(:,1:2);
x2 = matches(:,3:4);
x1=[x1,ones(size(x1,1),1)];
x2=[x2,ones(size(x2,1),1)];


no_of_match = size(x1,1);% tracing number of matches
tpo = zeros(no_of_match, 3);
img1po = zeros(no_of_match, 2); % image projection points 
img2po = zeros(no_of_match, 2);

for i = 1:no_of_match
    pt1 = x1(i,:);
    pt2 = x2(i,:);
    Mat1 = [  0   -pt1(3)  pt1(2); pt1(3)   0   -pt1(1); -pt1(2)  pt1(1)   0  ];%% cross product matrix
    Mat2 = [  0   -pt2(3)  pt2(2); pt2(3)   0   -pt2(1); -pt2(2)  pt2(1)   0  ];    
    E = [ Mat1*camMatrix1; Mat2*camMatrix2 ];
    
    [U,S,V] = svd(E);
    tpohomo = V(:,end)'; 
    tpo(i,:) = homo_2_cart(tpohomo);
    img1po(i,:) = homo_2_cart((camMatrix1 * tpohomo')');
    img2po(i,:) = homo_2_cart((camMatrix2 * tpohomo')');
    
end
camCenter1=get_cam_center(camMatrix1);
camCenter2=get_cam_center(camMatrix2);
plot_triangulation(tpo,camCenter1, camCenter2);

function [ camCenter ] = get_cam_center( camMatrix )

    [U,S,V] = svd(camMatrix);
    camCenter = V(:,end);
    camCenter = homo_2_cart(camCenter'); 
end


%%%credit: https://www.mathworks.com/matlabcentral/answers/8747-connecting-points-in-3d-using-plot3

function [  ] = plot_triangulation( tripo, camCenter1, camCenter2 )
    figure; axis equal;  hold on; 
    plot3(-tripo(:,1), tripo(:,2), tripo(:,3), '*r');
    plot3(-camCenter1(1), camCenter1(2), camCenter1(3),'*g');
    plot3(-camCenter2(1), camCenter2(2), camCenter2(3),'*b');
    grid on; xlabel('x'); ylabel('y'); zlabel('z'); axis equal;
    
end    

%%%credit: http://www.codeforge.com/read/234139/homo2cart.m__html
    
function [cart] = homo_2_cart(Hcor)

    dimension = size(Hcor, 2) - 1;
    nor = bsxfun(@rdivide,Hcor,Hcor(:,end));
    cart = nor(:,1:dimension);
end

    
 