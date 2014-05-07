%--------------------------------------------------------------------------
%Computing pairwise costs
%--------------------------------------------------------------------------
%This function computes pairwise costs given the LUV distance and common
%length boundaries The pairwise
%Input :
% _ obj of class jcas
% _ imgsetname = 'training' or 'test' depending on image set used
% Output: 'pairwise', saved in '%s-pairwise'

function compute_pairwise_cost(obj,imgsetname)
%Compute the pairwise cost;

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
ids = obj.dbparams.(imgsetname);

% cform1=makecform('srgb2xyz');
% cform2=makecform('xyz2uvl');

%For each image in image set
for i=1:length(ids)
    fprintf(sprintf('compute_pairwise_costs: Computed costs for %d of %d images\n',i,length(ids)));
    
    %Load image data
    sp_filename = sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
    img_filename=sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',obj.dbparams.image_names{ids(i)}));
    pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
    
    % Check if unary and pairwise have already been computed
    clear pairwise;
    %load(pairwise_filename, 'pairwise');
    if (~exist(pairwise_filename, 'file') || obj.force_recompute.pairwise)
        
        tmp=load(img_filename,'img_info'); img_info=tmp.img_info;
        tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
        

        % Compute the pairwise terms with LUV distance
        tmp=vl_xyz2luv(vl_rgb2xyz(img_sp.Iseg));    % rgb2luv using vlfeat
%         tmp(isnan(tmp(:)))=0;
%         tmp=applycform(applycform(img_sp.Iseg,cform1),cform2); % rgb2uvl using matlab
        I_Luv = [reshape(tmp,img_info.X*img_info.Y,3) reshape(img_sp.spInd,img_info.X*img_info.Y,1)];
        I_Luv(isnan(I_Luv(:)))=0;
        [~,index] = unique(I_Luv(:,4));
        I_Luv = I_Luv(index,1:3);
        pairwise = img_sp.length_common_boundary./(1+(sum((I_Luv(img_sp.edges(:,1),:) - I_Luv(img_sp.edges(:,2),:)).^2,2)).^0.5);
        pairwise = sparse([img_sp.edges(:,1); img_sp.edges(:,2)], [img_sp.edges(:,2); img_sp.edges(:,1)], [pairwise; pairwise], img_sp.nbSp, img_sp.nbSp);
        save(pairwise_filename,'pairwise');
    end
end

end
