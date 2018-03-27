img = imread('Images/Steve2.jpg');
% img = imread('imgs/1.jpg');
%img = imresize(img,[300 300]);

[ faces, faceBound ]=detectingFace(img,'trainClassifiers/trainedClassifiers.mat');

%%
% for n = 1:size(faces,1)
%     rectangle('Position',[faces(n,1) faces(n,2) 20 20]);
% end




