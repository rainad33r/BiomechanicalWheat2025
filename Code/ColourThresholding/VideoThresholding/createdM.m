function [maskThres, OutlineImg, maskedRGBImg] = createdM (rgbImage)

%see external create mask function
[maskThres, OutlineImg] = createMask1(rgbImage);

maskedRGBImg = bsxfun(@times, rgbImage,cast(OutlineImg,'like', rgbImage));

end