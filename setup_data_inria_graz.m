function setup_data_inria_graz
% code that reads the data from the zip files and sets it up to be used for
% the JCaS experiments
clear all; clc; close all;
% relevant variables and paths
classes={'bikes','cars','people'};
dataset_path='/cis/project/vision_sequences/inria_graz/';
tasks={'train','test'};
img_path=fullfile(dataset_path,'img');
vl_xmkdir(img_path);
gt_path=fullfile(dataset_path,'gt');
vl_xmkdir(gt_path);
seg_path=fullfile(dataset_path,'seg');
vl_xmkdir(seg_path);

% collect the segmentations into the usual graz format 
% 1-background 2-bike 3-car 4-people
for i=1:length(classes)
    for j=1:length(tasks)
        % get class of interest and the task
        cls=classes{i};
        task=tasks{j};
        % read the relevant file
        filename=fullfile(dataset_path,sprintf('%s_%s.txt',cls,task));
        image_names=read_file(filename);
        for k=1:length(image_names)
            fprintf('i: %d/%d j: %d/%d k: %d/%d \n',i,length(classes),j,length(tasks),k,length(image_names));
            % get relevant files
            img_file=fullfile(dataset_path,cls,sprintf('%s.image.png',image_names{k}));
            gt_files=fullfile(dataset_path,cls,sprintf('%s.mask.*.png',image_names{k}));
            gt_files=dir(gt_files);
            gt_files={gt_files(:).name};
            gt_files=cellfun(@(x) fullfile(dataset_path,cls,x),gt_files,'uniformoutput',false);
            % consolidate into one segmentation in the format we need. We
            % get a mask which is corrected to get the correct labeling
            mask=consolidate_gt_files(gt_files);
            seg_i=correct_labeling(mask,i+1);
            % move the files into their correct locations
            copyfile(img_file,img_path);
            for q=1:length(gt_files)
                copyfile(gt_files{q},gt_path);
            end
            save(fullfile(seg_path,sprintf('%s.mat',image_names{k})),'seg_i');
        end
    end
end

% collapse the train and test lists into one files
for i=1:length(tasks)
    op_file=fullfile(dataset_path,sprintf('%s.txt',tasks{i}));
    if(exist(op_file,'file')) delete(op_file); end
    for j=1:length(classes)
        ip_file=fullfile(dataset_path,sprintf('%s_%s.txt',classes{j},tasks{i}));
        cmd=sprintf('cat %s >> %s',ip_file,op_file);
        system(cmd);
    end
end

function mask=consolidate_gt_files(gt_files)
% read all gt files and use their red channel to create a combined mask
masks=cellfun(@(x) imread(x), gt_files,'uniformoutput',false);
masks=cellfun(@(x) x(:,:,1), masks,'uniformoutput',false);
masks=sum(cat(3,masks{:}),3);
mask=(masks>0);

function seg=correct_labeling(mask,l)
% use the mask and the input label to assign the background to 1 and the
% correct label l to the foreground
seg=zeros(size(mask));
seg(mask==1)=l;
seg(mask==0)=1;
