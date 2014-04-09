%--------------------------------------------------------------------------
%Top down dictionary building
%--------------------------------------------------------------------------
%This function computes the topdown dictionary with the associated
%features (sparse sift by default).
% Input : obj of class jcas
% Output: 'C', 'A' saved in 'sparse_topdown_dictionary_%d'

function build_topdown_dictionary(obj)
if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
sparse_dictionary_filename = sprintf(obj.topdown.dictionary.destmatpath,sprintf('topdown_dictionary_%d',obj.topdown.dictionary.params.size_dictionary));

if (~exist(sparse_dictionary_filename, 'file') || obj.force_recompute.topdown_dictionary)

    %Load the descriptors previously computed
    tmp=load(sprintf(obj.topdown.features.destmatpath,'topdown_descriptors_training'), 'feats', 'siftlbls');
    feats=tmp.feats; siftlbls=tmp.siftlbls;

    % Construct cluster indexes from descriptors labels
    index = (mod(siftlbls(2,:),2)==1);

    % Cluster features using k-means
    [C,A] = vl_ikmeans(feats(:,index),obj.topdown.dictionary.params.size_dictionary);

    save(sparse_dictionary_filename, 'C', 'A');
end

end
