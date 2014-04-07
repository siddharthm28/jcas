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
eps=1e-8;

%For each image in image set
for i=1:length(ids)
    fprintf(sprintf('\n load_unary_costs: loaded costs for %d of %d images',i,length(ids)));
    
    %Load image data
    img_filename=sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',...
        obj.dbparams.image_names{ids(i)}));
    sp_filename = sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',...
        obj.dbparams.image_names{ids(i)}));
    precomputed_unary_filename = sprintf(obj.unary.precomputed_path,...
        obj.dbparams.image_names{ids(i)});
    unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',...
        obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
    
    % Check if unary have already been computed
    
 %   load(unary_filename, 'unary');
    if (~exist(unary_filename, 'file') || obj.force_recompute.unary)
        
        tmp=load(img_filename,'img_info'); img_info=tmp.img_info;
        tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;

        % get the probabilities at the pixel level
        fid=fopen(precomputed_unary_filename,'r');
        tmp=fread(fid,inf,'float');
        fclose(fid);
        tmp=reshape(tmp,[obj.dbparams.ncat,img_info.Y*img_info.X]);
        tmp=tmp+eps;
        pixel_probability_estimates=tmp./repmat(sum(tmp),obj.dbparams.ncat,1);
        pixel_probability_estimates=pixel_probability_estimates';
        
        % use the superpixel info to calculate the info at the superpixel
        % level
        spInd=img_sp.spInd; nbsp=img_sp.nbSp;
        ind=reshape(spInd',numel(spInd),1);
        probability_estimates=zeros(nbsp,obj.dbparams.ncat);
        for j=1:nbsp
            probability_estimates(j,:)=mean(pixel_probability_estimates(ind==j,:));
        end
        unary=-log(probability_estimates);
        [~,predicted_label]=max(probability_estimates,[],2);
        
        save(unary_filename,'unary','predicted_label','probability_estimates',...
            'pixel_probability_estimates');
    end
end
end
