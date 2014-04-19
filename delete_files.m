function delete_files(obj,image_name)
% function that deletes all the relvant files correponding to that
% image_name for that particular experiment

imgdata_file=sprintf(obj.dbparams.destmatpath,[image_name,'-imagedata']);
if(exist(imgdata_file,'file')), delete(imgdata_file); end

sp_file=sprintf(obj.superpixels.destmatpath,[image_name,'-imgsp']);
if(exist(sp_file,'file')), delete(sp_file); end

feat_file=sprintf(obj.unary.features.destmatpath,[image_name,'-unfeat']);
if(exist(feat_file,'file')), delete(feat_file); end

hist_file=sprintf(obj.unary.destmatpath,[image_name,'-SP_histogram']);
if(exist(hist_file,'file')), delete(hist_file); end

aggr_hist_file=sprintf(obj.unary.destmatpath,[image_name,...
    sprintf('-histogram-neighbourhood-%d',obj.unary.SPneighboorhoodsize)]);
if(exist(aggr_hist_file,'file')), delete(aggr_hist_file); end

unary_file=sprintf(obj.unary.svm.destmatpath,[image_name,...
    sprintf('-unary-%d',obj.unary.svm.params.kernel_type)]);
if(exist(unary_file,'file')), delete(unary_file); end

pairwise_file=sprintf(obj.pairwise.destmatpath,[image_name,'-pairwise']);
if(exist(pairwise_file,'file')), delete(pairwise_file); end

td_feat_file=sprintf(obj.topdown.features.destmatpath,[image_name,'-topdown_features']);
if(exist(td_feat_file,'file')), delete(td_feat_file); end

td_unary_file=sprintf(obj.topdown.unary.destmatpath,[image_name,...
    sprintf('-topdown_unary-%d',obj.topdown.dictionary.params.size_dictionary)]);
if(exist(td_unary_file,'file')), delete(td_unary_file); end
