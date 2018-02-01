function [ newImage ] = fisheye_test( frame )
%% Read the indexed image
%rgbImage = imread('Star_City.png');
rgbImage = frame;
[r,c,d] = size(rgbImage);        %# Get the image dimensions
nPad = (c-r)/2;                  %# The number of padding rows
rgbImage = cat(1,ones(nPad,c,3),rgbImage,ones(nPad,c,3));  %# Pad with white

%% fisheye_inverse
options = [c c 3];  %# An array containing the columns, rows, and exponent
tf = maketform('custom',2,2,[],@fisheye_inverse,options);    %# Make the transformation structure
               
%% show the result
newImage = imtransform(rgbImage,tf);  %# Transform the image
newImage = imresize(newImage, [720 NaN],'bilinear');
tmp = zeros(720,1280,3);
tmp(:,281:1000,:)= newImage;
newImage = tmp;
%imshow(newImage);                    
end

