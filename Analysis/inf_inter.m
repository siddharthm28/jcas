function  inf_inter(optsvm,training_histograms,unary,pairwise,img_sp,topdown_unary)
        %Unary + pairwise + Linear classifier for TD potential \sum
        
        %Compute topdown Energy map labelHist
        %Unary matrix for Topdown
        %Coeff of entries in topdown_unary
       % training_histograms_filename=sprintf(obj.topdown.unary.destmatpath
       % ,'intersection_kernel_histograms');
       %load(training_histograms_filename);
        param.tHistograms=training_histograms;
        nbSp=size(unary,1);
ncat=size(unary,2);
        success=1;
        %Data preload
        [dum,initSeg]=min(unary',[],1);
        seg=initSeg;
        %Compute energy before graph cut
        %Histograms of the segmentation
        E=zeros(1,length(optsvm.w));
        ind=sub2ind(size(unary),([1:size(unary,1)]),double(seg(:))');
        E(1)=sum(unary(ind));
        
        %pairwise
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
        
        %Intersection kernel part

        segHists=compute_label_histograms(seg,topdown_unary,ncat);
 
        E(3:3+size(param.tHistograms,2)-1)=compute_intersection_kernel(segHists,param.tHistograms(1:end-2,:),param.tHistograms(end,:));
        
        %Histograms norms
        E(3+size(param.tHistograms,2):end)=double(sum(segHists,1)>0);      
        %Perform graph cut
        Ebefore=dot(E,optsvm.w);
        
        iter=0;
        miter=50;
        success=1;
        if optsvm.w(2)>0
            while iter<=miter && success==1;
                success=0;
                iter=iter+1;
                labperm=randperm(ncat);
                for ilab=1:ncat
                    %Pick one label
                    chosenLabel=labperm(ilab);
                    
                    %New segmentation
                    propSeg=alpha_expansion_intersection(param,chosenLabel,seg,optsvm.w,img_sp,unary,pairwise,topdown_unary);
                    imagesc(propSeg(img_sp.spInd));
pause;
        E=zeros(1,length(optsvm.w));
        ind=sub2ind(size(unary),([1:size(unary,1)]),double(propSeg(:))');
        E(1)=sum(unary(ind));
        
        %pairwise
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
        
        %Intersection kernel part

        segHists=compute_label_histograms(propSeg,topdown_unary,ncat);
 
        E(3:3+size(param.tHistograms,2)-1)=compute_intersection_kernel(segHists,param.tHistograms(1:end-2,:),param.tHistograms(end,:));
        
        %Histograms norms
        E(3+size(param.tHistograms,2):end)=double(sum(segHists,1)>0);      
        %Perform graph cut
        Eafter=dot(E,optsvm.w);   
        if Eafter<Ebefore
            Ebefore=Eafter;
                        seg=propSeg;
                        success=1;
                        fprintf('Success iter %d\n',iter);
                    end
                    
                end
            end
        end

end

