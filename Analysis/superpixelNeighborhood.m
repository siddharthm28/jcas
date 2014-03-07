function L=superpixelNeighborhood(img_sp,nbNN,nSp)
%For a given structure img_sp with mask Iseg etc.. plot the neighboorhood
%of the superpixel i

if nargin==2
    numSp=randi(img_sp.nbSp);
else
    numSp=nSp;
end

A=adjacency(img_sp.edges);
L=sparse(zeros(size(A)));

 for i=1:nbNN
     L=A*(speye(size(L))+L);
 end

ind=find(L(numSp,:));
result=(img_sp.spInd==numSp);
for i=1:length(ind)
    result(img_sp.spInd==ind(i))=1;
end

imagesc(result);

end

