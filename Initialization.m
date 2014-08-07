function expJCAS=Initialization(db_name,mode,pre_unary,pre_sp,recompute,optimization_type)
% Function that Initializes the framework for dataset db_name under type mode
% also pass if you want to use precomputed unaries and superpixels or not
clc; close all;
if(~exist('db_name','var') || isempty(db_name))
    db_name='inria-graz';
end
if(~exist('mode','var') || isempty(mode))
    mode=1;
end
if(~exist('pre_unary','var') || isempty(pre_unary))
    pre_unary=0;
end
if(~exist('pre_sp','var') || isempty(pre_sp))
    pre_sp=0;
end
if(~exist('recompute','var') || isempty(recompute))
    recompute=0;
end
% Create an object of class jcas.
expJCAS = jcas();
expJCAS.makedb(db_name);
if(~pre_sp)
    % Default Quickshift superpixels
    expJCAS.makesp('Quickshift');
else
    % Using ucm superpixels
    options.path=get_dataset_path('voc2012-ucm');
    options.threshold=12;
    expJCAS.makesp('ucm',options);
end
% dsift feature for unary options
expJCAS.makeunary_feats('dsiftext');
% mode for unary and pairwise terms
expJCAS.mode = mode; % 0-U 1-(U+P)
if(pre_unary)
    % use precomputed unaries from textonboost
    expJCAS.unary.precomputed=1;
    expJCAS.unary.precomputed_path=get_dataset_path([db_name,'-texton']);
end
% expJCAS.force_recompute.unary=1;
% kernel svm for bottom-up unary
expJCAS.unary.svm.params.kernel_type = 4; % chi2-rbf kernel
expJCAS.unary.svm.params.rbf = (expJCAS.unary.svm.params.kernel_type == 4);
% determine C value
expJCAS.unary.svm.params.cross = 10 ;
% gamma value for the rbf^2 kernel.
expJCAS.unary.svm.params.gamma = [] ;
% balancing strategy (0 or 1)
expJCAS.unary.svm.params.balance = 0 ;
% return probability value instead of decision value (0 or 1)
expJCAS.unary.svm.params.probability = 1 ;
expJCAS.unary.svm.params.type = 'C';
expJCAS.unary.svm.params.nu = 0.5;
expJCAS.unary.svm.params.C = 1;
% maximum number of features used for clustering (quanization)
expJCAS.unary.dictionary.params.max_features_for_clustering = 1e5;
% number of clusters for bottom up unary quantization
expJCAS.unary.dictionary.params.num_bu_clusters = 400;
% maximum number of histograms per class (used to balance the training)
expJCAS.unary.svm.params.max_hists_per_class_for_training = 750;
% maximum number of histogram per image
if(expJCAS.dbparams.num_images < 100)
    expJCAS.unary.svm.trainingset.params.hists_per_image = 100;
else
    expJCAS.unary.svm.trainingset.params.hists_per_image = 10;
end
expJCAS.unary.SPneighboorhoodsize=4;
% Slack variable for the Cutting Plane algorithm
% used for the segmentation constraints, this value
% will be divided by the number of training images
expJCAS.optimisation.params.eps = 0.01;
expJCAS.optimisation.method = 'CP';
expJCAS.optimisation.params.lossFnCP_name = 'hamming';
% SVM_STRUCT_ARGS
expJCAS.optimisation.params.args = '-w 0 -c 1.0';
% Callbacks functions :
switch optimization_type
    case 'nslack'
        expJCAS.optimisation.params.C1 = 1e6;
        expJCAS.optimisation.params.max_iter=1e2;
        expJCAS.optimisation.svm_struct=@(param,miter,C) svm_struct_mod(param,miter,C);
        expJCAS.optimisation.latent_svm_struct=@(param,miter,C) latent_svm_struct_mod(param,miter,C);
    case '1slack'
        expJCAS.optimisation.params.C1 = 1e6;
        expJCAS.optimisation.params.max_iter=1e3;
        expJCAS.optimisation.svm_struct=@(param,miter,C) svm_struct_mod_1slack(param,miter,C);
        expJCAS.optimisation.latent_svm_struct=@(param,miter,C) latent_svm_struct_mod_1slack(param,miter,C);
    case 'ssg'
        expJCAS.optimisation.params.C1=0.2;
        expJCAS.optimisation.params.max_iter=1e3;
        expJCAS.optimisation.svm_struct=@(param,miter,C) mySSVM(param,miter,C,'ssg');
    case 'fw'
        expJCAS.optimisation.params.C1=0.2;
        expJCAS.optimisation.params.max_iter=1e3;
        expJCAS.optimisation.svm_struct=@(param,miter,C) mySSVM(param,miter,C,'fw');
    case 'bcfw'
        expJCAS.optimisation.params.C1=0.2;
        expJCAS.optimisation.params.max_iter=1e3;
        expJCAS.optimisation.svm_struct=@(param,miter,C) mySSVM(param,miter,C,'bcfw');
end
expJCAS.optimisation.featureCB = @(parm,x,y) featureFnCP(expJCAS,parm,x,y);
expJCAS.optimisation.lossCB = @(parm,y,yhat) lossFnCP(expJCAS,parm,y,yhat);
expJCAS.optimisation.constraintCB = @(parm,model,x,y) constraintFnCP(expJCAS,parm,model,x,y);
if(expJCAS.mode==1)
    expJCAS.optimisation.params.E_dim = 2;
end
if(expJCAS.mode>=2)
    % -------------------------------------------------------------------------
    % Top Down options
    % -------------------------------------------------------------------------
    expJCAS.maketd_feats('SIFT');
    expJCAS.topdown.dictionary.params.size_dictionary=20;
    expJCAS.topdown.features.params.max_per_image='none';
    expJCAS.topdown.features.params.dimension=128;
end
if(expJCAS.mode>=7)
    % -------------------------------------------------------------------------
    % Latent options
    % -------------------------------------------------------------------------
    expJCAS.topdown.latent.params.n_neighbor=4;

    % -------------------------------------------------------------------------
    % Latent options
    % -------------------------------------------------------------------------
    %expJCAS.init.vals.UP=
    %expJCAS.init.vals.labelcost=
    %expJCAS.init.vals.alphaMat=
end

expJCAS.init.given=0;
switch recompute
    case 0  % reset
        expJCAS.force_recomputation('reset');
    case 1  % all    
        expJCAS.force_recomputation('all');
    case 2  % unary
        expJCAS.force_recomputation('unary');
    case 3  % topdown
        expJCAS.force_recomputation('topdown');
    case 4  % optimization
        expJCAS.force_recompute.optimisation=1;
end
expJCAS.train;
expJCAS.testing;

fprintf('\n Job done\n');
