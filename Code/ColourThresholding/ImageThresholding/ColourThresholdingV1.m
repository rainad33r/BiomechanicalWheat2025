%% Colour Thresholding Test
% Raina's 2025 USRA tests
% largely inspired by: 
% https://www.mathworks.com/matlabcentral/answers/647838-color-thresholding-in-the-rgb-or-hsv-space

clear figures;
clearvars;
format long g;
format compact;
fprintf('Running...');

%initialize figure for future use:
hFig1 = gcf;
hFig1.Units = 'Normalized';
hFig1.Name = 'Colour Thresholding Test';

%Read image
folder = [];
baseFile = 'orangeplt.jpg';
fullFile = fullfile(folder, baseFile);


%Image from initial cart test

% Make sure the file exists
if ~exist(fullFile, 'file')
        % Search other folders on the filepath
        fullFileSearch = baseFile;
        % Doesn't exist at all --> error
        if ~exist (fullFile, 'file')
            errormsg = sprintf( ...
                'Error: %s does not exist in searched folders', fullFile);
            uiwait(warndlg(errormsg));
            return;
        end 
end

% Read indexxed image
[rgbImage, ColourChannels] = BaseRGB(fullFile);

%Find center of image for oscillation distance purposes
XMean = length(rgbImage(1,:,:))/2;
YMean = length(rgbImage(:,1))/2;
ImgCenter = [YMean XMean];

%Display Test Image in upper left corner
subplot(2,2,1);
imshow(rgbImage, []);
axis('on','image');
caption = sprintf('Image %s', baseFile);
title(caption);
drawnow;

% Display Masked image underneath original image
[maskThres, OutlineImg, maskedRGBImage] = createdM (rgbImage);
subplot(2,2,2);
imshow(maskedRGBImage, []);
axis('on', 'image');
title('Masked RGB Image');
drawnow;

subplot(2,2,3);
imshow(OutlineImg);
hp = impixelinfo();
axis('on','image');
title('Outline Mask');


% Draws Circle around the mask
bounding_box = regionprops(OutlineImg, 'BoundingBox');

%Plot centroid on final bounded image
props = regionprops(OutlineImg,'Area', 'Centroid');
xy = vertcat(props.Centroid);
hold on
%loop circles centroids and lasts for the amount of centroids on the image
for i = 1 : length(props)
    plot(xy(i,1), xy(i,2), 'o', 'Linewidth', 2, 'Color', "r");
end
hold off;

% Calculate the distance from the center to the centroid: in pixels
D = norm(props.Centroid - ImgCenter);

fprintf('\nDone!\n');

