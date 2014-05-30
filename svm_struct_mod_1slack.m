function model=svm_struct_mod_1slack(param,miter,C)            
%Performing cutting plane learning for weights subject to positivity
%constraints.
%Input : param with handles like svm_struct, miter maximum number of
%iterations, C balancing constant.
%Output model with weights in model.w

n=length(param.patterns); Sfeature=[]; Sloss=[];
slack=0;
flag=1;iter=1;
feature0=zeros(param.dimension,n);
model.w=param.w0;
opts=optimset('Algorithm','interior-point-convex','Display','off');


while flag
        fprintf('CP learning : Iter. %d',iter);
        
        fprintf(' Image ');
        feature_sum=zeros(size(model.w,1),1);
        loss_sum=0;
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
            feature_sum=feature_sum+feature_new;
            feature0_sum=sum(feature0,2);
            loss_sum=loss_sum+param.lossFn(param,y,yhat);
            fprintf('\b\b\b');
        end 
        
        lb=[zeros(param.dimension+1,1);];
        ub=[];
        
        %If new violated constraint, add to working set and optimize
        if (dot(model.w,sum(feature0,2)-feature_sum)+loss_sum)/n>slack+param.eps
            Sloss=[Sloss,loss_sum];
            Sfeature=[Sfeature,feature_sum];
            H=blkdiag(eye(param.dimension),zeros(1));
            f=[zeros(param.dimension,1);C];
            A=zeros(length(Sloss),param.dimension+1);
            b=zeros(length(Sloss),1);
            for k=1:length(Sloss)
                feature=Sfeature(:,k);
                A(k,:)=[(feature0_sum'-feature')./n,1];
                b(k)=-Sloss(k)/n;
            end
            w=quadprog(H,f,A,b,[],[],lb,ub,[],opts);
            model.w=w(1:param.dimension);
            slack=w(end);
        else
            flag=0;
        end
        
    
    iter=iter+1;
    if iter>miter
        flag=0;
    end
    fprintf('\n');
    
end


end
