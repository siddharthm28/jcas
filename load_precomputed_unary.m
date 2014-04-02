%--------------------------------------------------------------------------
% Load precomputed Unary costs
%--------------------------------------------------------------------------
%This function loads unary costs computed earlier and whose path is given
%Input :
% _ obj of class jcas
% _ imgsetname = 'training' or 'test' depending on image set used
% Output: 'unary','predicted_label','probability_estimates' saved in
% '%s-unary'

function load_precomputed_unary(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
ids = obj.dbparams.(imgsetname);

%For each image in image set
for i=1:length(ids)
    fprintf(sprintf('\n load_unary_costs: loaded costs for %d of %d images',i,length(ids)));
    
    %Load image data
    img_filename=sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',...
        obj.dbparams.image_names{ids(i)}));
    feat_filename = sprintf(obj.unary.precomputed_path,sprintf('%s.unary',...
        obj.dbparams.image_names{ids(i)}));
    unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',...
        obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
    
    % Check if unary have already been computed
    
 %   load(unary_filename, 'unary');
    if (~exist(unary_filename, 'file') || obj.force_recompute.unary)
        
        tmp=load(img_filename,'img_info');
        img_info=tmp.img_info;
        
        keyboard;
        
        fid=fopen(feat_filename,'r');
        a=fread(fid,inf,'float');
        a=reshape(a,[obj.dbparams.ncat,Y,X]);
        c=zeros(globalparms.ncat,Y*X);
        for ii=1:globalparms.ncat
            b=squeeze(a(ii,:,:))';
            c(ii,:)=-log(b(:));
        end
        c(c==inf)=5; %any number that's big enough        
        fclose(fid);
        
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