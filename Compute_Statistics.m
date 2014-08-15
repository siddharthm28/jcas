function Compute_Statistics(obj,path)
%Given the testing set directory compute statistics for the results
%path should finish with %s.mat and usually obj.test.destmatpath

stat_file=sprintf(path,'stats');
ids=obj.dbparams.test;

cmatrixSP=zeros(obj.dbparams.ncat,obj.dbparams.ncat,length(ids));
cmatrixP=zeros(obj.dbparams.ncat,obj.dbparams.ncat,length(ids));

for i=1:length(ids)
    img_gt=sprintf(obj.dbparams.segpath,obj.dbparams.image_names{ids(i)});
    img_pred=sprintf(path,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
    img_predP=sprintf(path,sprintf('%s-seg_resultP',obj.dbparams.image_names{ids(i)}));
    
    load(img_gt,'seg_i'); seg_i=seg_i(:);
    load(img_pred,'seg'); seg=seg(:);
    load(img_predP,'pixelSeg'); pixelSeg=pixelSeg(:);
    gt=get_ground_truth(obj,obj.dbparams.image_names{ids(i)}); gt=gt(:);
    
    indNoVoidP=find(seg_i(:));
    indNoVoidSP=find(gt);
    
    %indCM=sub2ind([obj.dbparams.ncat,obj.dbparams.ncat],double(seg_i(:)),double(pixelSeg(:)));
    %indCMP=sub2ind([obj.dbparams.ncat,obj.dbparams.ncat],double(superpixel_histograms(end,:)'),double(seg(:)));
    indCM=sub2ind([obj.dbparams.ncat,obj.dbparams.ncat],double(seg_i(indNoVoidP)),double(pixelSeg(indNoVoidP)));
    indCMP=sub2ind([obj.dbparams.ncat,obj.dbparams.ncat],double(gt(indNoVoidSP)),double(seg(indNoVoidSP)));
    
    
    cmatrixSP(:,:,i)=vl_binsum(zeros(obj.dbparams.ncat,obj.dbparams.ncat),ones(size(indCMP)),indCMP);
    cmatrixP(:,:,i)=vl_binsum(zeros(obj.dbparams.ncat,obj.dbparams.ncat),ones(size(indCM)),indCM);
    
end

idx=eye(obj.dbparams.ncat); idx=(idx(:)>0);
tot = squeeze(sum(cmatrixSP,2));
gt=reshape(cmatrixSP,[obj.dbparams.ncat^2,length(ids)]);
gt=gt(idx,:);
tot2 = squeeze(sum(cmatrixSP,2)) + squeeze(sum(cmatrixSP,1))-gt;
nr2 = 0;
rc=zeros(1,obj.dbparams.ncat);
rc2=zeros(1,obj.dbparams.ncat);
for j = 1:obj.dbparams.ncat
    nr = cmatrixSP(j,j,:);
    nr2 = nr2 + nr;
    ind = find(tot(j,:)>0);
    rc(j) =  mean(squeeze(nr(ind))'./squeeze(tot(j,ind)));
    ind2 = find(tot2(j,:)>0);
    rc2(j) = mean(squeeze(nr(ind2))'./squeeze(tot2(j,ind2)));
end

rc = [rc(:)' mean(squeeze(nr2)'./sum(squeeze(sum(cmatrixSP,1)),1))];

c = sum(cmatrixSP,3); 
r_acc = (diag(c)./sum(c,2))';
r_acc_no_void = (diag(c(2:end,2:end))./sum(c(2:end,2:end),2))';
r_int = (diag(c)./(sum(c,2)+sum(c',2)-diag(c)))';
r_int_no_void = (diag(c(2:end,2:end))./(sum(c(2:end,2:end),2)+sum(c(2:end, 2:end)',2)-diag(c(2:end, 2:end))))';

% fprintf('\n Mean of correctly labelled pixels Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f). Mean = %.2f \n', 100*[r_acc(:)' mean(r_acc)]);
% fprintf('Mean of intersection by union Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[r_int(:)' mean(r_int)]);
% fprintf('Mean of correctly labeled per image Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[rc(:)']);
% fprintf('Mean of intersection by union per image Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[rc2(:)' mean(rc2)]);

fprintf('\n At superpixel level \n');
fprintf('Mean of correctly labelled pixels \n');
display_results(r_acc);
fprintf('Mean of intersection by union \n');
display_results(r_int);
fprintf('Mean of correctly labeled per image \n');
display_results2(rc);
fprintf('Mean of intersection by union per image \n');
display_results(rc2);

tot = squeeze(sum(cmatrixP,2));
tot2 = squeeze(sum(cmatrixP,2)) + squeeze(sum(cmatrixP,1));
nr2 = 0;
rc=zeros(1,obj.dbparams.ncat);
rc2=zeros(1,obj.dbparams.ncat);
for j = 1:obj.dbparams.ncat
    nr = cmatrixP(j,j,:);
    nr2 = nr2 + nr;
    ind = find(tot(j,:)>0);
    ind2 = find(tot2(j,:)>0);
    rc(j) =  mean(squeeze(nr(ind))'./squeeze(tot(j,ind)));
    rc2(j) = mean(squeeze(nr(ind))'./squeeze(tot2(j,ind)));
end



rc = [rc(:)' mean(squeeze(nr2)'./sum(squeeze(sum(cmatrixP,1)),1))];

c = sum(cmatrixP,3); 
r_acc = (diag(c)./sum(c,2))';
r_acc_no_void = (diag(c(2:end,2:end))./sum(c(2:end,2:end),2))';
r_int = (diag(c)./(sum(c,2)+sum(c',2)-diag(c)))';
r_int_no_void = (diag(c(2:end,2:end))./(sum(c(2:end,2:end),2)+sum(c(2:end, 2:end)',2)-diag(c(2:end, 2:end))))';
%save(sprintf(globalparms.finaldestmatpath,'statistics'),'r_acc','r_int','rc','rc2', 'r_acc_no_void', 'r_int_no_void');

% fprintf('\n Per pixel numbers\n');
% fprintf('Mean of correctly labelled pixels Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[r_acc(:)' mean(r_acc)]);
% fprintf('Mean of intersection by union Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[r_int(:)' mean(r_int)]);
% fprintf('Mean of correctly labeled per image Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[rc(:)']);
% fprintf('Mean of intersection by union per image Bike(%.2f) cars (%.2f) People(%.2f) BG(%.2f).. Mean = %.2f \n', 100*[rc2(:)' mean(rc2)]);

fprintf('\n Per pixel numbers\n');
fprintf('Mean of correctly labelled pixels \n');
display_results(r_acc);
fprintf('Mean of intersection by union \n');
display_results(r_int);
fprintf('Mean of correctly labeled per image \n');
display_results2(rc);
fprintf('Mean of intersection by union per image \n');
display_results(rc2);

save(stat_file,'cmatrixSP','cmatrixP');
end

function display_results(r_acc)
for i=1:length(r_acc)
    fprintf('%3.2f \t',100*r_acc(i));
end
fprintf('\nMean= %3.2f \n',100*mean(r_acc));
end

function display_results2(rc)
for i=1:length(rc)-1
    fprintf('%3.2f \t',100*rc(i));
end
fprintf('\nMean= %3.2f \n',100*rc(end));
end
