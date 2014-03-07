function [mask,nbSp,iSeg] = computeSuperpixels(obj,I)
%This method compute the superpixel mask of a given image according to the
%parameters given in obj.
% Input :
% _ obj of class jcas
% _ I image of t~he appropriate class for the superpixels
% Output : 
% _ mask : matrix giving the associated cluster number.
% _ nbsp : Number of superpixels in the image.

switch obj.superpixels.method
    case 'Quickshift'
        % find the initial segmentation and labels
        [iSeg, mask] = vl_quickseg(I, obj.superpixels.params.ratio, obj.superpixels.params.kernelsize, obj.superpixels.params.tau);               
        nbSp = max(max(mask));
    otherwise
        error(['Unknown superpixel method. Did you add it to the', ...
            ' appropriate files ?']);
end

% find the number of labels for each training image

end

