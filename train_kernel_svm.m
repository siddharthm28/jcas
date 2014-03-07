function svm = train_kernel_svm(obj, features)
% Train kernel SVM with given geatures

labels = features(end,:);
[M,N] = size(features);
X = repmat(1:N,N,1);
Y = X';
K = zeros(N);


switch obj.unary.svm.params.kernel_type

    case 1
        %%% LINEAR KERNEL %%%%%%%%%%%
        K = features(1:M-1,:)'*features(1:M-1,:);


    case 2
        %%% HISTOGRAM INTERSECTION KERNEL %%%%%%%%
        for i=1:M-1
            hh = features(i,:);
            K = K + min(hh(X),hh(Y));
        end


    case 3
        %%% CHI-SQUARE  KERNEL %%%%%%%%%%
        for i=1:M-1
            disp(sprintf('train_kernel_svm: Computed kernel from %d of %d dimensions',i,M)); pause(0.01);
            hh = features(i,:);
            index = find((hh(X) + hh(Y))>0);
            nr = (hh(X)-hh(Y)).^2;
            dr = hh(X)+hh(Y);
            K(index) = K(index) + nr(index)./dr(index);
        end
    case 4
        K = vl_alldist2(features(1:M-1,:),features(1:M-1,:), 'chi2');
        


end


svm = svmkernellearn(...
    K,                 labels,         ...
    'type',            obj.unary.svm.params.type,    ...
    'C',               obj.unary.svm.params.C,       ...
    'nu',              obj.unary.svm.params.nu,      ...
    'balance',         obj.unary.svm.params.balance, ...
    'crossvalidation', obj.unary.svm.params.cross,   ...
    'rbf',             obj.unary.svm.params.rbf,     ...
    'gamma',           obj.unary.svm.params.gamma,   ...
    'probability',     obj.unary.svm.params.probability, ...
    'debug',0,...     %      obj.unary.svm.params.debug,...
    'verbosity', 0);%      obj.unary.svm.params.verb) ;
%obj.unary.svm.params.K = K;

