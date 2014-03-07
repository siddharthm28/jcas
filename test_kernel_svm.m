%--------------------------------------------------------------------------
%Test kernel svm
%--------------------------------------------------------------------------
%This function returns the probability estimates and predicted label for a
%specified kernel given features and svm parameters
%Input : 
% _ features to be classified
% _ f_train parameters of the trained svm
% _ Kernel type 1- linear; 2- intersection; 3- Chi2; 4- Chi2-RBF
% _ model input like svmpredict
% _ gamma parameter given by trained svm

function [predicted_label,probability_estimates] = test_kernel_svm(features, f_train, kernel_type, model,gamma)

% features is a M*N matrix which contains N data points of dimension (M-1)
% The Mth row indicates the class_index

[M,N] = size(features);
[M2,N2] = size(f_train);
X = repmat(N+1:N+N2,N,1);
Y = repmat(1:N,N2,1)';
K = zeros(N,N2);


%Determine which class labes have been used
%classes_record(uint8(features(end,:))+1)=1;
%classes_present=find(classes_record)-1;
%number_classes=length(classes_present);


switch kernel_type

    case 1
        %%% LINEAR KERNEL %%%%%%%%%%%
        K = features(1:M-1,:)'*f_train(1:M-1,:);


    case 2
        %%% HISTOGRAM INTERSECTION KERNEL %%%%%%%%
        for i=1:M-1
            hh = [features(i,:) f_train(i,:)];
            K = K + min(hh(X),hh(Y));
        end


    case 3
        %%% CHI-SQUARE  KERNEL %%%%%%%%%%
        for i=1:M-1
            hh = [features(i,:) f_train(i,:)];
            index = find((hh(X) + hh(Y))>0);
            nr = (hh(X)-hh(Y)).^2;
            dr = hh(X)+hh(Y);
            K(index) = K(index) - nr(index)./dr(index);
        end

    case 4
        %%% CHI-SQUARE  KERNEL %%%%%%%%%%
        K = vl_alldist2(double(features(1:end-1,:)),double(f_train(1:end-1,:)),'chi2');
        K = exp(-gamma*K);
end


disp('kernel calculated');
[predicted_label, accuracy, probability_estimates] = svmpredict(double(features(M,:)'), [[1:N]' K], model, '-b 1');

