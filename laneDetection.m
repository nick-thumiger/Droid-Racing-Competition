function [leftColourMask, leftBinaryMask, leftEdge, rightColourMask, rightBinaryMask, rightEdge, bothEdges, bothBinary, bothColour] = laneDetection()
%Read image
RGBimage = imread('v_upcoming.jpg');
%Extract binary mask covering the lanes
[leftEdge, leftBinaryMask, leftColourMask] = blueMask(RGBimage);
[rightEdge, rightBinaryMask, rightColourMask] = redMask(RGBimage);

bothEdges = or(leftEdge, rightEdge);
bothBinary = or(leftBinaryMask, rightBinaryMask);
bothColour = or(leftColourMask, rightColourMask);
end

function [laneEdge, BW,maskedRGBImage] = blueMask(image)
% Convert RGB image to the ycbcr color space
I = rgb2ycbcr(image);   


% Define thresholds for Y Channel based on histogram settings
YchannelMin = 0.000; YChannelMax = 154.000;

% Define thresholds for Cb Channel based on histogram settings
CbChannelMin = 175.000; CbChannelMax = 255.000;

% Define thresholds for Cr Channel based on histogram settings
CrChannelMin = 107.000; CrChannelMax = 140.000;

% Create mask based on chosen histogram thresholds
BW = (I(:,:,1) >= YchannelMin ) & (I(:,:,1) <= YChannelMax) & ...
     (I(:,:,2) >= CbChannelMin ) & (I(:,:,2) <= CbChannelMax) & ...
     (I(:,:,3) >= CrChannelMin ) & (I(:,:,3) <= CrChannelMax);

% Initialize output masked image based on input image.
maskedRGBImage = image;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;


cleanUp = bwareaopen(BW, 900);

%Dilate the binary mask a little bit to get rid of gaps caused due to the
%grid. Structural element is set to a very small value so this does not
%affect the size of the lanes in the mask
se = strel('line', 15, 10);
dilatedMask = imdilate(cleanUp, se);

%Use sobel operators to extract edges from the binary mask
laneEdge = edge(dilatedMask, 'Sobel');
end


function [laneEdge, BW,maskedRGBImage] = redMask(image)
% Convert RGB image to YCbCr colour space
I = rgb2ycbcr(image);


% Define thresholds for Y Channel based on histogram settings
YchannelMin = 0.000; YchannelMax = 106.000;

% Define thresholds for Cb Channel based on histogram settings
CbChannelMin = 82.000; CbChannelMax = 121.000;

% Define thresholds for Cr Channel based on histogram settings
CrChannelMin = 157.000; CrChannelMax = 200.000;

% Create mask based on chosen histogram thresholds
BW = (I(:,:,1) >= YchannelMin ) & (I(:,:,1) <= YchannelMax) & ...
           (I(:,:,2) >= CbChannelMin ) & (I(:,:,2) <= CbChannelMax) & ...
           (I(:,:,3) >= CrChannelMin ) & (I(:,:,3) <= CrChannelMax);

% Initialize output masked image based on input image.
maskedRGBImage = image;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

cleanUp = bwareaopen(BW, 1000);

%Dilate the binary mask a little bit to get rid of gaps caused due to the
%grid. Structural element is set to a very small value so this does not
%affect the size of the lanes in the mask
se = strel('line', 15, 10);
dilatedMask = imdilate(cleanUp, se);

%Use sobel operators to extract edges from the binary mask
laneEdge = edge(dilatedMask, 'Sobel');
end
