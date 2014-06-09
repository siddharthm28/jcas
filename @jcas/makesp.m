function makesp(obj,method_name,options)
%Function designed to automatically generate the right parameters for the
%superpixels according to the method name.
%Input : obj of class jcas, method_name string.
%No output, just a modified obj according to method_name

obj.superpixels.method=method_name;

switch method_name
    case 'Quickshift'
        
        if nargin==2
            % -------------------------------------------------------------
            % quickshift superpixel options (Requires vl_feat)
            % -------------------------------------------------------------
            
            % vl_quickseg maxdist, it's the maximum distance between points
            % in the feature space that may be linked if the density is
            % increased
            obj.superpixels.params.tau = 8; % PREV params.tau
            
            % vl_quickseg kernelsize, it's the size of the kernel used to
            % estimate the density
            obj.superpixels.params.kernelsize = 2; % PREV params.sigma
            
            % vl_quickseg ratio value, it's a tradeoff between color
            % importance and spatial importance (larger values give more
            % importance to color)
            obj.superpixels.params.ratio = 0.5; % PREV params.lambda
        else
            obj.superpixels.params=options;
        end
    case 'ucm'
        % uses the superpixels computed using the gpb-owt-ucm method. 
        % The only parameter that needs to be specified once the ucm is
        % computed is the threshold at which to compute the superpixels. 
        % The assumption is that these have been computed already and we
        % are simply reading off the output to generate our superpixels.
        % So, the path to the precomputations needs to be specified. These
        % two things need to be passed via options.
        if(nargin==2)
            error(['To use this option, you need to mention path to the',...
                'precomputed superpixels and a threshold parameter']);
        end
        obj.superpixels.params=options;
    otherwise
        error('Superpixel method unknown, please add it to makesp.m file');
        
end
