function L=lossFnCP(obj,parm,y,yhat)
% y GT and yhat estimate

%Account latent struct
if obj.mode==7
    yhat=yhat(1:length(y));
end
switch obj.optimisation.params.lossFnCP_name
    case '%misclassified'
        %Loss function for CP
        %Add swictch here to change loss
        delta=(y~=yhat);
        % Number of labels misclassified over number of label.
        L=sum(delta(:))/length(delta(:));
    case 'hamming'
        L=0;
        delta=double((y~=yhat));
        for i=1:obj.dbparams.ncat
            ind=(y==i);
            if sum(ind(:))~=0
            L=L+sum(delta(ind(:)))/sum(ind(:));
            end
        end
end

