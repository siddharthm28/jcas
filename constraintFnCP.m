function yMostViolatedLabel=constraintFnCP(obj,param,model,x,y)
% Add switch for inference method

switch obj.mode
    case 1 % U+P
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
        tmp=load(unary_filename,'unary'); unary=tmp.unary;
        gt_h=y';
        
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        unary=(model.w(1)*unary - hamming);
        pairwise=sparse(model.w(2)*(pairwise));
        
        [~, yMostViolatedLabel] =  min(unary,[],2); %min(unary',[],1);
        labelcost_total = ones(obj.dbparams.ncat)-eye(obj.dbparams.ncat);
        if (model.w(2)~=0) %%% USING PAIRWISE
            [seg2,~,~] =  GCMex(yMostViolatedLabel'-1, single(unary'), pairwise, single(labelcost_total),0);
            yMostViolatedLabel = seg2+1;
        end
        yMostViolatedLabel=yMostViolatedLabel(:);
        
    case 2
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l delta(l present in interest points)
        wBu=model.w(1:2);
        alphaTd=model.w(3:end-obj.dbparams.ncat);
        betaTd=model.w(end-obj.dbparams.ncat+1:end);
        
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
        tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
        tmp=load(unary_filename,'unary'); unary=tmp.unary;
        gt_h=y';
        
        
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));       
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        %Compute topdown Energy map labelHist
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        tmp=load(topdown_unary_filename,'topdown_unary','topdown_count');
        topdown_unary=tmp.topdown_unary; topdown_count=tmp.topdown_count;
        %Unary matrix for Topdown
        alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
        %Coeff of entries in topdown_unary
        topdownU=(topdown_unary)*alphaMat;
        
        %Perform Graph cuts to find most violated constraint.
        unaryC=wBu(1)*unary-hamming+topdownU;
        pairwiseC=sparse(wBu(2)*pairwise);
        
        %%%%%%%%% INFERENCE %%%%%%%%
        %Interest points extraction
        IP=find(topdown_count>0);
        nbIP=topdown_count(IP);
        
        %Stop condition if no possible improvement
        success=1;
        %Data preload
        [~,initSeg]=min(unaryC,[],2);
        yMostViolatedLabel=initSeg';
        if (model.w(2)>0)
            %Rescale costs if neg
            betaTdb=betaTd;
            nbSp=size(unary,1);
            
            %Energy
            E=0;
            E=E+sum(unaryC((1:size(unary,1))+(yMostViolatedLabel-1)*size(unary,1)));
            edge_cost = pairwiseC(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
            E=E+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
            %labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
            labelPres=zeros(obj.dbparams.ncat,1);
            
            for l=1:obj.dbparams.ncat
                %v=sum(topdown_unary(yMostViolatedLabel'==l,:),1);
                %labelHist(:,l)=v;
                labelPres(l)=ismember(l,yMostViolatedLabel(IP));
            end
            
            %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
            %alphas_(l,k), then beta_l
            %Already in unaryC
            %E=E+dot(alphaTdb,labelHist(:));
            
            %Then betas
            %normLabelHist=sum(labelHist,1); % (1,nb labels)
            
            
            
            E=E+dot(betaTdb,labelPres);
            
            %%%%%% End Energy computation


            Ebefore=E;
            maxIter=100;
            iter=0;
            while success==1 && iter<=maxIter
                success=0;
                iter=iter+1;
                labperm=randperm(obj.dbparams.ncat);
                for ilab=1:obj.dbparams.ncat
                    %Pick one label
                    chosenLabel=labperm(ilab);

                    %New segmentation
                    propSeg=alpha_expansion_labelcost(chosenLabel,yMostViolatedLabel,img_sp,unaryC,edge_cost,betaTdb,IP,nbIP);
                    

                    %Compute Energy
                    Eafter=0;
                    Eafter=Eafter+sum(unaryC(sub2ind(size(unary),(1:size(unary,1)),double(propSeg(:))')));
                    Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                    for l=1:obj.dbparams.ncat
                      %  v=sum(topdown_unary(propSeg'==l,:),1);
                       % labelHist(:,l)=v;
                        labelPres(l)=ismember(l,propSeg(IP));
                    end
                    Eafter=Eafter+dot(labelPres,betaTdb);
                    
                    
                    if Eafter<Ebefore
                        yMostViolatedLabel=propSeg;
                        Ebefore=Eafter;
                        success=1;
                    end
                end
            end
        end
        
        yMostViolatedLabel=yMostViolatedLabel(:);
        optsvm=model;
        save(sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode)),'optsvm');
        
    case 3
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l delta(l present in labeling) (NEW)
        wBu=model.w(1:2);
        alphaTd=model.w(3:end-obj.dbparams.ncat);
        betaTd=model.w(end-obj.dbparams.ncat+1:end);
        
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
        tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
        tmp=load(unary_filename,'unary'); unary=tmp.unary;
        gt_h=y';
        
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));      
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        %Compute topdown Energy map labelHist
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        tmp=load(topdown_unary_filename,'topdown_unary','topdown_count');
        topdown_unary=tmp.topdown_unary; topdown_count=tmp.topdown_count;
        %Unary matrix for Topdown
        alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
        %Coeff of entries in topdown_unary
        topdownU=(topdown_unary)*alphaMat;
        
        %Perform Graph cuts to find most violated constraint.
        unaryC=wBu(1)*unary-hamming+topdownU;
        pairwiseC=sparse(wBu(2)*pairwise);
        
        %%%%%%%%% INFERENCE %%%%%%%%
        %Interest points extraction
        IP=(1:length(topdown_count))';
        
        %Stop condition if no possible improvement
        success=1;
        %Data preload
        [~,initSeg]=min(unaryC,[],2);
        yMostViolatedLabel=initSeg';
        if (model.w(2)>0)
            %Rescale costs if neg
            betaTdb=betaTd;
            nbSp=size(unary,1);
            
            %Energy
            E=0;
            E=E+sum(unaryC(sub2ind(size(unary),(1:size(unary,1)),double(yMostViolatedLabel(:))')));
            edge_cost = pairwiseC(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
            E=E+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
            labelPres=zeros(obj.dbparams.ncat,1);
            
            for l=1:obj.dbparams.ncat
                %v=sum(topdown_unary(yMostViolatedLabel'==l,:),1);
                %labelHist(:,l)=v;
                labelPres(l)=ismember(l,yMostViolatedLabel(IP));
            end
            
            %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
            %alphas_(l,k), then beta_l
            %Already in unaryC
            %E=E+dot(alphaTdb,labelHist(:));
            
            %Then betas
            %normLabelHist=sum(labelHist,1); % (1,nb labels)
            
            
            
            E=E+dot(betaTdb,labelPres);
            
            %%%%%% End Energy computation


            Ebefore=E;
            maxIter=100;
            iter=0;
            while success==1 && iter<=maxIter
                success=0;
                iter=iter+1;
                labperm=randperm(obj.dbparams.ncat);
                for ilab=1:obj.dbparams.ncat
                    %Pick one label
                    chosenLabel=labperm(ilab);

                    %New segmentation
                    propSeg=alpha_expansion_labelcost(chosenLabel,yMostViolatedLabel,img_sp,unaryC,edge_cost,betaTdb,IP,ones(size(IP)));
                    

                    %Compute Energy
                    Eafter=0;
                    Eafter=Eafter+sum(unaryC(sub2ind(size(unary),(1:size(unary,1)),double(propSeg(:))')));
                    Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                    for l=1:obj.dbparams.ncat
                      %  v=sum(topdown_unary(propSeg'==l,:),1);
                       % labelHist(:,l)=v;
                        labelPres(l)=ismember(l,propSeg(IP));
                    end
                    Eafter=Eafter+dot(labelPres,betaTdb);
                    
                    
                    if Eafter<Ebefore
                        yMostViolatedLabel=propSeg;
                        Ebefore=Eafter;
                        success=1;
                    end
                end
            end
        end
        
        yMostViolatedLabel=yMostViolatedLabel(:);
        optsvm=model;
        save(sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode)),'optsvm');
                
    case 4
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l *||h_l||
        
        %Weights
        wBu=model.w(1:2);
        alphaTd=model.w(3:end-obj.dbparams.ncat);
        betaTd=model.w(end-obj.dbparams.ncat+1:end);
        
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
        tmp=load(unary_filename,'unary'); unary=tmp.unary;
        gt_h=y';
        
        
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        %Compute topdown Energy map labelHist
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        tmp=load(topdown_unary_filename,'topdown_unary');
        topdown_unary=tmp.topdown_unary;
        %Unary matrix for Topdown
        alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary obj.dbparams.ncat]);
        betaMat=repmat(betaTd(:)',[obj.topdown.dictionary.params.size_dictionary 1]);
        %Coeff of entries in topdown_unary
        topdownU=(topdown_unary)*(alphaMat+betaMat);
        
        %Perform Graph cuts to find most violated constraint.
        unary=wBu(1)*unary-hamming+topdownU;
        pairwise=sparse(wBu(2)*pairwise);
        
        [~, initSeg] =  min(unary,[],2); %min(unary',[],1);
        yMostViolatedLabel=initSeg';
        labelcost_total = ones(obj.dbparams.ncat)-eye(obj.dbparams.ncat);
        if (model.w(2)>0) %%% USING PAIRWISE
            [seg2,~,~] =  GCMex(yMostViolatedLabel-1, single((unary)'), pairwise, single(labelcost_total),0);
            yMostViolatedLabel = seg2+1;
        end
        yMostViolatedLabel=yMostViolatedLabel(:);
        
    case 5
        %U+P+label cost

        wBu=model.w(1:2);
        betaTd=model.w(end-obj.dbparams.ncat+1:end);
        
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
        tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
        tmp=load(unary_filename,'unary'); unary=tmp.unary;
        gt_h=y';
        
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));  
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        %Perform Graph cuts to find most violated constraint.
        unary=wBu(1)*unary-hamming;
        pairwise=sparse(wBu(2)*pairwise);
        
        %%%%%%%%% INFERENCE %%%%%%%%
        %Stop condition if no possible improvement
        success=1;
        %Data preload
        [~,initSeg]=min(unary,[],2);
        yMostViolatedLabel=initSeg';

        if (model.w(2)>0)
            
            %Rescale costs if neg
            betaTdb=betaTd;
            nbSp=size(unary,1);
            
            %Energy
            %E=zeros(1,param.dimension);
            E=sum(unary(sub2ind(size(unary),(1:size(unary,1)),double(yMostViolatedLabel(:))')));
            edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
            E=E+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
            labelPres=zeros(obj.dbparams.ncat,1);
            
            for l=1:obj.dbparams.ncat
                labelPres(l)=ismember(l,yMostViolatedLabel);
            end

            %Then betas
            %normLabelHist=sum(labelHist,1); % (1,nb labels)
            E=E+dot(labelPres(:),model.w(3:end));
            
            %%%%%% End Energy computation


            Ebefore=E;
            maxIter=100;
            iter=0;
            while success==1 && iter<=maxIter
                success=0;
                iter=iter+1;
                labperm=randperm(obj.dbparams.ncat);
                for ilab=1:obj.dbparams.ncat
                    %Pick one label
                    chosenLabel=labperm(ilab);

                    %New segmentation
                    propSeg=alpha_expansion_labelcost(chosenLabel,yMostViolatedLabel,img_sp,unary,edge_cost,betaTdb,(1:size(unary,1))',ones(size(1:size(unary,1)))');
                    

                    %Compute Energy
                    %E=zeros(1,param.dimension);
                    Eafter=sum(unary(sub2ind(size(unary),(1:size(unary,1)),double(propSeg(:))')));
                    Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                    labelPres=zeros(obj.dbparams.ncat,1);
                    for l=1:obj.dbparams.ncat
                        labelPres(l)=ismember(l,propSeg);
                    end
                    Eafter=Eafter+dot(labelPres(:),model.w(3:end));
                    
                    if Eafter<Ebefore
                        yMostViolatedLabel=propSeg;
                        Ebefore=Eafter;
                        success=1;
                    end
                end
            end
        elseif model.w(2)<0
            error('negative weight w2')       
        end
        
        yMostViolatedLabel=yMostViolatedLabel(:);
        optsvm=model;
        save(sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode)),'optsvm');
        
    case 6
        %Unary Pairwise + intersection kernel (PAMI)
        
        %Load data
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));        
        tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
        tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
        tmp=load(unary_filename,'unary'); unary=tmp.unary;
        tmp=load(topdown_unary_filename,'topdown_unary'); topdown_unary=tmp.topdown_unary;
        
        %Hamming 
        gt_h=y';
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));       
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        unaryC=model.w(1)*unary-hamming;
        %Initialization of the most violated constraint
        [~,initSeg]=min(unaryC,[],2);
        yMostViolatedLabel=initSeg';
        %Compute energy before graph cut
        %Histograms of the segmentation
        segHist=compute_label_histograms(yMostViolatedLabel,topdown_unary,obj.dbparams.ncat);
        
        %Energy
       % Ebefore=dot(model.w,param.featureFn(param,x,yMostViolatedLabel));
         %E=zeros(1,length(model.w));
        ind=sub2ind(size(unary),(1:size(unary,1)),double(yMostViolatedLabel(:))');
        E=sum(unaryC(ind));
        
        %pairwise
        pairwise = sparse(pairwise);
        edge_cost = model.w(2)*pairwise(img_sp.edges(:,1)+img_sp.nbSp*(img_sp.edges(:,2)-1));
        E=E+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
        
        %Intersection kernel part

        segHists=compute_label_histograms(yMostViolatedLabel,topdown_unary,obj.dbparams.ncat);
        
        E=E+dot(model.w(3:end-obj.dbparams.ncat),compute_intersection_kernel(segHists,param.tHistograms,obj.dbparams.ncat));
        
        %Histograms norms
        E=E+dot(model.w(end-obj.dbparams.ncat+1:end),(sum(segHists,1)>0));      
        Ebefore=E;
        %Perform graph cut
        iter=0;
        miter=100;
        success=1;
        if model.w(2)>0
            while iter<=miter && success==1;
                success=0;
                iter=iter+1;
                labperm=randperm(obj.dbparams.ncat);
                for ilab=1:obj.dbparams.ncat
                    %Pick one label
                    chosenLabel=labperm(ilab);
                    
                    %New segmentation

                    propSeg=alpha_expansion_intersection(chosenLabel,yMostViolatedLabel,img_sp,unaryC,edge_cost,topdown_unary,param.tHistograms,model.w(3:end-obj.dbparams.ncat),model.w(end-obj.dbparams.ncat+1:end));
                    ind=sub2ind(size(unary),([1:size(unary,1)]),double(propSeg(:))');
                    E=sum(unaryC(ind));
                    
                    %pairwise
                    E =E+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                    
                    %Intersection kernel part
                    
                    segHists=compute_label_histograms(propSeg,topdown_unary,obj.dbparams.ncat);
                    E=E+dot(model.w(3:end-obj.dbparams.ncat),compute_intersection_kernel(segHists,param.tHistograms,obj.dbparams.ncat));
                    
                    %Histograms norms
                    E=E+dot(model.w(end-obj.dbparams.ncat+1:end),(sum(segHists,1)>0));  
                    %Perform graph cut
                    Eafter=E;
                    if Eafter<Ebefore
                        Ebefore=Eafter;
                        yMostViolatedLabel=propSeg;
                        success=1;
                    end
                    
                end
            end
        end
        
        yMostViolatedLabel=yMostViolatedLabel(:);
        optsvm=model;
        save(sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode)),'optsvm');
    
    case 7
        %Latent + Linear TD
        latentOffset=2+obj.dbparams.ncat*(obj.topdown.dictionary.params.size_dictionary+1);
        wBu=model.w(1:2);
        alphaTd=model.w(3:latentOffset-obj.dbparams.ncat);
        betaTd=model.w(latentOffset-obj.dbparams.ncat+1:latentOffset);
        %Descriptor in each column
        clusterCenters=reshape(model.w(latentOffset+1:end),[obj.topdown.features.params.dimension,obj.topdown.dictionary.params.size_dictionary]);
        
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        tdfeat_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
        load(sp_filename,'img_sp');
        load(pairwise_filename,'pairwise')
        load(unary_filename,'unary')
        load(tdfeat_filename,'feat_topdown');
        gt_h=y(1:img_sp.nbSp);
        z=y(img_sp.nbSp+1:end);
        
        %Unary matrix for Topdown
        alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
        
        %TD Features
        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=double(feat_topdown.descriptors);
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        %Perform Graph cuts to find most violated constraint.
        unaryCI=wBu(1)*unary-hamming;
        pairwiseC=sparse(wBu(2)*pairwise);
        
        %%%%%%%%% INFERENCE %%%%%%%%
        %Data preload
        [dum,yMostViolatedLabel]=min(unaryCI',[],1);
        
        %Initialize words
        [topdown_unary,topdown_count,z]=infer_words(yMostViolatedLabel,alphaMat,clusterCenters,D,locations,img_sp);
        unaryC=unaryCI+topdown_unary*alphaMat;
        %Interest points extraction
        IP=find(topdown_count>0);
        nbIP=topdown_count(IP);

        if (model.w(2)>0)
            %Rescale costs if neg
            betaTdb=betaTd;
            nbSp=size(unary,1);
            %Energy
            E=sum(unaryC([1:size(unary,1)]+(yMostViolatedLabel-1)*size(unary,1)));
            edge_cost = pairwiseC(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
            E=E+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
            %labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
            labelPres=zeros(obj.dbparams.ncat,1);
            
            for l=1:obj.dbparams.ncat
                %v=sum(topdown_unary(yMostViolatedLabel'==l,:),1);
                %labelHist(:,l)=v;
                labelPres(l)=ismember(l,yMostViolatedLabel(IP));
            end
            
            %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
            %alphas_(l,k), then beta_l
            %Already in unaryC
            %E=E+dot(alphaTdb,labelHist(:));
            
            %Then betas
            %normLabelHist=sum(labelHist,1); % (1,nb labels)
            
            
            
            E=E+dot(betaTdb,labelPres);
            
            %Latent part
            %E=E+sum(sum(clusterCenters(:,z).*D,1));
            
            %%%%%% End Energy computation
            
            
            Ebefore=E;
            maxIter=100;
            iter2=0;
            success2=1;
            while success2==1
                success2=0;
                success=1;
                iter=0;
                while success==1 && iter<=maxIter
                    success=0;
                    iter=iter+1;
                    labperm=randperm(obj.dbparams.ncat);
                    for ilab=1:obj.dbparams.ncat
                        %Pick one label
                        chosenLabel=labperm(ilab);
                        
                        %New segmentation
                        propSeg=alpha_expansion_labelcost(chosenLabel,yMostViolatedLabel,img_sp,unaryC,edge_cost,betaTdb,IP,nbIP);
                        
                        %Compute Energy
                        Eafter=0;
                        Eafter=Eafter+sum(unaryC([1:size(unary,1)]+(propSeg-1)*size(unary,1)));
                        Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                        for l=1:obj.dbparams.ncat
                            %  v=sum(topdown_unary(propSeg'==l,:),1);
                            % labelHist(:,l)=v;
                            labelPres(l)=ismember(l,propSeg(IP));
                        end
                        Eafter=Eafter+dot(labelPres,betaTdb);
                        %Eafter=Eafter+sum(sum(clusterCenters(:,z).*D,1));
                        if Eafter<Ebefore
                            yMostViolatedLabel=propSeg;
                            Ebefore=Eafter;
                            success=1;
                            success2=1;
                        end
                    end
                end
                [topdown_unary,topdown_count,z]=infer_words(yMostViolatedLabel,alphaMat,clusterCenters,D,locations,img_sp);
                unaryC=unaryCI+topdown_unary*alphaMat;
                Ebefore=sum(unaryC([1:size(unary,1)]+(yMostViolatedLabel-1)*size(unary,1)));
                Ebefore=Ebefore+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
                for l=1:obj.dbparams.ncat
                    labelPres(l)=ismember(l,yMostViolatedLabel(IP));
                end
                Ebefore=Ebefore+dot(labelPres,betaTdb);
            end
            %param.zhat=z;
            yMostViolatedLabel=[yMostViolatedLabel(:);z(:)];
            optsvm=model;
            save(sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode)),'optsvm');
        else
            yMostViolatedLabel=[yMostViolatedLabel(:);z(:)];
        end
        
    case 8
        %Latent + Linear TD with CRF on words
        latentOffset=2+obj.dbparams.ncat*(obj.topdown.dictionary.params.size_dictionary+1);
        wordOffset=latentOffset+obj.topdown.features.params.dimension*obj.topdown.dictionary.params.size_dictionary;
        wBu=model.w(1:2);
        alphaTd=model.w(3:latentOffset-obj.dbparams.ncat);
        betaTd=model.w(latentOffset-obj.dbparams.ncat+1:latentOffset);
        %Descriptor in each column
        clusterCenters=reshape(model.w(latentOffset+1:wordOffset),[obj.topdown.features.params.dimension,obj.topdown.dictionary.params.size_dictionary]);
        
        pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        tdfeat_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
        load(sp_filename,'img_sp');
        %obj.topdown.latent.params.n_neighbor
        load(pairwise_filename,'pairwise')
        load(unary_filename,'unary')
        load(tdfeat_filename,'feat_topdown');
        nn=obj.topdown.latent.params.n_neighbor;
        nn_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-ipAdj-%d',x,nn));
        load(nn_filename);
        gt_h=y(1:img_sp.nbSp);
        z=y(img_sp.nbSp+1:end);
        
        %Unary matrix for Topdown
        alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
        
        %TD Features
        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=double(feat_topdown.descriptors);
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        
        %Words Pairwise
        wordsPairwise=zeros(obj.topdown.dictionary.params.size_dictionary,obj.topdown.dictionary.params.size_dictionary);
        wordsPairwise(param.wordsInd)=model.w(wordOffset+1:end);
        wordsPairwise=wordsPairwise+wordsPairwise';
            
        ind_novoid=find(gt_h);
        
        hamming =ones(size(unary));
        hamming(sub2ind(size(unary),ind_novoid,gt_h(ind_novoid)))=0;
        
        ind_void=setdiff(1:size(unary,1),ind_novoid);
        hamming(ind_void,:)=zeros(length(ind_void),size(hamming,2));
        
        for i=1:obj.dbparams.ncat
            tmp=(gt_h(:)==i);
            if sum(tmp)~=0
                hamming(tmp,:) = double(hamming(tmp,:)/sum(tmp));
            end
        end
        
        %Perform Graph cuts to find most violated constraint.
        unaryCI=wBu(1)*unary-hamming;
        pairwiseC=sparse(wBu(2)*pairwise);
        
        %%%%%%%%% INFERENCE %%%%%%%%
        
        %Stop condition if no possible improvement
        %Data preload
        [dum,yMostViolatedLabel]=min(unaryCI',[],1);
        
        %Initialize words
        [topdown_unary,topdown_count,z]=infer_words(yMostViolatedLabel,alphaMat,clusterCenters,D,locations,img_sp,wordsPairwise,adj);
        unaryC=unaryCI+topdown_unary*alphaMat;
        %Interest points extraction
        IP=find(topdown_count>0);
        nbIP=topdown_count(IP);

        if (model.w(2)>0)
            %Rescale costs if neg
            betaTdb=betaTd;
            nbSp=size(unary,1);
            %Energy
            E=0;
            E=E+sum(unaryC([1:size(unary,1)]+(yMostViolatedLabel-1)*size(unary,1)));
            edge_cost = pairwiseC(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
            E=E+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
            %labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
            labelPres=zeros(obj.dbparams.ncat,1);
            
            for l=1:obj.dbparams.ncat
                %v=sum(topdown_unary(yMostViolatedLabel'==l,:),1);
                %labelHist(:,l)=v;
                labelPres(l)=ismember(l,yMostViolatedLabel(IP));
            end
            
            %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
            %alphas_(l,k), then beta_l
            %Already in unaryC
            %E=E+dot(alphaTdb,labelHist(:));
            
            %Then betas
            %normLabelHist=sum(labelHist,1); % (1,nb labels)
            
            
            
            E=E+dot(betaTdb,labelPres);
            
            %Latent part
            %E=E+sum(sum(clusterCenters(:,z).*D,1));
            
            %%%%%% End Energy computation
            
            
            Ebefore=E;
            maxIter=100;
            iter2=0;
            success2=1;
            while success2==1
                success2=0;
                iter=0;
                success=1;
                while success==1 && iter<=maxIter
                    success=0;
                    iter=iter+1;
                    labperm=randperm(obj.dbparams.ncat);
                    for ilab=1:obj.dbparams.ncat
                        %Pick one label
                        chosenLabel=labperm(ilab);
                        
                        %New segmentation
                        propSeg=alpha_expansion_labelcost(chosenLabel,yMostViolatedLabel,img_sp,unaryC,edge_cost,betaTdb,IP,nbIP);
                        
                        %Compute Energy
                        Eafter=0;
                        Eafter=Eafter+sum(unaryC(sub2ind(size(unary),(1:size(unary,1)),double(propSeg(:))')));
                        Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                        for l=1:obj.dbparams.ncat
                            %  v=sum(topdown_unary(propSeg'==l,:),1);
                            % labelHist(:,l)=v;
                            labelPres(l)=ismember(l,propSeg(IP));
                        end
                        Eafter=Eafter+dot(labelPres,betaTdb);
                        %Eafter=Eafter+sum(sum(clusterCenters(:,z).*D,1));
                        
                        if Eafter<Ebefore
                            yMostViolatedLabel=propSeg;
                            Ebefore=Eafter;
                            success=1;
                            success2=1;
                        end
                    end
                end
                [topdown_unary,topdown_count,z]=infer_words(yMostViolatedLabel,alphaMat,clusterCenters,D,locations,img_sp,wordsPairwise,adj);
                unaryC=unaryCI+topdown_unary*alphaMat;
                Ebefore=sum(unaryC(sub2ind(size(unary),(1:size(unary,1)),double(yMostViolatedLabel(:))')));
                Ebefore=Ebefore+sum(edge_cost((yMostViolatedLabel(img_sp.edges(:,1))~=yMostViolatedLabel(img_sp.edges(:,2)))));
                for l=1:obj.dbparams.ncat
                    labelPres(l)=ismember(l,yMostViolatedLabel(IP));
                end
                Ebefore=Ebefore+dot(labelPres,betaTdb);
            end
            %param.zhat=z;
            yMostViolatedLabel=[yMostViolatedLabel(:);z(:)];
            optsvm=model;
            save(sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode)),'optsvm');
            
        end
        
end
