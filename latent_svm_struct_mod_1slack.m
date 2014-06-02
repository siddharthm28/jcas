function model=latent_svm_struct_mod_1slack(obj,param,miter,C)            
%Performing cutting plane learning for weights subject to positivity
%constraints.
%Input : param with handles like svm_struct, miter maximum number of
%iterations, C balancing constant.
%Output model with weights in model.w

n=length(param.patterns);
model.w=param.w0';
previousw=model.w;
previousw(1)=previousw(1)+1;
opts=optimset('Algorithm','interior-point-convex','Display','off');
iterLatent=1;

while iterLatent<param.nbIterLatent && sum(previousw~=model.w)>0
    iterLatent=iterLatent+1;
    previousw=model.w;
    Sloss=[]; Sfeature=[];
    slack=0;
    flag=1;iter=1;
    feature0=zeros(param.dimension,n);
    % Words can be updated after each epoch or after each run of the SVMSTRUCT
    % To update only after the whole structural svm, remove comment in
    % front of the while iterLatent, the end at the end of the file, the if iter ==1,
    %and the follwoing lines :
    %Use current estimate to get "GT words"
    for i=1:n
        param.words{i}=wordsFnCP(obj,model,param.patterns{i},param.labels{i},param.wordsInd);
    end
    
% while flag
%     fprintf('CP learning : Iter. %d',iter);
%     oldcount=length(Slabel);
%     fprintf(' Image ');
% % Words can be updated after each epoch or after each run of the SVMSTRUCT    
%      %Use current estimate to get "GT words"
%      % Comment these
%     %      for i=1:n
%     %          param.words{i}=wordsFnCP(param,model,param.patterns{i},param.labels{i});
%     %          feature0(:,i)=param.featureFn(param,param.patterns{i},[param.labels{i};param.words{i}']);
%     %          fprintf('Update features and words\n')
%     %      end
%         
%     for i=1:n
%         fprintf('%03d',i);
%         x=param.patterns{i};
%         y=param.labels{i};
%         
%         %Update GT features
%         %if iter==1
%         %    feature0(:,i)=param.featureFn(param,param.patterns{i},[param.labels{i};param.words{i}']);
%         %end
%         
%         %Compute eventually new feature for CP
%         %Call separation oracle
%         yhat=param.constraintFn(param,model,x,[y;param.words{i}']);
%         %Also stores zhat in param.zhat
%         feature_new=param.featureFn(param,x,yhat);
%         
%         lb=[zeros(param.dimension,1);zeros(n,1)];
%         ub=[];
%         
%         %If new violated constraint, add to zorking set and optimize
%         if dot(model.w,feature0(:,i)-feature_new)+param.lossFn(param,y,yhat)>slack(i)+param.eps
%             S=[S,{yhat}];Slabel=[Slabel,i];
%             Sfeature=[Sfeature,feature_new];
%             H=blkdiag(eye(param.dimension),zeros(n));
%             f=[zeros(param.dimension,1);C/n*ones(n,1)];
%             A=zeros(length(Slabel),param.dimension+n);
%             b=zeros(length(Slabel),1);
%             for k=1:length(Slabel)
%                 feature=Sfeature(:,k);
%                 A(k,:)=-[feature'-feature0(:,Slabel(k))',zeros(1,n)];
%                 A(k,length(feature)+Slabel(k))=-1;
%                 b(k)=-param.lossFn(param,param.labels{Slabel(k)},S{k});
%             end
%             w=quadprog(H,f,A,b,[],[],lb,ub,[],opts);
%             model.w=w(1:param.dimension);
%             slack=w(end-n+1:end);
%         end
%         fprintf('\b\b\b');
%     end
%     iter=iter+1;
%     if length(Slabel)==oldcount || iter>miter
%         flag=0;
%     end
%     fprintf('\n');
%     
% end


%end
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
            %yhat=param.constraintFn(param,model,x,y);
              yhat=param.constraintFn(param,model,x,[y;param.words{i}']);
            if iter==1
               % feature0(:,i)=param.featureFn(param,x,y);
               feature0(:,i)=param.featureFn(param,param.patterns{i},[param.labels{i};param.words{i}']);
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
                A(k,:)=[(feature0_sum'-feature')./n,-1];
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
