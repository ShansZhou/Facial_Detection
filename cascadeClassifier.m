function output = cascadeClassifier(ii_img, classifiers, thresh)

result = 0;
num = size(classifiers,1);
weightSum = sum(classifiers(:,12));
for n = 1:num
    classifier = classifiers(n,:);
    haarTemplate = classifier(1);
    col = classifier(2);
    row = classifier(3);
    haar_scaledCol = classifier(4);
    haar_scaledRow = classifier(5);
    
    feature = calHaarFeatures(ii_img,haarTemplate, col, row, haar_scaledCol, haar_scaledRow);
    
    if feature >= classifier(9) && feature <= classifier(10)
        vote = classifier(12);
    else
        vote = 0;
    end
    result = result + vote;
end

%% check resulting weight with threshold 
if result >= weightSum*thresh
    output = 1; % face detected
else
    output = 0; % no face detected
end




end

