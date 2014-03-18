function [topdown_unary,topdown_count,z] = infer_words(seg,alphaMat,clusterCenters,D,locations,img_sp,wordsPairwise,adj)
%Compute from segmentation, coefficients, cluster centers, descriptors and
%feature map to Superpixels the optimal words assignment
%seg : segmentation nbSPx1
%alphaMat : nbWords x nLabel
% clusterCenters : descript Dim x nbWords
% D : descr Dim x nbInterestPoints
% featToSP : nbInterestPoints x 1 
% wordsPairwise: size of dict x size of dict
% nn = number of neighbor to consider
featToSP=img_sp.spInd(locations);
z=zeros(1,length(featToSP));
nbWords=size(clusterCenters,2);

%Build unary
ipUnary=zeros(length(featToSP),nbWords);
for ip=1:length(featToSP)
    ipUnary(ip,:)=(alphaMat(:,seg(featToSP(ip)))+clusterCenters'*double(D(:,ip)));
end

if ~exist('wordsPairwise','var')
    %Infer when only unaries
    [dum,z]=min(ipUnary,[],2);
    z=z';
else
    %Infer with pairwise and LBP
    %Get n nearest neigh.
    edgeStruct = UGM_makeEdgeStruct(adj,nbWords);
    edgePot=repmat(wordsPairwise,[1,1,edgeStruct.nEdges]);
    z=UGM_LoopyBP(ipUnary,edgePot,edgeStruct,1);
end
topdown_unary = sparse(img_sp.spInd(locations), z, ones(length(locations),1), img_sp.nbSp,nbWords);
topdown_count=sum(topdown_unary,2);
end

