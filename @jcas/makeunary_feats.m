function makeunary_feats(obj,method_name,opt)
%Builds the parameters for specific unary features


obj.unary.features.method=method_name;

switch method_name
    case 'dsift'
        
        if nargin==2
            obj.unary.features.params.size_bin=12;
            obj.unary.features.params.descriptor_dimension=128;
        else
            obj.unary.features.params=opt;
        end
    case 'dsiftext'
        
        if nargin==2
            obj.unary.features.params.size_bin=12;
            obj.unary.features.params.descriptor_dimension=128;
        else
            obj.unary.features.params=opt;
        end
    otherwise
        error('Unary Feature method unknown, please add it to makesp.m file');
        
end
