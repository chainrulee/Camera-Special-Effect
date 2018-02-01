[obj,~,alpha] = imread('obj2.png');
alpha(160:180,40:60) = 0;
imwrite(obj,'obj.png','alpha',alpha);