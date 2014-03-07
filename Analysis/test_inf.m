function  test_inf(optsvm,unaryI,pairwiseI,img_sp)

        wBu=optsvm.w(1:2);
        betaTd=optsvm.w(3:end);

        
        %Compute topdown Energy map labelHist
        %Unary matrix for Topdown
        %Coeff of entries in topdown_unary

        
        %Perform Graph cuts to find most violated constraint.
        unary=wBu(1)*unaryI;
        pairwise=sparse(wBu(2)*pairwiseI);
        
        %%%%%%%%% INFERENCE %%%%%%%%
        %Stop condition if no possible improvement
        success=1;
        %Data preload
        [dum,initSeg]=min(unary',[],1);
        seg=initSeg;
        if (optsvm.w(2)>0)
            nbSp=size(unary,1);
            
            %Energy
            E=0;
            E=E+sum(unary((1:nbSp)'+nbSp*(seg(:)-1)));
            edge_cost = pairwise(img_sp.edges(:,1)+nbSp*(img_sp.edges(:,2)-1));
            E = E+sum(edge_cost((seg(img_sp.edges(:,1))~=seg(img_sp.edges(:,2)))));
            labelPres=zeros(4,1);
            
            for l=1:4
                labelPres(l)=ismember(l,seg);
            end
           
            
            
            E(3:end)=dot(betaTd,labelPres);
            
            
            %%%%%% End Energy computation
            Ebefore=sum(E);
            maxIter=100;
            iter=0;
            while success==1 && iter<=maxIter
                success=0;
                iter=iter+1;
                fprintf('Iter %d\n',iter);
                labperm=randperm(4);
                for ilab=1:4
                    
                    %Pick one label
                    chosenLabel=labperm(ilab);
                    imagesc(seg(img_sp.spInd));
                    pause
                    
                    %New segmentation
                    propSeg=alpha_expansion_labelcost(chosenLabel,seg,img_sp,unary,edge_cost,betaTd);
                    imagesc(propSeg(img_sp.spInd));
                    pause

                    %Compute Energy
                    E=zeros(1,length(optsvm.w));
                    E(1)=sum(unary((1:nbSp)'+nbSp*(propSeg(:)-1)));
                    E(2) = sum(edge_cost((propSeg(img_sp.edges(:,1))~=propSeg(img_sp.edges(:,2)))));
                    for l=1:4
                        labelPres(l)=ismember(l,propSeg);
                    end;
                    E(3:end)=dot(betaTd,labelPres(:));
                    
                    Eafter=sum(E);
                    
                    if Eafter<Ebefore
                        seg=propSeg;
                        fprintf('Jump from %f to %f\n',Ebefore,Eafter);
                        Ebefore=Eafter;
                        success=1;
                    end
                end
                
                
            end

        end
        

end

