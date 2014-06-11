function yhat=run_up_solver(unary,pairwise,ncat)
% function that solves the inference problem with uanry and pairwise terms
% assuming unary is ncat x nbsp, pairwise is nbsp x nbsp.
if(ispc)
    h=BK_Create();
    BK_AddVars(h,size(unary,2));
    BK_SetUnary(h,unary);
    BK_SetNeighbors(h,pairwise);
    e=BK_Minimize(h);
    yhat=BK_GetLabeling(h);
    yhat=double(yhat(:)');
else
    unary=single(unary); pairwise=sparse(double(pairwise));
    [~,init]=max(unary);
    labelcost=single(ones(ncat)-eye(ncat));
    [yhat,~,~]=GCMex(init-1,unary,pairwise,labelcost,0);
    yhat=yhat+1;
end
