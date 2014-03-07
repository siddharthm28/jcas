function makedb(obj,db_name)
%Function building the parameters for the database
%Input:
%_ obj of class jcas
%_ db_name string
%_ image_names cell array of string containing the names of the image files
%within the imgpath directory.


obj.dbparams.name=db_name;

switch db_name
    case 'Graz'
        obj.dbparams.image_names=cell(1,900);
        for i=1:900
            if i<=300
                obj.dbparams.image_names{i}=sprintf('bike_%03d',i);
            elseif (300<i) && (i<=600)
                obj.dbparams.image_names{i}=sprintf('carsgraz_%03d',i-300);
            elseif (600<i)&&(i<=900)
                obj.dbparams.image_names{i}=sprintf('person_%03d',i-600);
            end
        end
        % total number of images
        obj.dbparams.num_images = 900;
        
        % total number of categories
        obj.dbparams.ncat       = 4;
        
            % image index for training set
            %obj.dbparams.training   = (1:2:900);
            obj.dbparams.training   = (2:2:900);
            % image index for test set
            %obj.dbparams.test       = (2:2:900);
            obj.dbparams.test   = (1:2:900);
            % path to the images
                obj.dbparams.imgpath=['/cis/home/brondep1/DB/GrazImages/'];
                obj.dbparams.format='.image.png';
%             obj.dbparams.imgpath     = ['/cis/home/pmcclure/jcas_complete/',...
%                 db_name,'_Raw_Images/%s',obj.dbparams.format];
            
            % % path to the ground truth lables??
            obj.dbparams.segpath     = ['/cis/home/brondep1/DB/GrazOldGT/%s.mat'];
            %obj.dbparams.segpath='/Users/Bertrand/Documents/X/Stage3A/DB/GrazCis/Graz_Labels/%s.mat';
            % path to the results
            obj.dbparams.destmatpath = ['/cis/home/luca/jcas_new/GrazOld/results/%s.mat'];
            
             case 'Graz1807'
        obj.dbparams.image_names=cell(1,900);
        for i=1:900
            if i<=300
                obj.dbparams.image_names{i}=sprintf('bike_%03d',i);
            elseif (300<i) && (i<=600)
                obj.dbparams.image_names{i}=sprintf('carsgraz_%03d',i-300);
            elseif (600<i)&&(i<=900)
                obj.dbparams.image_names{i}=sprintf('person_%03d',i-600);
            end
        end
        % total number of images
        obj.dbparams.num_images = 900;
        
        % total number of categories
        obj.dbparams.ncat       = 4;
        
            % image index for training set
            obj.dbparams.training   = (1:2:900);
            
            % image index for test set
            obj.dbparams.test       = (2:2:900);
            
            % path to the images
                obj.dbparams.imgpath=['/cis/home/brondep1/DB/GrazImages/'];
                obj.dbparams.format='.image.png';
%             obj.dbparams.imgpath     = ['/cis/home/pmcclure/jcas_complete/',...
%                 db_name,'_Raw_Images/%s',obj.dbparams.format];
            
            % % path to the ground truth lables??
            obj.dbparams.segpath     = ['/cis/home/brondep1/DB/GrazOldGT/%s.mat'];
            %obj.dbparams.segpath='/Users/Bertrand/Documents/X/Stage3A/DB/GrazCis/Graz_Labels/%s.mat';
            % path to the results
            obj.dbparams.destmatpath = ['/cis/home/luca/jcas_new/GrazOld/results1807/%s.mat'];
            
    case 'GrazInria_900'
        obj.dbparams.image_names=cell(1,900);
        for i=1:900
            if i<=300
                obj.dbparams.image_names{i}=sprintf('bike_%03d',i);
            elseif (300<i) && (i<=600)
                obj.dbparams.image_names{i}=sprintf('carsgraz_%03d',i-300);
            elseif (600<i)&&(i<=900)
                obj.dbparams.image_names{i}=sprintf('person_%03d',i-600);
            end
        end
        % total number of images
        obj.dbparams.num_images = 900;
        
        % total number of categories
        obj.dbparams.ncat       = 4;
        
            % image index for training set
            obj.dbparams.training   = (2:2:900);
            
            % image index for test set
            obj.dbparams.test       = (1:2:900);
            
            % path to the images
                obj.dbparams.imgpath=['/cis/home/brondep1/DB/GrazImages/'];
                obj.dbparams.format='.image.png';
%    
%                 db_name,'_Raw_Images/%s',obj.dbparams.format];
            
            % % path to the ground truth lables??
            obj.dbparams.segpath     = ['/cis/home/brondep1/DB/GrazNewGT/%s.mat'];
            %obj.dbparams.segpath='/Users/Bertrand/Documents/X/Stage3A/DB/GrazCis/Graz_Labels/%s.mat';
            % path to the results
            obj.dbparams.destmatpath = ['/cis/home/luca/jcas_new/Graz/results/%s.mat'];
                        
            
        case 'CamVid'
            
            obj.dbparams.image_names=cell(1,701);
            for i=1:701
                obj.dbparams.image_names{i}=num2str(i);
            end
            % total number of images
            obj.dbparams.num_images = 701;
            
            % total number of categories
            obj.dbparams.ncat       = 12;
            
            % image index for training set
            obj.dbparams.training   = (2:2:701);
            
            % image index for test set
            obj.dbparams.test       = (1:2:701);
            
            % path to the images
            obj.dbparams.imgpath     = ['/cis/home/pmcclure/jcas_complete/','CamVid','_Raw_Images/'];
            obj.dbparams.format='.png';
            
            obj.dbparams.segpath=['/cis/home/pmcclure/jcas_complete/CamVid_Labels/%s.mat'];
            
            % path to the results
            obj.dbparams.destmatpath = ['/cis/home/luca/jcas_new/CamVid/results/%s.mat'];
            
        case 'Pascal'
            % total number of images
            obj.dbparams.num_images = 2913;
            
            % total number of categories
            obj.dbparams.ncat       = 21;
            
            % image index for training set
            obj.dbparams.training   = (1:1464);
            
            % image index for test set
            obj.dbparams.test       = (1465:2913);
            
    case 'MSRCV1'
        obj.dbparams.image_names=cell(1,240);
        count=1;
        for i=1:8
            for j=1:30
                obj.dbparams.image_names{count}=sprintf('%d_%d_s',i);
                count=count+1;
            end
        end
        % total number of images
        obj.dbparams.num_images = 240;
        
        % total number of categories
        obj.dbparams.ncat       = 9;
        
        % image index for training set
        obj.dbparams.training   = (1:2:240);
        
        % image index for test set
        obj.dbparams.test       = (2:2:240);
        
        % path to the images
        obj.dbparams.imgpath=['/cis/home/brondep1/DB/MSRCV1/'];
        obj.dbparams.format='.bmp';
        %             obj.dbparams.imgpath     = ['/cis/home/pmcclure/jcas_complete/',...
        %                 db_name,'_Raw_Images/%s',obj.dbparams.format];
        
        % % path to the ground truth lables??
        obj.dbparams.segpath     = ['/cis/home/brondep1/DB/MSRCV1GT/%s.mat'];
        %obj.dbparams.segpath='/Users/Bertrand/Documents/X/Stage3A/DB/GrazCis/Graz_Labels/%s.mat';
        % path to the results
        obj.dbparams.destmatpath = ['/cis/home/luca/jcas_new/MSRCV1/results/%s.mat'];

            
        otherwise
            error('Database specified unknown');
    end
    


end

