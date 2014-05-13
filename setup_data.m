function setup_data(dataset_name)
% function that reads the images in the various sub-folders and setups up
% everything for each dataset - inria-graz, voc2010, voc2011, voc2011-all
% I need to read images for the inria-graz dataset as there are two
% different splits and the official test-train split doesn't use all the
% data available
clc; close all;
% get the location of the data
dataset_path=get_dataset_path(dataset_name);
% setup paths
img_path=fullfile(dataset_path,'img'); vl_xmkdir(img_path);
gt_path=fullfile(dataset_path,'gt'); vl_xmkdir(gt_path);
seg_path=fullfile(dataset_path,'seg'); vl_xmkdir(seg_path);
switch dataset_name
    case 'graz02'
        for i=1:900
            fprintf('i: %d \n',i);
            seg_i=imread(fullfile(gt_path,sprintf('%d.png',i)));
%             seg_i=imfill(seg_i);
            save(fullfile(seg_path,sprintf('%d.mat',i)),'seg_i');
        end
    case 'inria-graz'
        fprintf('Inria Graz dataset \n');
        % do for these three classes
        classes={'bikes','cars','people'};
        for i=1:length(classes)
            cls=classes{i};
            fprintf('Class : %s \n',cls);
            % get image files
            image_files=dir(fullfile(dataset_path,cls,'*.image.png'));
            image_files={image_files(:).name};
            image_names=cellfun(@(x) x(1:end-10),image_files,'uniformoutput',false);
            % run across all images
            for j=1:length(image_names)
                fprintf('i: %d/%d j: %d/%d \n',i,length(classes),j,length(image_names));
                % group all gt masks to get one segmentation annotation
                gt_files=dir(fullfile(dataset_path,cls,[image_names{j},'.mask.*']));
                gt_files={gt_files(:).name};
                gt_files=cellfun(@(x) fullfile(dataset_path,cls,x),gt_files,'uniformoutput',false);
                if(isempty(gt_files)), continue; end
                mask=consolidate_gt_files(gt_files);
                seg_i=correct_labeling(mask,i+1);
                % save the image in correct location
                copyfile(fullfile(dataset_path,cls,image_files{j}),...
                    fullfile(img_path,[image_names{j},'.png']));
                % save the gt .png file with bg=0,bike=1,car=2,people=3
                imwrite(uint8(seg_i)-1,fullfile(gt_path,[image_names{j},'.png']));
                % save the seg .mat file with bg=1,bike=2,car=3,people=4
                save(fullfile(seg_path,[image_names{j},'.mat']),'seg_i');
            end
        end
    case 'voc2010'
        fprintf('Pascal VOC2010 dataset \n');
        % location of the original data is different now
        orig_dataset_path=get_dataset_path('voc2010-orig');
        image_names=read_file(fullfile(orig_dataset_path,'ImageSets/Segmentation/trainval.txt'));
        orig_img_path=fullfile(orig_dataset_path,'JPEGImages');
        orig_gt_path=fullfile(orig_dataset_path,'SegmentationClass');
        for i=1:length(image_names)
            fprintf('i: %d/%d \n',i,length(image_names));
            % copy image and gt files into correct location
            copyfile(fullfile(orig_img_path,[image_names{i},'.jpg']),...
                fullfile(img_path,[image_names{i},'.jpg']));
            copyfile(fullfile(orig_gt_path,[image_names{i},'.png']),...
                fullfile(gt_path,[image_names{i},'.png']));
            % load gt and save correctly
            gt=imread(fullfile(orig_gt_path,[image_names{i},'.png']));
            seg_i=voc_labeling(gt);
            save(fullfile(seg_path,[image_names{i},'.mat']),'seg_i');
        end
    case 'voc2011-sbd-cars'
        fprintf('VOC2011-SBD dataset : cars \n');
        orig_dataset_path=get_dataset_path('voc2011-sbd-orig');
        train_images=read_file(fullfile(orig_dataset_path,'train.txt'));
        test_images=read_file(fullfile(orig_dataset_path,'val.txt'));
        image_names=sort([train_images;test_images]);
        orig_img_path=fullfile(orig_dataset_path,'img');
        orig_gt_path=fullfile(orig_dataset_path,'cls');
        % get car id
        VOCinit;
        car_id=find(strcmp(VOCopts.classes,'car'));
        for i=1:length(image_names)
            fprintf('i: %d/%d \n',i,length(image_names));
            % load gt annotation
            tmp=load(fullfile(orig_gt_path,[image_names{i},'.mat']));
            GTcls=tmp.GTcls;
            if(~ismember(GTcls.CategoriesPresent,car_id)), continue; end
            gt=GTcls.Segmentation;
            mask=uint8(gt==car_id);
            % copy image files into correct location
            copyfile(fullfile(orig_img_path,[image_names{i},'.jpg']),...
                fullfile(img_path,[image_names{i},'.jpg']));
            % save gt annotation
            seg_i=voc_labeling(double(mask));
            save(fullfile(seg_path,[image_names{i},'.mat']),'seg_i');
            imwrite(uint8(mask),fullfile(gt_path,[image_names{i},'.png']));
        end
    case 'voc2011-sbd-all'
        fprintf('VOC2011-SBD dataset \n');
        % location of the original data is different now
        orig_dataset_path=get_dataset_path('voc2011-sbd-orig');
        train_images=read_file(fullfile(orig_dataset_path,'train.txt'));
        test_images=read_file(fullfile(orig_dataset_path,'val.txt'));
        image_names=sort([train_images;test_images]);
        orig_img_path=fullfile(orig_dataset_path,'img');
        orig_gt_path=fullfile(orig_dataset_path,'cls');
        for i=1:length(image_names)
            fprintf('i: %d/%d \n',i,length(image_names));
            % copy image files into correct location
            copyfile(fullfile(orig_img_path,[image_names{i},'.jpg']),...
                fullfile(img_path,[image_names{i},'.jpg']));
            % load gt annotation
            tmp=load(fullfile(orig_gt_path,[image_names{i},'.mat']));
            gt=tmp.GTcls.Segmentation;
            % save gt annotation
            seg_i=voc_labeling(double(gt));
            save(fullfile(seg_path,[image_names{i},'.mat']),'seg_i');
            imwrite(uint8(gt),fullfile(gt_path,[image_names{i},'.png']));
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

function seg_i=voc_labeling(gt)
% voc annotations have label 0 for background and label 255 for ignore. We
% want the ignore=0 and background=1
seg_i=gt+1;
seg_i(gt==255)=0;
