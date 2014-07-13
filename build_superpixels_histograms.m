function build_superpixels_histograms(obj,imgsetname)
%Compute the histograms of wordprouts for each superpixel in the image
% Input:
% _ obj of class jcas
% _ imgsetname string either 'training' or 'test'
% Output: 'superpixel_histograms' saved in '%s-SP_histograms'
%%%%%%%% ADD CHECK IF SUPERPIXELS DO NOT CONTAIN ANY FEATURE %%%%%%%
%%%%%%%% NUMBER OF WORDS SHOULD MATCH %%%%%%%%%%%%
%%%%%%%% NB OF SIFT FEATURE MATCH IMAGE size %%%%%%%%%%%

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end

tmp=load(sprintf(obj.unary.dictionary.destmatpath,'unary_dictionary'));
feature_clusters=tmp.feature_clusters;
kdtree=vl_kdtreebuild(feature_clusters);

%Indices of the image set (training or testing)
ids = obj.dbparams.(imgsetname);

if ~exist(sprintf(obj.unary.destmatpath,'num_sphistograms_per_im'),'file');
    num_sphistograms_per_im = zeros(1,obj.dbparams.num_images);
else
    tmp=load(sprintf(obj.unary.destmatpath,'num_sphistograms_per_im'),'num_sphistograms_per_im');
    num_sphistograms_per_im=tmp.num_sphistograms_per_im;
end

fprintf('\n construct_histograms_for_superpixels: (total of %d images):    ', length(ids));

% for each image
for i=1:length(ids)
    fprintf('\b\b\b\b%04d',i);
    %Name of the mat file where the histograms will be stored
    histogram_filename = sprintf(obj.unary.destmatpath,sprintf('%s-SP_histogram',obj.dbparams.image_names{ids(i)}));
    
    
    if (~exist(histogram_filename, 'file') || obj.force_recompute.superpixels_histograms)
        
        %Load the data computed with extract_features
        tmp=load(sprintf(obj.dbparams.destmatpath,sprintf('%s-imagedata',obj.dbparams.image_names{ids(i)})));
        img_info=tmp.img_info;
        tmp=load(sprintf(obj.unary.features.destmatpath,sprintf('%s-unfeat',obj.dbparams.image_names{ids(i)})));
        img_feat=tmp.img_feat;
        tmp=load(sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)})));
        img_sp=tmp.img_sp;
        
        % Load training segmentation for each image
        tmp=load(sprintf(obj.dbparams.segpath,obj.dbparams.image_names{ids(i)}),'seg_i');
        seg_i=tmp.seg_i;
       
        % Find the number of labels
        %num_class = max(max(seg_i)); 
        
        %superpixel_histograms = (obj.unary.dictionary.params.num_bu_clusters, img_sp.nbSp, 'uint8');
        superpixel_histograms = zeros(obj.unary.dictionary.params.num_bu_clusters, img_sp.nbSp);
        %dominant_class = ones(1,num_class,'uint8');
        dominant_class = ones(1,img_sp.nbSp);
%         save(histogram_filename,'superpixel_histograms');
        % Find the locations of the image features
        F=img_feat.locations;
        locations = img_info.X*(round(F(1,:))-1)+round(F(2,:));
        feat_sp = img_sp.spInd(locations);

        zero_vector = zeros(1,obj.unary.dictionary.params.num_bu_clusters);
       
        % for each superpixel
        for n=1:img_sp.nbSp
            
            %Retrieve indices of pixels in superpixel n
            index_n = (feat_sp==n);
            
            if (sum(index_n)>0)
                
                % Use k-means to cluster features
                %hh = vl_ikmeanspush(uint8(img_feat.descriptors(:,index_n)),feature_clusters);
%                 hh = vl_ikmeanspush((img_feat.descriptors(:,index_n)),feature_clusters);
                hh = double(vl_kdtreequery(kdtree, feature_clusters, single(img_feat.descriptors(:,index_n)),'MaxComparisons', 50)) ;
              
                %superpixel_histograms(:,n)=hist(hh,1:obj.unary.dictionary.params.num_bu_clusters);
                superpixel_histograms(:,n) = vl_binsum(zero_vector,ones(size(hh)),hh);
                                
                % Find dominant classes
                %Void class OK
                superpixel_GT = seg_i(locations(index_n));
                superpixel_GT_NoVoid = superpixel_GT(superpixel_GT~=0);
                nbVoid=sum(superpixel_GT==0);
                
                classes = vl_binsum(zeros(1,obj.dbparams.ncat),ones(size(superpixel_GT_NoVoid)),superpixel_GT_NoVoid);
               % classes = hist(superpixel_GT,[1:obj.dbparams.ncat]);
                [M,ind] = max(classes);
                if M>nbVoid
                    dominant_class(n) = ind;
                else
                    dominant_class(n)=0;
                end
                
            end
            
        end
        
        %Add a last row with the dominant class per superpixel
        superpixel_histograms = [superpixel_histograms; dominant_class];
        
        %Filter for classes we're not interested in (need to have the
        %class of interest using first integers).
        %superpixel_histograms = superpixel_histograms(:,find(dominant_class(:)<obj.dbparams.ncat+1));	
        
        %Save the results
        save(histogram_filename,'superpixel_histograms');
        %Save the final number of superpixels histograms for image i.
        num_sphistograms_per_im(ids(i)) = size(superpixel_histograms,2);
   % else
    %    load (histogram_filename, 'superpixel_histograms');        
    end
    
end
    
save(sprintf(obj.unary.destmatpath,'num_sphistograms_per_im'),'num_sphistograms_per_im');


end

