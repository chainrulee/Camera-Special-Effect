function mask = gaussianMask_softFocus(sigma)
loLim=-ceil(3*sigma); % lower limit
hiLim=ceil(3*sigma); % upper limit
x=loLim:hiLim;
y=loLim:hiLim;

for i=1:((hiLim-loLim)+1) % x
  for j=1:((hiLim-loLim)+1) % y
    mask(i,j)=(1/(2*pi*sigma^2))*exp(-(x(i)^2+y(j)^2)/(2*sigma^2)); % blur
  end
end
