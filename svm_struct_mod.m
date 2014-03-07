function model=svm_struct_mod(param,miter,C)            
%Performing cutting plane learning for weights subject to positivity
%constraints.
%Input : param with handles like svm_struct, miter maximum number of
%iterations, C balancing constant.
%Output model with weights in model.w

n=length(param.patterns);
S=[]; Slabel=[]; Sfeature=[];
slack=zeros(1,n);
flag=1;iter=1;
feature0=zeros(param.dimension,n);
model.w=param.w0;
opts=optimset('Algorithm','interior-point-convex','Display','off');


while flag
    fprintf('CP learning : Iter. %d',iter);
    oldcount=length(Slabel);
            fprintf(' Image ');
    for i=1:n
        fprintf('%03d',i);
        x=param.patterns{i};
        y=param.labels{i};
        %Call separation oracle
        yhat=param.constraintFn(param,model,x,y);
        
        if iter==1
            feature0(:,i)=param.featureFn(param,x,y);
        end
        feature_new=param.featureFn(param,x,yhat);
        
        lb=[zeros(param.dimension,1);zeros(n,1)];
        ub=[];
        
        %If new violated constraint, add to zorking set and optimize
        if dot(model.w,feature0(:,i)-feature_new)+param.lossFn(param,y,yhat)>slack(i)+param.eps
            S=[S,{yhat}];Slabel=[Slabel,i];
            Sfeature=[Sfeature,feature_new];
            H=blkdiag(eye(param.dimension),zeros(n));
            f=[zeros(param.dimension,1);C/n*ones(n,1)];
            A=zeros(length(Slabel),param.dimension+n);
            b=zeros(length(Slabel),1);
            for k=1:length(Slabel)
                feature=Sfeature(:,k);
                A(k,:)=-[feature'-feature0(:,Slabel(k))',zeros(1,n)];
                A(k,length(feature)+Slabel(k))=-1;
                b(k)=-param.lossFn(param,param.labels{Slabel(k)},S{k});
            end
            w=quadprog(H,f,A,b,[],[],lb,ub,[],opts);
            model.w=w(1:param.dimension);
            slack=w(end-n+1:end);
        end
        fprintf('\b\b\b');
    end
    iter=iter+1;
    if length(Slabel)==oldcount || iter>miter
        flag=0;
    end
    fprintf('\n');
    
end


end
