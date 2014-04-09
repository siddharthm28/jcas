%--------------------------------------------------------------------------
%Building training set for unary svm classifier
%--------------------------------------------------------------------------
%This function creates a training set in order to train the classifier for
%the unary potentials.
%Input :
% _ obj of class jcas
% _ imgsetname string 'training' or 'test'

function build_trainingset_unary_histogramsvm(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end
%load the dictionary
tmp=load(sprintf(obj.unary.dictionary.destmatpath,'unary_dictionary'),'features');
features=tmp.features;

%Allocate space for training set
training_set_svm_filename = sprintf(obj.unary.svm.trainingset.destmatpath,sprintf('training_set-%d',obj.unary.SPneighboorhoodsize));


if ((~exist(training_set_svm_filename, 'file') || obj.force_recompute.trainingset_svm)) && isequal(imgsetname,'training')
    %Indices of the images corresponding to training or testing
    ids = obj.dbparams.(imgsetname);

    
    %Initialize training set
    training_set = zeros(obj.unary.dictionary.params.num_bu_clusters+1,length(ids)*obj.unary.svm.trainingset.params.hists_per_image*obj.dbparams.ncat);
    ctr = 1;
    num_hists_per_class = zeros(1,obj.dbparams.ncat);
    fprintf('construct_training_set_for_svm_on_histograms:(total of %d images):    ', length(ids));

    %Create a training set for SVM classification using the histograms associated with each superpixel
    for i=1:length(ids)
        fprintf('\b\b\b\b%04d',i);
        
        %Check if we work on aggregated superpixels histograms
        %if (obj.unary.SPneighboorhoodsize ==0)
            %load(sprintf(obj.unary.destmatpath,sprintf('%s-SP_histogram',obj.dbparams.image_names{ids(i)})),'superpixel_histograms');
            tmp=load(sprintf(obj.unary.destmatpath,sprintf('%s-histogram-neighborhood-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize)),'superpixel_histograms');
            superpixel_histograms=tmp.superpixel_histograms;

        %else
         %   load(sprintf(obj.unary.destmatpath,sprintf('%s-histogram-neighborhood-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize)),'superpixel_histograms');
       % end
        
        %Retrieve the classes present in image
        classes = (unique(superpixel_histograms(end,:)));
        
        %For each class find the superpixels that have this dominant class,
        %then add a number of histograms less or equal than max parameter
        %and build the training set.
        for j=1:length(classes);
            if classes(j)~=0
                index = (superpixel_histograms(end,:)==classes(j));
                num_added = min(obj.unary.svm.trainingset.params.hists_per_image,sum(index));
                randindex = randsample(sum(index),num_added);
                hh=superpixel_histograms(:,index);
                if (num_added>0)
                    num_hists_per_class(classes(j))=num_hists_per_class(classes(j))+num_added;
                    training_set(:,ctr:ctr+num_added-1) = hh(:,randindex);
                    ctr = ctr+num_added;
                end
            end
        end
    end

    training_set = training_set(:,1:ctr-1);

    for i=1:obj.dbparams.ncat
        fprintf(sprintf('construct_training_set_for_svm_on_histograms: Collected %d histograms for class %d \n',num_hists_per_class(i),i));
    end
    fprintf(sprintf('construct_training_set_for_svm_on_histograms: Collected a total of %d histograms \n' ,ctr));

    save(training_set_svm_filename,'training_set','num_hists_per_class');
    
end
end
