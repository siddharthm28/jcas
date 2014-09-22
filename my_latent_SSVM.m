function model=my_latent_SSVM(obj,param,miter,C,type)            
%Performing cutting plane learning for weights subject to positivity
%constraints.
%Input : param with handles like svm_struct, miter maximum number of
%iterations, C balancing constant.
%Output model with weights in model.w

n=length(param.patterns);
d=param.dimension;
model.w=param.w0';
model.wMat = rand(d,n); 
previousw=model.w;
previousw(1)=previousw(1)+1;
opts=optimset('Algorithm','interior-point-convex','Display','off');
iterLatent=1;

while iterLatent<param.nbIterLatent && sum(previousw~=model.w)>0
    iterLatent=iterLatent+1;
    previousw=model.w;
    % Words can be updated after each epoch or after each run of the SVMSTRUCT
    % To update only after the whole structural svm, remove comment in
    % front of the while iterLatent, the end at the end of the file, the if iter ==1,
    %and the follwoing lines :
    %Use current estimate to get "GT words"
    for i=1:n
        param.words{i}=wordsFnCP(obj,model,param.patterns{i},param.labels{i},param.wordsInd);
    end
    
    % learn the SSVM with the current words
    options.num_passes=miter;
    options.lambda=1/C;
    options.gap_check=100;
    options.w=model.w;
%     options.wMat=model.wMat;
    switch type
        case 'ssg'
            [model,progress]=latent_solverSSGpos(param,options);
        case 'fw'
            [model,progress]=latent_solverFWpos(param,options);
        case 'bcfw'
            [model,progress]=latent_solverBCFWpos(param,options);
    end
    
end
