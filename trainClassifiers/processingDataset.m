
%% loading images from dataset and copy to specific folders
% Start with a folder and get a list of all subfolders.
% Finds and prints names of all files in 
% that folder and all of its subfolders.
% Similar to imageSet() function in the Computer Vision System Toolbox: http://www.mathworks.com/help/vision/ref/imageset-class.html
clc;    % Clear the command window.
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
% Define a starting folder.
start_path = fullfile('E:\Matlab Projects\Facial_Recongnition');
if ~exist(start_path, 'dir')
	start_path = matlabroot;
end
% Ask user to confirm or change.
% uiwait(msgbox('Pick a starting folder on the next window that will come up.'));
topLevelFolder = uigetdir(start_path);
if topLevelFolder == 0
	return;
end
% Get list of all subfolders.
allSubFolders = genpath(topLevelFolder);
% Parse into a cell array.
remain = allSubFolders;
listOfFolderNames = {};
while true
	[singleSubFolder, remain] = strtok(remain, ';');
	if isempty(singleSubFolder)
		break;
	end
	listOfFolderNames = [listOfFolderNames singleSubFolder];
end
numberOfFolders = length(listOfFolderNames);
counter = 1;
fullDestinationFolder = 'E:\Matlab Projects\Facial_Recongnition\trainClassifiers\testImg/';
% Process all image files in those folders.
for k = 1 : numberOfFolders
	% Get this folder and print it out.
	thisFolder = listOfFolderNames{k};
	%fprintf('Processing folder %s\n', thisFolder);
	
	% Get ALL files.
	filePattern = sprintf('%s/*.jpg', thisFolder);   %%%%%% specify the image format
	baseFileNames = dir(filePattern);
% 	% Get m files.
% 	filePattern = sprintf('%s/*.m', thisFolder);
% 	baseFileNames = dir(filePattern);
% 	% Add on FIG files.
% 	filePattern = sprintf('%s/*.fig', thisFolder);
% 	baseFileNames = [baseFileNames; dir(filePattern)];
	% Now we have a list of all files in this folder.
	
	numberOfImageFiles = length(baseFileNames);
	if numberOfImageFiles >= 1
		% Go through all those files.
		for f = 1 : numberOfImageFiles
			fullFileName = fullfile(thisFolder, baseFileNames(f).name);
            clc;
            imgLocation = strcat(fullFileName);
            disp(imgLocation);
            a = (counter) / (numberOfFolders);
            a = sprintf('%.2f',a);
            progress = strcat('Loading image ...',a,'%');
            disp(progress);
            img = rgb2gray(imread(imgLocation));
            img = imcrop(img,[70 70 110 110]);          %%%%%%%%%%% face cropping for lfw dataset
            imshow(img);
            newName = strcat(fullDestinationFolder,int2str(counter),'.jpg');
            imwrite(img,newName,'jpg');            %%%%%% specify the image format
            counter = counter+1;        
        end
        
	else
		fprintf('     Folder %s has no files in it.\n', thisFolder);
	end
end
disp('Image Loaded');