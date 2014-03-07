function feat = computeFeatures_unary(obj,I)
%Given the type of features specified in obj, compute the features and
%store results in struct
% Input : 
% _ obj of type jcas
% Output :
% _ feat struct containing informations about features (depend on choice)
feat=struct();

switch obj.unary.features.method
    case 'dsiftext' %Require vl_feat
        %dsift will be computed on a larger image with padarray
        extNb=(3/2)*obj.unary.features.params.size_bin; 
        im=padarray(I,[extNb,extNb],'symmetric');
        [extlocations,feat.descriptors] = vl_dsift(single(rgb2gray(im)), 'size', obj.unary.features.params.size_bin);
        feat.locations=extlocations-extNb;
        feat.num_features=size(feat.descriptors,2);

    case 'dsift' %Require vl_feat
        %dsift will be computed on a larger image with padarray
        [feat.locations,feat.descriptors] = vl_dsift(single(rgb2gray(I)), 'size', obj.unary.features.params.size_bin);
        feat.num_features=size(feat.descriptors,2);

    otherwise
        error('Unknown type of feature. Please add it to the appropriate files');
end

end

