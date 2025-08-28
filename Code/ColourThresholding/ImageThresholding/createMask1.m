%% Used in conjunction with ColourThresholdingV1.m
% Change colour thresholding values for 

function [Threshold, mask] = createMask1 (Image)
    
% Convert image to HSV colour valeus for use
I = rgb2hsv(Image);

% Initialize threshold to be used for the mask (fluorescent orange)

Threshold = [0.000 0.058;
             0.360 1.000;
             0.422 0.879];

% %create mask using threshold values for bright orange on image
% mask = ((I(:,:,1) >= Threshold(1,1) | (I(:,:,1) <= Threshold(1,2)))) & ...
%        (I(:,:,2) >= Threshold(2,1)) & (I(:,:,2) <= Threshold(2,2)) & ...
%        (I(:,:,3) >= Threshold(3,1)) & (I(:,:,2) <= Threshold(3,2));

mask = ((I(:,:,1) >= Threshold(1,1) & (I(:,:,1) <= Threshold(1,2)))) & ...
       (I(:,:,2) >= Threshold(2,1)) & (I(:,:,2) <= Threshold(2,2)) & ...
       (I(:,:,3) >= Threshold(3,1)) & (I(:,:,2) <= Threshold(3,2));

%fill in internal holes created through the mask
FilledImg = imfill(mask, 'holes');

%erode edges to reduce noise
se = strel('disk', 5, 0);
mask = imerode(FilledImg, se);

end