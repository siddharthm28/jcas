function model=mySSVM(param,max_iter,C,type)
% wrapper to call the structural svm variants

options.num_passes=max_iter;
switch type
    case 'ssg'
        [model,progress]=solverSSGpos(param,options);
    case 'fw'
        [model,progress]=solverFWpos(param,options);
    case 'bcfw'
        [model,progress]=solverBCFW(param,options);
end
keyboard;