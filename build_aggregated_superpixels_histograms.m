%--------------------------------------------------------------------------
%Aggregate superpixels histograms
%--------------------------------------------------------------------------
%This function builds the aggregated histogram accross superpixels
%neighboorhood if the parameter obj.superpixels.neighboorhoodsize is non
%zero.
%Input :
%_ obj of class jcas
%_ imsetname : string either 'training' or 'test'
%
%Output : saving the aggregated histograms as %s-histogram-neighborhood-%d
%in obj.dbparams.destpathmat

function build_aggregated_superpixels_histograms(obj,imgsetname)

if ~obj.destpathmade
    error('Before doing anything you need to call obj.makedestpath')
end

%Check if a neighboorhood for superpixels is needed
%load(sprintf(obj.unary.dictionary.destmatpath,'unary_dictionary'));


%Load either training or testing set indices
ids = obj.dbparams.(imgsetname);

%obj.unary.num_superpixel_histograms = zeros(1,length(ids));
fprintf('\n aggregate_histograms_across_superpixel_neighborhoods (N=%d, total of %d images):    ',obj.unary.SPneighboorhoodsize, length(ids));

if ~exist(sprintf(obj.unary.destmatpath,sprintf('num_sphistograms_per_im-%d',obj.unary.SPneighboorhoodsize)),'file');
    num_sphistograms_per_im = [];
else
    load(sprintf(obj.unary.destmatpath,sprintf('num_sphistograms_per_im-%d',obj.unary.SPneighboorhoodsize)),'num_sphistograms_per_im');
end

% for each image
for i=1:length(ids)
    fprintf('\b\b\b\b%04d',i);
    
    aggregated_filename = sprintf(obj.unary.destmatpath,sprintf('%s-histogram-neighborhood-%d',obj.dbparams.image_names{ids(i)},...
        obj.unary.SPneighboorhoodsize));
    if (~exist(aggregated_filename, 'file')|| obj.force_recompute.aggregated_histograms)
        
        if (obj.unary.SPneighboorhoodsize >0)
            %Loading the image data and histograms previously computed
            load(sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)})));
            load(sprintf(obj.unary.destmatpath,sprintf('%s-SP_histogram',obj.dbparams.image_names{ids(i)})),'superpixel_histograms');
            edges=img_sp.edges;
            %Number of superpixels
            num_sp = size(superpixel_histograms,2);            
            hh = zeros(obj.unary.dictionary.params.num_bu_clusters+1, num_sp);
            save(aggregated_filename,'hh');
            %Building adjacency matrix
            A=adjacency(edges);
            L = A;
            
            % For size of superpixel neighborhood, computing the next loop
            % make the (i,j) term non zero if two superpixels are less than
            % neighboorhoodsize distant.
            for j=2:obj.unary.SPneighboorhoodsize
                L= A*(speye(size(L)) + L);
            end
            
            %Add the last line for dominant classes
            hh = zeros(obj.unary.dictionary.params.num_bu_clusters+1, num_sp);
            
            
            for j=1:num_sp
                %Retrieves the neighboorhood of superpixel j
                %index = find(L(j,:)~=0);
                %Gathering the histograms
%                 size(superpixel_histograms)
%                 size(L)
                 hh(:,j) = [(sum(superpixel_histograms(1:end-1,(L(j,:)~=0)),2)); superpixel_histograms(end,j)];
               %Normalization step
            end
            norm_tmp=sum(hh(1:end-1,:),1);
            hh(1:end-1,norm_tmp~=0)=hh(1:end-1,norm_tmp~=0)./repmat(norm_tmp,[size(hh,1)-1,1]);

            superpixel_histograms = hh;
        else
            load(sprintf(obj.superpixels.destmatpath,sprintf('%s-imgsp',obj.dbparams.image_names{ids(i)})));
            load(sprintf(obj.unary.destmatpath,sprintf('%s-SP_histogram',obj.dbparams.image_names{ids(i)})),'superpixel_histograms');
            for j=1:img_sp.nbSp
                %Normalization step
                if(sum(superpixel_histograms(1:end-1,j))~=0)
                    superpixel_histograms(1:end-1,j) = superpixel_histograms(1:end-1,j)/sum(superpixel_histograms(1:end-1,j));
                end
            end
            
        end
        num_sphistograms_per_im(ids(i)) = size(superpixel_histograms,2);
        save(aggregated_filename,'superpixel_histograms');
    end
    
end
save(sprintf(obj.unary.destmatpath,sprintf('num_sphistograms_per_im-%d',obj.unary.SPneighboorhoodsize)),'num_sphistograms_per_im');
fprintf('\n');
end
