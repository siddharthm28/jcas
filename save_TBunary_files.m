function save_TBunary_files
% function that loads the TBunary files and saves them as .mat files with
% pixel_probability_estimates in the natural matlab image format
clear all; clc; close all;
% get the relevant paths and files
dataset_path=get_dataset_path('voc2010');
img_path=fullfile(dataset_path,'img');
unary_path='F:/Datasets/voc2010/TBunarylogit1/';
unary_matfiles_path='F:/Datasets/voc2010/TBunarylogit1_matfiles/';
vl_xmkdir(unary_matfiles_path);
train_file=fullfile(dataset_path,'trainval.txt');
test_file=fullfile(dataset_path,'Test.txt');
% relevant variables
VOCinit; ncat=VOCopts.nclasses+1;
% run for all these images
image_names=sort([read_file(train_file);read_file(test_file)]);
vis_path=fullfile(unary_matfiles_path,'visualizations'); vl_xmkdir(vis_path);
matlabpool('open',4);
parfor i=1:length(image_names)
    process_image(i,image_names,img_path,unary_path,unary_matfiles_path,vis_path,ncat);
end
matlabpool('close');

function process_image(i,image_names,img_path,unary_path,unary_matfiles_path,vis_path,ncat)
% construct to do parfor
eps=0;
fprintf('i: %d/%d \n',i,length(image_names));
% relevant files
img_file=fullfile(img_path,[image_names{i},'.jpg']);
unary_file=fullfile(unary_path,[image_names{i},'.unary']);
% read the image file
img=imread(img_file);
[M,N,~]=size(img);
% read the unary file
fid=fopen(unary_file,'r');
tmp=fread(fid,inf,'float');
fclose(fid);
tmp=reshape(tmp,[ncat,M*N]);
tmp=tmp+eps;
prob=tmp./repmat(sum(tmp),ncat,1);
prob=num2cell(prob,2);
prob=cellfun(@(x) reshape(x,[N,M])',prob,'uniformoutput',false);
pixel_probability_estimates=cat(3,prob{:});
save(fullfile(unary_matfiles_path,[image_names{i},'.mat']),'pixel_probability_estimates');
visualize_prob_image(pixel_probability_estimates,image_names{i},vis_path);
