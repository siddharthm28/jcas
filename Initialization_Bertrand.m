clc;
close all;
clear;

disp('Preparing setup...');
addpath(genpath('/cis/home/brondep1/JCaS/JCaSLib/'));
run('/cis/home/brondep1/JCaS/JCaSLib/vlfeat-0.9.16/toolbox/vl_setup');
run('/cis/home/brondep1/JCaS/JCaSLib/blocks/blocks_setup');
disp('Setup done');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create an object of class jcas.
expJCAS=jcas();

%--------------------------------------------------------------------------
% Building the folders for experiment result storage
%--------------------------------------------------------------------------
%Main folder (that contains for a given database all the results and the
%files that stores all the previous experiments parameters.

expJCAS.makedb('graz02');
%expJCAS.dbparams.destmatpath='/Users/Bertrand/Documents/X/Stage3A/DB/GrazCis/results/';

expJCAS.dbparams.destmatpath=['/cis/home/luca/jcas_new/Graz/results/%s.mat'];
%--------------------------------------------------------------------------
% Custom folders for results
%--------------------------------------------------------------------------
% Don't modify this part unless you know what you are doing.
% Use this if you already have results that you want to use for this
% experiment, preformatted according to the matlab programs.
% 
% %Superpixels
% expJCAS.superpixels.destmatpath='';
% 
% %Unary potential directory
% expJCAS.unary.destmatpath='';
% 
% %Features used for unary computation
% expJCAS.unary.features.destmatpath='';
% expJCAS.unary.dictionary.destmatpath='';
% 
% %Pairwise potentials
% expJCAS.pairwise.destmatpath='';
% 
% %Topdown potentials
% expJCAS.topdown.features.destmatpath='';
% expJCAS.topdown.dictionary.destmatpath='';
% expJCAS.topdown.destmatpath='';
%
% %Latent Topdown potentials (latent dictionary)
% expJCAS.topdown_latent.destmatpath='';

%Make paths
%expJCAS.makedestpath(['/Users/Bertrand/Documents/X/Stage3A/DB/GrazCis/testresults/']);
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
%
%--------------------------------------------------------------------------
%Default Quickshift superpixels
expJCAS.makesp('Quickshift');


% -------------------------------------------------------------------------
% Unary Feature
% -------------------------------------------------------------------------

% Dsift feature for unary options
expJCAS.makeunary_feats('dsiftext');

% -------------------------------------------------------------------------
% Mode 
% -------------------------------------------------------------------------
%Modify only if default not enough
% 0 Unary
% 1 Unary + Pairwise 
% 2 Unary + Pairwise + TD \sum_l alpha_l^T h_l + beta_l delta(||h_l||>0)
% 3 Unary + Pairwise + TD \sum_l alpha_l^T h_l + beta_l delta(l in labeling)
% 4 Unary + Pairwise + TD \sum_l alpha_l^T h_l + beta_l * ||h_l||
% 5 Unary + Pairwise + beta_l delta(l in L)
% 6 Unary + Pairwise + TD intersection kernel (Dheeraj's paper)
expJCAS.mode=2;%(U+P)


% -------------------------------------------------------------------------
% Bottom Up Unary options
% -------------------------------------------------------------------------
% SVM kernel (requires BLOCKS toolbox)

% 1- linear; 2- intersection; 3- Chi2; 4- Chi2-RBF
expJCAS.unary.svm.params.kernel_type   = 4;
expJCAS.unary.svm.params.rbf = (expJCAS.unary.svm.params.kernel_type == 4);

% N value for the N-Fold crossvalidation used to
% determine C value
expJCAS.unary.svm.params.cross         = 10 ;

% gamma value for the rbf^2 kernel.
expJCAS.unary.svm.params.gamma                        = [] ;

% balancing strategy (0 or 1)
expJCAS.unary.svm.params.balance                      = 0 ;

% print debug info (0 or 1)
%expJCAS.unary.svm.params.debug                        = 0 ;

% return probability value instead of decision
% value (0 or 1)
expJCAS.unary.svm.params.probability                  = 1 ;

expJCAS.unary.svm.params.type = 'C';
%expJCAS.unary.svm.params.verb=0;
expJCAS.unary.svm.params.nu=0.5;
expJCAS.unary.svm.params.C=1;

% maximum number of features used for clustering
% (quanization)
expJCAS.unary.dictionary.params.max_features_for_clustering      = 2*50000;

% number of clusters for bottom up unary
% quantization
expJCAS.unary.dictionary.params.num_bu_clusters                  = 400;

% maximum number of histograms per class (used to
% balance the training)
expJCAS.unary.svm.params.max_hists_per_class_for_training = 750;

% maximum number of histogram per image
expJCAS.unary.svm.trainingset.params.hists_per_image                  = 5;

expJCAS.unary.SPneighboorhoodsize=4;

% -------------------------------------------------------------------------
% Cutting Plane algorithm
% -------------------------------------------------------------------------

% Slack variable for the Cutting Plane algorithm
% used for the segmentation constraints, this value
% will be divided by the number of training images
expJCAS.optimisation.params.C1 = 1000000; % Divided by number of training samples
expJCAS.optimisation.params.max_iter=50;
expJCAS.optimisation.method='CP';
expJCAS.optimisation.params.lossFnCP_name='hamming';
%SVM_STRUCT_ARGS
expJCAS.optimisation.params.args= [' -c ' num2str(expJCAS.optimisation.params.C1), ' -o 2 -t 0']; % Don't remove -t 0
%Callbacks functions :
expJCAS.optimisation.featureCB=@(parm,x,y) featureFnCP(expJCAS,parm,x,y);
expJCAS.optimisation.lossCB=@(parm,y,yhat) lossFnCP(expJCAS,parm,y,yhat);
expJCAS.optimisation.constraintCB=@(parm,model,x,y) constraintFnCP(expJCAS,parm,model,x,y);
expJCAS.optimisation.params.eps=0.001;

% -------------------------------------------------------------------------
% Top Down options
% -------------------------------------------------------------------------
expJCAS.maketd_feats('SIFT');
expJCAS.topdown.dictionary.params.size_dictionary=20;
expJCAS.topdown.features.params.max_per_image='none';

% -------------------------------------------------------------------------
% What to do ?
% -------------------------------------------------------------------------
keyboard;
expJCAS.train;
expJCAS.testing;



fprintf('\n Job done\n');
