%--------------------------------------------------------------------------
%Train classifiers for unary potentials
%--------------------------------------------------------------------------
%This function compute for training or testing image set the unary
%potentials, and more specifically the svm classifiers.
%Input : 
% _ obj of class jcas
% _ imgsetname string 'training' or 'test'
% Output: 'svm' saved in 'svm_data-%d' 

function train_unary_classifiers(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
svm_filename = sprintf(obj.unary.svm.destmatpath,sprintf('svm_data-%d',obj.unary.SPneighboorhoodsize));

if (~exist(svm_filename, 'file') || obj.force_recompute.unary_svm_classifiers)
    tmp=load(sprintf(obj.unary.svm.trainingset.destmatpath,sprintf('training_set-%d',obj.unary.SPneighboorhoodsize)),'training_set','num_hists_per_class');
    training_set=tmp.training_set; num_hists_per_class=tmp.num_hists_per_class;
    h_tmp =[];

    % Build the final training set for classification with maximum number
    % of histogram per class defined for training.
    for i=1:obj.dbparams.ncat
            index = (training_set(end,:)==i);
            randindex = randsample(sum(index),min(obj.unary.svm.params.max_hists_per_class_for_training,sum(index)));
            t_tmp=training_set(:,index);
            h_tmp = [h_tmp t_tmp(:,randindex)];
    end

    %Use LIBSVM to train the SVM kernel using the training images
    svm = train_kernel_svm(obj, h_tmp);
    svm.training_SVs = h_tmp(:,(svm.libsvm_cl.SVs+0));
    svm.libsvm_cl.SVs = sparse([1:svm.libsvm_cl.totalSV]');

    save(svm_filename,'svm');

end

end
