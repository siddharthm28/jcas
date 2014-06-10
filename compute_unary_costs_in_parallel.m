%--------------------------------------------------------------------------
%Computing unary costs
%--------------------------------------------------------------------------
%This function computes unary and pairwise costs given the svm previously
%trained on the histograms of words ofr unary potentials. The pairwise
%Input :
% _ obj of class jcas
% _ imgsetname = 'training' or 'test' depending on image set used
% Output: 'unary','predicted_label','probability_estimates' saved in
% '%s-unary'

function compute_unary_costs_in_parallel(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
%Load previously trained svm for unary potentials
tmp=load(sprintf(obj.unary.svm.destmatpath,sprintf('svm_data-%d',obj.unary.SPneighboorhoodsize)),'svm');
svm=tmp.svm;
ids = obj.dbparams.(imgsetname);

%For each image in image set
fprintf('\n');
parfor i=1:length(ids)
    process_image(obj,ids(i));
end

function process_image(obj,ind)
fprintf('compute_unary_costs: Computed costs for image %d \n',ind);

%Load image data
feat_filename = sprintf(obj.unary.features.destmatpath,sprintf('%s-unfeat',obj.dbparams.image_names{ind}));
sp_filename = sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ind}));
img_filename=sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',obj.dbparams.image_names{ind}));
unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ind},obj.unary.SPneighboorhoodsize));

% Check if unary have already been computed

%   load(unary_filename, 'unary');
if (~exist(unary_filename, 'file') || obj.force_recompute.unary)

    tmp=load(img_filename,'img_info'); img_info=tmp.img_info;
    tmp=load(feat_filename,'img_feat'); img_feat=tmp.img_feat;
    tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;

    % Compute the unaries
    tmp=load(sprintf(obj.unary.destmatpath,sprintf('%s-histogram-neighborhood-%d',obj.dbparams.image_names{ind},obj.unary.SPneighboorhoodsize)),'superpixel_histograms');
    superpixel_histograms=tmp.superpixel_histograms;

    %Give the probability estimates (potentials) and predicted labels
    [predicted_label,probability_estimates] = test_kernel_svm(superpixel_histograms, svm.training_SVs, obj.unary.svm.params.kernel_type, svm.libsvm_cl, svm.gamma);
    %Potentials = - log probability estimates
    unary = probability_estimates;
    unary(:,svm.libsvm_cl.Label) = -log(probability_estimates);
    save(unary_filename,'unary','predicted_label','probability_estimates');
end
