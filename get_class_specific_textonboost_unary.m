function get_class_specific_textonboost_unary
% function that gets the unary for a specific class from the precomputed
% textonboost potentials.
clear all; clc;
% some relevant variables and paths
cls='car';
VOCinit;
cls_id=find(strcmp(VOCopts.classes,cls));
ip_path=get_dataset_path('voc2010-texton');
db_path=get_dataset_path('voc2010');
op_path=fullfile(db_path,sprintf('%s_matfiles',cls));
vl_xmkdir(op_path);
train_images=read_file(fullfile(db_path,'trainval.txt'));
test_images=read_file(fullfile(db_path,'Test.txt'));
image_names=sort([train_images;test_images]);
vis_path=fullfile(op_path,'visualizations'); vl_xmkdir(vis_path);
% run across all images
parfor i=1:length(image_names)
    process_image(i,image_names,ip_path,cls_id,op_path,vis_path);
end

function process_image(i,image_names,ip_path,cls_id,op_path,vis_path)
% construct to do parfor
fprintf('i: %d \n',i);
tmp=load(fullfile(ip_path,[image_names{i},'.mat']));
pixel_probability_estimates=tmp.pixel_probability_estimates;
p=pixel_probability_estimates(:,:,cls_id+1);
pixel_probability_estimates=cat(3,1-p,p);
save(fullfile(op_path,[image_names{i},'.mat']),'pixel_probability_estimates');
visualize_prob_image(pixel_probability_estimates,image_names{i},vis_path);
