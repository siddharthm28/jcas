function finseg=alpha_expansion_intersection(cat,seg,img_sp,unary,edge_cost,topdown_unary,tHists,intcoeffs,label_cost)
%Compute 1 alpha expansion step with intersection kernel classifiers.
%IMPLEMENTED FOR HIGHER ORDER TERMS BUILT USING THE HISTOGRAM INTERSECTION
%KERNEL

%Compute pivots coefficients (efficiency to limit number of auxiliary
%variables) for l k fixed
%Remember : ordering l=1 ,s=1...nb tHists, l=2, s= 1:nb tHists, etc...

intcoeffs=reshape(intcoeffs,[size(tHists,2) size(unary,2)]);

pvts_tmp=cell(size(unary,2),size(topdown_unary,2));
pvts_coeffs=cell(size(unary,2),size(topdown_unary,2));
pvts_sparse=cell(size(unary,2),size(topdown_unary,2));

for word=1:size(topdown_unary,2)
    pvt_max=max(tHists(word,:));
    for label=1:size(unary,2)
        pvts_tmp{label,word}=sparse(ones(1,length(tHists(word,tHists(word,:)>0))),tHists(word,tHists(word,:)>0)',intcoeffs(tHists(word,:)>0,label),1,pvt_max);
        [~,pvts_sparse{label,word},pvts_coeffs{label,word}]=find(pvts_tmp{label,word});
    end
end

if sum(label_cost<0)>0
    error('Impossible to compute for negative label costs')
end

ncat=size(unary,2);
nbSp=img_sp.nbSp;
edges=img_sp.edges;
nlabels=nbSp;
cdim=size(topdown_unary,2);
topdown_count=sum(topdown_unary,2)';
unary=unary';

% FIND NUMBER OF EDGES WITH EXACTLY ONE NODE HAVING CURRENT CATEGORY LABEL
lbl_edges = seg(edges);
diff_edge = find(lbl_edges(:,1)~=lbl_edges(:,2));
same_edge = find(lbl_edges(:,1)==lbl_edges(:,2));

% FIND NUMBER OF EXTRA NODES
existing_labels = unique(seg(:));

% CONSTRUCT UNARIES
binary_unary = zeros(2,nlabels);

% unaries for pixels in the image
binary_unary(2,1:nlabels) = unary(cat,:);
binary_unary(1,1:nlabels) = unary(ncat*(0:nlabels-1)'+seg(:));
binary_unary(1,(seg==cat)) = 2e10;

% unaries for auxilary pixels for modeling the pairwise terms in  alpha expansion
binary_unary(1,nlabels+1:nlabels+length(diff_edge)) = edge_cost(diff_edge);




% CONSTRUCT PAIRWISE TERMS

% pairwise for pixels which have the same labels
new_edges1 = edges(same_edge,:);
new_cost1 = (lbl_edges(same_edge,1)~=cat).*edge_cost(same_edge);

% pairwise for pixels-aux_nodes to account for pairs of pixels which have different labels
new_edges2 = [[edges(diff_edge,1) [nlabels+1:nlabels+length(diff_edge)]'];...
    [[nlabels+1:nlabels+length(diff_edge)]' edges(diff_edge,2)]];

new_cost2 = [(lbl_edges(diff_edge,1)~=cat).*edge_cost(diff_edge); (lbl_edges(diff_edge,2)~=cat).*edge_cost(diff_edge)];


% pairwise for pixels_aux nodes to account for the histogram intersection

new_edges3 = [];
new_cost3 = [];
offset = nlabels+length(diff_edge);
for clstr=1:cdim
    pvts = pvts_sparse{cat,clstr};
    num_cat = sum(topdown_unary(find(seg==cat),clstr));
    num_all = sum(topdown_unary(:,clstr));
    pvts_active = pvts(find(pvts>num_cat & pvts<= num_all));
    %GOLU
    index_active = find(pvts>num_cat & pvts<= num_all);
    index_unary = find(pvts>num_all);
    num_pvts = length(pvts_active);
    if (num_pvts>0)
        coeff_catI= pvts_coeffs{cat,clstr};
        coeff_cat=coeff_catI(index_active);
        %GOLU coeff_cat = coeff(cat,clstr).im(end-num_pvts+1:end);
        index_i = find(topdown_unary(:,clstr)>0 & seg(:)~=cat);
        len_index_i = length(index_i);
        
        new_edges3 = [new_edges3; [reshape(repmat(offset+[1:num_pvts], len_index_i,1),len_index_i*num_pvts,1) repmat(index_i(:), num_pvts,1)]];
        new_cost3 = [new_cost3; 0.5*repmat(topdown_unary(index_i,clstr),num_pvts,1).*reshape(repmat(coeff_cat(:)',len_index_i,1),len_index_i*num_pvts,1)];
        
        binary_unary(2,offset+1:offset+num_pvts) = coeff_cat.*(pvts_active-num_cat);
        binary_unary(2,index_i) = binary_unary(2,index_i) + (topdown_unary(index_i,clstr)*sum(coeff_catI(index_unary)))';
        offset = offset+num_pvts;
    end
end

if (length(find(seg==cat))==0)
    index_i = find(topdown_count>0);
    len_index_i = length(index_i);
    if (len_index_i >0)
        new_edges3 = [new_edges3; [(offset+1)*ones(len_index_i,1) index_i(:)]];
        new_cost3 = [new_cost3; 0.5*label_cost(cat)*ones(len_index_i,1)];
        binary_unary(2,offset+1) = label_cost(cat);%GOLU 0.5*label_cost(cat);
        offset = offset+1;
    end
end




existing_labels = unique(seg(:));
existing_labels(find(existing_labels==cat)) = [];

for i=1:length(existing_labels)
    for clstr=1:cdim
        pvts = pvts_sparse{existing_labels(i),clstr};
        pvts_active = pvts(find(pvts <= sum(topdown_unary(find(seg==existing_labels(i)),clstr))));
        %                 length(pvts_active)
        num_pvts = length(pvts_active);
        if (num_pvts>0)
            index_i = find(seg(:)==existing_labels(i)  & topdown_unary(:,clstr)>0);
            len_index_i = length(index_i);
            coeff_catI = pvts_coeffs{existing_labels(i),clstr};
            coeff_cat=coeff_catI(1:num_pvts);
            
            new_edges3 = [new_edges3; [repmat(index_i(:), num_pvts,1) reshape(repmat(offset+[1:num_pvts], len_index_i,1),len_index_i*num_pvts,1)]];
            new_cost3 = [new_cost3; 0.5*repmat(topdown_unary(index_i,clstr),num_pvts,1).*reshape(repmat(coeff_cat(:)',len_index_i,1),len_index_i*num_pvts,1)];
            
            binary_unary(1,offset+1:offset+num_pvts) = coeff_cat.*pvts_active;
            coeff_catI = pvts_coeffs{existing_labels(i),clstr};
            coeff_cat=coeff_catI(num_pvts+1:end);
            binary_unary(1,index_i) = binary_unary(1,index_i) + (topdown_unary(index_i,clstr)*sum(coeff_cat(:)))';
            offset = offset+num_pvts;
        end
    end
    
    index_i = find(seg(:)==existing_labels(i) & topdown_count(:)>0);
    len_index_i = length(index_i);
    if (len_index_i>0)
        new_edges3 = [new_edges3; [index_i(:) (offset+1)*ones(len_index_i,1) ]];
        new_cost3 = [new_cost3; 0.5*label_cost(existing_labels(i))*ones(len_index_i,1)];
        binary_unary(1,offset+1) = label_cost(existing_labels(i));% GOLU 0.5*label_cost(existing_labels(i));
        offset = offset+1;
    end
    
end

num_nodes = offset;
indexnz = find(new_cost3~=0);
new_edges3 = new_edges3(indexnz,:);
new_cost3 = new_cost3(indexnz);

% adjust the unaries to account for conversion of asymmetric edges into symmetric edges
if size(new_edges3,1)>0
    tmp1 = full(sparse(new_edges3(:,1), ones(size(new_edges3,1),1), +new_cost3, num_nodes,1))';
    tmp2 = full(sparse(new_edges3(:,2), ones(size(new_edges3,1),1), -new_cost3, num_nodes,1))';
    binary_unary(1,:) = binary_unary(1,:)+tmp1+tmp2;
end



binary_edges = [new_edges1; new_edges2; new_edges3];
binary_cost = [new_cost1; new_cost2; new_cost3];

binary_pairwise = sparse([binary_edges(:,1); binary_edges(:,2)], [binary_edges(:,2); binary_edges(:,1)],...
    [binary_cost; binary_cost], num_nodes, num_nodes);

%initseg_binary = [double(seg(:)'==cat) zeros(1,num_nodes-nbSp)];
% PERFORM EXPANSION MOVE
[~, seg2]=maxflow(binary_pairwise,sparse(binary_unary'));

%seg2=GCMex(initseg_binary, single(binary_unary'), binary_pairwise, single(ones(2)-eye(2)),0);
finseg=seg;
%Careful with the number associated to sink/source here 0 for some strange
%reasons.
finseg(seg2(1:nbSp)==0)=cat;
end
