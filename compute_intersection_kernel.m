function E = compute_intersection_kernel(segHist,trainHists,nlab)
%Compute the matrix corresponding to the coefficientss a_ls of the
%classifier
numCoeffs=size(trainHists,2);
E=zeros(1,numCoeffs*nlab);
for lab=1:nlab
    hcomp=segHist(:,lab);
    for i=1+(lab-1)*numCoeffs:lab*numCoeffs
        E(i)=sum(min(hcomp,trainHists(:,i-(lab-1)*numCoeffs)));
    end
end
end

