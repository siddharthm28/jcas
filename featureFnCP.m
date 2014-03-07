function E=featureFnCP(obj,param,x,y)
%Feature map building for CP training.
%x image_names and y label for this image
%U

%U+P
switch obj.mode
    case 1
        E = zeros(2,1);
        
        %Unary
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        load(unary_filename,'unary');
        
        nbSp=size(unary,1);
        if sum(y==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        load(sp_filename);
        load(pw_filename);
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        E=sparse(E);
    case 2
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l delta(l in interest points)
        E = zeros(param.dimension,1);
        
        %Unary
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        load (unary_filename,'unary');
        
        nbSp=size(unary,1);
        if sum(y==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        load(sp_filename);
        load(pw_filename);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        
        %Compute topdown Energy map labelHist
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        load(topdown_unary_filename,'topdown_unary','topdown_count');
        labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
        labelPres=zeros(obj.dbparams.ncat,1);
        IP=find(topdown_count>0);
        for l=1:obj.dbparams.ncat
            v=sum(topdown_unary(y'==l,:),1);
            labelHist(:,l)=v';
            labelPres(l)=ismember(l,y(IP));
        end
        
        %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
        %alphas_(l,k), then beta_l
        E(3:3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat)-1) = ...
            labelHist(:);
        
        %Then betas
        %normLabelHist=sum(labelHist,1); % (1,nb labels)

        E(3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat):end)=...
            labelPres(:);
        
        E=sparse(E);   
        
    case 3
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l delta(l in interest points)
        E = zeros(param.dimension,1);
        
        %Unary
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        load (unary_filename,'unary');
        
        nbSp=size(unary,1);
        if sum(y==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        load(sp_filename);
        load(pw_filename);
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        
        %Compute topdown Energy map labelHist
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        load(topdown_unary_filename,'topdown_unary','topdown_count');
        labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
        labelPres=zeros(obj.dbparams.ncat,1);
        IP=1:length(topdown_count);
        for l=1:obj.dbparams.ncat
        v=sum(topdown_unary(y'==l,:),1);
        labelHist(:,l)=v;
        labelPres(l)=ismember(l,y);
        end
        
        %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
        %alphas_(l,k), then beta_l
        E(3:3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat)-1) = ...
            labelHist(:);
        
        %Then betas
        %normLabelHist=sum(labelHist,1); % (1,nb labels)

        E(3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat):end)=...
            labelPres(:);
        
        E=sparse(E);   
        
    case 4
        %Unary + pairwise + Linear classifier for TD potential \sum
        %alpha_k,l h_k,l + beta_l *||h_l||
        E = zeros(param.dimension,1);
        
        %Unary
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        load (unary_filename,'unary');
        
        nbSp=size(unary,1);
        if sum(y==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        load(sp_filename);
        load(pw_filename);
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost(find(y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        
        %Compute topdown Energy map labelHist
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        load(topdown_unary_filename,'topdown_unary');
        labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
        for l=1:obj.dbparams.ncat
        v=sum(topdown_unary(y'==l,:),1);
        labelHist(:,l)=v;
        end
        
        %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
        %alphas_(l,k), then beta_l
        E(3:3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat)-1) = ...
            labelHist(:);
        
        %Then betas l=1 ,l=2, etc...
        normLabelHist=sum(labelHist,1); % (1,nb labels)
        
        E(3+(obj.topdown.dictionary.params.size_dictionary*obj.dbparams.ncat):end)=...
            normLabelHist;
        
        E=sparse(E);
        
    case 5
        %Unary + pairwise + beta_l delta(l in labeling)
        E = zeros(param.dimension,1);
        
        %Unary
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        load (unary_filename,'unary');
        
        nbSp=size(unary,1);
        if sum(y==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        load(sp_filename);
        load(pw_filename);
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        
        %Compute topdown Energy map labelHist
        labelPres=zeros(obj.dbparams.ncat,1);
        
        for l=1:obj.dbparams.ncat
            labelPres(l)=ismember(l,y);
        end
                
        %Then betas
        %normLabelHist=sum(labelHist,1); % (1,nb labels)

        E(3:end)=labelPres(:);
        
        E=sparse(E);           
    
    
    case 6
        E = zeros(param.dimension,1);
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        
        load (unary_filename,'unary');
        
        nbSp=size(unary,1);
        if sum(y==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        load(sp_filename);
        load(pw_filename);
        pairwise = sparse(pairwise);
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        
        %Intersection kernel part
        topdown_unary_filename = sprintf(obj.topdown.unary.destmatpath,sprintf('%s-topdown_unary-%d',x,obj.topdown.dictionary.params.size_dictionary));
        load(topdown_unary_filename,'topdown_unary');
        segHists=compute_label_histograms(y,topdown_unary,obj.dbparams.ncat);
 
        E(3:end-obj.dbparams.ncat)=compute_intersection_kernel(segHists,param.tHistograms,obj.dbparams.ncat);
        
        %Histograms norms
        E(end-obj.dbparams.ncat+1:end)=double(sum(segHists,1)>0);
        
        E=sparse(E);
        
    case 7
        latentOffset=2+obj.dbparams.ncat*(obj.topdown.dictionary.params.size_dictionary+1);
        %Descriptor in each column

        E = zeros(param.dimension,1);
 
        %Unary
        unary_filename=sprintf(obj.unary.svm.destmatpath,sprintf('%s-unary-%d',x,obj.unary.SPneighboorhoodsize));
        load (unary_filename,'unary');
        
        nbSp=size(unary,1);
            z=y(nbSp+1:end);
            y=y(1:nbSp);       
        if sum(y(:)==0)>0
            ind_NoVoid=find(y>0);
            ind_void=setdiff(1:nbSp,ind_NoVoid);
            ind=sub2ind(size(unary),ind_NoVoid,double(y(ind_NoVoid)));
            E(1)=sum(unary(ind));
        else
            ind=sub2ind(size(unary),([1:size(unary,1)]),double(y(:))');
            E(1)=sum(unary(ind));
        end
        
        %pairwise
        sp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',x));
        pw_filename=sprintf(obj.pairwise.destmatpath,sprintf('%s-pairwise',x));
        tdfeat_filename=sprintf(obj.topdown.features.destmatpath,sprintf('%s-topdown_features',x));
        load(sp_filename);
        load(pw_filename);
        load(tdfeat_filename,'feat_topdown');
                
        edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
        E(2) = sum(edge_cost((y(img_sp.edges(:,1))~=y(img_sp.edges(:,2)))));
        
        %Compute topdown Energy map labelHist
        %TD Features
        [X,Y] = size(img_sp.spInd);
        F=feat_topdown.locations;
        D=feat_topdown.descriptors;
        locations = X*(round(F(1,:))-1)+round(F(2,:));
        topdown_unary = sparse(img_sp.spInd(locations), double(z), ones(length(locations),1), img_sp.nbSp,obj.topdown.dictionary.params.size_dictionary);
        topdown_count=full(sparse(img_sp.spInd(locations), ones(length(locations),1), ones(length(locations),1), img_sp.nbSp,1));
        
        labelHist=zeros(obj.topdown.dictionary.params.size_dictionary,obj.dbparams.ncat);
        labelPres=zeros(obj.dbparams.ncat,1);
        IP=find(topdown_count>0);
        for l=1:obj.dbparams.ncat
            v=sum(topdown_unary(y'==l,:),1);
            labelHist(:,l)=v';
            labelPres(l)=ismember(l,y(IP));
        end
        
        %Ordering : l=1, k=1, k=2 ,..., k=size td dict, l=2 etc... for
        %alphas_(l,k), then beta_l
        E(3:latentOffset-obj.dbparams.ncat) = ...
            labelHist(:);
        
        %Then betas
        %normLabelHist=sum(labelHist,1); % (1,nb labels)

        E(latentOffset-obj.dbparams.ncat+1:latentOffset)=...
            labelPres(:);
        
        %Latent 
        for k=1:size(topdown_unary,2)
        E(latentOffset+1+(k-1)*obj.topdown.features.params.dimension:latentOffset+k*obj.topdown.features.params.dimension)=...
            sum(D(:,z==k),2);
        end
        E=sparse(E);   

    otherwise
        error('Problem with mode selected')
end

end