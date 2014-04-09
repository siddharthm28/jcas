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
if ~exist(rootDir,'dir')
    mkdir(rootDir);
end

%--------------------------------------------------------------------------
%Superpixels
%--------------------------------------------------------------------------
%Load / Create superpixels data
%(Check if custom user directory)
    
if isempty(obj.superpixels.destmatpath)
if ~exist([rootDir,'superpixels/superpixelsBase.mat'],'file')
    superpixelsBase={};
    superpixelsBaseCount=0;
    mkdir([rootDir,'superpixels']);
else
    tmp=load([rootDir,'superpixels/superpixelsBase.mat']);
    superpixelsBase=tmp.superpixelsBase;
    superpixelsBaseCount=tmp.superpixelsBaseCount;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:superpixelsBaseCount
        if isequal(superpixelsBase{i}.params,obj.superpixels.params) && ...
                isequal(superpixelsBase{i}.method,obj.superpixels.method)
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
        obj.superpixels.destmatpath=sprintf([rootDir,'superpixels/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([rootDir,'superpixels/%s/'],datenow));
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
    
if isempty(obj.unary.features.destmatpath)
if ~exist([rootDir,'unary_features/unary_featuresBase.mat'],'file')
    unary_featuresBase={};
    unary_featuresBaseCount=0;
    mkdir([rootDir,'unary_features']);
else
    tmp=load([rootDir,'unary_features/unary_featuresBase.mat']);
    unary_featuresBaseCount=tmp.unary_featuresBaseCount;
    unary_featuresBase=tmp.unary_featuresBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.

    %Check the previous experiments
    for i=1:unary_featuresBaseCount
        if isequal(unary_featuresBase{i}.method,obj.unary.features.method) && ...
                isequal(unary_featuresBase{i}.params,obj.unary.features.params)
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
        obj.unary.features.destmatpath=sprintf([rootDir,'unary_features/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([rootDir,'unary_features/%s/'],datenow));
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
    
if isempty(obj.topdown.features.destmatpath)
if ~exist([rootDir,'topdown_features/topdown_featuresBase.mat'],'file')
    topdown_featuresBase={};
    topdown_featuresBaseCount=0;
    mkdir([rootDir,'topdown_features']);
else
    tmp=load([rootDir,'topdown_features/topdown_featuresBase.mat']);
    topdown_featuresBase=tmp.topdown_featuresBase;
    topdown_featuresBaseCount=tmp.topdown_featuresBaseCount;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:topdown_featuresBaseCount
        if isequal(topdown_featuresBase{i}.params,obj.topdown.features.params) && ...
                isequal(topdown_featuresBase{i}.method,obj.topdown.features.method)
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
        obj.topdown.features.destmatpath=sprintf([rootDir,'topdown_features/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([rootDir,'topdown_features/%s/'],datenow));
        topdown_featuresBase{topdown_featuresBaseCount}.folder=obj.topdown.features.destmatpath;
    end
    
    %Save the modifications
    save([rootDir,'topdown_features/topdown_featuresBase.mat'],'topdown_featuresBase','topdown_featuresBaseCount');
    clear topdown_featuresBase topdown_featuresBaseCount;
end


% %--------------------------------------------------------------------------
% % Pre-processing directory
% %--------------------------------------------------------------------------
% % Includes superpixels histograms with SP+unary features.
% 
% if isempty(obj.preprocessing.destmatpath)
% if ~exist([rootDir,'preprocessing/preprocessingBase.mat'],'file')
%     preprocessingBase={};
%     preprocessingBaseCount=0;
%     mkdir([rootDir,'preprocessing']);
% else
%     load([rootDir,'preprocessing/preprocessingBase.mat']);
% end
% 
% % Check if experiment with these parameters was already done and if yes
% % retrieves folders. If not then creates a new entry.
% 
% 
%     %Check the previous experiments
%     for i=1:preprocessingBaseCount
%         if isequal(preprocessingBase{i}.params,obj.topdown.features.params) && ...
%                 isequal(topdown_featuresBase{i}.method,obj.topdown.features.method)
%             obj.topdown.features.destmatpath=topdown_featuresBase{i}.folder;
%             break;
%         end
%     end
%     
%     %If not in the previous, create a new exp
%     if isempty(obj.preprocessing.destmatpath)
%        preprocessingBaseCount=preprocessingBaseCount+1;
%         preprocessingBase{preprocessingBaseCount}.params=
%         
%         %Create folder
%         obj.preprocessing.destmatpath=sprintf([rootDir,'preprocessing/%s/%s.mat'],datenow,'%s');
%         mkdir(sprintf([rootDir,'preprocessing/%s/'],datenow));
%         preprocessingBase{preprocessingBaseCount}.folder=obj.preprocessing.destmatpath;
%     end
%     
%     %Save the modifications
%     save([rootDir,'preprocessing/preprocessingBase.mat'],'preprocessingBase','preprocessingBaseCount');
%     clear preprocessingBase preprocessingBaseCount;
% end
% 
% 
% %--------------------------------------------------------------------------


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
    if isequal(trainBase{i}.training,obj.dbparams.training)
        tDir=trainBase{i}.folder;        
        break;
    end
end

%If not in the previous, create a new exp
if isempty(tDir)
    trainBaseCount=trainBaseCount+1;
    trainBase{trainBaseCount}.training=obj.dbparams.training;
    
    %Create folder
    tDir=sprintf([rootDir,'Train_%s/'],datenow);
    mkdir(tDir);
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
    
if isempty(obj.unary.dictionary.destmatpath)
if ~exist([tDir,'unary_dictionary/unary_dictionaryBase.mat'],'file')
    unary_dictionaryBase={};
    unary_dictionaryBaseCount=0;
    mkdir([tDir,'unary_dictionary']);
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
        if isequal(unary_dictionaryBase{i}.dictionary.params,obj.unary.dictionary.params) && ...
                isequal(unary_dictionaryBase{i}.features.method,obj.unary.features.method) &&...
                isequal(unary_dictionaryBase{i}.features.params,obj.unary.features.params)
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
        obj.unary.dictionary.destmatpath=sprintf([tDir,'unary_dictionary/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([tDir,'unary_dictionary/%s/'],datenow));
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
    mkdir([tDir,'unary']);
else
    tmp=load([tDir,'unary/unaryBase.mat']);
    unaryBaseCount=tmp.unaryBaseCount;
    unaryBase=tmp.unaryBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:unaryBaseCount
        if isequal(unaryBase{i}.unary.features.params,obj.unary.features.params) && ...
                isequal(unaryBase{i}.unary.features.method,obj.unary.features.method) && ...
                isequal(unaryBase{i}.unary.dictionary.params,obj.unary.dictionary.params) && ...
                isequal(unaryBase{i}.superpixels.params,obj.superpixels.params)
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
        %Create folder
        obj.unary.destmatpath=sprintf([tDir,'unary/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([tDir,'unary/%s/'],datenow));
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
    
if isempty(obj.unary.svm.trainingset.destmatpath)
if ~exist(sprintf(obj.unary.destmatpath,'unarytestsvm/unarytestsvmBase'),'file')
    unarytestsvmBase={};
    unarytestsvmBaseCount=0;
    dirS=sprintf(obj.unary.destmatpath,'unarytestsvm/%s');
    mkdir(dirS(1:end-6));
else
    tmp=load(sprintf(obj.unary.destmatpath,'unarytestsvm/unarytestsvmBase'));
    unarytestsvmBase=tmp.unarytestsvmBase;
    unarytestsvmBaseCount=tmp.unarytestsvmBaseCount;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:unarytestsvmBaseCount
        if isequal(unarytestsvmBase{i}.params,obj.unary.svm.trainingset.params)
            obj.unary.svm.trainingset.destmatpath=unarytestsvmBase{i}.folder;
            break;
        end
    end
    
    %If not in the previous, create a new exp
    if isempty(obj.unary.svm.trainingset.destmatpath)
        unarytestsvmBaseCount=unarytestsvmBaseCount+1;
        unarytestsvmBase{unarytestsvmBaseCount}.params=obj.unary.svm.trainingset.params;
        
        %Create folder
        obj.unary.svm.trainingset.destmatpath=sprintf(obj.unary.destmatpath,sprintf('unarytestsvm/%s/%s',datenow,'%s'));
        mkdir(obj.unary.svm.trainingset.destmatpath(1:end-6));
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
    
if isempty(obj.unary.svm.destmatpath)
if ~exist(sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/unarysvmBase'),'file')
    unarysvmBase={};
    unarysvmBaseCount=0;
    dirS=sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/%s');
    mkdir(dirS(1:end-6));
else
    tmp=load(sprintf(obj.unary.svm.trainingset.destmatpath,'unarysvm/unarysvmBase'));
    unarysvmBaseCount=tmp.unarysvmBaseCount;
    unarysvmBase=tmp.unarysvmBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
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
        obj.unary.svm.destmatpath=sprintf(obj.unary.svm.trainingset.destmatpath,sprintf('unarysvm/%s/%s',datenow,'%s'));
        mkdir(obj.unary.svm.destmatpath(1:end-6));
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
    mkdir([tDir,'pairwise']);
else
    tmp=load([tDir,'pairwise/pairwiseBase.mat']);
    pairwiseBaseCount=tmp.pairwiseBaseCount;
    pairwiseBase=tmp.pairwiseBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:pairwiseBaseCount
        if isequal(pairwiseBase{i}.pairwise.params,obj.pairwise.params) && ...
                isequal(pairwiseBase{i}.superpixels.params,obj.superpixels.params)
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
        obj.pairwise.destmatpath=sprintf([tDir,'pairwise/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([tDir,'pairwise/%s/'],datenow));
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
    
if isempty(obj.topdown.dictionary.destmatpath)
if ~exist([tDir,'topdown_dictionary/topdown_dictionaryBase.mat'],'file')
    topdown_dictionaryBase={};
    topdown_dictionaryBaseCount=0;
    mkdir([tDir,'topdown_dictionary']);
else
    tmp=load([tDir,'topdown_dictionary/topdown_dictionaryBase.mat']);
    topdown_dictionaryBaseCount=tmp.topdown_dictionaryBaseCount;
    topdown_dictionaryBase=tmp.topdown_dictionaryBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:topdown_dictionaryBaseCount
        if isequal(topdown_dictionaryBase{i}.dictionary.params,obj.topdown.dictionary.params) && ...
                isequal(topdown_dictionaryBase{i}.features.method,obj.topdown.features.method) && ...
                isequal(topdown_dictionaryBase{i}.features.params,obj.topdown.features.params) && ...
                isequal(topdown_dictionaryBase{i}.superpixels.params,obj.superpixels.params) && ...
                isequal(topdown_dictionaryBase{i}.superpixels.method,obj.superpixels.method)
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
        obj.topdown.dictionary.destmatpath=sprintf([tDir,'topdown_dictionary/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([tDir,'topdown_dictionary/%s/'],datenow));
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
    
if isempty(obj.topdown.unary.destmatpath)
if ~exist([tDir,'topdownUnary/topdownUnaryBase.mat'],'file')
    topdownUnaryBase={};
    topdownUnaryBaseCount=0;
    mkdir([tDir,'topdownUnary']);
else
    tmp=load([tDir,'topdownUnary/topdownUnaryBase.mat']);
    topdownUnaryBaseCount=tmp.topdownUnaryBaseCount;
    topdownUnaryBase=tmp.topdownUnaryBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.


    %Check the previous experiments
    for i=1:topdownUnaryBaseCount
        if isequal(topdownUnaryBase{i}.topdown.dictionary.params,obj.topdown.dictionary.params) && ...
                isequal(topdownUnaryBase{i}.topdown.features.method,obj.topdown.features.method) && ...
                isequal(topdownUnaryBase{i}.topdown.features.params,obj.topdown.features.params) && ...
                isequal(topdownUnaryBase{i}.superpixels.params,obj.superpixels.params) && ...
                isequal(topdownUnaryBase{i}.superpixels.method,obj.superpixels.method)
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
        obj.topdown.unary.destmatpath=sprintf([tDir,'topdownUnary/%s/%s.mat'],datenow,'%s');
        mkdir(sprintf([tDir,'topdownUnary/%s/'],datenow));
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
    mkdir([tDir,'optimisation']);
else
    tmp=load([tDir,'optimisation/optimisationBase.mat']);
    optimisationBaseCount=tmp.optimisationBaseCount;
    optimisationBase=tmp.optimisationBase;
end

% Check if experiment with these parameters was already done and if yes
% retrieves folders. If not then creates a new entry.

    %Check the previous experiments
    for i=1:optimisationBaseCount
        if isequal(obj.optimisation.method,optimisationBase{i}.optimisation.method) && ...
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
                isequal(optimisationBase{i}.unary.features.method,obj.unary.features.method)
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
        obj.optimisation.destmatpath=sprintf([tDir,'optimisation/%s/%s_UNBS_%d.mat'],datenow,'%s',obj.unary.SPneighboorhoodsize);
        mkdir(sprintf([tDir,'optimisation/%s/'],datenow));
        optimisationBase{optimisationBaseCount}.folder=sprintf([tDir,'optimisation/%s/%s_UNBS_%s','.mat'],datenow,'%s','%d');
    end
    
    %Save the modifications
    save([tDir,'optimisation/optimisationBase.mat'],'optimisationBase','optimisationBaseCount');
    clear optimisationBase optimisationBaseCount;
end

obj.destpathmade=1;
obj.dbparams.trainingpath=[tDir,'%s.mat'];

end
