%% input target and source image
boxImg = rgb2gray(imread('box.png'));
figure;imshow(boxImg);title('Box');
sceneImg = rgb2gray(imread('scene.png'));
figure;imshow(sceneImg);title('Target Scene');

%% detect feature points
boxPoints = detectSURFFeatures(boxImg);
scenePoints = detectSURFFeatures(sceneImg);

%% extracing feature descriptors
[boxFeatures, boxPoints] = extractFeatures(boxImg, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImg, scenePoints);

%% matching feature points
boxPairs = matchFeatures(boxFeatures, sceneFeatures);
matchedBoxPoints = boxPoints(boxPairs(:,1),:);
matchedScenePoints = scenePoints(boxPairs(:,2),:);
figure;
showMatchedFeatures(boxImg, sceneImg, matchedBoxPoints, matchedScenePoints, 'montage');
title('matched points');

[tform, inlierBoxPoints, inlierScenePoints] = ...
estimateGeometricTransform(matchedBoxPoints, matchedScenePoints,...
'affine');

showMatchedFeatures(boxImg, sceneImg, inlierBoxPoints, ...
inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)'); 

%% marking detected region
boxPolygon = [1, 1;... % top-left
size(boxImg, 2), 1;... % top-right
size(boxImg, 2), size(boxImg, 1);... % bottom-right
1, size(boxImg, 1);... % bottom-left
1, 1]; % top-left again to close the polygon

newBoxPolygon = transformPointsForward(tform, boxPolygon);

figure;
imshow(sceneImg);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');