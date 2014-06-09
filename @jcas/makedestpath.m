function tDir=makedestpath(obj,rootDirw)
%Given the parameters of the class, builds the correct paths for the
%experiments, load the existing table of experiments already done and
%create/add the new ones into the appropriate files.
if obj.destpathmade
    obj.resetPath;
end
%--------------------------------------------------------------------------
% Main result directory
%--------------------------------------------------------------------------
%Store the resultat folder : must end with /
obj.dbparams.destmatpath=rootDirw;
%Remove %s.mat
rootDir=rootDirw(1:end-6);

datenow=datestr(now,'yyyy_mm_dd_HH.MM.SS');

%Add the %s.mat for all the sprintf instructions :
%obj.dbparams.destmatpath=[obj.dbparams.destmatpath,'%s.mat'];

%--------------------------------------------------------------------------
%Make Database result directory
%--------------------------------------------------------------------------
vl_xmkdir(rootDir);
% if ~exist(rootDir,'dir')
%     mkdir(rootDir);
% end

%--------------------------------------------------------------------------
%Superpixels
%--------------------------------------------------------------------------
%Load / Create superpixels data
%(Check if custom user directory)
    
if isempty(obj.superpixels.destmatpath)
    if ~exist([rootDir,'superpixels/superpixelsBase.mat'],'file')
        superpixelsBase={};
        superpixelsBaseCount=0;
        vl_xmkdir([rootDir,'superpixels']);
    else
        tmp=load([rootDir,'superpixels/superpixelsBase.mat']);
        superpixelsBase=tmp.superpixelsBase;
        superpixelsBaseCount=tmp.superpixelsBaseCount;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:superpixelsBaseCount
        ctr= isequal(superpixelsBase{i}.params,obj.superpixels.params) && ...
            isequal(superpixelsBase{i}.method,obj.superpixels.method);
        if  ctr
            obj.superpixels.destmatpath=superpixelsBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.superpixels.destmatpath)
        superpixelsBaseCount=superpixelsBaseCount+1;
        superpixelsBase{superpixelsBaseCount}.params=obj.superpixels.params;
        superpixelsBase{superpixelsBaseCount}.method=obj.superpixels.method;
        
        %Create folder
        obj.superpixels.destmatpath=[rootDir,sprintf('superpixels/%s-%d/',...
            obj.superpixels.method,superpixelsBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.superpixels.destmatpath));
        superpixelsBase{superpixelsBaseCount}.folder=obj.superpixels.destmatpath;
    end
    
    %Save the modifications
    save([rootDir,'superpixels/superpixelsBase.mat'],'superpixelsBase','superpixelsBaseCount');
    clear superpixelsBase superpixelsBaseCount;
end

%--------------------------------------------------------------------------
% Unary features
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.unary.features.destmatpath) && ~obj.unary.precomputed
    if ~exist([rootDir,'unary_features/unary_featuresBase.mat'],'file')
        unary_featuresBase={};
        unary_featuresBaseCount=0;
        vl_xmkdir([rootDir,'unary_features']);
    else
        tmp=load([rootDir,'unary_features/unary_featuresBase.mat']);
        unary_featuresBaseCount=tmp.unary_featuresBaseCount;
        unary_featuresBase=tmp.unary_featuresBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:unary_featuresBaseCount
        ctr= isequal(unary_featuresBase{i}.method,obj.unary.features.method) && ...
                isequal(unary_featuresBase{i}.params,obj.unary.features.params);
        if ctr
            obj.unary.features.destmatpath=unary_featuresBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.unary.features.destmatpath)
        unary_featuresBaseCount=unary_featuresBaseCount+1;
        unary_featuresBase{unary_featuresBaseCount}.params=obj.unary.features.params;
        unary_featuresBase{unary_featuresBaseCount}.method=obj.unary.features.method;
        
        %Create folder
        obj.unary.features.destmatpath=[rootDir,sprintf('unary_features/%s-%d/',...
            obj.unary.features.method,unary_featuresBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.unary.features.destmatpath));
        unary_featuresBase{unary_featuresBaseCount}.folder=obj.unary.features.destmatpath;
    end
    
    %Save the modifications
    save([rootDir,'unary_features/unary_featuresBase.mat'],'unary_featuresBase','unary_featuresBaseCount');
    clear unary_featuresBase unary_featuresBaseCount;
end

%--------------------------------------------------------------------------
% TopDown features
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.topdown.features.destmatpath) && ~isempty(obj.topdown.features.method)
    if ~exist([rootDir,'topdown_features/topdown_featuresBase.mat'],'file')
        topdown_featuresBase={};
        topdown_featuresBaseCount=0;
        vl_xmkdir([rootDir,'topdown_features']);
    else
        tmp=load([rootDir,'topdown_features/topdown_featuresBase.mat']);
        topdown_featuresBase=tmp.topdown_featuresBase;
        topdown_featuresBaseCount=tmp.topdown_featuresBaseCount;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:topdown_featuresBaseCount
        ctr=isequal(topdown_featuresBase{i}.params,obj.topdown.features.params) && ...
                isequal(topdown_featuresBase{i}.method,obj.topdown.features.method);
        if ctr
            obj.topdown.features.destmatpath=topdown_featuresBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.topdown.features.destmatpath)
        topdown_featuresBaseCount=topdown_featuresBaseCount+1;
        topdown_featuresBase{topdown_featuresBaseCount}.params=obj.topdown.features.params;
        topdown_featuresBase{topdown_featuresBaseCount}.method=obj.topdown.features.method;
        
        %Create folder
        obj.topdown.features.destmatpath=[rootDir,sprintf('topdown_features/%s-%d/',...
            obj.topdown.features.method,topdown_featuresBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.topdown.features.destmatpath));
        topdown_featuresBase{topdown_featuresBaseCount}.folder=obj.topdown.features.destmatpath;
    end
    
    %Save the modifications
    save([rootDir,'topdown_features/topdown_featuresBase.mat'],'topdown_featuresBase','topdown_featuresBaseCount');
    clear topdown_featuresBase topdown_featuresBaseCount;
end

%--------------------------------------------------------------------------
% Training set directory
%--------------------------------------------------------------------------
% According to the selected training set, builds the right destination path
%
% Separate testing and training directories
if ~exist([rootDir,'trainBase.mat'],'file')
    trainBase={};
    trainBaseCount=0;
else
    tmp=load([rootDir,'trainBase.mat']);
    trainBase=tmp.trainBase;
    trainBaseCount=tmp.trainBaseCount;
end

% Check if experiment with these training/testing sets were already done
% and if yes retrieves folders. If not then creates a new entry.
tDir='';
%Sort the training indexes to compare image sets
obj.dbparams.training=sort(obj.dbparams.training);

%Check the previous experiments
for i=1:trainBaseCount
    ctr=isequal(trainBase{i}.training,obj.dbparams.training) && ...
        isequal(trainBase{i}.db_name,obj.dbparams.name);
    if ctr
        tDir=trainBase{i}.folder;        
        break;
    end
end

%If not in the previous, create a new exp
if isempty(tDir)
    trainBaseCount=trainBaseCount+1;
    trainBase{trainBaseCount}.training=obj.dbparams.training;
    trainBase{trainBaseCount}.db_name=obj.dbparams.name;
    
    %Create folder
    tDir=[rootDir,sprintf('Train_%s/',obj.dbparams.name)];
    vl_xmkdir(tDir);
    trainBase{trainBaseCount}.folder=tDir;
end

%Save the modifications
save([rootDir,'trainBase.mat'],'trainBase','trainBaseCount');
clear trainBase trainBaseCount;

%--------------------------------------------------------------------------
% Unary dictionary
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)

if isempty(obj.unary.dictionary.destmatpath) && ~obj.unary.precomputed
    if ~exist([tDir,'unary_dictionary/unary_dictionaryBase.mat'],'file')
        unary_dictionaryBase={};
        unary_dictionaryBaseCount=0;
        vl_xmkdir([tDir,'unary_dictionary']);
    else
        tmp=load([tDir,'unary_dictionary/unary_dictionaryBase.mat']);
        unary_dictionaryBaseCount=tmp.unary_dictionaryBaseCount;
        unary_dictionaryBase=tmp.unary_dictionaryBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    %%% If balancing added : check superpixels did not change
    %Check the previous experiments
    for i=1:unary_dictionaryBaseCount
        ctr=isequal(unary_dictionaryBase{i}.dictionary.params,obj.unary.dictionary.params) && ...
                isequal(unary_dictionaryBase{i}.features.method,obj.unary.features.method) &&...
                isequal(unary_dictionaryBase{i}.features.params,obj.unary.features.params);
        if ctr
            obj.unary.dictionary.destmatpath=unary_dictionaryBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.unary.dictionary.destmatpath)
        unary_dictionaryBaseCount=unary_dictionaryBaseCount+1;
        unary_dictionaryBase{unary_dictionaryBaseCount}.dictionary.params=obj.unary.dictionary.params;
        unary_dictionaryBase{unary_dictionaryBaseCount}.features.params=obj.unary.features.params;
        unary_dictionaryBase{unary_dictionaryBaseCount}.features.method=obj.unary.features.method;
        
        %Create folder
        obj.unary.dictionary.destmatpath=[tDir,sprintf('unary_dictionary/%s-%d/',...
            obj.unary.features.method,unary_dictionaryBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.unary.dictionary.destmatpath));
        unary_dictionaryBase{unary_dictionaryBaseCount}.folder=obj.unary.dictionary.destmatpath;
    end
    
    %Save the modifications
    save([tDir,'unary_dictionary/unary_dictionaryBase.mat'],'unary_dictionaryBase','unary_dictionaryBaseCount');
    clear unary_dictionaryBase unary_dictionaryBaseCount;
end

%--------------------------------------------------------------------------
% Unary Histograms
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
if isempty(obj.unary.destmatpath)
    if ~exist([tDir,'unary/unaryBase.mat'],'file')
        unaryBase={};
        unaryBaseCount=0;
        vl_xmkdir([tDir,'unary']);
    else
        tmp=load([tDir,'unary/unaryBase.mat']);
        unaryBaseCount=tmp.unaryBaseCount;
        unaryBase=tmp.unaryBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:unaryBaseCount
        ctr=isequal(unaryBase{i}.unary.features.params,obj.unary.features.params) && ...
                isequal(unaryBase{i}.unary.features.method,obj.unary.features.method) && ...
                isequal(unaryBase{i}.unary.dictionary.params,obj.unary.dictionary.params) && ...
                isequal(unaryBase{i}.superpixels.params,obj.superpixels.params) && ...
                isequal(unaryBase{i}.unary.precomputed,obj.unary.precomputed) && ...
                isequal(unaryBase{i}.unary.precomputed_path,obj.unary.precomputed_path);
        if ctr
            obj.unary.destmatpath=unaryBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.unary.destmatpath)
        unaryBaseCount=unaryBaseCount+1;
        unaryBase{unaryBaseCount}.superpixels.params=obj.superpixels.params;
        unaryBase{unaryBaseCount}.unary.features.params=obj.unary.features.params;
        unaryBase{unaryBaseCount}.unary.dictionary.params=obj.unary.dictionary.params;
        unaryBase{unaryBaseCount}.unary.features.method=obj.unary.features.method;
        unaryBase{unaryBaseCount}.unary.precomputed=obj.unary.precomputed;
        unaryBase{unaryBaseCount}.unary.precomputed_path=obj.unary.precomputed_path;
        %Create folder
        if(obj.unary.precomputed)
            obj.unary.destmatpath=[tDir,sprintf('unary/precomputed-%d/',unaryBaseCount),'%s.mat'];
        else
            obj.unary.destmatpath=[tDir,sprintf('unary/%s-%d/',...
                obj.unary.features.method,unaryBaseCount),'%s.mat'];
        end
        vl_xmkdir(fileparts(obj.unary.destmatpath));
        unaryBase{unaryBaseCount}.folder=obj.unary.destmatpath;
    end
    
    %Save the modifications
    save([tDir,'unary/unaryBase.mat'],'unaryBase','unaryBaseCount');
    clear unaryBase unaryBaseCount;
end

%--------------------------------------------------------------------------
% Unary training set
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.unary.svm.trainingset.destmatpath) && ~obj.unary.precomputed
    if ~exist(sprintf(obj.unary.destmatpath,'unarytestsvm/unarytestsvmBase'),'file')
        unarytestsvmBase={};
        unarytestsvmBaseCount=0;
        dirS=sprintf(obj.unary.destmatpath,'unarytestsvm/%s');
        vl_xmkdir(fileparts(dirS));
    else
        tmp=load(sprintf(obj.unary.destmatpath,'unarytestsvm/unarytestsvmBase'));
        unarytestsvmBase=tmp.unarytestsvmBase;
        unarytestsvmBaseCount=tmp.unarytestsvmBaseCount;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:unarytestsvmBaseCount
        ctr=isequal(unarytestsvmBase{i}.params,obj.unary.svm.trainingset.params);
        if ctr
            obj.unary.svm.trainingset.destmatpath=unarytestsvmBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.unary.svm.trainingset.destmatpath)
        unarytestsvmBaseCount=unarytestsvmBaseCount+1;
        unarytestsvmBase{unarytestsvmBaseCount}.params=obj.unary.svm.trainingset.params;
        
        %Create folder
        obj.unary.svm.trainingset.destmatpath=[fileparts(obj.unary.destmatpath),'/unarytestsvm/',num2str(unarytestsvmBaseCount),'/%s.mat'];
        vl_xmkdir(fileparts(obj.unary.svm.trainingset.destmatpath));
        unarytestsvmBase{unarytestsvmBaseCount}.folder=obj.unary.svm.trainingset.destmatpath;
    end
    
    %Save the modifications
    save(sprintf(obj.unary.destmatpath,'unarytestsvm/unarytestsvmBase'),'unarytestsvmBase','unarytestsvmBaseCount');
    clear unarytestsvmBase unarytestsvmBaseCount;
end
%--------------------------------------------------------------------------
% Unary SVM
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.unary.svm.destmatpath) && ~obj.unary.precomputed
    if ~exist(sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/unarysvmBase'),'file')
        unarysvmBase={};
        unarysvmBaseCount=0;
        dirS=sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/%s');
        vl_xmkdir(fileparts(dirS));
    else
        tmp=load(sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/unarysvmBase'));
        unarysvmBaseCount=tmp.unarysvmBaseCount;
        unarysvmBase=tmp.unarysvmBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:unarysvmBaseCount
        if isequal(unarysvmBase{i}.params,obj.unary.svm.params)
            obj.unary.svm.destmatpath=unarysvmBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.unary.svm.destmatpath)
        unarysvmBaseCount=unarysvmBaseCount+1;
        unarysvmBase{unarysvmBaseCount}.params=obj.unary.svm.params;
        
        %Create folder
        obj.unary.svm.destmatpath=[fileparts(obj.unary.svm.trainingset.destmatpath),'/unarysvm/',num2str(unarysvmBaseCount),'/%s.mat'];
        vl_xmkdir(fileparts(obj.unary.svm.destmatpath));
        unarysvmBase{unarysvmBaseCount}.folder=obj.unary.svm.destmatpath;
    end
    
    %Save the modifications
    save(sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/unarysvmBase'),'unarysvmBase','unarysvmBaseCount');
    clear unarysvmBase unarysvmBaseCount;
end

%--------------------------------------------------------------------------
% Pairwise
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.pairwise.destmatpath)
    if ~exist([tDir,'pairwise/pairwiseBase.mat'],'file')
        pairwiseBase={};
        pairwiseBaseCount=0;
        vl_xmkdir([tDir,'pairwise']);
    else
        tmp=load([tDir,'pairwise/pairwiseBase.mat']);
        pairwiseBaseCount=tmp.pairwiseBaseCount;
        pairwiseBase=tmp.pairwiseBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:pairwiseBaseCount
        ctr=isequal(pairwiseBase{i}.pairwise.params,obj.pairwise.params) && ...
                isequal(pairwiseBase{i}.superpixels.params,obj.superpixels.params);
        if ctr
            obj.pairwise.destmatpath=pairwiseBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.pairwise.destmatpath)
        pairwiseBaseCount=pairwiseBaseCount+1;
        pairwiseBase{pairwiseBaseCount}.pairwise.params=obj.pairwise.params;
        pairwiseBase{pairwiseBaseCount}.superpixels.params=obj.superpixels.params;
        
        %Create folder
        obj.pairwise.destmatpath=[tDir,sprintf('pairwise/%s-%d/',...
            obj.unary.features.method,pairwiseBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.pairwise.destmatpath));
        pairwiseBase{pairwiseBaseCount}.folder=obj.pairwise.destmatpath;
    end
    
    %Save the modifications
    save([tDir,'pairwise/pairwiseBase.mat'],'pairwiseBase','pairwiseBaseCount');
    clear pairwiseBase pairwiseBaseCount;
end

%--------------------------------------------------------------------------
% TopDown dictionary
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.topdown.dictionary.destmatpath) && ~isempty(obj.topdown.features.method)
    if ~exist([tDir,'topdown_dictionary/topdown_dictionaryBase.mat'],'file')
        topdown_dictionaryBase={};
        topdown_dictionaryBaseCount=0;
        vl_xmkdir([tDir,'topdown_dictionary']);
    else
        tmp=load([tDir,'topdown_dictionary/topdown_dictionaryBase.mat']);
        topdown_dictionaryBaseCount=tmp.topdown_dictionaryBaseCount;
        topdown_dictionaryBase=tmp.topdown_dictionaryBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:topdown_dictionaryBaseCount
        ctr=isequal(topdown_dictionaryBase{i}.dictionary.params,obj.topdown.dictionary.params) && ...
                isequal(topdown_dictionaryBase{i}.features.method,obj.topdown.features.method) && ...
                isequal(topdown_dictionaryBase{i}.features.params,obj.topdown.features.params) && ...
                isequal(topdown_dictionaryBase{i}.superpixels.params,obj.superpixels.params) && ...
                isequal(topdown_dictionaryBase{i}.superpixels.method,obj.superpixels.method);
        if ctr
            obj.topdown.dictionary.destmatpath=topdown_dictionaryBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.topdown.dictionary.destmatpath)
        topdown_dictionaryBaseCount=topdown_dictionaryBaseCount+1;
        topdown_dictionaryBase{topdown_dictionaryBaseCount}.dictionary.params=obj.topdown.dictionary.params;
        topdown_dictionaryBase{topdown_dictionaryBaseCount}.features.params=obj.topdown.features.params;
        topdown_dictionaryBase{topdown_dictionaryBaseCount}.features.method=obj.topdown.features.method;
        topdown_dictionaryBase{topdown_dictionaryBaseCount}.superpixels.params=obj.superpixels.params;
        topdown_dictionaryBase{topdown_dictionaryBaseCount}.superpixels.method=obj.superpixels.method;
        
        %Create folder
        obj.topdown.dictionary.destmatpath=[tDir,sprintf('topdown_dictionary/%s-%d/',...
            obj.topdown.features.method,topdown_dictionaryBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.topdown.dictionary.destmatpath));
        topdown_dictionaryBase{topdown_dictionaryBaseCount}.folder=obj.topdown.dictionary.destmatpath;
    end
    
    %Save the modifications
    save([tDir,'topdown_dictionary/topdown_dictionaryBase.mat'],'topdown_dictionaryBase','topdown_dictionaryBaseCount');
    clear topdown_dictionaryBase topdown_dictionaryBaseCount;
end

%--------------------------------------------------------------------------
% TopDown Unary
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.topdown.unary.destmatpath) && ~isempty(obj.topdown.features.method)
    if ~exist([tDir,'topdownUnary/topdownUnaryBase.mat'],'file')
        topdownUnaryBase={};
        topdownUnaryBaseCount=0;
        vl_xmkdir([tDir,'topdownUnary']);
    else
        tmp=load([tDir,'topdownUnary/topdownUnaryBase.mat']);
        topdownUnaryBaseCount=tmp.topdownUnaryBaseCount;
        topdownUnaryBase=tmp.topdownUnaryBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:topdownUnaryBaseCount
        ctr=isequal(topdownUnaryBase{i}.topdown.dictionary.params,obj.topdown.dictionary.params) && ...
                isequal(topdownUnaryBase{i}.topdown.features.method,obj.topdown.features.method) && ...
                isequal(topdownUnaryBase{i}.topdown.features.params,obj.topdown.features.params) && ...
                isequal(topdownUnaryBase{i}.superpixels.params,obj.superpixels.params) && ...
                isequal(topdownUnaryBase{i}.superpixels.method,obj.superpixels.method);
        if ctr
            obj.topdown.unary.destmatpath=topdownUnaryBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.topdown.unary.destmatpath)
        topdownUnaryBaseCount=topdownUnaryBaseCount+1;
        topdownUnaryBase{topdownUnaryBaseCount}.topdown.dictionary.params=obj.topdown.dictionary.params;
        topdownUnaryBase{topdownUnaryBaseCount}.topdown.features.params=obj.topdown.features.params;
        topdownUnaryBase{topdownUnaryBaseCount}.topdown.features.method=obj.topdown.features.method;
        topdownUnaryBase{topdownUnaryBaseCount}.superpixels.params=obj.superpixels.params;
        topdownUnaryBase{topdownUnaryBaseCount}.superpixels.method=obj.superpixels.method;
        
        
        %Create folder
        obj.topdown.unary.destmatpath=[tDir,sprintf('topdownUnary/%s-%d/',...
            obj.topdown.features.method,topdownUnaryBaseCount),'%s.mat'];
        vl_xmkdir(fileparts(obj.topdown.unary.destmatpath));
        topdownUnaryBase{topdownUnaryBaseCount}.folder=obj.topdown.unary.destmatpath;
    end
    
    %Save the modifications
    save([tDir,'topdownUnary/topdownUnaryBase.mat'],'topdownUnaryBase','topdownUnaryBaseCount');
    clear topdownUnaryBase topdownUnaryBaseCount;
end

%--------------------------------------------------------------------------
% Optimisation directory
%--------------------------------------------------------------------------
%Load / Create 
%(Check if custom user directory)
    
if isempty(obj.optimisation.destmatpath)
    if ~exist([tDir,'optimisation/optimisationBase.mat'],'file')
        optimisationBase={};
        optimisationBaseCount=0;
        vl_xmkdir([tDir,'optimisation']);
    else
        tmp=load([tDir,'optimisation/optimisationBase.mat']);
        optimisationBaseCount=tmp.optimisationBaseCount;
        optimisationBase=tmp.optimisationBase;
    end

    % Check if experiment with these parameters was already done and if yes
    % retrieves folders. If not then creates a new entry.
    for i=1:optimisationBaseCount
        ctr=isequal(obj.optimisation.method,optimisationBase{i}.optimisation.method) && ...
                isequal(obj.optimisation.params,optimisationBase{i}.optimisation.params) && ...
                isequal(optimisationBase{i}.topdown.dictionary.params,obj.topdown.dictionary.params) && ...
                isequal(optimisationBase{i}.topdown.features.method,obj.topdown.features.method) && ...
                isequal(optimisationBase{i}.topdown.features.params,obj.topdown.features.params) && ...
                isequal(optimisationBase{i}.pairwise.params,obj.pairwise.params) && ...
                isequal(optimisationBase{i}.superpixels.params,obj.superpixels.params) && ...
                isequal(optimisationBase{i}.unary.svm.params,obj.unary.svm.params) && ...
                isequal(optimisationBase{i}.unary.svm.trainingset.params,obj.unary.svm.trainingset.params) && ...
                isequal(optimisationBase{i}.unary.features.params,obj.unary.features.params) && ...
                isequal(optimisationBase{i}.unary.dictionary.params,obj.unary.dictionary.params) && ...
                isequal(optimisationBase{i}.unary.features.method,obj.unary.features.method);
        if ctr
            obj.optimisation.destmatpath=sprintf(optimisationBase{i}.folder,'%s',obj.unary.SPneighboorhoodsize);
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.optimisation.destmatpath)
        optimisationBaseCount=optimisationBaseCount+1;
        optimisationBase{optimisationBaseCount}.optimisation.method=obj.optimisation.method;
        optimisationBase{optimisationBaseCount}.optimisation.params=obj.optimisation.params;
        optimisationBase{optimisationBaseCount}.topdown.dictionary.params=obj.topdown.dictionary.params;
        optimisationBase{optimisationBaseCount}.topdown.features.method=obj.topdown.features.method;
        optimisationBase{optimisationBaseCount}.topdown.features.params=obj.topdown.features.params;
        optimisationBase{optimisationBaseCount}.pairwise.params=obj.pairwise.params;
        optimisationBase{optimisationBaseCount}.superpixels.params=obj.superpixels.params;
        optimisationBase{optimisationBaseCount}.unary.features.method=obj.unary.features.method;
        optimisationBase{optimisationBaseCount}.unary.features.params=obj.unary.features.params;
        optimisationBase{optimisationBaseCount}.unary.svm.params=obj.unary.svm.params;
        optimisationBase{optimisationBaseCount}.unary.svm.trainingset.params=obj.unary.svm.trainingset.params;
        optimisationBase{optimisationBaseCount}.unary.dictionary.params=obj.unary.dictionary.params;
        
        %Create folder
        obj.optimisation.destmatpath=[tDir,sprintf('optimisation/%s-%d',...
            obj.optimisation.method,optimisationBaseCount),'/%s_UNBS_',...
            num2str(obj.unary.SPneighboorhoodsize),'.mat'];
        vl_xmkdir(fileparts(obj.optimisation.destmatpath));
        optimisationBase{optimisationBaseCount}.folder=sprintf([tDir,'optimisation/%s/%s_UNBS_%s','.mat'],datenow,'%s','%d');
    end
    
    %Save the modifications
    save([tDir,'optimisation/optimisationBase.mat'],'optimisationBase','optimisationBaseCount');
    clear optimisationBase optimisationBaseCount;
end

obj.destpathmade=1;
obj.dbparams.trainingpath=[tDir,'%s.mat'];
