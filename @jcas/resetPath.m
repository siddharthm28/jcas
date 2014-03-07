function resetPath(obj)
%This function resets the destmatpath 
            obj.superpixels.destmatpath='';
            obj.unary.destmatpath='';
            obj.unary.features.destmatpath='';
            obj.unary.dictionary.destmatpath='';
            obj.topdown_latent.destmatpath='';
            obj.pairwise.destmatpath='';
            obj.topdown.features.destmatpath='';
            obj.topdown.dictionary.destmatpath='';
            obj.topdown.unary.destmatpath='';
            obj.optimisation.destmatpath='';
            obj.test.destmatpath='';
            obj.unary.svm.destmatpath='';
            obj.unary.svm.trainingset.destmathpath='';
end

