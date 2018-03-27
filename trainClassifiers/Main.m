
%% Large time to train the classifiers
% parameters :(sizeOfImage, numOfFace, numOfNonface, facePath, faceImgFormat, nonfacePath, nonFaceImgFormat,numOfClassifier)
selectedClassifiers = trainClassifier(19, 50, 100, 'testImg','.jpg', 'nonfaces', '.pgm', 300);
save('classifiers.mat','selectedClassifiers');
