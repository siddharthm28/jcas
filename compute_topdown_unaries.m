%--------------------------------------------------------------------------
%Compute topdown unaries for latent structure
%--------------------------------------------------------------------------
%This function computes the unary potentials associated with a dictionary.
%Input : 
%_ obj of class jcas
%_ imsetname : string either 'training' or 'test'
%
% Output: 'topdown_unary','topdown_unary_h', 'topdown_count','td_clustered_h' save in
% '%d-topdown_unary-%d'



function compute_topdown_unaries(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end

load(sprintf(obj.topdown.dictionary.destmatpath,sprintf('topdown_dictionary_%d',obj.topdown.dictionary.params.size_dictionary)), 'C');

% Establish the set of images of interest
ids = obj.dbparams.(imgsetname);

fprintf('Compute topdown unaries:(total of %d images):    ', length(ids));

% for each image
for i=1:length(ids)
    fprintf('\b\b\b\b %03d',i);
    topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',obj.dbparams.image_names{ids(i)},obj.topdown.dictionary.params.size_dictionary));
    if (~exist(topdown_unary_filename, 'file') || obj.force_recompute.topdown_unary)
        
        %Load features/superpixels
        load(sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)})),'img_sp');
        load(sprintf(obj.topdown.features.destmatpath, sprintf('%s-topdown_features',obj.dbparams.image_names{ids(i)})),'feat_topdown');

        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=feat_topdown.descriptors;
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        A = vl_ikmeanspush(D,C);
        %        A = vl_ikmeanspush(uint8(D),int32(C));

        %Map from features to dictionary words
        td_clustered_h = A;

        % Compute sift unary costs and count
        topdown_unary = sparse(img_sp.spInd(locations), double(A), ones(length(locations),1), img_sp.nbSp,size(C,2));
      %  topdown_unary_h = sparse(img_sp.spInd(locations), double(A), ones(length(locations),1), img_sp.nbSp,size(C,2));
        topdown_count = full(sparse(img_sp.spInd(locations), ones(length(locations),1), ones(length(locations),1), img_sp.nbSp,1));

        save(topdown_unary_filename, 'topdown_unary', 'topdown_count');
    end
    
end
