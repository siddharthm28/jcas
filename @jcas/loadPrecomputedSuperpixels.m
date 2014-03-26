function [mask,nbSp,iSeg] = loadPrecomputedSuperpixels(obj,I,image_name)
%This method loads the precomputed superpixel mask of a given image 
% according to the parameters given in obj.
% Input :
% _ obj of class jcas
% _ image_name: name of the image whose superpixels we want to load
% Output : 
% _ mask : matrix giving the associated cluster number.
% _ nbsp : Number of superpixels in the image.

switch obj.superpixels.method
    case 'ucm'
        % load the precomputed results corresponding to image name
        tmp=load(fullfile(obj.superpixels.params.path,[image_name,'.mat']));
        ucm2=tmp.ucm2;
        labels2=bwlabel(ucm2 <= obj.superpixels.params.threshold);
        mask=labels2(2:2:end,2:2:end);
        iSeg=generateSeg(I,mask);
        nbSp = max(max(mask));
    otherwise
        error(['Unknown superpixel method. Did you add it to the', ...
            ' appropriate files ?']);
end

% find the number of labels for each training image

end

function seg=generateSeg(I,sp)
% code to compute the mean color for each superpixel and generate a
% superpixel based color image
    [M,N,d]=size(I);
    In=reshape(I,[M*N,d]);
    sp=sp(:);
    nbsp=max(sp);
    seg=zeros(size(In));
    for i=1:nbsp
        tmp=round(mean(In(sp==i,:)));
        seg(sp==i,:)=repmat(tmp,sum(sp==i),1);
    end
    seg=uint8(reshape(seg,[M,N,d]));
end
