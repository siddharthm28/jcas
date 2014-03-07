function words= wordsFnCP(param,model,x,y)
%w{i} contains curent word assigment for image i (best predictor)

ncat=param.tmp.ncat;
nwords=param.tmp.nwords;
featdim=param.tmp.featdim;
sp_filename=sprintf(param.tmp.superpixels.destmatpath,sprintf('%s-imgsp',x));
tdfeat_filename=sprintf(param.tmp.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
load(tdfeat_filename,'feat_topdown');
load(sp_filename,'img_sp');
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


end

