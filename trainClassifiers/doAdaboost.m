function [ newWeights, alpha ] = doAdaboost( classifier, allImages, faceAmount, imgWeights )
numOfFace = faceAmount;
[~, numOfImg] = size(allImages);
captures = zeros(numOfImg,1);
error = 0;

for i = 1:numOfImg
    img = allImages{i};
    haarFeaure = classifier(1);
    col_img = classifier(2);
    row_img = classifier(3);
    colScaled_haar = classifier(4);
    rowScaled_haar = classifier(5);
    feature = calHaarFeatures(img,haarFeaure,col_img,row_img,colScaled_haar,rowScaled_haar);
    
    if feature >= classifier(9) && feature <= classifier(10) % if falls between correct value
        if i <= numOfFace % if its a face
            captures(i) = 1; % correct capture
        else
            captures(i) = 0; % error
            error = error + imgWeights(i); % increase weighted error count
        end
    else % if falls outside the expected range
        if i <= numOfFace % if is a face
            captures(i) = 0;
            error = error + imgWeights(i); % error
        else 
            captures(i) = 1;
        end
    end
end

alpha = 0.5*log((1-error)/error);

for i = 1:numOfImg
    if captures(i) == 0
        imgWeights(i) = imgWeights(i).*exp(alpha);
    else
        imgWeights(i) = imgWeights(i).*exp(-alpha);
    end
end

% normalize image weights
imgWeights = imgWeights./sum(imgWeights); 
newWeights = imgWeights; 

end

