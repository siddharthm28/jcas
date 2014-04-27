function visualize_prob_image(p,name,filepath)
% function to visualize the given probability map on the basis of MAP
% estimate of the class
[~,labels]=max(p,[],3);
tmp=label2rgb(labels);
imwrite(tmp,fullfile(filepath,[name,'.png']));
