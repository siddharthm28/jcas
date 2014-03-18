function words= wordsFnCP(obj,model,x,y)
%w{i} contains curent word assigment for image i (best predictor)
ncat=obj.dbparams.ncat;
nwords=obj.topdown.dictionary.params.size_dictionary;
featdim=obj.topdown.features.params.dimension;
sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
tdfeat_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
load(tdfeat_filename,'feat_topdown');
load(sp_filename,'img_sp');

switch obj.mode
    case 7
        latentOffset=2+ncat*(nwords+1);
        alphaTd=model.w(3:latentOffset-ncat);
        %Descriptor in each column
        alphaMat=reshape(alphaTd,[nwords,ncat]);
        clusterCenters=reshape(model.w(latentOffset+1:end),[featdim,nwords]);
        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=feat_topdown.descriptors;
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        [topdown_unary,topdown_count,z]=infer_words(y,alphaMat,clusterCenters,D,locations,img_sp);
        words=z;
    case 8
        nn=obj.topdown.latent.params.n_neighbor;
        nn_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-ipAdj-%d',x,nn));
        load(nn_filename);
        latentOffset=2+ncat*(nwords+1);
        wordsOffset=latentOffset+obj.topdown.features.params.dimension*obj.topdown.dictionary.params.size_dictionary;
        alphaTd=model.w(3:latentOffset-ncat);
        %Descriptor in each column
        alphaMat=reshape(alphaTd,[nwords,ncat]);
        clusterCenters=reshape(model.w(latentOffset+1:wordsOffset),[featdim,nwords]);
        wordsPairwise=reshape(model.w(wordsOffset+1:end),[nwords,nwords]);
        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=feat_topdown.descriptors;
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        [topdown_unary,topdown_count,z]=infer_words(y,alphaMat,clusterCenters,D,locations,img_sp,wordsPairwise,adj);
        words=z;
    otherwise
        error('Wrong mode somewhere...')
end

