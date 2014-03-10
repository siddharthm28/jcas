function build_dictionary_unary(obj,imgsetname)
%This function builds the dictionary of visual words for the unary
%potentials. Cluster the features with k-means.
%
%Input :
%_ obj of class jcas with all parameters
%_ imgsetname = 'training' or 'test'
% 
% Output: 'features', 'feats_chosen', 'feature_clusters' stored in
% 'dense_sift_dictionary'

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end

dictionary_filename = sprintf(obj.unary.dictionary.destmatpath,'unary_dictionary');

if (~exist(dictionary_filename, 'file') || (obj.force_recompute.dictionary_unary == 1))
    %Retrieve the indexes of the right image set (training or testing)
    ids = obj.dbparams.(imgsetname);

    load(sprintf(obj.unary.features.destmatpath,'num_features_per_image'),'num_features_per_images');

    
    %Test if the total number of features extracted from the images exceeds
    %the number of feature allowed.
    %If it doesn't then keep all the features, and if it does take a random
    %sample of the features extracted of the maximum size allowed
    if (sum(num_features_per_images(obj.dbparams.training))<obj.unary.dictionary.params.max_features_for_clustering)
        disp(sprintf('\n cluster_dense_sift_features: Total features (%d) is than the maximum allowed (%d).',...
            num_features,obj.unary.dictionary.params.max_features_for_clustering) );
        num_features = sum(num_features_per_images(obj.dbparams.training));
        randindex = [1:num_features];
    else
        disp(sprintf('\n cluster_dense_sift_features: Sampling %d features from a total of %d.',...
        obj.unary.dictionary.params.max_features_for_clustering, sum(num_features_per_images(obj.dbparams.training))));
        num_features = obj.unary.dictionary.params.max_features_for_clustering;
        randindex = randsample(num_features,num_features);
        randindex = sort(randindex);
    end
    %Stores the indexes of the chosen features
    feats_chosen = randindex;
    %----------------------------------------------------------------------
    %Build the matrix of the features to cluster
    %----------------------------------------------------------------------
    %Add type uint ?
    features = zeros(obj.unary.features.params.descriptor_dimension,num_features, 'uint8');
    num_features_added=1;
    fprintf('\n cluster_dense_sift_features (total of %d images):    ', length(ids));

    % Extract the features from each image (feature already stored)

    for i=1:length(ids)
        fprintf('\b\b\b\b%04d',i);
        load(sprintf(obj.unary.features.destmatpath,sprintf('%s-unfeat',obj.dbparams.image_names{ids(i)})));
        %Retrieve the indexes corresponding to the current image
        index = find(randindex<=img_feat.num_features);
        len = length(index);
        if (len>0)
            features(:,num_features_added:num_features_added+len-1) = (img_feat.descriptors(:,randindex(index))); %removed uint8 (already is ?)
            randindex = randindex(len+1:end) - img_feat.num_features;
            num_features_added = num_features_added+len;
        end
    end
    %----------------------------------------------------------------------
    %Build Dictionary with k-means
    %----------------------------------------------------------------------
    fprintf('\n Computing unary dictionary with kmeans')
    feature_clusters = vl_ikmeans(features,obj.unary.dictionary.params.num_bu_clusters) ;
    
    %Store the features/idexes of chosen features for clusturing/Clusters
    %centers given by k-means
    save(dictionary_filename,'features', 'feats_chosen', 'feature_clusters');
    
end
end

