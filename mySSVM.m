function model=mySSVM(param,max_iter,C,type)
% wrapper to call the structural svm variants

options.num_passes=max_iter;
options.lambda=1/C;
options.gap_check=0;
switch type
    case 'ssg'
        [model,progress]=solverSSGpos(param,options);
    case 'fw'
        [model,progress]=solverFWpos(param,options);
    case 'bcfw'
        [model,progress]=solverBCFWpos(param,options);
end
