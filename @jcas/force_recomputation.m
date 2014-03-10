function force_recomputation(obj,varargin)
%This function builds the right force_recompute parameters to ensure that
%if you recompute something you will effectively recompute the right
%options.

if nargin>1 && isequal(varargin{1},'reset')
    fprintf('Reset Forcin recomputation\n');
    %Disable default recomputing of training data (Superpixels/Features)
    obj.force_recompute.trainingdata_UF=0;
    obj.force_recompute.imagedata=0;
    obj.force_recompute.trainingdata_SP=0;
    %Recomputing dictionary for unary
    obj.force_recompute.dictionary_unary=0;
    %Recomputing superpixels histograms
    obj.force_recompute.superpixels_histograms=0;
    %Recomputing aggregated superpixels histograms
    obj.force_recompute.aggregated_histograms=0;
    %Recomputing training set for svm on unary potentials
    obj.force_recompute.trainingset_svm=0;
    %Recomputing the svm classifiers for unary potentials
    obj.force_recompute.unary_svm_classifiers=0;
    %Recomputing the unary potentials
    obj.force_recompute.unary=0;
    %Recomputing pairwise potentials
    obj.force_recompute.pairwise=0;
    %Recomputing Topdown Dictionary
    obj.force_recompute.topdown_dictionary=0;
    %Recomputing topdown descriptors
    obj.force_recompute.topdown_descriptors=0;
    %Recomputing topdown unary
    obj.force_recompute.topdown_unary=0;
    %Recomputing optimisation
    obj.force_recompute.optimisation=0;
elseif nargin>1 && isequal(varargin{1},'all')
    fprintf('Forcing recomputation for everything\n');
    fprintf('Not recomputing image data, features and superpixels though \n');
    %Disable default recomputing of training data (Superpixels/Features)
    obj.force_recompute.trainingdata_UF=0;
    obj.force_recompute.imagedata=0;
    obj.force_recompute.trainingdata_SP=0;
    %Recomputing dictionary for unary
    obj.force_recompute.dictionary_unary=1;
    %Recomputing superpixels histograms
    obj.force_recompute.superpixels_histograms=1;
    %Recomputing aggregated superpixels histograms
    obj.force_recompute.aggregated_histograms=1;
    %Recomputing training set for svm on unary potentials
    obj.force_recompute.trainingset_svm=1;
    %Recomputing the svm classifiers for unary potentials
    obj.force_recompute.unary_svm_classifiers=1;
    %Recomputing the unary potentials
    obj.force_recompute.unary=1;
    %Recomputing pairwise potentials
    obj.force_recompute.pairwise=1;
    %Recomputing Topdown Dictionary
    obj.force_recompute.topdown_dictionary=1;
    %Recomputing topdown descriptors
    obj.force_recompute.topdown_descriptors=1;
    %Recomputing topdown unary
    obj.force_recompute.topdown_unary=1;
    %Recomputing optimisation
    obj.force_recompute.optimisation=1;
else
        %Disable default recomputing of training data (Superpixels/Features)
    %Recomputing dictionary for unarytrainingdata_UF
    obj.force_recompute.trainingdata_UF=obj.force_recompute.imagedata||obj.force_recompute.trainingdata_UF;
    obj.force_recompute.trainingdata_SP=obj.force_recompute.trainingdata_SP||obj.force_recompute.imagedata;
    obj.force_recompute.dictionary_unary=obj.force_recompute.trainingdata_UF|| ...
        obj.force_recompute.dictionary_unary;
    %Recomputing superpixels histograms
    obj.force_recompute.superpixels_histograms=obj.force_recompute.dictionary_unary||...
        obj.force_recompute.trainingdata_SP||obj.force_recompute.superpixels_histograms;
    %Recomputing aggregated superpixels histograms
    obj.force_recompute.aggregated_histograms=obj.force_recompute.superpixels_histograms||...
        obj.force_recompute.aggregated_histograms;
    %Recomputing training set for svm on unary potentials
    obj.force_recompute.trainingset_svm=obj.force_recompute.aggregated_histograms||...
        obj.force_recompute.trainingset_svm;
    %Recomputing the svm classifiers for unary potentials
    obj.force_recompute.unary_svm_classifiers=obj.force_recompute.trainingset_svm||obj.force_recompute.unary_svm_classifiers;
    %Recomputing the unary potentials
    obj.force_recompute.unary=obj.force_recompute.unary_svm_classifiers||obj.force_recompute.unary;
    %Recomputing pairwise potentials
    obj.force_recompute.pairwise=obj.force_recompute.trainingdata_SP||...
    obj.force_recompute.pairwise;
    %Recomputing Topdown Dictionary
    obj.force_recompute.topdown_dictionary=obj.force_recompute.topdown_descriptors||...
    obj.force_recompute.topdown_dictionary;
    %Recomputing topdown unary
    obj.force_recompute.topdown_unary=obj.force_recompute.topdown_dictionary||...
        obj.force_recompute.topdown_unary;
    %Recomputing optimisation
   
    obj.force_recompute.optimisation=obj.force_recompute.unary||obj.force_recompute.pairwise||...
        obj.force_recompute.topdown_unary||obj.force_recompute.optimisation;
end
end
