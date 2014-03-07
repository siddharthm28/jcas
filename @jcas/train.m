%This function launch the training step given the parameters given in the
%object obj of class jcas. Can be called with "obj.train;"

function train(obj)

if obj.destpathmade==1
    obj.resetPath;
end
tDir=obj.makedestpath(obj.dbparams.destmatpath);
%Build the appropriate recomputations
obj.force_recomputation;
%Make path according to parameter.


%--------------------------------------------------------------------------
% Time saving
%--------------------------------------------------------------------------



%Extract the features to compute unary from the set of training images
profile on
extract_features(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'extract_features'),'file')
    p = profile('info');
    save(sprintf([tDir,'%s.mat'],'extract_features'),'p');
end
profile clear

%Compute the dictionary associated to the features previously extracted
build_dictionary_unary(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'build_dictionary_unary'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'build_dictionary_unary'),'p');
end
profile clear

%Compute the histograms associated to superpixels in each image of training
%set
%Ok Void
build_superpixels_histograms(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'build_superpixel_histograms'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'build_superpixel_histograms'),'p');
end
profile clear

%Build aggregated histograms accross superpixels if associated parameter is
%non zero
%Ok Void
build_aggregated_superpixels_histograms(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'aggregation_histograms'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'aggregation_histograms'),'p');
end
profile clear

%Build the training set used to learn the classifier for the unary
%potentials
build_trainingset_unary_histogramsvm(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'trainingset_unary'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'trainingset_unary'),'p');
end
profile clear

%Train the classifiers for unary potential
train_unary_classifiers(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'unary_class'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'unary_class'),'p');
end
profile clear

%Compute unary costs
compute_unary_costs(obj,'training');
if ~exist(sprintf([tDir,'%s.mat'],'unary_costs'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'unary_costs'),'p');
end
profile clear

if obj.mode>=1
    %compute pairwise costs
    compute_pairwise_cost(obj,'training');
    if ~exist(sprintf([tDir,'%s.mat'],'pairwise_costs'),'file')
    p = profile('info');
    save(sprintf([tDir,'%s.mat'],'pairwise_costs'),'p');
    end
    profile clear
end

if obj.mode>=2
    fprintf('\n Generate TD descriptors');
    generate_topdown_descriptors(obj,'training');
    fprintf('\n Generate TD dictionary');
    build_topdown_dictionary(obj);
    fprintf('\n Generate TD unary');
    compute_topdown_unaries(obj,'training');
end
    

%Cutting plane algorithm to learn the parameters
cutting_plane_learning(obj);

if ~exist(sprintf([tDir,'%s.mat'],'CP_learning'),'file')
p = profile('info');
save(sprintf([tDir,'%s.mat'],'CP_learning'),'p');
end
profile off
% 
% if ~exist([tDir,'jcasObjSaveAll/'],'dir')
%     mkdir ([tDir,'jcasObjSaveAll/'])
% end
% save(sprintf([tDir,'jcasObjSaveAll/jcasObj_%s.mat'],datestr(now,'yyyy_mm_dd_HH.MM.SS')),'obj');
% 


end