%%% parameters: @sizeOfImage, is the training image size,
%%%             @numOfFace, is the amount of face image,
%%%             @numOfNonface, is the amount of non-face image,
%%%             @facePath, is the path of face image,
%%%             @faceImgFormat, is the format of face image,
%%%             @nonfacePath, is the path of non-face image,
%%%             @nonFaceImgFormat, is the format of face image,
%%%             @numOfClassifier, is the amount of strong classifiers,

function [ trainedClassifiers ] = trainClassifier(sizeOfImage, numOfFace, numOfNonface, facePath, faceImgFormat, nonfacePath, nonFaceImgFormat,numOfClassifier)

faces = cell(1,numOfFace);
nonfaces = cell(1,numOfNonface);


temp1 = []; temp2=[]; temp3=[]; temp4=[]; temp5=[];

%% input face image

for faceIndex = 1:numOfFace
    str = facePath;
    faceNum = int2str(faceIndex);
    path = strcat(str,'/',faceNum,faceImgFormat);   % image format for input !
    face = (double(imread(path)));
    face = imresize(face,[19 19]);
    ii_face = computeIntegralImage(face);
    faces{faceIndex} = ii_face;
    
    clc;
    disp('Reading Face Images');
    progress = strcat(int2str((faceIndex/numOfFace)*100),'%');
    disp(progress);
end
allImages = faces;
%% append nonface image to faces list
fprintf('Reading Non-Face Images\n');
for nonfaceIndex = 1:numOfNonface
    str = nonfacePath;
    nonfaceNum = int2str(nonfaceIndex);
    path = strcat(str,'/',nonfaceNum,nonFaceImgFormat);
    nonface = (double(imread(path)));
    ii_nonface = computeIntegralImage(nonface);
    nonfaces{nonfaceIndex} = ii_nonface; 
    allImages{nonfaceIndex+numOfFace} = ii_nonface;
    
    clc
    
    disp('Reading Non-Face Images');
    progress = strcat(int2str((nonfaceIndex/numOfNonface)*100),'%');
    disp(progress);
end

clc;
disp('Reading Face Images... completed');
disp('Reading Non-Face Images... completed');
fprintf('Constructing Haar Features...\n');
imgWeights = ones(numOfFace + numOfNonface,1)./(numOfFace + numOfNonface);
haarFeatures = [1,2;2,1;1,3;3,1;2,2];
searchWindow = sizeOfImage;

for iteration = 1:2
    fprintf(strcat('<iteration:',int2str(iteration),'>\n'));
    weakClassifiers = {};
    for haarIndex = 1:5
        
       col_haar = haarFeatures(haarIndex,1);
       row_haar = haarFeatures(haarIndex,2);
       
       for col_img = 2:searchWindow - col_haar
           for row_img = 2:searchWindow - row_haar
               for colScaled_haar = col_haar:col_haar:searchWindow - col_img
                   for rowScaled_haar = row_haar:row_haar:searchWindow - row_img                      
                       % calculate features of face img 
                       featureOfFaces = zeros(1,numOfFace);
                       for imgIndex = 1:numOfFace
                           feature = calHaarFeatures(faces{imgIndex},haarIndex, col_img, row_img, colScaled_haar, rowScaled_haar);
                           featureOfFaces(imgIndex) = feature;
                       end
                        
                       faceMean = mean(featureOfFaces);
                       faceStd = std(featureOfFaces);
                       faceMax = max(featureOfFaces);
                       faceMin = min(featureOfFaces);
                       
                       % calculate feature of nonface img
                       featureOfNonfaces = zeros(1,numOfNonface);
                       for imgIndex = 1:numOfNonface
                           feature = calHaarFeatures(nonfaces{imgIndex},haarIndex, col_img, row_img, colScaled_haar, rowScaled_haar);
                           featureOfNonfaces(imgIndex) = feature;
                       end
                       list_ratingDiff = [];
                       list_faceRating = [];
                       list_nonfaceRating = [];
                       list_totalError = [];
                       list_lowerBound = [];
                       list_upperBound = [];
                       list_strongCounter = 0;
                       
                       T = 50;
                       for iter = 1:T
                           C = ones(size(imgWeights,1),1);
                           minRating = faceMean - abs((iter/T)*(faceMean - faceMin));
                           maxRating = faceMean + abs((iter/T)*(faceMax - faceMean));
                           % false negative values
                           for featureIndex = 1:numOfFace
                               if featureOfFaces(featureIndex) >= minRating && featureOfFaces(featureIndex) <= maxRating
                                   C(featureIndex)= 0;
                               end
                           end
                           % weighted false negative capture rate
                           faceRate = sum(imgWeights(1:numOfFace).*C(1:numOfFace));
                           if faceRate < 0.05
                               for featureIndex = 1:numOfNonface
                                   if featureOfNonfaces(featureIndex) >= minRating && featureOfNonfaces(featureIndex) <= maxRating
                                   else
                                       C(featureIndex+ numOfFace) = 0;
                                   end
                               end
                               % weighted false positive capture rate
                               nonfaceRate = sum(imgWeights(numOfFace+1:numOfNonface+numOfFace).*C(numOfFace+1:numOfNonface+numOfFace));
                                
                               % total error
                               totalError = sum(imgWeights.*C);
                               if totalError < .5       
                                   list_strongCounter = list_strongCounter+1;
                                   list_ratingDiff = [list_ratingDiff, (1 - faceRate) - nonfaceRate];
                                   list_faceRating = [list_faceRating, 1 - faceRate];
                                   list_nonfaceRating = [list_nonfaceRating, nonfaceRate];
                                   list_totalError = [list_totalError, totalError];
                                   list_lowerBound = [list_lowerBound, minRating];
                                   list_upperBound = [list_upperBound, maxRating];
                               end
                           end                        
                       end
                       
                       if size(list_ratingDiff) > 0
                           maxRateIndex = -inf;
                           maxRateDiff = max(list_ratingDiff);
                           for index = 1:size(list_ratingDiff,2)
                               if list_ratingDiff(index) == maxRateDiff
                                   maxRateIndex = index;
                                   break;
                               end
                           end                           
                       end
                       % store weak classifier data     
                       if size(list_ratingDiff) >0
                           classifier = [haarIndex, col_img, row_img, colScaled_haar, rowScaled_haar...
                                        ,maxRateDiff...
                                        ,list_faceRating(maxRateIndex)...
                                        ,list_nonfaceRating(maxRateIndex)...
                                        ,list_lowerBound(maxRateIndex)...
                                        ,list_upperBound(maxRateIndex)...
                                        ,list_totalError(maxRateIndex)];
                           % iterating with Adaboost alogrithm
                           % alpha determines how good a classifier is
                           [imgWeights, alpha] = doAdaboost(classifier, allImages, numOfFace,imgWeights);
                           
                           classifier = [classifier, alpha];
                           weakClassifiers{size(weakClassifiers,2)+1} = classifier;
                           if haarIndex ==1 
                               temp1 = [temp1; classifier];
                           elseif haarIndex ==2
                               temp2 = [temp2; classifier];
                           elseif haarIndex ==3
                               temp3 = [temp3; classifier];
                           elseif haarIndex ==4
                               temp4 = [temp4; classifier];
                           elseif haarIndex ==5
                               temp5 = [temp5; classifier];
                           end
                       end
                   end
               end
           end
       end
       printout = strcat('Completed Haar Feature-> ',int2str(haarIndex),'\n');
       fprintf(printout);
    end
end
    
    
%% build strong classifiers
fprintf('Make strong classifiers...\n');
alphas = zeros(size(weakClassifiers,2),1);
for i = 1:size(alphas,1)
    % extract alpha column from classifier metadata
    alphas(i) = weakClassifiers{i}(12);
end    
% sort weakClassifiers
tempClassifiers = zeros(size(alphas,1),2); % 2 column
% first column is simply original alphas
tempClassifiers(:,1) = alphas;
for i = 1:size(alphas,1)
    % second column is the initial index of alpha values wrt original alphas
   tempClassifiers(i,2) = i; 
end

tempClassifiers = sortrows(tempClassifiers,-1); % sort descending order

% number of strong classifiers tailored to our implementation, might vary
selectedClassifiers = zeros(numOfClassifier,12);
for i = 1:numOfClassifier
    selectedClassifiers(i,:) = weakClassifiers{tempClassifiers(i,2)};
end


trainedClassifiers = selectedClassifiers;
fprintf('Strong classifiers...completed\n');
end
    
