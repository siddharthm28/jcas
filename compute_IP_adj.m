function compute_IP_adj(obj,imgsetname)

num_imgs = length(obj.dbparams.(imgsetname));
imgset=obj.dbparams.(imgsetname);
for i=1:num_imgs
    x=obj.dbparams.image_names{imgset(i)};
    % Need to store adjacency matrix for interest points
    sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
    tdfeat_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
    nn=obj.topdown.latent.params.n_neighbor;
    nn_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-ipAdj-%d',x,nn));
    
    if ~exist(nn_filename,'file') || obj.force_recompute.latent_adj==1
        load(tdfeat_filename,'feat_topdown');
        load(sp_filename,'img_sp');
        %TD Features
        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=double(feat_topdown.descriptors);
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        [I,J]=ind2sub(size(img_sp.spInd),locations);
        I=I';
        J=J';
        IDX=knnsearch([I,J],[I,J],'K',nn+1);
        edge1=repmat(1:length(locations),[nn,1]);
        edge1=reshape(edge1,[1,length(locations)*nn]);
        edge2=reshape(IDX(:,2:end),[1,nn*length(locations)]);
        adj=sparse(edge1,edge2,ones(size(edge1)),length(locations),length(locations));
        adj=adj+adj';
        adj=adj-diag(diag(adj));
        save(nn_filename,'adj');
    end
end
end

