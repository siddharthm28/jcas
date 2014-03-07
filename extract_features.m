function extract_features(obj,imgsetname)
%
% This function reads each image in imageset and:
% 1) computes superpixels
% 2) builds edges between superpixels of the same image
% 3) extracts sift features
% 4) store all the extracted info in a file
%
% Input:
% obj:   obj of class jcas with all user input
% imgset: collection of image indexes (equal to params.training or
%           param.test)
%
% Output:
% There is only one output as such.
% num_features: which is a vector that contains the number of features
%               extracted in each image of imageset
%
% The rest of the output is stored in 3 files called 0001-imagedata.mat
% if the input file image is called 0001.jpg.
% The information stored are:
%ImageData :
% img_info.I: RGB image
% img_info.Y: width of image img_feat.I.
% img_info.X: hieght of image img_feat.I.
%
%Superpixels :
% img_sp.Iseg: image iwth superpixels of image img_feat.I
% img_sp.spInd: label given to each pixel (tells you to which
%                  superpixels that pixel belong to.
% img_sp.nbSp: number of initial label (i.e. number of superpixels).
% img_sp.edges:
% img_sp.length_common_boundary:
%
%Features :
%img_feat : struct containing at least img_feat.locations and
%img_feat.descriptors

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
display(['Extracting features from ' obj.dbparams.name '. Total number of images in current set ' num2str(length(obj.dbparams.(imgsetname)))]);
fprintf('Processing image    ');

% compute number of images in imageset
num_imgs = length(obj.dbparams.(imgsetname));
imgset=obj.dbparams.(imgsetname);

% allocate memory
img_info = struct();
img_sp=struct();
img_feat=struct();

% if it does not exist create destination directory
% if (~exist(obj.dbparams.destmatpath, 'dir'))
%     mkdir(obj.dbparams.destmatpath);
% end

% for each image
if ~exist(sprintf(obj.unary.features.destmatpath,'num_features_per_image'),'file')
    num_features_per_images=[];
else
    load(sprintf(obj.unary.features.destmatpath,'num_features_per_image'),'num_features_per_images');
end

for i=1:num_imgs
    
    % print image index
    fprintf('\b\b\b\b%04d', imgset(i));
    
    % build filename for storing extracted image information
    imagedata_filename = sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',obj.dbparams.image_names{imgset(i)}));
    img_feat_filename=sprintf(obj.unary.features.destmatpath,sprintf('%s-unfeat',obj.dbparams.image_names{imgset(i)}));
    img_sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{imgset(i)}));
    
    % check if data have already been computed
    if (~exist(imagedata_filename, 'file') || ~exist(img_feat_filename,'file')|| ...
            ~exist(img_sp_filename,'file') || obj.force_recompute.imagedata || ...
            obj.force_recompute.trainingdata_SP || obj.force_recompute.trainingdata_UF)
        
        
        % load image
        img_info.I = imread([obj.dbparams.imgpath,obj.dbparams.image_names{imgset(i)},...
            obj.dbparams.format]);
        
        
        
        % extract image size
        [img_info.X,img_info.Y,~] = size(img_info.I);
        % H = X; W=Y;
        % -----------------------------------------------------------------
        % Superpixels
        % -----------------------------------------------------------------
        if ~exist(img_sp_filename,'file')||obj.force_recompute.trainingdata_SP
            [img_sp.spInd,img_sp.nbSp,img_sp.Iseg]=obj.computeSuperpixels(img_info.I);
        
        % -----------------------------------------------------------------
        % Build graph
        % -----------------------------------------------------------------
        
        % compute initial graph
        [~, edges]=lattice(img_info.X,img_info.Y);
        
        % find real edges (i.e. connection between pixels that belong to
        % different superpixels)
        edges = img_sp.spInd(edges(img_sp.spInd(edges(:,1))-img_sp.spInd(edges(:,2)) ~=0,:));
        L = sparse(edges(:,1), edges(:,2), ones(size(edges(:,1),1),1), img_sp.nbSp, img_sp.nbSp);
        L=tril(L+L');
        img_sp.edges =[];
        [img_sp.edges(:,1), img_sp.edges(:,2), img_sp.length_common_boundary] = find(L);
        save(img_sp_filename,'img_sp');
        end
        
        % -----------------------------------------------------------------
        % Features
        % -----------------------------------------------------------------
        if ~exist(img_feat_filename,'file')||obj.force_recompute.trainingdata_UF
        img_feat=obj.computeFeatures_unary(img_info.I);
        num_features_per_images(imgset(i))=img_feat.num_features;
        save(img_feat_filename,'img_feat');
        end
        % -----------------------------------------------------------------
        % Save info
        % -----------------------------------------------------------------
        
        if ~exist(imagedata_filename, 'file')||obj.force_recompute.imagedata
        save(imagedata_filename, 'img_info'); %'features','I', 'H','W','Iseg', 'labels', 'nlabels', 'edges', 'length_common_boundary');
        end

    end
end
save(sprintf(obj.unary.features.destmatpath,'num_features_per_image'),'num_features_per_images');
end


