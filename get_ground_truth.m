function sp_gt=get_ground_truth(obj,image_name)
% function that computes the ground truth labels at the superpixel level
% for the image image_name

% get some parameters
ncat=obj.dbparams.ncat;
% get the pixel level gt
gt_file=sprintf(obj.dbparams.segpath,image_name);
tmp=load(gt_file,'seg_i'); gt=tmp.seg_i(:);
% get the superpixel
sp_file=sprintf(obj.superpixels.destmatpath,[image_name,'-imgsp']);
tmp=load(sp_file,'img_sp'); img_sp=tmp.img_sp;
sp=img_sp.spInd(:); nbsp=img_sp.nbSp;
% count labels for each superpixel
labels=zeros(nbsp,obj.dbparams.ncat);
ind=sub2ind([nbsp,ncat],sp(gt>0),double(gt(gt>0)));
labels=vl_binsum(labels,ones(size(ind)),ind);
[~,sp_gt]=max(labels,[],2);
