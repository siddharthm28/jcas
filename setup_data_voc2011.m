function setup_data_voc2011
% code that reads data from the segmentations given in VOC2011 as annotated
% by the Inverse Detector work into format relevant to us.
clear all; clc;
% relevant variables and paths
dataset_path='F:/Datasets/SCB/benchmark_RELEASE/dataset/';
train_file=fullfile(dataset_path,'train.txt');
test_file=fullfile(dataset_path,'val.txt');
% get segmentation label corresponding to class 'car'
VOCinit;    % assumes that the VOCCode folder in Pascal VOC is in path
bg_label=VOCopts.nclasses+1;    % it is 0 in the segmentations which is treated as void
% setup directory structure and files for output
op_path=fullfile(dataset_path,'seg');
vl_xmkdir(op_path);
% read all train images and save only those related to cars
process_images(train_file,dataset_path,op_path,bg_label);
% read all val images and save only those related to cars
process_images(test_file,dataset_path,op_path,bg_label);

function process_images(image_file,ip_path,op_path,bg_label)
% read data from ip_path and save only relevant files in op_path
image_names=read_file(image_file);
for i=1:length(image_names)
    fprintf('i: %d/%d \n',i,length(image_names));
    tmp=load(fullfile(ip_path,'cls',[image_names{i},'.mat']));
    GTcls=tmp.GTcls;
    seg_i=GTcls.Segmentation;
    seg_i(seg_i==0)=bg_label;
    seg_file=fullfile(op_path,[image_names{i},'.mat']);
    save(seg_file,'seg_i');
end
