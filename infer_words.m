function [topdown_unary,topdown_count,z] = infer_words(seg,alphaMat,clusterCenters,D,locations,img_sp)
%Compute from segmentation, coefficients, cluster centers, descriptors and
%feature map to Superpixels the optimal words assignment
%seg : segmentation nbSPx1
%alphaMat : nbWords x nLabel
% clusterCenters : descript Dim x nbWords
% D : descr Dim x nbInterestPoints
% featToSP : nbInterestPoints x 1 
featToSP=img_sp.spInd(locations);
z=zeros(1,length(featToSP));
nbWords=size(clusterCenters,2);
for ip=1:length(featToSP)
    [dum,z(ip)]=min(alphaMat(:,seg(featToSP(ip)))+clusterCenters'*double(D(:,ip)));
end
topdown_unary = sparse(img_sp.spInd(locations), z, ones(length(locations),1), img_sp.nbSp,nbWords);
topdown_count=sum(topdown_unary,2);
end

