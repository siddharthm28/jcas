function run_experiments
% code to run all experiments for the subset data and visualize the results
clear all; clc; close all;
% modes=[0,1,2,6,7];
% % textonboost-ucm
% use_unary=1; use_sp=1;
% jcas_objects=cell(1,length(modes));
% for i=1:length(modes)
%     if(i==1), recompute=1; else recompute=0; end
%     jcas_objects{i}=Initialization('voc2011-sbd-cars-subset',modes(i),...
%         use_unary,use_sp,recompute);
% end
% save('results/textonboost-ucm.mat','jcas_objects');
% % textonboost-quickshift
% use_unary=1; use_sp=0;
% jcas_objects=cell(1,length(modes));
% for i=1:length(modes)
%     if(i==1), recompute=1; else recompute=0; end
%     jcas_objects{i}=Initialization('voc2011-sbd-cars-subset',modes(i),...
%         use_unary,use_sp,recompute);
% end
% save('results/textonboost-quickshift.mat','jcas_objects');
% % dsift-ucm
% use_unary=0; use_sp=1;
% jcas_objects=cell(1,length(modes));
% for i=1:length(modes)
%     if(i==1), recompute=1; else recompute=0; end
%     jcas_objects{i}=Initialization('voc2011-sbd-cars-subset',modes(i),...
%         use_unary,use_sp,recompute);
% end
% save('results/dsift-ucm.mat','jcas_objects');
% % dsift-quickshift
% use_unary=0; use_sp=0;
% jcas_objects=cell(1,length(modes));
% for i=1:length(modes)
%     if(i==1), recompute=1; else recompute=0; end
%     jcas_objects{i}=Initialization('voc2011-sbd-cars-subset',modes(i),...
%         use_unary,use_sp,recompute);
% end
% save('results/dsift-quickshift.mat','jcas_objects');

% % run experiments to check if bootstrapping works or not
% num_experiments=10;
% jcas_objects=cell(1,num_experiments);
% for i=1:num_experiments
%     jcas_objects{i}=Initialization('inria-graz',1,0,0,1);
% end

% % run all experiments on inria-graz data
% modes=[0,1,2,7,6];
% jcas_objects=cell(1,length(modes));
% for i=1:length(modes)
%     jcas_objects{i}=Initialization('inria-graz',modes(i),0,0,0);
% end
% save('results/inria-graz-experiments','jcas_objects');

% run all experiments on inria-graz data with old splits
modes=[0,1,2,7,6];
jcas_objects=cell(1,length(modes));
for i=1:length(modes)
    jcas_objects{i}=Initialization('inria-graz-old-splits',modes(i),0,0,0);
end
save('results/inria-graz-old-splits-experiments','jcas_objects');
