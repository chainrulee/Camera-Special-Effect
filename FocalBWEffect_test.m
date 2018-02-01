function [ output_frame ] = FocalBWEffect_test( input, pY, pX )
%UNTITLED13 Summary of this function goes here
%   Detailed explanation goes here
% clear all;
% close all;
% clc;
%% Parameters
scale = 0.5;
grade = 5;
radius = 1.7;

%% File select
% [FileName,PathName] = uigetfile({'*.jpg';'*.jpeg';'*.JPG'},'SelectImage');
% file = [PathName,FileName];
% img = cast(imresize(imread(file),scale),'double');
%img = imread('Star_City.png');
img = input;
[r c d] = size(img);
IMG = zeros(r,c,d);

%% Pick point in interest
h = figure; %imshow(cast(img,'uint8'));
%[X Y] = getpts(h);
X = pX;
Y = pY;
c0 = floor(X(1));
r0 = floor(Y(1));
c_ = max(c0,(c-c0));
r_ = max(r0,(r-r0));
L = sqrt(r_^2 + c_^2);
close(h);

%% Operation
frame = img;
bwframe = cast(rgb2gray(cast(frame,'uint8')),'double');
for i = 1:r
  for j = 1:c
    Ln = sqrt((r0-i)^2 + (c0-j)^2);
    fn = (L-Ln)./L;
    f = (radius*fn^grade);
    if f>1
      f = 1;
    end
    IMG(i,j,1) = (f*frame(i,j,1))+((1-f)*bwframe(i,j));
    IMG(i,j,2) = (f*frame(i,j,2))+((1-f)*bwframe(i,j));
    IMG(i,j,3) = (f*frame(i,j,3))+((1-f)*bwframe(i,j));
  end
end

%% Display
imG = cast(IMG,'uint8');
output_frame = imG;
%imshow(imG);


end

