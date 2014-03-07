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

function compute_unary_costs(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
%Load previously trained svm for unary potentials
load(sprintf(obj.unary.svm.destmatpath,sprintf('svm_data-%d',obj.unary.SPneighboorhoodsize)),'svm');
ids = obj.dbparams.(imgsetname);

%For each image in image set
for i=1:length(ids)
    fprintf(sprintf('\n compute_unary_costs: Computed costs for %d of %d images',i,length(ids)));
    
    %Load image data
    feat_filename = sprintf(obj.unary.features.destmatpath,sprintf('%s-unfeat',obj.dbparams.image_names{ids(i)}));
    sp_filename = sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
    img_filename=sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',obj.dbparams.image_names{ids(i)}));
    unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
    
    % Check if unary have already been computed
    
 %   load(unary_filename, 'unary');
    if (~exist(unary_filename, 'file') || obj.force_recompute.unary)
        
        load(img_filename,'img_info');
        load(feat_filename,'img_feat');
        load(sp_filename,'img_sp');
        
        % Compute the unaries
        %Check superpixels neighboorhood size
       % if (obj.unary.SPneighboorhoodsize ==0)
        %    load(sprintf(obj.unary.destmatpath,sprintf('%s-SP_histogram',obj.dbparams.image_names{ids(i)})),'superpixel_histograms');
        %else
            load(sprintf(obj.unary.destmatpath,sprintf('%s-histogram-neighborhood-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize)),'superpixel_histograms');
        %end
        
        %Give the probability estimates (potentials) and predicted labels
        [predicted_label,probability_estimates] = test_kernel_svm(superpixel_histograms, svm.training_SVs, obj.unary.svm.params.kernel_type, svm.libsvm_cl, svm.gamma);
        %Potentials = - log probability estimates
        unary = probability_estimates;
        unary(:,svm.libsvm_cl.Label) = -log(probability_estimates);
        %unary_size = size(unary)    ;
        %         % If superpixel belong to void class give them max probability
        %         if (globalparms.use_gt_for_void == 1)
        %             unary(:,SOMETHING_GT == VOID) = 0; % LUCA: Patrick what is ground truth?
        %         end
                
        save(unary_filename,'unary','predicted_label','probability_estimates');
    end
end
end