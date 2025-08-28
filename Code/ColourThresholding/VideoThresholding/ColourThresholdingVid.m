%% Colour Thresholding Video Test
% Raina's 2025 USRA tests
% largely inspired by: 
% https://github.com/hritik5102/Blob-detection-using-Matlab

fprintf('Running...');
clear workspace;

%Imports video and sets data type to be used
cap = vision.VideoFileReader('testervideo.mp4');
cap.VideoOutputDataType = 'double';

obj = VideoReader('testervideo.mp4');
D = zeros(1, length(obj.NumFrames));

%Sort folder to ensure it exists
folder = [];
baseFile = 'testervideo.mp4';
fullFile = fullfile(folder, baseFile);
j(1,1) = 1;
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

while ~isDone(cap)
    
    frame = step(cap);
    
    % Read and turn frame into HSV format for use
    % [rgbImage, ColourChannels] = BaseRGB(frame);
    % Create mask from predetermined threshold of one (1) frame
    [maskThres, OutlineImg, maskedRGBImage] = createdM(frame);
    figure(1)
    subplot(2,2,1)
    imshow(frame)
    subplot(2,2,2)
    imshow(maskedRGBImage)
    subplot(2,2,3)
    imshow(OutlineImg)

    %Calculate the pixel center of the image
    XMean = length(maskedRGBImage(1,:,:))/2;
    YMean = length(maskedRGBImage(:,1))/2;
    ImgCenter = [YMean XMean];

    % Create bounding box to frame the flag
    bounding_box = regionprops(OutlineImg, 'BoundingBox');
    
    %Plot centroid on final bounded image
    props = regionprops(OutlineImg,'Area', 'Centroid');
    xy = vertcat(props.Centroid);

    hold on
    %loop circles centroids and lasts for the amount of centroids on the image
    for i = 1 : length(props)
        plot(xy(i,1), xy(i,2), 'o', 'Linewidth', 2, 'Color', "r");
    end

    % Calculate the distance from the center to the centroid: in pixels
    % Only works for one centroid in EVERY frame
    % D(j) = norm(props.Centroid - ImgCenter);
    % j = j +1;
end
hold off;

release(cap)