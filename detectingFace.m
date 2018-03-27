function [ faces, faceBound ] = detectingFace(img,classifiersPath)

img_orginal = img;
img = rgb2gray(img);
img = conv2(img,fspecial('gaussian',3,3),'same');

[maxRow, maxCol] = size(img);
scanIteration = 8;
faces = [];
ii_img = computeIntegralImage(img);

% load trained classifiers
% load 'trainClassifiers/classifiers.mat' % 300 classifiers
load(classifiersPath) % 286 classifiers

% 7 class with 200 classifiers
class1 = selectedClassifiers(1:2,:);
class2 = selectedClassifiers(3:12,:);
class3 = selectedClassifiers(13:20,:);
class4 = selectedClassifiers(21:40,:);
class5 = selectedClassifiers(41:70,:);
class6 = selectedClassifiers(71:150,:);
class7 = selectedClassifiers(151:200,:);


for i = 1:scanIteration
    printout = strcat('Iteration:',int2str(i),'\n');
    fprintf(printout);
    for r = 1:2:maxRow-19
        if r + 19 > maxRow
            break;
        end
        for c = 1:2:maxCol-19
            if c + 19 > maxCol
                break;
            end
            searchWindow_ii = ii_img(r:r+18, c:c+18);
%             threshold = 0.5;
%             depth = 4;
%             a=1;
%             b=10;
%             const =10;
%             output = cascadeRecursive(searchWindow_ii, selectedClassifiers, threshold, depth ,a,b,const);
%             if output ==1
%                 bounds = [c, r, c+18, r+18, i];
%                 faces = [faces; bounds];
%                 fprintf('Face detected!\n');
%            end
            class1_result = cascadeClassifier(searchWindow_ii, class1, 1);
            if class1_result == 1
                class2_result = cascadeClassifier(searchWindow_ii, class2, 0.5);  

                if class2_result == 1
                    class3_result = cascadeClassifier(searchWindow_ii, class3, 0.5);    

                    if class3_result == 1
                        class4_result = cascadeClassifier(searchWindow_ii, class4, 0.5); 
                     
                        if class4_result == 1
                            class5_result = cascadeClassifier(searchWindow_ii, class5, 0.6); 
                           
                            if class5_result == 1
                                class6_result = cascadeClassifier(searchWindow_ii, class6, 0.6);
                               
                                if class6_result == 1
                                    class7_result = cascadeClassifier(searchWindow_ii, class7, 0.5);
                                    fprintf('Passed level 6 cascade.\n');
                                    if class7_result ==1
                                        bounds = [c, r, c+18, r+18, i];
                                        faces = [faces; bounds];
                                        fprintf('Face detected!\n');
                                    end
                                end
                            end
                        end
                    end
                end
            end   
        end
    end
    tempImg = imresize(img,0.8);
    img = tempImg;
    [maxRow, maxCol] = size(img);
    ii_img = computeIntegralImage(img);
end


if size(faces,1) == 0
    disp('No face detected');
    faceBound =[];
else

faceBound = zeros(size(faces,1),4);
maxItr = max(faces(:,5));
for i = 1:size(faces,1)
    if faces(i,5) ~= maxItr
        continue;
    end
    faceBound(i,:) = floor(faces(i,1:4)*1.25^(faces(i,5)-1));
end
startRow = 1;
for i = 1:size(faceBound,1)
    if faceBound(i,1)==0
        startRow = startRow+1;
    end
end
faceBound = faceBound(startRow:end,:);
faceBound = [min(faceBound(:,1)), min(faceBound(:,2)), max(faceBound(:,3)), max(faceBound(:,4))];
figure, imshow(img_orginal),hold on;
if (~isempty(faceBound));
    for n=1:size(faceBound,1)
        toleranceX = floor(0.1*(faceBound(n,3)-faceBound(n,1)));
        toleranceY = floor(0.1*(faceBound(n,4)-faceBound(n,2)));
        % original bounds
        x1=faceBound(n,1); y1=faceBound(n,2);
        x2=faceBound(n,3); y2=faceBound(n,4);
        % adjusted bounds to get wider face capture
        x1t=faceBound(n,1)-toleranceX; y1t=faceBound(n,2)-toleranceY;
        x2t=faceBound(n,3)+toleranceX; y2t=faceBound(n,4)+toleranceY;
        imSize = size((img_orginal));
        % if adjusted bounds will lead to out-of-bounds plotting, use original bounds
        if x1t < 1 || y1t < 1 || x2t > imSize(2) || y2t > imSize(1)
            fprintf('Out of bounds adjustments. Plotting original values...\n');
            plot([x1 x1 x2 x2 x1],[y1 y2 y2 y1 y1],'LineWidth',2);
        else
            plot([x1t x1t x2t x2t x1t],[y1t y2t y2t y1t y1t],'LineWidth',2);
        end
    end
end

title('Detected face in image');
hold off;
   
end
end

