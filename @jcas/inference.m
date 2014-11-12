function inference(obj,imgsetname)
%perform inference on training set
ids=obj.dbparams.(imgsetname);

switch obj.mode
    case 0
        for i=1:length(ids)
            %Inference
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            % load the unary file only
            tmp=load(unary_filename,'unary');
            unary=tmp.unary;
            % i assume the unary is of the size nbsp x ncat where nbsp is
            % number of superpixels and ncat is number of categories
            [~, seg] =  min(unary,[],2);
            save(segres_filename,'seg');
        end
        
    case 1
        for i=1:length(ids)
            %Inference
            pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
            
            tmp=load(unary_filename,'unary'); unary=tmp.unary;
            tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
            tmp=load(model_filename,'optsvm'); optsvm=tmp.optsvm;
            
            unary=full(optsvm.w(1))*unary;
            pairwise=sparse(optsvm.w(2)*pairwise);
            
%             labelcost_total = ones(size(unary,2))-eye(size(unary,2));
%             [~, seg] =  min(unary,[],2);
%             if (optsvm.w(2)~=0) %%% USING PAIRWISE
%                 [seg2,~,~] =  GCMex(seg'-1, single(unary'), pairwise, single(labelcost_total),0);
%                 seg = seg2+1;
%             end
            seg=run_solver(unary',pairwise,size(unary,2));
            save(segres_filename,'seg');
        end
        
    case 2
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l delta(l present in Interest points)
        
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        tmp=load(model_filename,'optsvm'); optsvm=tmp.optsvm;
        wBu=optsvm.w(1:2);
        alphaTd=optsvm.w(3:end-obj.dbparams.ncat);
        betaTd=optsvm.w(end-obj.dbparams.ncat+1:end);
        
        if sum(optsvm.w<0)>0
            fprintf('Warning : negative coeffs in weights learned\n');
        end
        
        for i=1:length(ids)
%             fprintf('i: %d \n',i);
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
            tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
            tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
            tmp=load(unary_filename,'unary'); unary=tmp.unary;
            
            %Compute topdown Energy map labelHist
            topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',obj.dbparams.image_names{ids(i)},obj.topdown.dictionary.params.size_dictionary));
            tmp=load(topdown_unary_filename,'topdown_unary','topdown_count');
            topdown_unary=tmp.topdown_unary;
            topdown_count=tmp.topdown_count;
            %Unary matrix for Topdown
            alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
            %Coeff of entries in topdown_unary
            topdownU=(topdown_unary)*alphaMat;
            
            %Perform Graph cuts to find most violated constraint.
            unary=wBu(1)*unary+topdownU;
            pairwise=sparse(wBu(2)*pairwise);
            
            %%%%%%%%% INFERENCE %%%%%%%%
            %Stop condition if no possible improvement
            success=1;
            IP=find(topdown_count>0);
            nbIP=topdown_count(IP);
            %Data preload
            [~,initSeg]=min(unary,[],2);
            seg=initSeg';
            if (optsvm.w(2)>0)
                %Rescale costs if neg
                nbSp=size(unary,1);
                
                %Energy
                E=sum(unary((1:size(unary,1))+(seg-1)*size(unary,1)));
                edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
                E=E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
                %labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
                labelPres=zeros(obj.dbparams.ncat,1);
                
                for l=1:obj.dbparams.ncat
                    % v=sum(topdown_unary(seg'==l,:),1);
                    % labelHist(:,l)=v;
                    labelPres(l)=ismember(l,seg(IP));
                end
                
                %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
                %alphas_(l,k), then beta_l
                %   E(3:3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat)-1) = ...
                %      labelHist(:);
                
                %Then betas
                %normLabelHist=sum(labelHist,1); % (1,nb labels)
                
                
                
                E=E+dot(betaTd,labelPres);
                
                
                %%%%%% End Energy computation
                Ebefore=E;
                maxIter=100;
                iter=0;
                while success==1 && iter<=maxIter
                    success=0;
                    iter=iter+1;
%                     fprintf('Iter %d\n',iter);
                    labperm=randperm(obj.dbparams.ncat);
                    for ilab=1:obj.dbparams.ncat
                        
                        %Pick one label
                        chosenLabel=labperm(ilab);
                        
                        %New segmentation
                        propSeg=alpha_expansion_labelcost(chosenLabel,seg,img_sp,unary,edge_cost,betaTd,IP,nbIP);
                        
                        
                        %Compute Energy
                        labelPres=zeros(obj.dbparams.ncat,1);
                        Eafter=sum(unary((1:size(unary,1))+(propSeg-1)*size(unary,1)));
                        Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                        for l=1:obj.dbparams.ncat
                            % v=sum(topdown_unary(propSeg'==l,:),1);
                            % labelHist(:,l)=v;
                            labelPres(l)=ismember(l,propSeg(IP));
                        end
                        Eafter=Eafter+dot(betaTd,labelPres);
                        
                        if Eafter<Ebefore
                            seg=propSeg;
%                             fprintf('Jump from %f to %f\n',Ebefore,Eafter);
                            Ebefore=Eafter;
                            success=1;
                        end
                    end
                end
            elseif optsvm.w(2)<0
                error('negative weight w2')
            end
            save(segres_filename,'seg');
            
        end
        
        
    case 3
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l delta(l present)
        
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        tmp=load(model_filename,'optsvm'); optsvm=tmp.optsvm;
        wBu=optsvm.w(1:2);
        alphaTd=optsvm.w(3:end-obj.dbparams.ncat);
        betaTd=optsvm.w(end-obj.dbparams.ncat+1:end);
        
        if sum(optsvm.w<0)>0
            fprintf('Warning : negative coeffs in weights learned\n');
        end
        
        for i=1:length(ids)
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
            tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
            tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
            tmp=load(unary_filename,'unary'); unary=tmp.unary;
            
            %Compute topdown Energy map labelHist
            topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',obj.dbparams.image_names{ids(i)},obj.topdown.dictionary.params.size_dictionary));
            tmp=load(topdown_unary_filename,'topdown_unary','topdown_count');
            topdown_unary=tmp.topdown_unary;
            topdown_count=tmp.topdown_count;
            %Unary matrix for Topdown
            alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
            %Coeff of entries in topdown_unary
            topdownU=(topdown_unary)*alphaMat;
            
            %Perform Graph cuts to find most violated constraint.
            unary=wBu(1)*unary+topdownU;
            pairwise=sparse(wBu(2)*pairwise);
            
            %%%%%%%%% INFERENCE %%%%%%%%
            %Stop condition if no possible improvement
            success=1;
            IP=(1:length(topdown_count))';
            %Data preload
            [~,initSeg]=min(unary,[],2);
            seg=initSeg';
            if (optsvm.w(2)>0)
                %Rescale costs if neg
                nbSp=size(unary,1);
                
                %Energy
                E=sum(unary((1:size(unary,1))+(seg-1)*size(unary,1)));
                edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
                E=E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
                %labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
                labelPres=zeros(obj.dbparams.ncat,1);
                
                for l=1:obj.dbparams.ncat
                    % v=sum(topdown_unary(seg'==l,:),1);
                    % labelHist(:,l)=v;
                    labelPres(l)=ismember(l,seg(IP));
                end
                
                %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
                %alphas_(l,k), then beta_l
                %   E(3:3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat)-1) = ...
                %      labelHist(:);
                
                %Then betas
                %normLabelHist=sum(labelHist,1); % (1,nb labels)
                
                
                
                E=E+dot(betaTd,labelPres);
                
                
                %%%%%% End Energy computation
                Ebefore=E;
                maxIter=100;
                iter=0;
                while success==1 && iter<=maxIter
                    success=0;
                    iter=iter+1;
%                     fprintf('Iter %d',iter);
                    labperm=randperm(obj.dbparams.ncat);
                    for ilab=1:obj.dbparams.ncat
                        
                        %Pick one label
                        chosenLabel=labperm(ilab);
                        
                        %New segmentation
                        propSeg=alpha_expansion_labelcost(chosenLabel,seg,img_sp,unary,edge_cost,betaTd,IP,topdown_count);
                        
                        
                        %Compute Energy
                        labelPres=zeros(obj.dbparams.ncat,1);
                        Eafter=sum(unary((1:size(unary,1))+(propSeg-1)*size(unary,1)));
                        Eafter=Eafter+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                        for l=1:obj.dbparams.ncat
                            % v=sum(topdown_unary(propSeg'==l,:),1);
                            % labelHist(:,l)=v;
                            labelPres(l)=ismember(l,propSeg(IP));
                        end
                        Eafter=Eafter+dot(betaTd,labelPres);
                        
                        if Eafter<Ebefore
                            seg=propSeg;
%                             fprintf('Jump from %f to %f\n',Ebefore,Eafter);
                            Ebefore=Eafter;
                            success=1;
                        end
                    end
                end
            elseif optsvm.w(2)<0
                error('negative weight w2')
            end
            save(segres_filename,'seg');
            
        end
        
    case 4
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l *||h_l||
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        tmp=load(model_filename,'optsvm'); optsvm=tmp.optsvm;
        fprintf('Processing image:     ');
        for i=1:length(ids)
            fprintf('\b\b\b\b%04d', ids(i));
            %Weights
            
            
            pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            
            tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
            tmp=load(unary_filename,'unary'); unary=tmp.unary;
            wBu=optsvm.w(1:2);
            alphaTd=optsvm.w(3:end-obj.dbparams.ncat);
            betaTd=optsvm.w(end-obj.dbparams.ncat+1:end);
            
            %Compute topdown Energy map labelHist
            topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',obj.dbparams.image_names{ids(i)},obj.topdown.dictionary.params.size_dictionary));
            tmp=load(topdown_unary_filename,'topdown_unary'); topdown_unary=tmp.topdown_unary;
            %Unary matrix for Topdown
            alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
            betaMat=repmat(betaTd',[obj.topdown.dictionary.params.size_dictionary 1]);
            %Coeff of entries in topdown_unary
            topdownU=topdown_unary*(alphaMat+betaMat);
            
            %Perform Graph cuts to find most violated constraint.
            unary=wBu(1)*unary+topdownU;
            pairwise=sparse(wBu(2)*pairwise);
            
            [~, seg] =  min(unary,[],2); %min(unary',[],1);
            labelcost_total = ones(obj.dbparams.ncat)-eye(obj.dbparams.ncat);
            if (optsvm.w(2)~=0) %%% USING PAIRWISE
                [seg2,~,~] =  GCMex(seg'-1, single(unary'), pairwise, single(labelcost_total),0);
                seg = seg2+1;
            end
            save(segres_filename,'seg');
        end
        
        
    case 5
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        tmp=load(model_filename,'optsvm'); optsvm=tmp.optsvm;
        wBu=optsvm.w(1:2);
        betaTd=optsvm.w(end-obj.dbparams.ncat+1:end);
        
        if sum(optsvm.w<0)>0
            fprintf('Warning : negative coeffs in weights learned\n');
        end
        
        for i=1:length(ids)
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
            tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
            tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
            tmp=load(unary_filename,'unary'); unary=tmp.unary;
            
            
            %Perform Graph cuts to find most violated constraint.
            unary=wBu(1)*unary;
            pairwise=sparse(wBu(2)*pairwise);
            
            %%%%%%%%% INFERENCE %%%%%%%%
            %Stop condition if no possible improvement
            success=1;
            %Data preload
            [~,initSeg]=min(unary,[],2);
            seg=initSeg';
            if (optsvm.w(2)>0)
                %Rescale costs if neg
                if sum(betaTd<0)>0
                    error('Negative label cost')
                end
                nbSp=size(unary,1);
                
                %Energy
                %E=zeros(1,length(optsvm.w));
                E=sum(unary(sub2ind(size(unary),1:size(unary,1),double(seg(:))')));
                edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
                E=E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
                labelPres=zeros(obj.dbparams.ncat,1);
                
                for l=1:obj.dbparams.ncat
                    labelPres(l)=ismember(l,seg);
                end
                
                %Then betas
                %normLabelHist=sum(labelHist,1); % (1,nb labels)
                E=E+dot(labelPres(:),optsvm.w(3:end));
                
                
                %%%%%% End Energy computation
                Ebefore=E;
                maxIter=100;
                iter=0;
                while success==1 && iter<=maxIter
                    success=0;
                    iter=iter+1;
%                     fprintf('Iter %d\n',iter);
                    labperm=randperm(obj.dbparams.ncat);
                    for ilab=1:obj.dbparams.ncat
                        
                        %Pick one label
                        chosenLabel=labperm(ilab);
                        
                        %New segmentation
                        propSeg=alpha_expansion_labelcost(chosenLabel,seg,img_sp,unary,edge_cost,betaTd,(1:size(unary,1))',ones(1,size(unary,1))');
                        
                        
                        %Compute Energy
                        %E=zeros(1,length(optsvm.w));
                        E=sum(unary(sub2ind(size(unary),(1:size(unary,1)),double(propSeg(:))')));
                        E=E+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                        for l=1:obj.dbparams.ncat
                            labelPres(l)=ismember(l,propSeg);
                        end
                        
                        E=E+dot(labelPres(:),optsvm.w(3:end));
                        
                        Eafter=E;
                        
                        if Eafter<Ebefore
                            seg=propSeg;
%                             fprintf('Jump from %f to %f\n',Ebefore,Eafter);
                            Ebefore=Eafter;
                            success=1;
                        end
                    end
                end
            elseif optsvm.w(2)<0
                error('negative weight w2')
            end
            save(segres_filename,'seg');
            
        end
        
    case 6
        %Unary Pairwise + intersection kernel (PAMI)
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        tmp=load(model_filename,'optsvm'); optsvm=tmp.optsvm;
        training_histograms_filename=sprintf(obj.topdown.unary.destmatpath,'intersection_kernel_histograms');
        tmp=load(training_histograms_filename); training_histograms=tmp.training_histograms;
        param.tHistograms=training_histograms;
        
        for i=1:length(ids)
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
            %Load data
            pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',obj.dbparams.image_names{ids(i)}));
            unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',obj.dbparams.image_names{ids(i)},obj.unary.SPneighboorhoodsize));
            sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
            topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',obj.dbparams.image_names{ids(i)},obj.topdown.dictionary.params.size_dictionary));
            tmp=load(sp_filename,'img_sp'); img_sp=tmp.img_sp;
            tmp=load(pairwise_filename,'pairwise'); pairwise=tmp.pairwise;
            tmp=load(unary_filename,'unary'); unary=tmp.unary;
            tmp=load(topdown_unary_filename,'topdown_unary'); topdown_unary=tmp.topdown_unary;
            
            
            %Initialization of the most violated constraint
            [~,seg]=min((optsvm.w(1)*unary),[],2);
            unaryC=optsvm.w(1)*unary;
            %Compute energy before graph cut
            %Histograms of the segmentation
            segHist=compute_label_histograms(seg,topdown_unary,obj.dbparams.ncat);
            
            %Energy Computation
            ind=sub2ind(size(unary),(1:size(unary,1)),double(seg(:))');
            E=sum(unaryC(ind));
            
            %pairwise
            pairwise = sparse(optsvm.w(2)*pairwise);
            edge_cost = pairwise(img_sp.edges(:,1)+img_sp.nbSp*(img_sp.edges(:,2)-1));
            E=E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
            
            %Intersection kernel part
            
            segHists=compute_label_histograms(seg,topdown_unary,obj.dbparams.ncat);
            
            E=E+dot(optsvm.w(3:end-obj.dbparams.ncat),compute_intersection_kernel(segHists,param.tHistograms,obj.dbparams.ncat));            
            %Histograms norms
            E=E+dot(optsvm.w(end-obj.dbparams.ncat+1:end),(sum(segHists,1)>0));
            Ebefore=E;
            
            %Perform graph cut
            iter=0;
            miter=50;
            success=1;
            if optsvm.w(2)>0
                while iter<=miter && success==1;
                    success=0;
                    iter=iter+1;
                    labperm=randperm(obj.dbparams.ncat);
                    for ilab=1:obj.dbparams.ncat
                        %Pick one label
                        chosenLabel=labperm(ilab);
                        
                        %New segmentation
                        propSeg=alpha_expansion_intersection(chosenLabel,seg,img_sp,unaryC,edge_cost,topdown_unary,param.tHistograms,optsvm.w(3:end-obj.dbparams.ncat),optsvm.w(end-obj.dbparams.ncat+1:end));
                        ind=sub2ind(size(unary),([1:size(unary,1)]),double(propSeg(:))');
                        E=sum(unaryC(ind));
                        
                        %pairwise
                        E=E+sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                        
                        %Intersection kernel part
                        segHists=compute_label_histograms(propSeg,topdown_unary,obj.dbparams.ncat);
                        E=E+dot(optsvm.w(3:end-obj.dbparams.ncat),compute_intersection_kernel(segHists,param.tHistograms,obj.dbparams.ncat));
                        E=E+dot(optsvm.w(end-obj.dbparams.ncat+1:end),(sum(segHists,1)>0));  

                        %Perform graph cut
                        Eafter=E;
                        
                        if Eafter<Ebefore
%                             fprintf('Jump iter %d dE=%f\n',iter,Ebefore-Eafter)
                            seg=propSeg;
                            Ebefore=Eafter;
                            success=1;
                        end
                        
                    end
                end
            end
            save(segres_filename,'seg');
        end
        
    case 7
        latentOffset=2+obj.dbparams.ncat*(obj.topdown.dictionary.params.size_dictionary+1);
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        load(model_filename,'optsvm');
        wBu=optsvm.w(1:2);
        alphaTd=optsvm.w(3:latentOffset-obj.dbparams.ncat);
        alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
        betaTd=optsvm.w(latentOffset-obj.dbparams.ncat+1:latentOffset);
        %Descriptor in each column
        clusterCenters=reshape(optsvm.w(latentOffset+1:end),[obj.topdown.features.params.dimension,obj.topdown.dictionary.params.size_dictionary]);       
        if sum(optsvm.w<0)>0
            fprintf('Warning : negative coeffs in weights learned\n');
        end
        
        for i=1:length(ids)
%         	fprintf('DOing inference on image %i over %i\n',i,length(ids))
        	x=obj.dbparams.image_names{ids(i)};
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
        	pairwise_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        	unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        	sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        	tdfeat_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
        	load(sp_filename,'img_sp');
        	load(pairwise_filename,'pairwise')
        	load(unary_filename,'unary')
			load(tdfeat_filename,'feat_topdown');
        
			%Unary matrix for Topdown
			alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
		
			%TD Features
			[X,Y] = size(img_sp.spInd);
			F=feat_topdown.locations;
			D=double(feat_topdown.descriptors);
			locations = X*(round(F(1,:))-1)+round(F(2,:));
		
			%Perform Graph cuts to find most violated constraint.
			unaryCI=wBu(1)*unary;
			pairwiseC=sparse(wBu(2)*pairwise);
		
			%%%%%%%%% INFERENCE %%%%%%%%
			%Data preload
			[dum,seg]=min(unaryCI',[],1);
		
			%Initialize words
			[topdown_unary,topdown_count,z]=infer_words(seg,alphaMat,clusterCenters,D,locations,img_sp);
			unaryC=unaryCI+topdown_unary*alphaMat;
			%Interest points extraction
			IP=find(topdown_count>0);
			nbIP=topdown_count(IP);

			if (optsvm.w(2)>0)
				%Rescale costs if neg
				betaTdb=betaTd;
				nbSp=size(unary,1);
				%Energy
				E=sum(unaryC([1:size(unary,1)]+(seg-1)*size(unary,1)));
				edge_cost = pairwiseC(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
				E=E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
				%labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
				labelPres=zeros(obj.dbparams.ncat,1);
			
				for l=1:obj.dbparams.ncat
					%v=sum(topdown_unary(seg'==l,:),1);
					%labelHist(:,l)=v;
					labelPres(l)=ismember(l,seg(IP));
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
							propSeg=alpha_expansion_labelcost(chosenLabel,seg,img_sp,unaryC,edge_cost,betaTdb,IP,nbIP);
						
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
								seg=propSeg;
								Ebefore=Eafter;
								success=1;
								success2=1;
							end
						end
					end
					[topdown_unary,topdown_count,z]=infer_words(seg,alphaMat,clusterCenters,D,locations,img_sp);
					unaryC=unaryCI+topdown_unary*alphaMat;
					Ebefore=sum(unaryC([1:size(unary,1)]+(seg-1)*size(unary,1)));
					Ebefore=Ebefore+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
					for l=1:obj.dbparams.ncat
						labelPres(l)=ismember(l,seg(IP));
					end
					Ebefore=Ebefore+dot(labelPres,betaTdb);
            	end            
            elseif optsvm.w(2)<0
                error('negative weight w2')
            end
            save(segres_filename,'seg');
            
        end

    case 8
        model_filename=sprintf(obj.optimisation.destmatpath,sprintf('optmodel_%d',obj.mode));
        load(model_filename,'optsvm');
        %Latent + Linear TD with CRF on words
        latentOffset=2+obj.dbparams.ncat*(obj.topdown.dictionary.params.size_dictionary+1);
        wordOffset=latentOffset+obj.topdown.features.params.dimension*obj.topdown.dictionary.params.size_dictionary;
        wBu=optsvm.w(1:2);
        alphaTd=optsvm.w(3:latentOffset-obj.dbparams.ncat);
        betaTd=optsvm.w(latentOffset-obj.dbparams.ncat+1:latentOffset);
        %Descriptor in each column
        clusterCenters=reshape(optsvm.w(latentOffset+1:wordOffset),[obj.topdown.features.params.dimension,obj.topdown.dictionary.params.size_dictionary]);
        if sum(optsvm.w<0)>0
            fprintf('Warning : negative coeffs in weights learned\n');
        end
        
        wordsInd=zeros(obj.topdown.dictionary.params.size_dictionary*(obj.topdown.dictionary.params.size_dictionary-1)/2,1);
        wpit=1;
        for wp=1:obj.topdown.dictionary.params.size_dictionary
            for wp2=wp+1:obj.topdown.dictionary.params.size_dictionary
                wordsInd(wpit)=wp+obj.topdown.dictionary.params.size_dictionary*(wp2-1);
                wpit=wpit+1;
            end
        end
        for i=1:length(ids)
        	x=obj.dbparams.image_names{ids(i)};
%         	fprintf('DOing inference on image %i over %i\n',i,length(ids))
            segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
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
		
			%Unary matrix for Topdown
			alphaMat=reshape(alphaTd,[obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat]);
		
			%TD Features
			[X,Y] = size(img_sp.spInd);
			F=feat_topdown.locations;
			D=double(feat_topdown.descriptors);
			locations = X*(round(F(1,:))-1)+round(F(2,:));
		
			%Words Pairwise
			wordsPairwise=zeros(obj.topdown.dictionary.params.size_dictionary,obj.topdown.dictionary.params.size_dictionary);
			wordsPairwise(wordsInd)=optsvm.w(wordOffset+1:end);
			wordsPairwise=wordsPairwise+wordsPairwise';
		
			%Perform Graph cuts to find most violated constraint.
			unaryCI=wBu(1)*unary;
			pairwiseC=sparse(wBu(2)*pairwise);
		
			%%%%%%%%% INFERENCE %%%%%%%%
		
			%Stop condition if no possible improvement
			%Data preload
			[dum,seg]=min(unaryCI',[],1);
		
			%Initialize words
			[topdown_unary,topdown_count,z]=infer_words(seg,alphaMat,clusterCenters,D,locations,img_sp,wordsPairwise,adj);
			unaryC=unaryCI+topdown_unary*alphaMat;
			%Interest points extraction
			IP=find(topdown_count>0);
			nbIP=topdown_count(IP);

			if (optsvm.w(2)>0)
				%Rescale costs if neg
				betaTdb=betaTd;
				nbSp=size(unary,1);
				%Energy
				E=0;
				E=E+sum(unaryC([1:size(unary,1)]+(seg-1)*size(unary,1)));
				edge_cost = pairwiseC(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
				E=E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
				%labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
				labelPres=zeros(obj.dbparams.ncat,1);
			
				for l=1:obj.dbparams.ncat
					%v=sum(topdown_unary(seg'==l,:),1);
					%labelHist(:,l)=v;
					labelPres(l)=ismember(l,seg(IP));
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
							propSeg=alpha_expansion_labelcost(chosenLabel,seg,img_sp,unaryC,edge_cost,betaTdb,IP,nbIP);
						
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
								seg=propSeg;
								Ebefore=Eafter;
								success=1;
								success2=1;
							end
						end
					end
					[topdown_unary,topdown_count,z]=infer_words(seg,alphaMat,clusterCenters,D,locations,img_sp,wordsPairwise,adj);
					unaryC=unaryCI+topdown_unary*alphaMat;
					Ebefore=sum(unaryC(sub2ind(size(unary),(1:size(unary,1)),double(seg(:))')));
					Ebefore=Ebefore+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
					for l=1:obj.dbparams.ncat
						labelPres(l)=ismember(l,seg(IP));
					end
					Ebefore=Ebefore+dot(labelPres,betaTdb);
				end    
            elseif optsvm.w(2)<0
                error('negative weight w2')
            end
            save(segres_filename,'seg');
        end        
        
    otherwise
        error('Mode unknown')
end

fprintf('Inference finished \n');
