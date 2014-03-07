%--------------------------------------------------------------------------
% Computing the topdown descriptors
%--------------------------------------------------------------------------
% This function computes the topdown descriptors that you will use to build
% the top down dictionary
% Input : obj of class jcas imgsetname = 'training' or 'test'
% Output: 'feats', 'siftlbls', 'siftlocations' saved in 'sparse_sift'


function generate_topdown_descriptors(obj,imgsetname)
if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
topdown_descriptors_filename = sprintf(obj.topdown.features.destmatpath,['topdown_descriptors_',imgsetname]);

if isequal(obj.topdown.features.params.max_per_image,'none')
maxnb=1;
else
    maxnb=obj.topdown.features.params.max_per_image;
end

if (~exist(topdown_descriptors_filename, 'file') || obj.force_recompute.topdown_descriptors)
    %Establish the set of images
    ids = obj.dbparams.(imgsetname);
    
    %Allocate memory
    feats = zeros(obj.topdown.features.params.dimension,length(ids)*maxnb,'uint8');
    siftlbls = zeros(2,length(ids)*maxnb,'uint32');
    siftlocations = zeros(1,length(ids)*maxnb);
    ctr = 1;

    tic
    fprintf('generate_topdown_descriptors (total of %d images):    ', length(ids));

    % for each image
    for i=1:length(ids)
        featImName=sprintf(obj.topdown.features.destmatpath, sprintf('%s-topdown_features',obj.dbparams.image_names{ids(i)}));
        if (~exist(featImName, 'file') || obj.force_recompute.topdown_descriptors)
        
        fprintf('\b\b\b\b %03d',i);

        % Read image i and convert it to gray scale
        I = imread([obj.dbparams.imgpath,obj.dbparams.image_names{ids(i)},obj.dbparams.format]);
        %Load ground truth
        load(sprintf(obj.dbparams.segpath,obj.dbparams.image_names{ids(i)}), 'seg_i');
        
        %Extract chosen features from image
        feat_topdown = obj.computeFeatures_topdown(I);
        F=feat_topdown.locations;
        D=feat_topdown.descriptors;

        %Save image features extracted
        %save(sprintf(obj.topdown.destmatpath, sprintf('%s-topdown_features',obj.dbparams.image_names{ids(i)})),'D','F','I','seg');
        save(featImName,'feat_topdown');
        else
            load(featImName,'feat_topdown');
            load(sprintf(obj.dbparams.segpath,obj.dbparams.image_names{ids(i)}), 'seg_i');
            I = imread([obj.dbparams.imgpath,obj.dbparams.image_names{ids(i)},obj.dbparams.format]);
            F=feat_topdown.locations;
            D=feat_topdown.descriptors;
        end

        % Find features locations
        [X,Y ~] = size(I);
        locations = X*(round(F(1,:))-1)+round(F(2,:));

        % Find features
        feats(:,ctr:ctr+size(D,2)-1) = D;

        % Find features labels
        siftlbls(:,ctr:ctr+size(D,2)-1) = [uint32(seg_i(locations)); i*ones(1,size(D,2))];

        % Find sift locations
        siftlocations(:,ctr:ctr+size(D,2)-1) = locations;

        % Find new center
        ctr = ctr+size(D,2);
    end

    % Find features
    feats = feats(:,1:ctr-1);
save(topdown_descriptors_filename, 'feats', 'siftlbls', 'siftlocations');

end
end
