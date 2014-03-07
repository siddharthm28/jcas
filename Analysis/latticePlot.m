function L=latticePlot(img_sp,pairwise,nSp)
%For a given structure img_sp with mask Iseg etc.. plot the neighboorhood
%of the superpixel i


if nargin==2
    numSp=randi(img_sp.nbSp);
else
    numSp=nSp;
end


A=adjacency(img_sp.edges);

ind=find(A(numSp,:));
result=double((img_sp.spInd==numSp));
for i=1:length(ind)
    result(img_sp.spInd==ind(i))=full(pairwise(numSp,ind(i)));
end

imagesc(result);
figure
imshow(repmat(result~=0,[1,1,3]).*img_sp.Iseg)



end