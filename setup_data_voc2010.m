function setup_data_voc2010
% code that reads data from the class segmentations given in Pascal VOC2011 
% and stores in the format we use. Note that all the pixels to be ignored
% (indicated by 255) in the Pascal annotations are marked 0 and background
% is class 1 with the remaining 20 classes adjusted accordingly
clear all; clc;
% relevant variables and paths
dataset_path='G:/datasets/VOC2010/VOCdevkit/VOC2010/';
trainval_file=fullfile(dataset_path,'ImageSets/Segmentation','trainval.txt');
gt_path=fullfile(dataset_path,'SegmentationClass');
% read the VOC parameters
VOCinit;    % the VOCdevkit folder should be in your path
% read the list of all images having a segmentation annotation
image_names=read_file(trainval_file);
% transform all the segmentation files into the gt matfiles
op_path=fullfile(dataset_path,'seg');
vl_xmkdir(op_path);
% run across all images
for i=1:length(image_names)
    fprintf('i: %d/%d \n',i,length(image_names));
    gt_file=fullfile(gt_path,[image_names{i},'.png']);
    seg_i=imread(gt_file);
    seg_i=seg_i+1;
    seg_i(seg_i==255)=0;
    seg_file=fullfile(op_path,[image_names{i},'.mat']);
    save(seg_file,'seg_i');
end
