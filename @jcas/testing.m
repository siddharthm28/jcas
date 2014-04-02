function testing(obj)
if ~obj.destpathmade
    obj.makedestpath(obj.dbparams.destmatpath);
end

%Check if you have to train/retrain
%if obj.force_recompute.optimisation
%    obj.train;
%end



%--------------------------------------------------------------------------
% Testing directory
%--------------------------------------------------------------------------
%Load / Create
%(Check if custom user directory)
datenow=datestr(now,'yyyy_mm_dd_HH.MM.SS');

rootDir=obj.dbparams.trainingpath(1:end-6);
if ~exist(sprintf([rootDir,'test_%d/testBase.mat'],obj.mode),'file')
    testBase={};
    testBaseCount=0;
    mkdir([rootDir,sprintf('test_%d',obj.mode)]);
else
    load([rootDir,sprintf('test_%d/testBase.mat',obj.mode)]);
end


%create a new exp
testBaseCount=testBaseCount+1;
testBase{testBaseCount}.JCAS=obj;

%Create folder
obj.test.destmatpath=sprintf([rootDir,'test_%d/%s/%s.mat'],obj.mode,datenow,'%s');
mkdir(sprintf([rootDir,'test_%d/%s/'],obj.mode,datenow));
testBase{testBaseCount}.folder=obj.test.destmatpath;

%Save the modifications
save([rootDir,sprintf('test_%d/testBase.mat',obj.mode)],'testBase','testBaseCount');
clear testBase testBaseCount;

%Save obj parameters
save(sprintf(obj.test.destmatpath,'jcasObj'),'obj');

%--------------------------------------------------------------------------
%Launch testing phase
%--------------------------------------------------------------------------
profile on

%Extract the features to compute unary from the set of training images
extract_features(obj,'test');

if(~isfield(obj.unary,'precomputed') || ~obj.unary.precomputed)
    %Compute the histograms associated to superpixels in each image of training
    %set
    build_superpixels_histograms(obj,'test');

    %Build aggregated histograms accross superpixels if associated parameter is
    %non zero
    build_aggregated_superpixels_histograms(obj,'test');

    %Compute unary costs
    compute_unary_costs(obj,'test');
else
    if(~isfield(obj.unary,'precomputed_path') || isempty(obj.unary.precomputed_path))
        error('Please mention precomputed path if you want to use this option \n');
    else
        load_precomputed_unary(obj,'test');
    end
end

if obj.mode>0;
%compute pairwise costs
compute_pairwise_cost(obj,'test');

end

if obj.mode>=2;
    fprintf('\n Generate TD descriptors');
    generate_topdown_descriptors(obj,'test');
    fprintf('\n Generate TD unary');
    compute_topdown_unaries(obj,'test');
end

obj.inference('test');

fprintf('\n Converting superpixels to pixels');
sp_label_to_pixlabel(obj,'test');

fprintf('\n Computing Statistics');
Compute_Statistics_with_Bootstrapping(obj,obj.test.destmatpath);
profile off
p = profile('info');
save(sprintf(obj.test.destmatpath,sprintf('testprofile_mode_%d',obj.mode)) ,'p');
clear p
%load myprofiledata
%profview(0,p)
end


