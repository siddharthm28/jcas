function finseg=alpha_expansion_labelcost(cat,seg,img_sp,unary,edge_cost,label_cost,IP,nbIP)
%Compute 1 alpha expansion step for img_sp superpixels struct, unary Nnodes
%x nLabels, pairwise nNodes^2, label_costs, IP interest points list
%nbIP(i) : number of SIFT in superpixel of point IP(i)
if sum(label_cost<0)>0
  error('Impossible to compute for negative label costs')
end


nbSp=img_sp.nbSp;
edges=img_sp.edges;

lbl_edges = seg(edges);
diff_edge = find(lbl_edges(:,1)~=lbl_edges(:,2));
same_edge = find(lbl_edges(:,1)==lbl_edges(:,2));

% FIND NUMBER OF EXTRA NODES
existing_labels=unique(seg);
if ismember(cat,existing_labels)
    num_nodes=nbSp + length(diff_edge) + length(existing_labels);
else
    num_nodes = nbSp + length(diff_edge) + length(existing_labels)+1;
end


% CONSTRUCT UNARIES
binary_unary = zeros(num_nodes,2,'double');

% unaries for pixels in the image
binary_unary(1:nbSp,2) = unary(:,cat);
tmp=unary((1:nbSp)+nbSp*(seg-1));
binary_unary(1:nbSp,1) = tmp(:);
binary_unary((seg==cat),1) = 2e10;

% unaries for auxilary pixels for modeling the pairwise terms in  alpha expansion
%binary_unary(1,nbSp+1:nbSp+length(diff_edge)) = edge_cost(diff_edge);
binary_unary(nbSp+1:nbSp+length(diff_edge),1) = edge_cost(diff_edge);

% CONSTRUCT PAIRWISE TERMS from Bottom UP

% pairwise for pixels which have the same labels
new_edges1 = edges(same_edge,:);
%new_cost1 = edge_cost(same_edge);
new_cost1 = (lbl_edges(same_edge,1)~=cat).*edge_cost(same_edge);

% pairwise for pixels-aux_nodes to account for pairs of pixels which have different labels
new_edges2 = [[edges(diff_edge,1) [nbSp+1:nbSp+length(diff_edge)]'];...
    [[nbSp+1:nbSp+length(diff_edge)]' edges(diff_edge,2)]];

new_cost2 = [(lbl_edges(diff_edge,1)~=cat).*edge_cost(diff_edge); (lbl_edges(diff_edge,2)~=cat).*edge_cost(diff_edge)];
%new_cost2 = [edge_cost(diff_edge); edge_cost(diff_edge)];


%Unary for linear classifier
if ismember(cat,existing_labels)
    existing_labels(existing_labels==cat) = [];
    binary_unary(nbSp+length(diff_edge)+1:nbSp+length(diff_edge)+length(existing_labels),1) = label_cost(existing_labels);
else
    binary_unary(nbSp+length(diff_edge)+1,2) = label_cost(cat);
    binary_unary(nbSp+length(diff_edge)+2:nbSp+length(diff_edge)+length(existing_labels)+1,1) = label_cost(existing_labels);
end

% pairwise for pixels_aux nodes to account for the linear classifiers
labelOffset=nbSp+length(diff_edge);
new_edges3 = [];
new_cost3 = [];

existing_labels=unique(seg);
if ~ismember(cat,existing_labels)
    index_i = find(nbIP>0);
    new_edges3 = [new_edges3; [(labelOffset+1)*ones(length(index_i),1) IP(index_i) ]];
    new_cost3 = [new_cost3; 0.5*label_cost(cat).*nbIP(index_i)];
    labelOffset = labelOffset+1;
else
    existing_labels(existing_labels==cat) = [];
end


%Label besides alpha
for i=1:length(existing_labels)
    lCost=label_cost(existing_labels(i));
    if existing_labels(i)~=cat
        indClique=IP(seg(IP)==existing_labels(i));
        nbIPClique=nbIP(seg(IP)==existing_labels(i));
        cardClique=length(indClique);
        nbIPCliqueSum=sum(nbIPClique);
        %binary_unary(labelOffset+i,1)=lCost;%*(1-nbIPCliqueSum/2);
        %binary_unary(indClique,2)=binary_unary(indClique,2)-lCost/2*nbIPClique;
        % Edges from pixels with label l to aux var y_l
        new_edges3=[new_edges3 ; [indClique(:),(labelOffset+i)*ones(size(indClique(:)))]];
        new_cost3=[new_cost3 ; lCost/2*nbIPClique(:)];
    else
        nbIPCliqueSum=sum(nbIP);
        %binary_unary(labelOffset+i,2)=lCost;%*(1-nbIPCliqueSum/2)
        %binary_unary(IP,1)=binary_unary(IP,1)-lCost/2*nbIP;
        % Edges from pixels with label l to aux var y_l
        new_edges3=[new_edges3 ; [(labelOffset+i)*ones(length(IP),1),IP(:)]];
        new_cost3=[new_cost3 ; lCost/2*nbIP(:)];        
    end
end

%Symetrize edges
if size(new_edges3,1)>0
    tmp1 = full(sparse(new_edges3(:,1), ones(size(new_edges3,1),1), +new_cost3, num_nodes,1));
    tmp2 = full(sparse(new_edges3(:,2), ones(size(new_edges3,1),1), -new_cost3, num_nodes,1));
    binary_unary(:,1) = binary_unary(:,1)+tmp1+tmp2;
end


binary_edges = [new_edges1; new_edges2; new_edges3];
binary_cost = [new_cost1; new_cost2; new_cost3];

binary_pairwise = sparse([binary_edges(:,1); binary_edges(:,2)], [binary_edges(:,2); binary_edges(:,1)],...
    [binary_cost; binary_cost], num_nodes, num_nodes);

% PERFORM EXPANSION MOVE
[~, seg2]=maxflow(binary_pairwise,sparse(binary_unary));
% [~,initseg_binary]=max(binary_unary,[],2);
% seg2=GCMex(initseg_binary-1, single(binary_unary'), binary_pairwise, single(ones(2)-eye(2)),0);

finseg=seg;
%Careful with the number associated to sink/source here 0 for some strange
%reasons.
finseg(seg2(1:nbSp)==0)=cat;
end
