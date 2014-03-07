function labelHist= compute_label_histograms(seg,topdown_unary,ncat)
%Given the segmentation and the superpixels histograms return the
%histograms of words for each label

labelHist=zeros(size(topdown_unary,2),ncat);
for l=1:ncat
    labelHist(:,l)=sum(topdown_unary(seg==l,:),1)';
end

end

