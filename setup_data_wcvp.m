function setup_data_wcvp
% code to setup the wcvp data for segmentation experiments
clear all; clc;
% relevant paths
dataset_path='F:/Datasets/WCVP/';
splits_file=fullfile(dataset_path,'splits.txt');
% read the train, val and test splits
fid=fopen(splits_file,'r');
tmp=textscan(fid,'%s','delimiter','\n');
fclose(fid);
tmp=[tmp{:}];
train_cars=sort([str2num(tmp{1}),str2num(tmp{2})]);
test_cars=sort(str2num(tmp{3}));
% put all images into one image dir and generate random segmentations
img_path=fullfile(dataset_path,'img'); vl_xmkdir(img_path);
seg_path=fullfile(dataset_path,'seg'); vl_xmkdir(seg_path);
% process the image lists
train_file=fullfile(dataset_path,'train.txt');
process_images(train_cars,dataset_path,img_path,seg_path,train_file);
test_file=fullfile(dataset_path,'test.txt');
process_images(test_cars,dataset_path,img_path,seg_path,test_file);

function process_images(cars_list,dataset_path,img_path,seg_path,filename)
% run across cars in the list and push them into correct locations
fid=fopen(filename,'w');
for i=1:length(cars_list)
    fprintf('car: %d \n',cars_list(i));
    car_name=sprintf('car_%03d',cars_list(i));
    img_files=dir(fullfile(dataset_path,car_name,'*.jpg'));
    img_files={img_files(:).name};
    img_files=cellfun(@(x) x(1:end-4),img_files,'uniformoutput',false);
    for j=1:length(img_files)
        op_filename=sprintf('%s_%s',car_name,img_files{j});
        fprintf(fid,'%s \n',op_filename);
        ip_file=fullfile(dataset_path,car_name,[img_files{j},'.jpg']);
        op_file=fullfile(img_path,[op_filename,'.jpg']);
        copyfile(ip_file,op_file);
        im=imread(ip_file);
        [M,N,~]=size(im);
        seg_i=ones(M,N);
        save(fullfile(seg_path,[op_filename,'.mat']),'seg_i');
    end
end
fclose(fid);
