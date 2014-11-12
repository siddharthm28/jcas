function dataset_path=get_dataset_path(dataset_name)
% function used to retrieve the path
switch dataset_name
    case 'graz02'
        if(ispc)
            dataset_path='F:/Datasets/Graz_Object_Rec_Database/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/Graz_Object_Rec_Database/';
        end
    case 'inria-graz'
        if(ispc)
            dataset_path='F:/Datasets/InriaGraz/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/inria_graz/';
        end
	case 'inria-graz-texton'
		if(ispc)
			dataset_path='F:/Datasets/InriaGraz/TBunary_matfiles/';
		elseif(isunix)
			dataset_path='/cis/project/vision_sequences/inria_graz/TBunary_matfiles/';
		end
    case 'voc2010'
        if(ispc)
            dataset_path='F:/datasets/voc2010/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2010/';
        end
    case 'voc2010-orig'
        if(ispc)
            dataset_path='G:/datasets/VOC2010/VOCdevkit/VOC2010/';
        end
    case 'voc2010-texton'
        if(ispc)
            dataset_path='F:/datasets/voc2010/unary/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2010/TBunarylogit1_matfiles/';
        end
    case 'voc2011-sbd-cars'
        if(ispc)
            dataset_path='F:/Datasets/voc2011/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2011/';
        end
    case {'voc2011-sbd-cars-texton','voc2011-sbd-cars-subset-texton'}
        if(ispc)
            dataset_path='F:/Datasets/voc2011/TBunary_matfiles';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2011/TBunary_matfiles';
        end
    case 'voc2011-sbd-all'
        if(ispc)
            dataset_path='F:/Datasets/voc2011-all/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2011-all/';
        end
    case 'voc2011-sbd-orig'
        if(ispc)
            dataset_path='G:/datasets/SCB/benchmark_RELEASE/dataset/';
        end
    case 'voc2012-ucm'
        if(ispc)
            dataset_path='F:/Datasets/ucm2_voc2012/VOC2012/ucm2_uint8/';
        else
            dataset_path='/cis/project/vision_sequences/ucm2_voc2012/VOC2012/ucm2_uint8/';
        end
    case 'msrc'
        if(ispc)
            dataset_path='F:/Datasets/msrc21_segmentation/';
        else
            dataset_path='/cis/project/vision_sequences/msrc21_segmentation/';
        end
    case 'msrc-texton'
        if(ispc)
            dataset_path='F:/Datasets/msrc21_segmentation/unary/';
        else
            dataset_path='/cis/project/vision_sequences/msrc21_segmentation/TBunary_matfiles/';
        end
end
