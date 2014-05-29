%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Definition of JCaS class
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This file defines all the properties and methods needed to build a
%structure for Joint Categorization and Segmentation work.
%
%To generate an empty sample with all the parameters needed, use "jcas();"
%
%--------------------------------------------------------------------------
%Database handling :
%--------------------------------------------------------------------------
%Currently 3 databases are handled : Graz, CamVid, Pascal.
%_To handle automated management of your own databases, please modify the
%makedb.m file in the @jcas directory.
%_ To use custom database, generate a jcas object with jcas(); and modify
%the parameters in the structure "obj.dbparams". For more details, please
%see the default constructor down below or Documentation file.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Superpixels handling :
%--------------------------------------------------------------------------
%Currently only 1 superpixel method is compatible : 'Quickshift' You can
%add your own in makesp.m and computeSuperpixels files or use default
%configuration.
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Features handling :
%--------------------------------------------------------------------------
%Currently only 1 feature (dsift) can be used but you can add your own in
%the computeFeature.m file.
%--------------------------------------------------------------------------




%Parameters tuning Training Testing

classdef jcas < handle
    %The class jcas stores all parameters needed to train/test any of the
    %algorithm of Joint Categorization and Segmentation
    
    properties 
        %Parameters associated with the database
        dbparams=struct();
        
        %Parameters of superpixels
        superpixels=struct();
        
        %Mode : struct indicating which term should be used
        mode=0;
        
        %Unary potentials options
        unary=struct();
        
        %Pairwise potentials options
        pairwise=struct();
        
        %Topdown potiential options
        topdown=struct();
        
        %Latent structure options
        topdown_latent=struct();
        
        %Cutting-plane slack variable
        optimisation=struct();
        
        %Force recomputing of parameters even if results are already there
        force_recompute=struct();
        
        %Test structure 
        test=struct();
        
        %Flag for makedestpath
        destpathmade=0;
        
        %Initialization of hte model
        init=struct();
        
%         %Preprocessing
%         preprocessing=struct();
        
        
        
    end
  
    methods

      
        %Default constructor for class jcas
        function obj=jcas(d)
            
            obj;
            
            %--------------------------------------------------------------
            %Default Database Parameters
            %--------------------------------------------------------------
            obj.dbparams.name='';
            
            obj.dbparams.format='.';
            
            % total number of images
            obj.dbparams.num_images =0;
            
            % total number of categories
            obj.dbparams.ncat       =0;
            
            %Map from index to filenames
            obj.dbparams.image_names=cell(0);
            
            
            % image names and index for training set
            obj.dbparams.training   =[];
            
            % image index for test set
            obj.dbparams.test       = [];
            
            % path to the images
            obj.dbparams.imgpath     = '';
            
            % % path to the ground truth lables??
            obj.dbparams.segpath     = '';
            
            % path to the results
            obj.dbparams.destmatpath = '';
            %--------------------------------------------------------------
            
            %--------------------------------------------------------------
            %Destination path for mat files
            %--------------------------------------------------------------
            obj.superpixels.destmatpath='';
            obj.unary.destmatpath='';
            obj.unary.features.destmatpath='';
            obj.unary.dictionary.destmatpath='';
            obj.topdown_latent.destmatpath='';
            obj.pairwise.destmatpath='';
            obj.topdown.features.destmatpath='';
            obj.topdown.dictionary.destmatpath='';
            obj.optimisation.destmatpath='';
            obj.test.destmatpath='';
            
            %--------------------------------------------------------------
            
            %--------------------------------------------------------------
            % Superpixels options
            %--------------------------------------------------------------          
            %Parameter structure (ex quickshift tau/ratio/kernelsize)
            obj.superpixels.params=struct();
            
            %Method name
            obj.superpixels.method='';
            
            %Number of superpixel histograms
            obj.superpixels.params.num_superpixel_histograms=0;
            

            %--------------------------------------------------------------
            
            %--------------------------------------------------------------
            % Unary features initialization
            %--------------------------------------------------------------
            %Name of feature method
            obj.unary.features.method='';
            obj.unary.precomputed=0;
            obj.unary.precomputed_path=[];
            
            %Parameters (if needed)
            obj.unary.features.params=struct();
            
            %Size of features descriptors
            obj.unary.features.params.descriptor_dimension=0;
            
            %--------------------------------------------------------------
            % Unary dictionary initialization
            %--------------------------------------------------------------
            
            %Parameters (if needed)
            obj.unary.dictionary.params=struct();
            obj.unary.dictionary.params.num_bu_clusters=0;

            %--------------------------------------------------------------
            % Unary initialization
            %--------------------------------------------------------------
            
            %Parameters (if needed)
            obj.unary.svm.params.max_hists_per_class_for_training=0;
            obj.unary.svm.trainingset.params.hists_per_image=0;
            obj.unary.svm.trainingset.destmatpath='';
            %Size of neighborhood superpixel
            obj.unary.SPneighboorhoodsize=0;
            obj.unary.svm.params.unary_kernel_type=1;
            obj.unary.svm.destmatpath='';
            %--------------------------------------------------------------
            % Pairwise initialization
            %--------------------------------------------------------------
            
            %Parameters (if needed)
            obj.pairwise.params=struct();

            %--------------------------------------------------------------
            % Topdown features initialization
            %--------------------------------------------------------------
            obj.topdown.params=struct();
            %Parameters (if needed)
            obj.topdown.features.method='';
            obj.topdown.features.params=struct();
            obj.topdown.features.params.max_per_image='none';
            obj.topdown.features.destmatpath='';
            obj.topdown.dictionary.destmatpath='';
            obj.topdown.unary.destmatpath='';

            %--------------------------------------------------------------
            %Topdown dictionary initialization
            %--------------------------------------------------------------
            %Size of the dictionary for top down potentials
            obj.topdown.dictionary.params=struct();
            obj.topdown.dictionary.params.size_dictionary=0;
            
            
            %--------------------------------------------------------------
            % Optimisation initialization
            %--------------------------------------------------------------
            %Size of the dictionary for top down potentials
            obj.optimisation.params=struct();
            obj.optimisation.method='';
            
            
            %--------------------------------------------------------------
            
            %--------------------------------------------------------------
            % Test initialization
            %--------------------------------------------------------------
            %
            
            
            %--------------------------------------------------------------  

            
            %--------------------------------------------------------------
            %Force recomputing options
            %--------------------------------------------------------------
            
            %Disable default recomputing of training data (Superpixels/Features)
            obj.force_recompute.trainingdata_UF=0;
            obj.force_recompute.imagedata=0;
            obj.force_recompute.trainingdata_SP=0;
            %Recomputing dictionary for unary
            obj.force_recompute.dictionary_unary=0;
            %Recomputing superpixels histograms
            obj.force_recompute.superpixels_histograms=0;
            %Recomputing aggregated superpixels histograms
            obj.force_recompute.aggregated_histograms=0;
            %Recomputing training set for svm on unary potentials
            obj.force_recompute.trainingset_svm=0;
            %Recomputing the svm classifiers for unary potentials
            obj.force_recompute.unary_svm_classifiers=0;
            %Recomputing the unary potentials
            obj.force_recompute.unary=0;
            %Recomputing pairwise potentials
            obj.force_recompute.pairwise=0;
            %Recomputing Topdown Dictionary
            obj.force_recompute.topdown_dictionary=0;
            %Recomputing topdown descriptors
            obj.force_recompute.topdown_descriptors=0;
            %Recomputing topdown unary
            obj.force_recompute.topdown_unary=0;
            %Recomputing optimisation
            obj.force_recompute.optimisation=0;
            %Recompute td adjacency
            obj.force_recompute.latent_adj=0;
            %--------------------------------------------------------------

            %--------------------------------------------------------------
            %Mode initialization
            %--------------------------------------------------------------
            %Use unary 1 or 0
            obj.mode=0;
            
            %--------------------------------------------------------------
            
            if nargin>0
                switch d
                    case 'Default'
                        %Default superpixels Quickshift
                        obj.makesp('Quickshift');
                        
                        
                        % -------------------------------------------------------------------------
                        % Feature option
                        % -------------------------------------------------------------------------
                        
                        % Size of the spatial bin used by vl_dsift
                        obj.unary.features.size = 12;
                        
                        % -------------------------------------------------------------------------
                        % Bottom Up Unary options
                        % -------------------------------------------------------------------------
                        %Use unary terms in energy (1 or 0)
                        obj.unary.use=1;
                        % SVM kernel (requires BLOCKS toolbox)
                        obj.unary.precomputed=0;
                        obj.unary.precomputed_path=[];
                        
                        % 1- linear; 2- intersection; 3- Chi2; 4- Chi2-RBF
                        obj.unary.svm.kernel_type   = 4;
                        obj.unary.svm.rbf = (obj.unary.svm.kernel_type == 4);
                        
                        % N value for the N-Fold crossvalidation used to
                        % determine C value
                        obj.unary.svm.cross         = 10 ;
                        
                        % gamma value for the rbf^2 kernel.
                        obj.unary.svm.gamma                        = [] ;
                        
                        % balancing strategy (0 or 1)
                        obj.unary.svm.balance                      = 0 ;
                        
                        % print debug info (0 or 1)
                        obj.unary.svm.debug                        = 1 ;
                        
                        % return probability value instead of decision
                        % value (0 or 1)
                        obj.unary.svm.probability                  = 1 ;
                        
                        % maximum number of features used for clustering
                        % (quanization)
                        obj.unary.features.max_features_for_clustering      = 2*50000;
                        
                        % number of clusters for bottom up unary
                        % quantization
                        obj.unary.num_bu_clusters                  = 400;
                        
                        % maximum number of histograms per class (used to
                        % balance the training)
                        obj.unary.max_hists_per_class_for_training = 750;
                        
                        % maximum number of histogram per image
                        obj.unary.hists_per_image                  = 5;
                        
                        % -------------------------------------------------------------------------
                        % Cutting Plane algorithm
                        % -------------------------------------------------------------------------
                        
                        % Slack variable for the Cutting Plane algorithm
                        % used for the segmentation constraints, this value
                        % will be divided by the number of training images
                        obj.optimisation.params.C1 = 1e6;
                    otherwise
                        error('Unknown constructor')
                end
            else
                
            end
            disp('Please customize parameters before training/testing');
            
            
        end
        %------------------------------------------------------------------
        %Make destination mat path
        %------------------------------------------------------------------
        %Given the parameters & the obj.dbparams.destmatpath, builds the
        %correct destmathpath inside of each sub parameter structure.
        tDir=makedestpath(obj,rootDir);
        resetPath(obj);
        %------------------------------------------------------------------
        
        %--------------------------------------------------------------------------
        %Build Database parameters
        %--------------------------------------------------------------------------
        %Given the name of the database, builds the associated parameters
        %of the training set
        %Currently available : 'Graz', 'CamVid', 'Pascal'
        
        makedb(obj,db_name);
        
        %--------------------------------------------------------------------------
        
        %--------------------------------------------------------------------------
        %Build Superpixels parameters
        %--------------------------------------------------------------------------
        %Given the name of the superpixels method builds the appropriate
        %parameters
        
        makesp(obj,sp_name,options);

        %--------------------------------------------------------------------------
        % Top down features
        %
        maketd_feats(obj,m_name);
        
        %------------------------------------------------------------------
        %Training
        %------------------------------------------------------------------
        %Method that launch training step.
        train(obj);
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %Inference
        %------------------------------------------------------------------
        %Method that launch training step.
        inference(obj,imse);
        %------------------------------------------------------------------        
        %------------------------------------------------------------------
        %Testing
        %------------------------------------------------------------------
        %Method that launch training step.
        testing(obj);
        %------------------------------------------------------------------
        %------------------------------------------------------------------
        %Force_recomputing
        %------------------------------------------------------------------
        %Toreset  : force_recomputation(obj,'reset') sinon construit.
        force_recomputation(obj,vargin)
        %------------------------------------------------------------------        
        

        
    end

end

