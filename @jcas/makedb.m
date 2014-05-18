function makedb(obj,db_name)
%Function building the parameters for the database
%Input:
%_ obj of class jcas
%_ db_name string
%_ image_names cell array of string containing the names of the image files
%within the imgpath directory.


obj.dbparams.name=db_name;

switch db_name
	case 'test_bertrand'
		obj.dbparams.image_names=arrayfun(@(x) sprintf('%d',x),1:900,'uniformoutput',false);
        obj.dbparams.num_images=900;
        obj.dbparams.ncat=4;
        obj.dbparams.training=[1 401 601 701];
        obj.dbparams.test=[2 400 600 700];
        dataset_path=get_dataset_path('graz02');
        obj.dbparams.imgpath = [fullfile(dataset_path,'img'),'/'];
        obj.dbparams.format = '.png';
        % path to the ground truth labels stored in a specific format
        obj.dbparams.segpath = strrep(fullfile(dataset_path,'seg/%s.mat'),'\','/');
        % path to the results
        obj.dbparams.destmatpath = [strrep(pwd,'\','/'),'/results/%s.mat'];
        vl_xmkdir(fileparts(obj.dbparams.destmatpath));
		
    case 'graz02'
        obj.dbparams.image_names=arrayfun(@(x) sprintf('%d',x),1:900,'uniformoutput',false);
        obj.dbparams.num_images=900;
        obj.dbparams.ncat=4;
        obj.dbparams.training=(1:2:900);
        obj.dbparams.test=(2:2:900);
        dataset_path=get_dataset_path('graz02');
        obj.dbparams.imgpath = [fullfile(dataset_path,'img'),'/'];
        obj.dbparams.format = '.png';
        % path to the ground truth labels stored in a specific format
        obj.dbparams.segpath = strrep(fullfile(dataset_path,'seg/%s.mat'),'\','/');
        % path to the results
        obj.dbparams.destmatpath = [strrep(pwd,'\','/'),'/results/%s.mat'];
        vl_xmkdir(fileparts(obj.dbparams.destmatpath));
    case 'inria-graz-old-splits'
        % image names
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
        obj.dbparams.num_images = 900;  % total number of images
        obj.dbparams.ncat = 4;    % total number of categories
        obj.dbparams.training = (1:2:900);    % image index for training set
        obj.dbparams.test = (2:2:900);    % image index for test set
        % path to the images
        dataset_path=get_dataset_path('inria-graz');
        obj.dbparams.imgpath = [fullfile(dataset_path,'img'),'/'];
        obj.dbparams.format = '.png';
        % path to the ground truth labels stored in a specific format
        obj.dbparams.segpath = strrep(fullfile(dataset_path,'seg/%s.mat'),'\','/');
        % path to the results
        obj.dbparams.destmatpath = [strrep(pwd,'\','/'),'/results/%s.mat'];
        vl_xmkdir(fileparts(obj.dbparams.destmatpath));
    case 'CamVid' % NEED TO DO
        num_images=701;
        % image names
        image_names=cellfun(@(x) num2str(x),num2cell(1:num_images),'uniformoutput',false);
        obj.dbparams.image_names=image_names;
        obj.dbparams.num_images = num_images;   % total number of images
        obj.dbparams.ncat       = 12;    % total number of categories
        obj.dbparams.training   = (2:2:701);    % image index for training set
        obj.dbparams.test       = (1:2:701);    % image index for test set
        % path to the images
        obj.dbparams.imgpath     = '/cis/home/pmcclure/jcas_complete/CamVid_Raw_Images/';
        obj.dbparams.format='.png';
        % path to segmentations
        obj.dbparams.segpath='/cis/home/pmcclure/jcas_complete/CamVid_Labels/%s.mat';
        % path to the results
        obj.dbparams.destmatpath = '/cis/home/luca/jcas_new/CamVid/results/%s.mat';
    case 'msrc' % NEED TO DO
        % relevant paths and files
        dataset_path='/cis/project/vision_sequences/msrc21_segmentation/';
        train_file=fullfile(dataset_path,'Train.txt');
        val_file=fullfile(dataset_path,'Validation.txt');
        test_file=fullfile(dataset_path,'Test.txt');
        % load the images
        train_images=read_file(train_file);
        val_images=read_file(val_file);
        test_images=read_file(test_file);
        image_names=[train_images;val_images;test_images];
        image_names=cellfun(@(x) x(1:end-4),image_names,'uniformoutput',false);
        obj.dbparams.image_names=image_names;
        obj.dbparams.num_images = length(image_names);        % total number of images
        obj.dbparams.ncat       = 9;          % total number of categories
        obj.dbparams.training   = 1:(length(train_images)+length(val_images));  % image index for training set
        obj.dbparams.test       = length(val_images)+(1:length(test_images));  % image index for test set
        % path to the images
        obj.dbparams.imgpath=fullfile(dataset_path,'Images/');
        obj.dbparams.format='.bmp';
        % path to the ground truth labels
        obj.dbparams.segpath= fullfile(dataset_path,'seg');
        % path to the results
        obj.dbparams.destmatpath = [strrep(pwd,'\','/'),'/results/%s.mat'];
        vl_xmkdir(fileparts(obj.dbparams.destmatpath));
    case {'inria-graz','voc2010','voc2011-sbd-cars','voc2011-sbd-all',...
            'voc2011-sbd-cars-subset'}
        switch db_name
            case 'inria-graz'
                % relevant paths
                dataset_path=get_dataset_path('inria-graz');
                train_file=fullfile(dataset_path,'train.txt');
                test_file=fullfile(dataset_path,'test.txt');
                % total number of categories
                obj.dbparams.ncat = 4;
                % image format
                obj.dbparams.format = '.png';
            case 'voc2010'
                % relevant paths
                dataset_path=get_dataset_path('voc2010');
                train_file=fullfile(dataset_path,'trainval.txt');
                test_file=fullfile(dataset_path,'Test.txt');
                % total number of categories
                obj.dbparams.ncat = 21;
                % image format
                obj.dbparams.format = '.jpg';
            case 'voc2011-sbd-cars'
                % relevant paths
                dataset_path=get_dataset_path('voc2011-sbd-cars');
                train_file=fullfile(dataset_path,'train.txt');
                test_file=fullfile(dataset_path,'val.txt');
                % total number of categories
                obj.dbparams.ncat = 2;
                % image format
                obj.dbparams.format = '.jpg';
            case 'voc2011-sbd-all'
                % relevant paths
                dataset_path=get_dataset_path('voc2011-sbd-all');
                train_file=fullfile(dataset_path,'train.txt');
                test_file=fullfile(dataset_path,'val.txt');
                % total number of categories
                obj.dbparams.ncat = 21;
                % image format
                obj.dbparams.format = '.jpg';
            case 'voc2011-sbd-cars-subset'
                % relevant paths
                dataset_path=get_dataset_path('voc2011-sbd-cars');
                train_file=fullfile(dataset_path,'train_subset.txt');
                test_file=fullfile(dataset_path,'test_subset.txt');
                % total number of categories
                obj.dbparams.ncat=2;
                % image format
                obj.dbparams.format='.jpg';
        end
        % read the train file for training images
        train_images = read_file(train_file);
        test_images = read_file(test_file);
        % total number of images
        obj.dbparams.num_images = length(train_images)+length(test_images);
        obj.dbparams.image_names = [train_images;test_images];
        % image index for training set
        obj.dbparams.training = 1:length(train_images);
        % image index for test set
        obj.dbparams.test = length(train_images)+(1:length(test_images));
        % path to the images
        obj.dbparams.imgpath = [fullfile(dataset_path,'img'),'/'];
        % path to the ground truth lables
        obj.dbparams.segpath = strrep(fullfile(dataset_path,'seg/%s.mat'),'\','/');
        % path to the results
        obj.dbparams.destmatpath = [strrep(pwd,'\','/'),'/results/%s.mat'];
        vl_xmkdir(fileparts(obj.dbparams.destmatpath));
    case 'wcvp-pc'
        % relevant paths
        dataset_path='F:/Datasets/WCVP/';
        train_file=fullfile(dataset_path,'train.txt');
        test_file=fullfile(dataset_path,'test.txt');
        % read the train file for training images
        train_images = read_file(train_file);
        test_images = read_file(test_file);
        % total number of images
        obj.dbparams.num_images = length(train_images)+length(test_images);
        obj.dbparams.image_names = [train_images;test_images];
        % total number of categories
        obj.dbparams.ncat = 2;
        % image index for training set
%         obj.dbparams.training = 1:length(train_images);
        obj.dbparams.training = [];
        % image index for test set
        obj.dbparams.test = 1:obj.dbparams.num_images;
        % path to the images
        obj.dbparams.imgpath = [fullfile(dataset_path,'img'),'/'];
        obj.dbparams.format = '.jpg';
        % path to the ground truth lables
        obj.dbparams.segpath = strrep(fullfile(dataset_path,'seg/%s.mat'),'\','/');
        % path to the results
        obj.dbparams.destmatpath = [strrep(pwd,'\','/'),'/results/%s.mat'];
        vl_xmkdir(fileparts(obj.dbparams.destmatpath));

    otherwise
            error('Database specified unknown');
end

end

