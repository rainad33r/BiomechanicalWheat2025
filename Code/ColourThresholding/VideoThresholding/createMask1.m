%% Used in conjunction with ColourThresholdingV1.m
% Change colour thresholding values for 

function [Threshold, mask] = createMask1 (Image)
    
% Convert image to HSV colour valeus for use
I = rgb2hsv(Image);

% Initialize threshold to be used for the mask (fluorescent orange)
% Threshold = [0.004 0.127;
%              0.625 1.000;
%              0.570 1.000];

%Second Threshold
Threshold = [0.953 0.084;
             0.504 1.000;
             0.485 0.879];

% Threshold = [0.044 0.172;
%              0.776 1.000;
%              0.578 1.000];

% %create mask using threshold values for bright orange on image
% mask = ((I(:,:,1) >= Threshold(1,1) | (I(:,:,1) <= Threshold(1,2)))) & ...
%        (I(:,:,2) >= Threshold(2,1)) & (I(:,:,2) <= Threshold(2,2)) & ...
%        (I(:,:,3) >= Threshold(3,1)) & (I(:,:,2) <= Threshold(3,2));

mask = ((I(:,:,1) >= Threshold(1,1) | (I(:,:,1) <= Threshold(1,2)))) & ...
       (I(:,:,2) >= Threshold(2,1)) & (I(:,:,2) <= Threshold(2,2)) & ...
       (I(:,:,3) >= Threshold(3,1)) & (I(:,:,2) <= Threshold(3,2));
%fill in internal holes created through the mask
FilledImg = imfill(mask, 'holes');

%erode edges to reduce noise
se = strel('disk', 2, 0);
mask = imerode(FilledImg, se);

end