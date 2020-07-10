function [laneEdge, BW, maskedRGBImage] = laneDetection(image)
%Read image
RGBimage = imread(image);
%Extract binary mask covering the lanes
[BW, maskedRGBImage] = createMask(RGBimage);
figure(); imshow(maskedRGBImage);

%Clear any noise on the binary mask
cleanUp = bwareaopen(BW, 500);
figure(2); imshow(cleanUp);

%Dilate the binary mask a little bit to get rid of gaps caused due to the
%grid. Structural element is set to a very small value so this does not
%affect the size of the lanes in the mask
se = strel('line', 15, 10);
dilatedMask = imdilate(cleanUp, se);
figure(3); imshow(dilatedMask);

%Use sobel operators to extract edges from the binary mask
laneEdge = edge(dilatedMask, 'Sobel');
figure(4); imshow(laneEdge);
end

function [BW,maskedRGBImage] = createMask(image)
% Convert RGB image to the lab colour space.
I = rgb2lab(image);

% Define thresholds for channel 1 based on histogram settings
lMin = 21.017; lMax = 82.729;

% Define thresholds for channel 2 based on histogram settings
aMin = 9.549; aMax = 78.012;

% Define thresholds for channel 3 based on histogram settings
bStarMin = -106.228; bStarMax = 41.205;

% Create mask based on chosen histogram thresholds
filter = (I(:,:,1) >= lMin ) & (I(:,:,1) <= lMax) & (I(:,:,2) >= aMin ) & (I(:,:,2) <= aMax) & (I(:,:,3) >= bStarMin ) & (I(:,:,3) <= bStarMax);
BW = filter;

% Create a copy of the original image to help set the background pixels to
% zero.
maskedRGBImage = image;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
