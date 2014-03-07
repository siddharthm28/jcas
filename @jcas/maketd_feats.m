function maketd_feats(obj,method)
%Building the parameters given the name of the method
obj.topdown.features.method=method;
switch method
    case 'SIFT'
        obj.topdown.features.params.dimension=128;
end


end

