function dataset_path=get_dataset_path(dataset_name)
% function used to retrieve the path
switch dataset_name
    case 'inria-graz'
        if(ispc)
            dataset_path='F:/Datasets/InriaGraz/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/inria_graz/';
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
            dataset_path='F:/datasets/voc2010/TBunarylogit1/%s.unary';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2010/TBunarylogit1/%s.unary';
        end
    case 'voc2011-sbd-cars'
        if(ispc)
            dataset_path='F:/Datasets/voc2011/';
        elseif(isunix)
            dataset_path='/cis/project/vision_sequences/voc2011/';
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
end
