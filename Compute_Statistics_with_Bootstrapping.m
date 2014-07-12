function op=Compute_Statistics_with_Bootstrapping(obj,path)
%Given the testing set directory compute statistics for the results
%path should finish with %s.mat and usually obj.test.destmatpath. This
%function computes only the Intersection over Union score TP/(TP+FP+FN)
%aggregate and per image at the superpixel and pixel level. Also, it does
%this with bootstrapping to generate a mean score with a 95% confidence
%interval

stat_file=sprintf(path,'stats');
ids=obj.dbparams.test;
ncat=obj.dbparams.ncat;
num_images=length(ids);

cmatrixSP=zeros(ncat,ncat,num_images);
cmatrixP=zeros(ncat,ncat,num_images);

for i=1:num_images
    img_gt=sprintf(obj.dbparams.segpath,obj.dbparams.image_names{ids(i)});
    img_pred=sprintf(path,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
    img_predP=sprintf(path,sprintf('%s-seg_resultP',obj.dbparams.image_names{ids(i)}));
    
    tmp=load(img_gt,'seg_i'); pixel_gt=tmp.seg_i(:);
    tmp=load(img_pred,'seg'); seg=tmp.seg(:);
    tmp=load(img_predP,'pixelSeg'); pixelSeg=tmp.pixelSeg(:);
    gt=get_ground_truth(obj,obj.dbparams.image_names{ids(i)}); gt=gt(:);
    
    indNoVoidSP=find(gt);
    indNoVoidP=find(pixel_gt);
    
    indCMSP=sub2ind([ncat,ncat],double(gt(indNoVoidSP)),double(seg(indNoVoidSP)));
    indCMP=sub2ind([ncat,ncat],double(pixel_gt(indNoVoidP)),double(pixelSeg(indNoVoidP)));
    
    cmatrixSP(:,:,i)=vl_binsum(zeros(ncat),ones(size(indCMSP)),indCMSP);
    cmatrixP(:,:,i)=vl_binsum(zeros(ncat),ones(size(indCMP)),indCMP);
    
end

% compute the I/U score at the superpixel level
[rc2_SP,r_int_SP]=compute_scores(cmatrixSP);
% compute the I/U score at the pixel level
[rc2_P,r_int_P]=compute_scores(cmatrixP);

fprintf('\nWithout any bootstrapping \n');
% fprintf('\n At superpixel level \n');
% fprintf('Intersection by Union (aggregate) \n');
% display_results(r_int_SP);
% fprintf('Intersection by Union (per image) \n');
% display_results(rc2_SP);

fprintf('\nPer pixel numbers\n');
fprintf('Intersection by Union (aggregate) \n');
display_results(r_int_P);
% fprintf('Intersection by Union (per image) \n');
% display_results(rc2_P);

% Bootstrapping parameters
B=1e3; alpha=0.3173;
% compute the I/U score at the superpixel level with bootstrapping
[rc2_SP,ci_SP,r_int_SP,ci_int_SP]=compute_scores_with_bootstrapping(cmatrixSP,B,alpha);
% compute the I/U score at the pixel level with bootstrapping
[rc2_P,ci_P,r_int_P,ci_int_P]=compute_scores_with_bootstrapping(cmatrixP,B,alpha);

fprintf('\n\nWith bootstrapping \n');
% fprintf('\n At superpixel level \n');
% fprintf('Intersection by Union (aggregate) \n');
% display_results2(r_int_SP,ci_int_SP);
% fprintf('Intersection by Union (per image) \n');
% display_results2(rc2_SP,ci_SP);

fprintf('\nPer pixel numbers\n');
fprintf('Intersection by Union (aggregate) \n');
display_results2(r_int_P,ci_int_P);
% fprintf('Intersection by Union (per image) \n');
% display_results2(rc2_P,ci_P);

save(stat_file,'cmatrixSP','cmatrixP');
op=r_int_P;
end

function [rc2,r_int]=compute_scores(cmatrix)
% code to compute the aggregate and per image scores given confusion matrix
% for every image
ncat=size(cmatrix,1); num_images=size(cmatrix,3);
rc2=zeros(ncat,num_images);
counts=zeros(ncat,num_images);
for i=1:num_images
    c=cmatrix(:,:,i);
    rc2(:,i)=(diag(c)./(sum(c,2)+sum(c)'-diag(c)));
    counts(:,i)=(sum(c,2)>0);
end
rc2(isnan(rc2))=0;
rc2=sum(rc2.*counts,2)./sum(counts,2);

c = sum(cmatrix,3); 
r_int = (diag(c)./(sum(c,2)+sum(c)'-diag(c)));
end

function [rc2,ci_rc2,r_int,ci_r_int]=compute_scores_with_bootstrapping(cmatrix,B,alpha)
% code to compute the aggregate and per image scores given confusion matrix
% for every image with bootstapping over B samples with replacement. Also
% return the confidence intervals or error bars for the results
ncat=size(cmatrix,1); num_images=size(cmatrix,3);
rc2=zeros(ncat+1,B); r_int=zeros(ncat+1,B);
for b=1:B
    % sample with replacement
    ind=randsample(num_images,num_images,1);
    % generate temporary confusion matrices using this sampling
    tmp_cmatrix=cmatrix(:,:,ind);
    % generate the scores for this temporary confusion matrix and store
    [rc2(1:ncat,b),r_int(1:ncat,b)]=compute_scores(tmp_cmatrix);
    rc2(ncat+1,b)=mean(rc2(1:ncat,b)); 
    r_int(ncat+1,b)=mean(r_int(1:ncat,b));
end
ci_rc2=zeros(ncat,2); ci_r_int=zeros(ncat,2);
for i=1:ncat+1
    tmp=sort(rc2(i,:)); 
    ci_rc2(i,1)=quantile(tmp,alpha/2);
    ci_rc2(i,2)=quantile(tmp,1-alpha/2);
    tmp=sort(r_int(i,:));
    ci_r_int(i,1)=quantile(tmp,alpha/2);
    ci_r_int(i,2)=quantile(tmp,1-alpha/2);
end
rc2=mean(rc2,2);
r_int=mean(r_int,2);
end

function display_results(r_acc)
for i=1:length(r_acc)
    fprintf('%3.2f \t',100*r_acc(i));
end
fprintf('\nMean= %3.2f \n',100*mean(r_acc));
end

function display_results2(r_acc,ci)
for i=1:length(r_acc)-1
    fprintf('%3.2f (%3.2f-%3.2f) \t',100*r_acc(i),100*ci(i,1),100*ci(i,2));
end
fprintf('\nMean= %3.2f (%3.2f-%3.2f) \n',100*r_acc(end),100*ci(end,1),100*ci(end,2));
end
