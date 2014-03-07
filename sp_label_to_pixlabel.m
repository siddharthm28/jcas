function sp_label_to_pixlabel(obj,imgset)

ids=obj.dbparams.(imgset);
for i=1:length(ids)
segres_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_result',obj.dbparams.image_names{ids(i)}));
segresP_filename=sprintf(obj.test.destmatpath,sprintf('%s-seg_resultP',obj.dbparams.image_names{ids(i)}));

imgsp_filename=sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)}));
img_filename=sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',obj.dbparams.image_names{ids(i)}));


load(segres_filename);
load(imgsp_filename);
load(img_filename);

%Pixel label from superpixels
pixelSeg=seg(img_sp.spInd);

save(segresP_filename,'pixelSeg');
end