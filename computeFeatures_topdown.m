function feat = computeFeatures_topdown(obj,I)
%Given the type of features specified in obj, compute the features and
%store results in struct
% Input : 
% _ obj of type jcas
% Output :
% _ feat struct containing informations about features (depend on choice)
feat=struct();

switch obj.topdown.features.method
    case 'SIFT' %Require vl_feat
[feat.locations,feat.descriptors] = vl_sift(single(rgb2gray(I)));
        
        
    otherwise
        error('Unknown type of feature. Please add it to the appropriate files');
end

end

